import { supabase } from '@/lib/supabase';

/**
 * Data access for the Company Manager Dashboard. Everything goes through the
 * signed-in user's anon-key client, so RLS decides what comes back:
 *  - roster: get_company_members_details (SECURITY DEFINER, checks is_company_admin)
 *  - progress / quiz attempts / certificates: direct selects, limited by the
 *    is_company_manager_of() policies from migration 20261008150000
 *  - add / remove: manager_add_company_member / manager_remove_company_member
 *    from migration 20261014120000 (degrades if not applied yet)
 *  - assignments / invites: course_assignments + company_invites tables and the
 *    manager_assign_course / manager_create_invite / manager_revoke_invite RPCs
 *    from migration 20261014180000 (features hide themselves until applied)
 */

export interface RosterMember {
  user_id: string;
  role: 'owner' | 'admin' | 'member';
  email: string | null;
  full_name: string | null;
  created_at: string | null;
}

export interface CourseRollup {
  user_id: string;
  course_id: string;
  lessons_started: number;
  lessons_completed: number;
  avg_quiz_score: number | null;
  enrolled_at: string | null;
  last_activity: string | null;
}

export interface QuizRow { user_id: string; lesson_id: string; course_id: string; score: number; passed: boolean; created_at: string }
export interface CertRow { user_id: string; course_id: string; certificate_number: string; issued_at: string }
export interface LessonRow { user_id: string; lesson_id: string; course_id: string; completed: boolean; quiz_score: number | null; completed_at: string | null; created_at: string | null }

export interface TeamSnapshot {
  members: RosterMember[];
  rollups: CourseRollup[];
  quizzes: QuizRow[];
  certs: CertRow[];
  lessons: LessonRow[];
  courseTitles: Record<string, string>;
  lessonTitles: Record<string, string>;
  lessonTotals: Record<string, number>;
}

export interface AssignmentRow { id: string; company_id: string; user_id: string; course_id: string; due_date: string | null; created_at: string }
export interface InviteRow { id: string; email: string; token: string; status: 'pending' | 'accepted' | 'revoked'; created_at: string; expires_at: string; accepted_at: string | null }
export interface CreatedInvite { id: string; token: string; expires_at: string }
export type InviteEmailResult = { sent: true } | { sent: false; reason: string };

export type MutationResult = { ok: true } | { ok: false; error: string; unavailable?: boolean };

export interface ManagerDataSource {
  loadTeam(companyId: string): Promise<TeamSnapshot>;
  /** Fresh seat_limit; undefined if the column does not exist yet. */
  loadSeatLimit(companyId: string): Promise<number | null | undefined>;
  addMember(companyId: string, email: string): Promise<MutationResult>;
  removeMember(companyId: string, userId: string): Promise<MutationResult>;
  /** undefined = feature not available yet (migration not applied). */
  loadAssignments(companyId: string): Promise<AssignmentRow[] | undefined>;
  /** userId null = every current member of the company. */
  assignCourse(companyId: string, courseId: string, userId: string | null, dueDate: string | null): Promise<MutationResult>;
  removeAssignment(assignmentId: string): Promise<MutationResult>;
  /** undefined = feature not available yet (migration not applied). */
  loadInvites(companyId: string): Promise<InviteRow[] | undefined>;
  createInvite(companyId: string, email: string): Promise<({ ok: true } & CreatedInvite) | { ok: false; error: string; unavailable?: boolean }>;
  revokeInvite(inviteId: string): Promise<MutationResult>;
  /** Ask the (optional) send-company-invite edge function to email the link. Never throws. */
  sendInviteEmail(inviteId: string): Promise<InviteEmailResult>;
}

/** Link the manager can copy and send. Joining is matched on the invitee's verified email. */
export function inviteUrl(token: string, origin = typeof window !== 'undefined' ? window.location.origin : ''): string {
  return `${origin}/auth?invite=${encodeURIComponent(token)}`;
}

function isMissingTable(err: { code?: string; message?: string } | null): boolean {
  if (!err) return false;
  return err.code === '42P01' || err.code === 'PGRST205' || /could not find the table|does not exist/i.test(err.message ?? '');
}

/** PostgREST "function not found" / Postgres undefined_function. */
function isMissingRpc(err: { code?: string; message?: string } | null): boolean {
  if (!err) return false;
  return err.code === 'PGRST202' || err.code === '42883' || /could not find the function/i.test(err.message ?? '');
}

const UNAVAILABLE = 'Adding and removing employees from this dashboard is not switched on yet. Contact ForgeLine and we will update your team.';

export const supabaseManagerData: ManagerDataSource = {
  async loadTeam(companyId) {
    const { data: memberData, error: mErr } = await supabase.rpc('get_company_members_details', { target_company_id: companyId });
    if (mErr) throw mErr;
    const members = ((memberData as RosterMember[]) ?? []).map((m) => ({
      user_id: m.user_id, role: m.role, email: m.email, full_name: m.full_name, created_at: m.created_at ?? null,
    }));
    const ids = members.map((m) => m.user_id);
    const empty: TeamSnapshot = { members, rollups: [], quizzes: [], certs: [], lessons: [], courseTitles: {}, lessonTitles: {}, lessonTotals: {} };
    if (ids.length === 0) return empty;

    const [roll, quiz, cert, prog, courseRes, lessonRes] = await Promise.all([
      supabase.from('company_member_course_progress').select('*').in('user_id', ids),
      supabase.from('quiz_attempts').select('user_id, lesson_id, course_id, score, passed, created_at').in('user_id', ids).order('created_at', { ascending: false }).limit(1000),
      supabase.from('certificates').select('user_id, course_id, certificate_number, issued_at').in('user_id', ids),
      supabase.from('user_progress').select('user_id, lesson_id, course_id, completed, quiz_score, completed_at, created_at').in('user_id', ids).limit(5000),
      supabase.from('courses').select('id, title'),
      supabase.from('lessons').select('id, title, modules!inner(course_id)'),
    ]);
    for (const r of [roll, quiz, cert, prog]) if (r.error) throw r.error;

    const courseTitles: Record<string, string> = {};
    for (const c of (courseRes.data ?? []) as { id: string; title: string }[]) courseTitles[c.id] = c.title;
    const lessonTitles: Record<string, string> = {};
    const lessonTotals: Record<string, number> = {};
    for (const l of (lessonRes.data ?? []) as unknown as { id: string; title: string; modules: { course_id: string } }[]) {
      lessonTitles[l.id] = l.title;
      lessonTotals[l.modules.course_id] = (lessonTotals[l.modules.course_id] ?? 0) + 1;
    }
    return {
      members,
      rollups: (roll.data as CourseRollup[]) ?? [],
      quizzes: (quiz.data as QuizRow[]) ?? [],
      certs: (cert.data as CertRow[]) ?? [],
      lessons: (prog.data as LessonRow[]) ?? [],
      courseTitles, lessonTitles, lessonTotals,
    };
  },

  async loadSeatLimit(companyId) {
    const { data, error } = await supabase.from('companies').select('seat_limit').eq('id', companyId).maybeSingle();
    if (error) return undefined;
    return (data as { seat_limit: number | null } | null)?.seat_limit ?? null;
  },

  async addMember(companyId, email) {
    const { data, error } = await supabase.rpc('manager_add_company_member', { p_company_id: companyId, p_email: email });
    if (isMissingRpc(error)) return { ok: false, error: UNAVAILABLE, unavailable: true };
    if (error) return { ok: false, error: error.message };
    const r = data as { success?: boolean; error?: string } | null;
    return r?.success ? { ok: true } : { ok: false, error: r?.error ?? 'Could not add that employee.' };
  },

  async removeMember(companyId, userId) {
    const { error } = await supabase.rpc('manager_remove_company_member', { p_company_id: companyId, p_user_id: userId });
    if (isMissingRpc(error)) return { ok: false, error: UNAVAILABLE, unavailable: true };
    if (error) return { ok: false, error: error.message };
    return { ok: true };
  },

  async loadAssignments(companyId) {
    const { data, error } = await supabase.from('course_assignments')
      .select('id, company_id, user_id, course_id, due_date, created_at').eq('company_id', companyId);
    if (error) { if (isMissingTable(error)) return undefined; throw error; }
    return (data as AssignmentRow[]) ?? [];
  },

  async assignCourse(companyId, courseId, userId, dueDate) {
    const { data, error } = await supabase.rpc('manager_assign_course', {
      p_company_id: companyId, p_course_id: courseId, p_user_id: userId, p_due_date: dueDate,
    });
    if (isMissingRpc(error)) return { ok: false, error: 'Assigning courses is not switched on yet.', unavailable: true };
    if (error) return { ok: false, error: error.message };
    const r = data as { success?: boolean; error?: string } | null;
    return r?.success ? { ok: true } : { ok: false, error: r?.error ?? 'Could not assign that course.' };
  },

  async removeAssignment(assignmentId) {
    const { error } = await supabase.from('course_assignments').delete().eq('id', assignmentId);
    return error ? { ok: false, error: error.message } : { ok: true };
  },

  async loadInvites(companyId) {
    const { data, error } = await supabase.from('company_invites')
      .select('id, email, token, status, created_at, expires_at, accepted_at')
      .eq('company_id', companyId).order('created_at', { ascending: false });
    if (error) { if (isMissingTable(error)) return undefined; throw error; }
    return (data as InviteRow[]) ?? [];
  },

  async createInvite(companyId, email) {
    const { data, error } = await supabase.rpc('manager_create_invite', { p_company_id: companyId, p_email: email });
    if (isMissingRpc(error)) return { ok: false, error: 'Email invites are not switched on yet.', unavailable: true };
    if (error) return { ok: false, error: error.message };
    const r = data as { success?: boolean; error?: string; invite_id?: string; token?: string; expires_at?: string } | null;
    if (!r?.success || !r.invite_id || !r.token) return { ok: false, error: r?.error ?? 'Could not create the invite.' };
    return { ok: true, id: r.invite_id, token: r.token, expires_at: r.expires_at ?? '' };
  },

  async revokeInvite(inviteId) {
    const { data, error } = await supabase.rpc('manager_revoke_invite', { p_invite_id: inviteId });
    if (error) return { ok: false, error: error.message };
    return (data as { success?: boolean } | null)?.success ? { ok: true } : { ok: false, error: 'That invite is no longer pending.' };
  },

  async sendInviteEmail(inviteId) {
    try {
      const { data, error } = await supabase.functions.invoke('send-company-invite', { body: { invite_id: inviteId } });
      if (error) return { sent: false, reason: 'Automatic email is not available.' };
      const r = data as { email_sent?: boolean; reason?: string } | null;
      return r?.email_sent ? { sent: true } : { sent: false, reason: r?.reason ?? 'Automatic email is not configured.' };
    } catch {
      return { sent: false, reason: 'Automatic email is not available.' };
    }
  },
};
