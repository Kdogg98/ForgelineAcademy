import { supabase } from '@/lib/supabase';

/**
 * Company accounts v3 data access (migration 20261015120000). Everything goes
 * through the signed-in user's client, so RLS / SECURITY DEFINER RPC checks
 * decide what comes back. Each loader returns `undefined` when the migration is
 * not applied yet so the UI can hide the feature instead of erroring.
 */

export type BaseRole = 'owner' | 'admin' | 'supervisor' | 'employee';
export type StoredRole = BaseRole | 'member';
export const ROLE_LABEL: Record<StoredRole, string> = { owner: 'Owner', admin: 'Admin', supervisor: 'Supervisor', employee: 'Employee', member: 'Employee' };
export const normRole = (r: string | null | undefined): BaseRole => (r === 'owner' || r === 'admin' || r === 'supervisor' ? r : 'employee');
export const ROLE_RANK: Record<BaseRole, number> = { owner: 4, admin: 3, supervisor: 2, employee: 1 };

export const TRADE_PRESETS = ['Electrician', 'Millwright', 'I&E Tech', 'Mechanic', 'Welder', 'CNC Machinist'];
export const INDUSTRIES = ['Manufacturing', 'Aerospace', 'Automotive', 'Oil & Gas', 'Chemical', 'Food & Beverage', 'Medical/Healthcare', 'Power/Utilities', 'Pulp & Paper', 'Mining', 'Water/Wastewater', 'Pharma', 'Other'];
export const EQUIPMENT = ['Allen-Bradley PLCs', 'Siemens PLCs', 'VFDs', 'Hydraulics', 'Pneumatics', 'Conveyors', 'Boilers', 'Compressors', 'CNC', 'Robots', 'Pumps', 'Chillers / HVAC', 'Packaging lines', 'Cranes / hoists'];
export const TRAINING_TOPICS = ['Welding', 'CNC', 'PLC/Allen-Bradley', 'VFDs', 'Hydraulics', 'Pneumatics', 'Lockout/Tagout', 'Rigging', 'Plant-specific equipment'];
export const REQUEST_STATUSES = ['new', 'quoted', 'in_progress', 'delivered', 'declined'] as const;
export type RequestStatus = typeof REQUEST_STATUSES[number];
export const STATUS_TEXT: Record<RequestStatus, string> = { new: 'New', quoted: 'Quoted', in_progress: 'In progress', delivered: 'Delivered', declined: 'Declined' };
export const KRIS_MAILTO = 'mailto:kris@forgelineacademy.com?subject=Custom%20training%20request';

export interface MemberDetails {
  trade: string | null; placement_id: string | null; site_location: string | null;
  contract_name: string | null; contract_number: string | null; contract_start: string | null; contract_end: string | null;
  shift: string | null; supervisor_name: string | null; notes: string | null;
}
export const EMPTY_DETAILS: MemberDetails = { trade: null, placement_id: null, site_location: null, contract_name: null, contract_number: null, contract_start: null, contract_end: null, shift: null, supervisor_name: null, notes: null };

export interface TeamMember {
  user_id: string; role: StoredRole; custom_role_id: string | null; custom_role: string | null;
  email: string | null; full_name: string | null; created_at: string | null; details: MemberDetails | null;
}
export interface CompanyRole { id: string; company_id: string; name: string; base_role: 'admin' | 'supervisor' | 'employee' }
export interface CompanyTrade { id: string; company_id: string; name: string }
export interface Placement {
  id: string; company_id: string; client_name: string; industry: string[]; location: string | null;
  equipment: string[]; equipment_notes: string | null; research_ok: boolean; notes: string | null;
}
export interface TrainingProfile { company_id: string; industries: string[]; plant_details: string | null; equipment: string[]; equipment_notes: string | null; research_ok: boolean }
export interface TrainingRequest {
  id: string; company_id: string; placement_id: string | null; topic: string; topics: string[]; details: string | null;
  worker_count: number | null; trades: string | null; urgency: 'flexible' | 'normal' | 'soon' | 'urgent';
  preferred_format: 'online' | 'on_site' | 'blend'; industries: string[]; equipment: string[]; research_ok: boolean;
  attachments: string[]; source: 'form' | 'assistant'; status: RequestStatus; admin_notes: string | null; created_at: string;
  companies?: { name: string } | null;
}
export type NewTrainingRequest = Omit<TrainingRequest, 'id' | 'status' | 'admin_notes' | 'created_at' | 'companies' | 'attachments'>;
export interface AssignmentProposal { user_id: string | null; course_id: string; due_date: string | null; reason: string }
export interface AssistantReply { reply: string; proposals: AssignmentProposal[]; draft: Partial<NewTrainingRequest> | null }

export type Result<T = object> = ({ ok: true } & T) | { ok: false; error: string };

type PgErr = { code?: string; message?: string } | null;
const missing = (e: PgErr) => !!e && (['42P01', 'PGRST205', 'PGRST202', '42883', '42703'].includes(e.code ?? '') || /could not find|does not exist/i.test(e.message ?? ''));
const fail = (e: PgErr | unknown, fallback: string): { ok: false; error: string } =>
  ({ ok: false, error: (e as PgErr)?.message || fallback });

export interface AccountsDataSource {
  loadTeam(companyId: string): Promise<TeamMember[] | undefined>;
  loadRoles(companyId: string): Promise<CompanyRole[] | undefined>;
  loadTrades(companyId: string): Promise<CompanyTrade[] | undefined>;
  loadPlacements(companyId: string): Promise<Placement[] | undefined>;
  loadProfile(companyId: string): Promise<TrainingProfile | null | undefined>;
  loadRequests(companyId: string | null): Promise<TrainingRequest[] | undefined>;
  loadSettings(companyId: string): Promise<{ allow_employee_self_trade: boolean } | undefined>;
  setRole(companyId: string, userId: string, role: BaseRole | null, customRoleId: string | null): Promise<Result>;
  saveDetails(companyId: string, userId: string, d: MemberDetails): Promise<Result>;
  addRole(companyId: string, name: string, base: CompanyRole['base_role']): Promise<Result>;
  deleteRole(id: string): Promise<Result>;
  addTrade(companyId: string, name: string): Promise<Result>;
  deleteTrade(id: string): Promise<Result>;
  savePlacement(p: Partial<Placement> & { company_id: string; client_name: string }): Promise<Result<{ id: string }>>;
  deletePlacement(id: string): Promise<Result>;
  saveProfile(p: TrainingProfile): Promise<Result>;
  setSelfTrade(companyId: string, allow: boolean): Promise<Result>;
  submitRequest(r: NewTrainingRequest, files: File[]): Promise<Result<{ id: string; emailed: boolean; uploadErrors: number }>>;
  updateRequestStatus(id: string, status: RequestStatus, notes: string | null): Promise<Result>;
  assignToGroup(companyId: string, courseId: string, trade: string | null, role: string | null, due: string | null): Promise<Result<{ assigned: number }>>;
  setInviteExtras(inviteId: string, trade: string | null, role: 'supervisor' | 'employee' | null): Promise<Result>;
  askAssistant(companyId: string, mode: 'chat' | 'daily_summary', messages: { role: 'user' | 'assistant'; content: string }[]): Promise<Result<AssistantReply>>;
  fileUrl(path: string): Promise<string | null>;
}

const clean = (s: string | null | undefined) => { const t = (s ?? '').trim(); return t ? t : null; };

export const supabaseAccountsData: AccountsDataSource = {
  async loadTeam(companyId) {
    const { data, error } = await supabase.rpc('get_company_team', { p_company_id: companyId });
    if (error) { if (missing(error)) return undefined; throw error; }
    return (data as TeamMember[]) ?? [];
  },
  async loadRoles(companyId) {
    const { data, error } = await supabase.from('company_roles').select('id, company_id, name, base_role').eq('company_id', companyId).order('name');
    if (error) return missing(error) ? undefined : [];
    return (data as CompanyRole[]) ?? [];
  },
  async loadTrades(companyId) {
    const { data, error } = await supabase.from('company_trades').select('id, company_id, name').eq('company_id', companyId).order('name');
    if (error) return missing(error) ? undefined : [];
    return (data as CompanyTrade[]) ?? [];
  },
  async loadPlacements(companyId) {
    const { data, error } = await supabase.from('company_placements').select('*').eq('company_id', companyId).order('client_name');
    if (error) return missing(error) ? undefined : [];
    return (data as Placement[]) ?? [];
  },
  async loadProfile(companyId) {
    const { data, error } = await supabase.from('company_training_profile').select('*').eq('company_id', companyId).maybeSingle();
    if (error) return missing(error) ? undefined : null;
    return (data as TrainingProfile | null) ?? null;
  },
  async loadRequests(companyId) {
    let q = supabase.from('training_requests').select('*, companies(name)').order('created_at', { ascending: false });
    if (companyId) q = q.eq('company_id', companyId);
    const { data, error } = await q;
    if (error) return missing(error) ? undefined : [];
    return (data as TrainingRequest[]) ?? [];
  },
  async loadSettings(companyId) {
    const { data, error } = await supabase.from('companies').select('allow_employee_self_trade').eq('id', companyId).maybeSingle();
    if (error || !data) return undefined;
    return { allow_employee_self_trade: !!(data as { allow_employee_self_trade?: boolean }).allow_employee_self_trade };
  },
  async setRole(companyId, userId, role, customRoleId) {
    const { error } = await supabase.rpc('set_company_member_role', { p_company_id: companyId, p_user_id: userId, p_role: role, p_custom_role_id: customRoleId });
    return error ? fail(error, 'Could not change the role.') : { ok: true };
  },
  async saveDetails(companyId, userId, d) {
    const row = { company_id: companyId, user_id: userId, ...Object.fromEntries(Object.entries(d).map(([k, v]) => [k, typeof v === 'string' ? clean(v) : v])) };
    const { error } = await supabase.from('company_member_details').upsert(row, { onConflict: 'company_id,user_id' });
    return error ? fail(error, 'Could not save.') : { ok: true };
  },
  async addRole(companyId, name, base) {
    const { error } = await supabase.from('company_roles').insert({ company_id: companyId, name: name.trim(), base_role: base });
    return error ? fail(error, 'Could not add the role.') : { ok: true };
  },
  async deleteRole(id) { const { error } = await supabase.from('company_roles').delete().eq('id', id); return error ? fail(error, 'Could not delete.') : { ok: true }; },
  async addTrade(companyId, name) {
    const { error } = await supabase.from('company_trades').insert({ company_id: companyId, name: name.trim() });
    return error ? fail(error, 'Could not add the trade.') : { ok: true };
  },
  async deleteTrade(id) { const { error } = await supabase.from('company_trades').delete().eq('id', id); return error ? fail(error, 'Could not delete.') : { ok: true }; },
  async savePlacement(p) {
    const { data, error } = await supabase.from('company_placements').upsert(p).select('id').maybeSingle();
    return error ? fail(error, 'Could not save the client site.') : { ok: true, id: (data as { id: string } | null)?.id ?? p.id ?? '' };
  },
  async deletePlacement(id) { const { error } = await supabase.from('company_placements').delete().eq('id', id); return error ? fail(error, 'Could not delete.') : { ok: true }; },
  async saveProfile(p) {
    const { error } = await supabase.from('company_training_profile').upsert(p, { onConflict: 'company_id' });
    return error ? fail(error, 'Could not save the training profile.') : { ok: true };
  },
  async setSelfTrade(companyId, allow) {
    const { error } = await supabase.rpc('manager_set_company_settings', { p_company_id: companyId, p_allow_employee_self_trade: allow });
    return error ? fail(error, 'Could not save the setting.') : { ok: true };
  },
  async submitRequest(r, files) {
    // upload first into "<company>/<upload-id>/<name>"; a failed upload never blocks the request
    const folder = `${r.company_id}/${crypto.randomUUID()}`;
    const paths: string[] = [];
    let uploadErrors = 0;
    for (const f of files) {
      const path = `${folder}/${f.name.replace(/[^\w.\- ]+/g, '_').slice(0, 120)}`;
      const { error } = await supabase.storage.from('training-request-files').upload(path, f, { upsert: false });
      if (error) uploadErrors++; else paths.push(path);
    }
    const { data, error } = await supabase.from('training_requests').insert({ ...r, attachments: paths }).select('id').maybeSingle();
    if (error || !data) return fail(error, 'Could not send the request.');
    const id = (data as { id: string }).id;
    let emailed = false;
    try {
      const res = await supabase.functions.invoke('notify-training-request', { body: { request_id: id } });
      emailed = !res.error && !!(res.data as { email_sent?: boolean } | null)?.email_sent;
    } catch { /* email is best effort */ }
    return { ok: true, id, emailed, uploadErrors };
  },
  async updateRequestStatus(id, status, notes) {
    const { error } = await supabase.from('training_requests').update({ status, admin_notes: clean(notes) }).eq('id', id);
    return error ? fail(error, 'Could not update.') : { ok: true };
  },
  async assignToGroup(companyId, courseId, trade, role, due) {
    const { data, error } = await supabase.rpc('manager_assign_course_to_group', { p_company_id: companyId, p_course_id: courseId, p_trade: trade, p_role: role, p_due_date: due });
    if (error) return fail(error, 'Could not assign.');
    const r = data as { success?: boolean; error?: string; assigned?: number } | null;
    return r?.success ? { ok: true, assigned: r.assigned ?? 0 } : { ok: false, error: r?.error ?? 'Could not assign.' };
  },
  async setInviteExtras(inviteId, trade, role) {
    const { error } = await supabase.rpc('manager_set_invite_extras', { p_invite_id: inviteId, p_trade: trade, p_role: role });
    return error ? fail(error, 'Could not save trade/role on the invite.') : { ok: true };
  },
  async askAssistant(companyId, mode, messages) {
    try {
      const { data, error } = await supabase.functions.invoke('manager-assistant', { body: { company_id: companyId, mode, messages } });
      if (error) return { ok: false, error: 'The Manager Assistant is not available yet.' };
      const r = data as Partial<AssistantReply> & { error?: string };
      if (r?.error) return { ok: false, error: r.error };
      return { ok: true, reply: r.reply ?? '', proposals: r.proposals ?? [], draft: r.draft ?? null };
    } catch { return { ok: false, error: 'The Manager Assistant is not available yet.' }; }
  },
  async fileUrl(path) {
    const { data } = await supabase.storage.from('training-request-files').createSignedUrl(path, 600);
    return (data as { signedUrl?: string } | null)?.signedUrl ?? null;
  },
};

/* ---------------- helpers shared by UI ---------------- */
export function daysUntil(date: string | null, now = new Date()): number | null {
  if (!date) return null;
  const [y, m, d] = date.split('-').map(Number);
  const t = Date.UTC(y, m - 1, d);
  const n = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate());
  return Math.round((t - n) / 864e5);
}
export const endingSoon = (d: MemberDetails | null, within = 30) => { const n = daysUntil(d?.contract_end ?? null); return n != null && n >= 0 && n <= within; };

/** Parse pasted text or CSV: "email, trade, role" per line (header optional). */
export function parseBulkInvites(text: string): { email: string; trade: string | null; role: 'supervisor' | 'employee' | null; error?: string }[] {
  const out: { email: string; trade: string | null; role: 'supervisor' | 'employee' | null; error?: string }[] = [];
  for (const raw of text.split(/\r?\n/)) {
    const line = raw.trim();
    if (!line) continue;
    const cols = line.split(/[,\t;]/).map((c) => c.trim().replace(/^"|"$/g, ''));
    if (/^e-?mail$/i.test(cols[0])) continue;
    const email = cols[0].toLowerCase();
    const r = (cols[2] ?? '').toLowerCase();
    const role = r === 'supervisor' ? 'supervisor' : r === '' || r === 'employee' || r === 'member' ? (r ? 'employee' : null) : null;
    const err = !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email) ? 'Invalid email' : r && !role ? 'Role must be employee or supervisor' : undefined;
    out.push({ email, trade: clean(cols[1]), role, error: err });
  }
  return out;
}
