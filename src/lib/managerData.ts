import { supabase } from '@/lib/supabase';

/**
 * Data access for the Company Manager Dashboard. Everything goes through the
 * signed-in user's anon-key client, so RLS decides what comes back:
 *  - roster: get_company_members_details (SECURITY DEFINER, checks is_company_admin)
 *  - progress / quiz attempts / certificates: direct selects, limited by the
 *    is_company_manager_of() policies from migration 20261008150000
 *  - add / remove: manager_add_company_member / manager_remove_company_member
 *    from migration 20261014120000 (degrades if not applied yet)
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

export type MutationResult = { ok: true } | { ok: false; error: string; unavailable?: boolean };

export interface ManagerDataSource {
  loadTeam(companyId: string): Promise<TeamSnapshot>;
  /** Fresh seat_limit; undefined if the column does not exist yet. */
  loadSeatLimit(companyId: string): Promise<number | null | undefined>;
  addMember(companyId: string, email: string): Promise<MutationResult>;
  removeMember(companyId: string, userId: string): Promise<MutationResult>;
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
};
