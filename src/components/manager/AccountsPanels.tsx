import { cloneElement, isValidElement, useEffect, useMemo, useRef, useState } from 'react';
import {
  Bot, Briefcase, Building2, CalendarClock, Check, ClipboardPaste, Factory, FileUp, Filter, Loader2, Mail, MapPin, Plus,
  Send, Sparkles, Trash2, UserCog, Users, Wrench, X,
} from 'lucide-react';
import {
  EQUIPMENT, INDUSTRIES, KRIS_MAILTO, ROLE_LABEL, ROLE_RANK, STATUS_TEXT, TRADE_PRESETS, TRAINING_TOPICS, EMPTY_DETAILS,
  daysUntil, endingSoon, normRole, parseBulkInvites,
  type AccountsDataSource, type AssignmentProposal, type BaseRole, type CompanyRole, type CompanyTrade, type MemberDetails,
  type NewTrainingRequest, type Placement, type TeamMember, type TrainingProfile, type TrainingRequest,
} from '@/lib/accountsData';
import { Modal } from '@/components/ui/Modal';

const fmt = (d: string | null | undefined) => (d ? new Date(d.length === 10 ? d + 'T12:00:00' : d).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' }) : '—');
export const memberName = (m: Pick<TeamMember, 'full_name' | 'email'> | undefined) => m?.full_name || m?.email || 'Unknown';
const roleText = (m: TeamMember) => m.custom_role || ROLE_LABEL[m.role] || 'Employee';

/* ---------------- small building blocks ---------------- */
export function Chips({ options, value, onChange, disabled }: { options: string[]; value: string[]; onChange: (v: string[]) => void; disabled?: boolean }) {
  return (
    <div className="flex flex-wrap gap-1.5">
      {options.map((o) => {
        const on = value.includes(o);
        return (
          <button key={o} type="button" disabled={disabled} onClick={() => onChange(on ? value.filter((x) => x !== o) : [...value, o])}
            className={`text-xs px-2.5 py-1 rounded-full border transition-colors ${on ? 'border-accent-500 bg-accent-500/15 text-accent-200' : 'border-steel-600 text-steel-300 hover:border-steel-400'} disabled:opacity-60`}>
            {on && <Check className="inline w-3 h-3 mr-1 -mt-0.5" />}{o}
          </button>
        );
      })}
    </div>
  );
}
function Field({ label, children, hint, group }: { label: string; children: React.ReactNode; hint?: string; group?: boolean }) {
  const Tag = group ? 'div' : 'label';
  // Give the wrapped control a name (autofill / form tooling expect id or name).
  if (!group && isValidElement<{ name?: string; id?: string }>(children) && !children.props.name && !children.props.id) {
    children = cloneElement(children, { name: label.toLowerCase().replace(/\(.*?\)/g, '').trim().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') });
  }
  return (
    <Tag className="block" {...(group ? { role: 'group', 'aria-label': label } : {})}>
      <span className="block text-[11px] font-semibold uppercase tracking-wider text-steel-400 mb-1">{label}</span>
      {children}
      {hint && <span className="block text-[11px] text-steel-500 mt-1">{hint}</span>}
    </Tag>
  );
}
function ResearchBox({ checked, onChange, disabled }: { checked: boolean; onChange: (v: boolean) => void; disabled?: boolean }) {
  return (
    <label className="flex items-start gap-2 rounded-lg border border-accent-500/30 bg-accent-500/5 p-3 text-sm text-steel-200 cursor-pointer">
      <input type="checkbox" name="research-ok" className="mt-0.5" checked={checked} disabled={disabled} onChange={(e) => onChange(e.target.checked)} />
      <span><b className="text-white">Not sure?</b> ForgeLine will research this company/site and tailor the training.</span>
    </label>
  );
}
/* ---------------- dashboard cards ---------------- */
export function EndingSoonCard({ team, placements, onOpen }: { team: TeamMember[]; placements: Placement[]; onOpen: (id: string) => void }) {
  const rows = team.filter((m) => endingSoon(m.details)).sort((a, b) => (a.details!.contract_end ?? '').localeCompare(b.details!.contract_end ?? ''));
  const pl = new Map(placements.map((p) => [p.id, p]));
  return (
    <div className="card p-4 sm:p-5">
      <h2 className="font-display text-base font-semibold text-white flex items-center gap-2 mb-3"><CalendarClock className="w-5 h-5 text-warning-400" /> Contracts ending in 30 days</h2>
      {rows.length === 0 ? <p className="text-sm text-steel-500">None in the next 30 days.</p> : (
        <ul className="space-y-2">
          {rows.map((m) => (
            <li key={m.user_id}>
              <button onClick={() => onOpen(m.user_id)} className="w-full text-left flex items-center justify-between gap-2 rounded-lg border border-steel-700/40 bg-navy-950/30 px-3 py-2 hover:bg-navy-800/40">
                <span className="min-w-0">
                  <span className="block text-sm text-white truncate">{memberName(m)}</span>
                  <span className="block text-[11px] text-steel-500 truncate">{pl.get(m.details?.placement_id ?? '')?.client_name ?? 'No client'}{m.details?.contract_name ? ` · ${m.details.contract_name}` : ''}</span>
                </span>
                <span className="text-xs font-semibold text-warning-400 shrink-0">{daysUntil(m.details!.contract_end)}d · {fmt(m.details!.contract_end)}</span>
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export function DailySummaryCard({ ds, companyId, onProposals, onReview }: { ds: AccountsDataSource; companyId: string; onProposals: (p: AssignmentProposal[], text: string) => void; onReview?: () => void }) {
  const [text, setText] = useState<string | null>(null);
  const [proposed, setProposed] = useState(0);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  async function run() {
    setBusy(true); setErr(null);
    const r = await ds.askAssistant(companyId, 'daily_summary', []);
    setBusy(false);
    if (!r.ok) { setErr(r.error); return; }
    setText(r.reply);
    setProposed(r.proposals.length);
    if (r.proposals.length) onProposals(r.proposals, r.reply);
  }
  return (
    <div className="card p-4 sm:p-5">
      <div className="flex items-center justify-between gap-2 mb-2">
        <h2 className="font-display text-base font-semibold text-white flex items-center gap-2"><Sparkles className="w-5 h-5 text-accent-400" /> Daily summary</h2>
        <button onClick={() => void run()} disabled={busy} className="btn-secondary text-xs px-3 py-1.5 flex items-center gap-1.5">
          {busy ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Bot className="w-3.5 h-3.5" />} {text ? 'Refresh' : 'Generate'}
        </button>
      </div>
      {err && <p className="text-xs text-error-400">{err}</p>}
      {text ? <div className="text-sm text-steel-200 whitespace-pre-wrap break-words">{text}</div>
        : !err && <p className="text-sm text-steel-500">AI summary of today: who's active, behind, overdue, contracts ending and certificates. Generated on demand.</p>}
      {proposed > 0 && onReview && (
        <button onClick={onReview} className="mt-3 btn-primary text-xs px-3 py-1.5">Review {proposed} proposed assignment{proposed === 1 ? '' : 's'}</button>
      )}
    </div>
  );
}

/* ---------------- Employees tab ---------------- */
export function EmployeesTab({ team, placements, roles, currentUserId, canManage, onEdit, onGroupAssign, onBulkInvite, onRemove, progress, busy }: {
  team: TeamMember[]; placements: Placement[]; roles: CompanyRole[]; currentUserId: string; canManage: boolean;
  onEdit: (id: string) => void; onGroupAssign?: () => void; onBulkInvite?: () => void; onRemove?: (m: TeamMember) => void;
  progress: Record<string, { courses: number; completed: number }>; busy?: boolean;
}) {
  const [trade, setTrade] = useState('');
  const [role, setRole] = useState('');
  const [client, setClient] = useState('');
  const [industry, setIndustry] = useState('');
  const [site, setSite] = useState('');
  const [group, setGroup] = useState(false);
  const pl = useMemo(() => new Map(placements.map((p) => [p.id, p])), [placements]);
  const trades = useMemo(() => Array.from(new Set(team.map((m) => m.details?.trade).filter((t): t is string => !!t))).sort(), [team]);
  const sites = useMemo(() => Array.from(new Set(team.map((m) => m.details?.site_location || pl.get(m.details?.placement_id ?? '')?.location).filter((t): t is string => !!t))).sort(), [team, pl]);
  const industries = useMemo(() => Array.from(new Set(placements.flatMap((p) => p.industry))).sort(), [placements]);
  const roleOpts = useMemo(() => ['owner', 'admin', 'supervisor', 'employee', ...roles.map((r) => `custom:${r.id}`)], [roles]);
  const rows = team.filter((m) => {
    const p = pl.get(m.details?.placement_id ?? '');
    const s = m.details?.site_location || p?.location || '';
    if (trade && m.details?.trade !== trade) return false;
    if (role && (role.startsWith('custom:') ? m.custom_role_id !== role.slice(7) : normRole(m.role) !== role)) return false;
    if (client && (client === '__none' ? !!p : p?.id !== client)) return false;
    if (industry && !p?.industry.includes(industry)) return false;
    if (site && s !== site) return false;
    return true;
  });
  const groups: [string, TeamMember[]][] = group
    ? Array.from(rows.reduce((acc, m) => { const k = pl.get(m.details?.placement_id ?? '')?.client_name ?? 'No client placement'; acc.set(k, [...(acc.get(k) ?? []), m]); return acc; }, new Map<string, TeamMember[]>()))
    : [['', rows]];
  const sel = 'input !w-auto text-xs py-1.5 pr-7';
  const cols = 'lg:grid-cols-[minmax(10rem,1.4fr)_6.5rem_7rem_minmax(8rem,1.2fr)_minmax(7rem,1fr)_6.5rem_4rem_2rem]';
  return (
    <div className="card p-4 sm:p-5">
      <div className="flex flex-wrap items-center gap-2 mb-3">
        <h2 className="font-display text-lg font-semibold text-white flex items-center gap-2"><Users className="w-5 h-5 text-accent-400" /> Employees <span className="text-sm text-steel-500 font-normal">({rows.length}{rows.length !== team.length ? ` of ${team.length}` : ''})</span></h2>
        <div className="flex-1" />
        {onGroupAssign && <button onClick={onGroupAssign} className="btn-secondary text-xs px-3 py-1.5">Assign to a trade / role</button>}
        {onBulkInvite && <button onClick={onBulkInvite} className="btn-secondary text-xs px-3 py-1.5 flex items-center gap-1"><ClipboardPaste className="w-3.5 h-3.5" /> Bulk invite</button>}
      </div>
      <div className="flex flex-wrap items-center gap-2 mb-3">
        <Filter className="w-4 h-4 text-steel-500" />
        <select aria-label="Filter by trade" name="filter-trade" className={sel} value={trade} onChange={(e) => setTrade(e.target.value)}><option value="">All trades</option>{trades.map((t) => <option key={t}>{t}</option>)}</select>
        <select aria-label="Filter by role" name="filter-role" className={sel} value={role} onChange={(e) => setRole(e.target.value)}><option value="">All roles</option>{roleOpts.map((r) => <option key={r} value={r}>{r.startsWith('custom:') ? roles.find((x) => x.id === r.slice(7))?.name : ROLE_LABEL[r as BaseRole]}</option>)}</select>
        <select aria-label="Filter by client" name="filter-client" className={sel} value={client} onChange={(e) => setClient(e.target.value)}><option value="">All clients</option>{placements.map((p) => <option key={p.id} value={p.id}>{p.client_name}</option>)}<option value="__none">No client</option></select>
        <select aria-label="Filter by industry" name="filter-industry" className={sel} value={industry} onChange={(e) => setIndustry(e.target.value)}><option value="">All industries</option>{industries.map((i) => <option key={i}>{i}</option>)}</select>
        <select aria-label="Filter by site" name="filter-site" className={sel} value={site} onChange={(e) => setSite(e.target.value)}><option value="">All sites</option>{sites.map((s) => <option key={s}>{s}</option>)}</select>
        <label className="flex items-center gap-1.5 text-xs text-steel-300 ml-1"><input type="checkbox" name="group-by-client" checked={group} onChange={(e) => setGroup(e.target.checked)} /> Group by client</label>
      </div>
      <div className={`hidden lg:grid ${cols} gap-2 px-3 pb-1 text-[10px] font-semibold text-steel-500 uppercase tracking-wider`}>
        <div>Employee</div><div>Role</div><div>Trade</div><div>Client / industry</div><div>Site</div><div>Contract end</div><div className="text-center">Done</div><div />
      </div>
      {groups.map(([g, list]) => (
        <div key={g || 'all'} className="mb-2">
          {g && <div className="px-1 pt-2 pb-1 text-xs font-semibold text-accent-300 flex items-center gap-1.5"><Building2 className="w-3.5 h-3.5" />{g} <span className="text-steel-500 font-normal">· {list.length}</span></div>}
          <div className="space-y-1.5">
            {list.map((m) => {
              const p = pl.get(m.details?.placement_id ?? '');
              const days = daysUntil(m.details?.contract_end ?? null);
              const soon = endingSoon(m.details);
              const pr = progress[m.user_id] ?? { courses: 0, completed: 0 };
              return (
                <div key={m.user_id} id={`emp-${m.user_id}`} className={`grid grid-cols-[1fr_auto] ${cols} gap-2 items-center p-3 rounded-lg border border-steel-700/40 bg-navy-950/30 hover:bg-navy-800/40`}>
                  <button onClick={() => onEdit(m.user_id)} className="min-w-0 text-left">
                    <div className="text-sm font-medium text-white truncate">{memberName(m)}{m.user_id === currentUserId && <span className="text-steel-500 font-normal"> · you</span>}</div>
                    <div className="text-[11px] text-steel-500 truncate">{m.email}</div>
                    <div className="lg:hidden text-[11px] text-steel-400 truncate">{roleText(m)} · {m.details?.trade ?? 'No trade'} · {p?.client_name ?? 'No client'}{soon ? ` · ends in ${days}d` : ''}</div>
                  </button>
                  <div className="hidden lg:block"><span className={`text-[11px] px-2 py-0.5 rounded-full border ${ROLE_RANK[normRole(m.role)] >= 3 ? 'border-accent-500/50 text-accent-300' : normRole(m.role) === 'supervisor' ? 'border-premium-500/50 text-premium-400' : 'border-steel-600 text-steel-300'}`}>{roleText(m)}</span></div>
                  <div className="hidden lg:block text-xs text-steel-200 truncate">{m.details?.trade ?? <span className="text-steel-600">—</span>}</div>
                  <div className="hidden lg:block min-w-0"><div className="text-xs text-white truncate">{p?.client_name ?? <span className="text-steel-600">—</span>}</div><div className="text-[10px] text-steel-500 truncate">{p?.industry.join(', ')}</div></div>
                  <div className="hidden lg:block text-xs text-steel-300 truncate">{m.details?.site_location || p?.location || <span className="text-steel-600">—</span>}</div>
                  <div className={`hidden lg:block text-xs ${soon ? 'text-warning-400 font-semibold' : days != null && days < 0 ? 'text-steel-500 line-through' : 'text-steel-300'}`}>{fmt(m.details?.contract_end)}</div>
                  <div className="hidden lg:block text-center text-xs text-steel-300">{pr.completed}/{pr.courses}</div>
                  <div className="flex items-center justify-end gap-1">
                    {canManage && onRemove && m.user_id !== currentUserId && normRole(m.role) !== 'owner' && (
                      <button onClick={() => onRemove(m)} disabled={busy} aria-label={`Remove ${memberName(m)}`} className="p-1 rounded text-steel-500 hover:text-error-400"><Trash2 className="w-4 h-4" /></button>
                    )}
                    <button onClick={() => onEdit(m.user_id)} aria-label="Edit" className="p-1 rounded text-steel-400 hover:text-white"><UserCog className="w-4 h-4" /></button>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      ))}
      {rows.length === 0 && <p className="text-sm text-steel-500 py-6 text-center">No employees match these filters.</p>}
    </div>
  );
}

/* ---------------- Employee edit panel ---------------- */
export function EmployeeEditPanel({ member, team, placements, roles, trades, currentUserId, callerRole, isPlatformAdmin, onClose, onSaveRole, onSaveDetails, onViewProgress }: {
  member: TeamMember; team: TeamMember[]; placements: Placement[]; roles: CompanyRole[]; trades: CompanyTrade[];
  currentUserId: string; callerRole: BaseRole; isPlatformAdmin?: boolean;
  onClose: () => void; onSaveRole: (role: BaseRole | null, customRoleId: string | null) => Promise<boolean>;
  onSaveDetails: (d: MemberDetails) => Promise<boolean>; onViewProgress?: () => void;
}) {
  const canEdit = isPlatformAdmin || callerRole === 'owner' || callerRole === 'admin';
  const [d, setD] = useState<MemberDetails>({ ...EMPTY_DETAILS, ...(member.details ?? {}) });
  const [roleVal, setRoleVal] = useState(member.custom_role_id ? `custom:${member.custom_role_id}` : normRole(member.role));
  const [busy, setBusy] = useState(false);
  const owners = team.filter((m) => m.role === 'owner').length;
  const self = member.user_id === currentUserId;
  const myRank = isPlatformAdmin ? 5 : ROLE_RANK[callerRole];
  const roleBlocked = (r: BaseRole) => {
    if (isPlatformAdmin) return member.role === 'owner' && owners <= 1 && r !== 'owner';
    if (!canEdit) return true;
    if (r === 'owner' && callerRole !== 'owner') return true;
    if (member.role === 'owner' && callerRole !== 'owner') return true;
    if (self && ROLE_RANK[r] > ROLE_RANK[normRole(member.role)]) return true;
    if (member.role === 'owner' && owners <= 1 && r !== 'owner') return true;
    return ROLE_RANK[r] > myRank;
  };
  const set = <K extends keyof MemberDetails>(k: K, v: MemberDetails[K]) => setD((x) => ({ ...x, [k]: v }));
  const p = placements.find((x) => x.id === d.placement_id);
  const tradeOpts = Array.from(new Set([...TRADE_PRESETS, ...trades.map((t) => t.name), ...(d.trade ? [d.trade] : [])]));
  async function save() {
    setBusy(true);
    const newRole = roleVal.startsWith('custom:') ? null : (roleVal as BaseRole);
    const newCustom = roleVal.startsWith('custom:') ? roleVal.slice(7) : null;
    const roleChanged = newCustom !== member.custom_role_id || (newRole && newRole !== normRole(member.role));
    let ok = true;
    if (canEdit && roleChanged) ok = await onSaveRole(newRole, newCustom);
    if (ok && canEdit) ok = await onSaveDetails(d);
    setBusy(false);
    if (ok) onClose();
  }
  const ro = !canEdit;
  return (
    <Modal title={memberName(member)} subtitle={`${member.email ?? ''}${ro ? ' · view only (supervisors can view, owners/admins edit)' : ''}`} onClose={onClose} size="lg"
      footer={<>
        {onViewProgress && <button onClick={onViewProgress} className="btn-ghost text-sm mr-auto">View training progress</button>}
        <button onClick={onClose} className="btn-ghost text-sm">{ro ? 'Close' : 'Cancel'}</button>
        {!ro && <button onClick={() => void save()} disabled={busy} className="btn-primary text-sm px-4">{busy ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Save'}</button>}
      </>}>
      <div className="grid sm:grid-cols-2 gap-3 mb-4">
        <Field label="Role" hint={member.role === 'owner' && owners <= 1 ? 'Only owner: promote someone else to owner first.' : self ? 'You cannot raise your own role.' : undefined}>
          <select className="input w-full" value={roleVal} disabled={ro} onChange={(e) => setRoleVal(e.target.value)}>
            {(['owner', 'admin', 'supervisor', 'employee'] as BaseRole[]).map((r) => <option key={r} value={r} disabled={roleBlocked(r) && normRole(member.role) !== r}>{ROLE_LABEL[r]}</option>)}
            {roles.map((r) => <option key={r.id} value={`custom:${r.id}`} disabled={roleBlocked(r.base_role)}>{r.name} ({ROLE_LABEL[r.base_role]})</option>)}
          </select>
        </Field>
        <Field label="Trade / position">
          <select className="input w-full" value={d.trade ?? ''} disabled={ro} onChange={(e) => set('trade', e.target.value || null)}>
            <option value="">Not set</option>{tradeOpts.map((t) => <option key={t}>{t}</option>)}
          </select>
        </Field>
      </div>
      <h4 className="text-sm font-semibold text-white mb-2 flex items-center gap-2"><Briefcase className="w-4 h-4 text-accent-400" /> Placement & contract</h4>
      <div className="grid sm:grid-cols-2 gap-3 mb-3">
        <Field label="Client placement (company they work at)">
          <select className="input w-full" value={d.placement_id ?? ''} disabled={ro} onChange={(e) => set('placement_id', e.target.value || null)}>
            <option value="">None / in-house</option>{placements.map((x) => <option key={x.id} value={x.id}>{x.client_name}{x.location ? ` · ${x.location}` : ''}</option>)}
          </select>
        </Field>
        <Field label="Site / location" hint={p?.location && !d.site_location ? `Uses client site: ${p.location}` : undefined}>
          <input className="input w-full" value={d.site_location ?? ''} disabled={ro} onChange={(e) => set('site_location', e.target.value)} placeholder={p?.location ?? 'e.g. Plant 2, Building C'} />
        </Field>
      </div>
      {p && (
        <div className="mb-3 rounded-lg border border-steel-700/50 bg-navy-950/40 p-3 text-xs text-steel-300">
          <div className="flex items-center gap-1.5 text-white font-semibold mb-1"><Factory className="w-3.5 h-3.5 text-accent-400" />{p.client_name}</div>
          <div>Industry: {p.industry.join(', ') || '—'} · Equipment: {p.equipment.join(', ') || '—'}{p.research_ok ? ' · ForgeLine to research' : ''}</div>
        </div>
      )}
      <div className="grid sm:grid-cols-2 gap-3 mb-3">
        <Field label="Contract name"><input className="input w-full" value={d.contract_name ?? ''} disabled={ro} onChange={(e) => set('contract_name', e.target.value)} /></Field>
        <Field label="Contract number"><input className="input w-full" value={d.contract_number ?? ''} disabled={ro} onChange={(e) => set('contract_number', e.target.value)} /></Field>
        <Field label="Contract start"><input type="date" className="input w-full" value={d.contract_start ?? ''} disabled={ro} onChange={(e) => set('contract_start', e.target.value || null)} /></Field>
        <Field label="Contract end"><input type="date" className="input w-full" value={d.contract_end ?? ''} disabled={ro} onChange={(e) => set('contract_end', e.target.value || null)} /></Field>
        <Field label="Shift"><input className="input w-full" value={d.shift ?? ''} disabled={ro} onChange={(e) => set('shift', e.target.value)} placeholder="Days / Nights / 4x10" /></Field>
        <Field label="Supervisor"><input className="input w-full" value={d.supervisor_name ?? ''} disabled={ro} onChange={(e) => set('supervisor_name', e.target.value)} /></Field>
      </div>
      <Field label="Notes"><textarea className="input w-full min-h-[70px]" value={d.notes ?? ''} disabled={ro} onChange={(e) => set('notes', e.target.value)} /></Field>
    </Modal>
  );
}

/* ---------------- Clients & sites (placements) ---------------- */
export function PlacementsPanel({ placements, team, canEdit, onSave, onDelete }: {
  placements: Placement[]; team: TeamMember[]; canEdit: boolean;
  onSave: (p: Partial<Placement> & { client_name: string }) => Promise<boolean>; onDelete: (p: Placement) => void;
}) {
  const [edit, setEdit] = useState<Partial<Placement> | null>(null);
  const count = (id: string) => team.filter((m) => m.details?.placement_id === id).length;
  return (
    <div className="card p-4 sm:p-5">
      <div className="flex items-center justify-between mb-3">
        <h2 className="font-display text-lg font-semibold text-white flex items-center gap-2"><MapPin className="w-5 h-5 text-accent-400" /> Clients & sites</h2>
        {canEdit && <button onClick={() => setEdit({ client_name: '', industry: [], equipment: [], research_ok: false })} className="btn-primary text-sm flex items-center gap-1.5"><Plus className="w-4 h-4" /> Add client site</button>}
      </div>
      <p className="text-xs text-steel-500 mb-3">Where your people work: each client site has its own industry and equipment, so training can match the job. Several employees can share one site.</p>
      {placements.length === 0 ? <p className="text-sm text-steel-500 py-4 text-center">No client sites yet.</p> : (
        <div className="grid sm:grid-cols-2 gap-3">
          {placements.map((p) => (
            <div key={p.id} className="rounded-lg border border-steel-700/50 bg-navy-950/30 p-3">
              <div className="flex items-start justify-between gap-2">
                <div className="min-w-0"><div className="text-sm font-semibold text-white truncate">{p.client_name}</div><div className="text-[11px] text-steel-500 truncate">{p.location ?? 'No location'} · {count(p.id)} employee{count(p.id) === 1 ? '' : 's'}</div></div>
                {canEdit && <div className="flex gap-1"><button onClick={() => setEdit(p)} className="text-xs text-accent-300">Edit</button><button onClick={() => onDelete(p)} aria-label="Delete" className="text-steel-500 hover:text-error-400"><Trash2 className="w-3.5 h-3.5" /></button></div>}
              </div>
              <div className="mt-2 flex flex-wrap gap-1">{p.industry.map((i) => <span key={i} className="text-[10px] px-1.5 py-0.5 rounded bg-accent-500/10 text-accent-300">{i}</span>)}{p.equipment.map((i) => <span key={i} className="text-[10px] px-1.5 py-0.5 rounded bg-navy-800 text-steel-300">{i}</span>)}{p.research_ok && <span className="text-[10px] px-1.5 py-0.5 rounded bg-premium-500/10 text-premium-400">ForgeLine to research</span>}</div>
            </div>
          ))}
        </div>
      )}
      {edit && <PlacementEditor initial={edit} onClose={() => setEdit(null)} onSave={async (p) => { if (await onSave(p)) setEdit(null); }} />}
    </div>
  );
}
function PlacementEditor({ initial, onClose, onSave }: { initial: Partial<Placement>; onClose: () => void; onSave: (p: Partial<Placement> & { client_name: string }) => Promise<void> }) {
  const [p, setP] = useState<Partial<Placement>>({ industry: [], equipment: [], research_ok: false, ...initial });
  const [busy, setBusy] = useState(false);
  return (
    <Modal title={initial.id ? 'Edit client site' : 'Add client site'} onClose={onClose} size="lg"
      footer={<>
        <button onClick={onClose} className="btn-ghost text-sm">Cancel</button>
        <button disabled={busy || !p.client_name?.trim()} onClick={async () => { setBusy(true); await onSave({ ...p, client_name: p.client_name!.trim() }); setBusy(false); }} className="btn-primary text-sm px-4">{busy ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Save'}</button>
      </>}>
      <div className="grid sm:grid-cols-2 gap-3 mb-3">
        <Field label="Client company"><input className="input w-full" value={p.client_name ?? ''} onChange={(e) => setP({ ...p, client_name: e.target.value })} autoFocus /></Field>
        <Field label="Site location"><input className="input w-full" value={p.location ?? ''} onChange={(e) => setP({ ...p, location: e.target.value })} placeholder="City, plant, building" /></Field>
      </div>
      <Field group label="Client industry"><Chips options={INDUSTRIES} value={p.industry ?? []} onChange={(v) => setP({ ...p, industry: v })} /></Field>
      <div className="h-3" />
      <Field group label="Equipment at this site"><Chips options={EQUIPMENT} value={p.equipment ?? []} onChange={(v) => setP({ ...p, equipment: v })} /></Field>
      <div className="h-3" />
      <Field label="Other equipment / specifics"><textarea className="input w-full min-h-[60px]" value={p.equipment_notes ?? ''} onChange={(e) => setP({ ...p, equipment_notes: e.target.value })} placeholder="e.g. Fanuc robots on line 4, Ingersoll Rand compressors" /></Field>
      <div className="h-3" />
      <ResearchBox checked={!!p.research_ok} onChange={(v) => setP({ ...p, research_ok: v })} />
    </Modal>
  );
}

/* ---------------- Company training profile ---------------- */
export function TrainingProfilePanel({ profile, companyId, canEdit, onSave }: { profile: TrainingProfile | null; companyId: string; canEdit: boolean; onSave: (p: TrainingProfile) => Promise<boolean> }) {
  const [p, setP] = useState<TrainingProfile>(profile ?? { company_id: companyId, industries: [], plant_details: null, equipment: [], equipment_notes: null, research_ok: false });
  const [busy, setBusy] = useState(false);
  const [saved, setSaved] = useState(false);
  return (
    <div className="card p-4 sm:p-5">
      <h2 className="font-display text-lg font-semibold text-white flex items-center gap-2 mb-1"><Factory className="w-5 h-5 text-accent-400" /> Company training profile <span className="text-xs font-normal text-steel-500">(optional)</span></h2>
      <p className="text-xs text-steel-500 mb-4">Tell ForgeLine about your company so custom training fits. Client sites carry their own industry and equipment too.</p>
      <Field group label="Industry"><Chips options={INDUSTRIES} value={p.industries} disabled={!canEdit} onChange={(v) => setP({ ...p, industries: v })} /></Field>
      <div className="h-3" />
      <Field label="Company / plant specifics"><textarea className="input w-full min-h-[70px]" disabled={!canEdit} value={p.plant_details ?? ''} onChange={(e) => setP({ ...p, plant_details: e.target.value })} placeholder="What you make, plant size, shifts, unions, anything that matters for training" /></Field>
      <div className="h-3" />
      <Field group label="Equipment you use"><Chips options={EQUIPMENT} value={p.equipment} disabled={!canEdit} onChange={(v) => setP({ ...p, equipment: v })} /></Field>
      <div className="h-3" />
      <Field label="Other equipment"><input className="input w-full" disabled={!canEdit} value={p.equipment_notes ?? ''} onChange={(e) => setP({ ...p, equipment_notes: e.target.value })} placeholder="Makes, models, control systems" /></Field>
      <div className="h-3" />
      <ResearchBox checked={p.research_ok} disabled={!canEdit} onChange={(v) => setP({ ...p, research_ok: v })} />
      {canEdit && (
        <div className="flex items-center justify-end gap-3 mt-4">
          {saved && <span className="text-xs text-success-400">Saved</span>}
          <button disabled={busy} onClick={async () => { setBusy(true); setSaved(await onSave(p)); setBusy(false); }} className="btn-primary text-sm px-4">{busy ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Save profile'}</button>
        </div>
      )}
    </div>
  );
}

/* ---------------- Request custom training ---------------- */
export function RequestTrainingPanel({ companyId, profile, placements, requests, initialDraft, onSubmit }: {
  companyId: string; profile: TrainingProfile | null; placements: Placement[]; requests: TrainingRequest[];
  initialDraft?: Partial<NewTrainingRequest> | null;
  onSubmit: (r: NewTrainingRequest, files: File[]) => Promise<boolean>;
}) {
  const base = (): NewTrainingRequest => ({
    company_id: companyId, placement_id: null, topic: '', topics: [], details: '', worker_count: null, trades: '',
    urgency: 'normal', preferred_format: 'online', industries: profile?.industries ?? [], equipment: profile?.equipment ?? [],
    research_ok: profile?.research_ok ?? false, source: 'form', ...(initialDraft ?? {}),
  });
  const [r, setR] = useState<NewTrainingRequest>(base);
  const [files, setFiles] = useState<File[]>([]);
  const [busy, setBusy] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);
  const pickPlacement = (id: string) => {
    const p = placements.find((x) => x.id === id);
    setR({ ...r, placement_id: id || null, industries: p ? p.industry : profile?.industries ?? [], equipment: p ? p.equipment : profile?.equipment ?? [], research_ok: p ? p.research_ok : profile?.research_ok ?? false });
  };
  return (
    <div className="space-y-6">
      <div className="card p-4 sm:p-6 border-accent-500/30">
        <p className="text-[11px] font-semibold uppercase tracking-wider text-accent-400">Request custom training</p>
        <h2 className="font-display text-xl sm:text-2xl font-bold text-white mb-1">Get your skilled workers the training they actually need</h2>
        <p className="text-sm text-steel-400 mb-4">Tell us what your crew works on. ForgeLine builds training around your equipment and sites, online, on-site or both.</p>
        <Field group label="Topics"><Chips options={TRAINING_TOPICS} value={r.topics} onChange={(v) => setR({ ...r, topics: v, topic: r.topic || v[0] || '' })} /></Field>
        <div className="grid sm:grid-cols-2 gap-3 mt-3">
          <Field label="Topic / title"><input className="input w-full" value={r.topic} onChange={(e) => setR({ ...r, topic: e.target.value })} placeholder="e.g. VFD troubleshooting for night shift" /></Field>
          <Field label="For a client site (optional)">
            <select className="input w-full" value={r.placement_id ?? ''} onChange={(e) => pickPlacement(e.target.value)}>
              <option value="">Whole company</option>{placements.map((p) => <option key={p.id} value={p.id}>{p.client_name}{p.location ? ` · ${p.location}` : ''}</option>)}
            </select>
          </Field>
          <Field label="Number of workers"><input type="number" min={1} className="input w-full" value={r.worker_count ?? ''} onChange={(e) => setR({ ...r, worker_count: e.target.value ? Number(e.target.value) : null })} /></Field>
          <Field label="Trades / roles"><input className="input w-full" value={r.trades ?? ''} onChange={(e) => setR({ ...r, trades: e.target.value })} placeholder="Electricians, I&E techs" /></Field>
          <Field label="Urgency">
            <select className="input w-full" value={r.urgency} onChange={(e) => setR({ ...r, urgency: e.target.value as NewTrainingRequest['urgency'] })}>
              <option value="flexible">Flexible</option><option value="normal">Next 1-3 months</option><option value="soon">Within a month</option><option value="urgent">Urgent</option>
            </select>
          </Field>
          <Field group label="Preferred format">
            <div className="flex gap-1.5">{(['online', 'on_site', 'blend'] as const).map((f) => (
              <button key={f} type="button" aria-pressed={r.preferred_format === f} onClick={() => setR({ ...r, preferred_format: f })} className={`flex-1 text-xs py-2 rounded-lg border ${r.preferred_format === f ? 'border-accent-500 bg-accent-500/15 text-accent-200' : 'border-steel-600 text-steel-300'}`}>{f === 'online' ? 'Online' : f === 'on_site' ? 'On-site' : 'Blend'}</button>
            ))}</div>
          </Field>
        </div>
        <div className="mt-3"><Field label="Details"><textarea className="input w-full min-h-[90px]" value={r.details ?? ''} onChange={(e) => setR({ ...r, details: e.target.value })} placeholder="What's going wrong, what they need to be able to do, any deadlines or audits" /></Field></div>
        <div className="mt-3"><Field group label={`Industry${r.placement_id ? ' (from client site)' : profile ? ' (from your profile)' : ''}`}><Chips options={INDUSTRIES} value={r.industries} onChange={(v) => setR({ ...r, industries: v })} /></Field></div>
        <div className="mt-3"><Field group label="Equipment"><Chips options={EQUIPMENT} value={r.equipment} onChange={(v) => setR({ ...r, equipment: v })} /></Field></div>
        <div className="mt-3"><ResearchBox checked={r.research_ok} onChange={(v) => setR({ ...r, research_ok: v })} /></div>
        <div className="mt-3">
          <input ref={fileRef} type="file" name="attachments" aria-label="Attach files" multiple className="hidden" onChange={(e) => { setFiles([...files, ...Array.from(e.target.files ?? [])].slice(0, 10)); e.target.value = ''; }} />
          <button type="button" onClick={() => fileRef.current?.click()} className="btn-ghost text-sm flex items-center gap-1.5"><FileUp className="w-4 h-4" /> Attach files (prints, procedures, photos)</button>
          {files.length > 0 && <ul className="mt-1 text-xs text-steel-300 space-y-1">{files.map((f, i) => <li key={i} className="flex items-center gap-2 min-w-0"><span className="min-w-0 break-all">{f.name}</span> <button type="button" onClick={() => setFiles(files.filter((_, j) => j !== i))} aria-label={`Remove ${f.name}`} className="shrink-0 p-1 rounded hover:bg-navy-800"><X className="w-3 h-3" /></button></li>)}</ul>}
        </div>
        <div className="flex flex-wrap items-center justify-between gap-3 mt-5">
          <a href={KRIS_MAILTO} className="text-sm text-steel-400 hover:text-accent-300 flex items-center gap-1.5 min-w-0 break-all"><Mail className="w-4 h-4" /> or email us: kris@forgelineacademy.com</a>
          <button disabled={busy || !r.topic.trim()} onClick={async () => { setBusy(true); const ok = await onSubmit({ ...r, topic: r.topic.trim() }, files); setBusy(false); if (ok) { setR(base()); setFiles([]); } }}
            className="btn-primary text-sm px-5 flex items-center gap-2">{busy ? <Loader2 className="w-4 h-4 animate-spin" /> : <Send className="w-4 h-4" />} Send request</button>
          {!r.topic.trim() && <p className="basis-full text-right text-[11px] text-steel-500">Pick a topic or enter a title to send.</p>}
        </div>
      </div>
      <div className="card p-4 sm:p-5">
        <h3 className="font-display text-base font-semibold text-white mb-3">Your requests</h3>
        {requests.length === 0 ? <p className="text-sm text-steel-500">No requests yet.</p> : (
          <ul className="divide-y divide-steel-700/40 rounded-lg border border-steel-700/40">
            {requests.map((q) => (
              <li key={q.id} className="flex flex-wrap items-center justify-between gap-2 px-3 py-2 text-sm">
                <span className="min-w-0 break-words"><span className="text-white">{q.topic}</span> <span className="text-[11px] text-steel-500">· {fmt(q.created_at)}{q.placement_id ? ` · ${placements.find((p) => p.id === q.placement_id)?.client_name ?? ''}` : ''}</span></span>
                <RequestStatusPill status={q.status} />
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
export function RequestStatusPill({ status }: { status: TrainingRequest['status'] }) {
  const cls = { new: 'border-accent-500/50 text-accent-300', quoted: 'border-premium-500/50 text-premium-400', in_progress: 'border-warning-500/50 text-warning-400', delivered: 'border-success-500/50 text-success-400', declined: 'border-steel-600 text-steel-400' }[status];
  return <span className={`text-[11px] font-semibold px-2 py-0.5 rounded-full border ${cls}`}>{STATUS_TEXT[status]}</span>;
}

/* ---------------- Settings: custom roles, trades, self-trade ---------------- */
export function RolesTradesSettings({ roles, trades, allowSelfTrade, onAddRole, onDeleteRole, onAddTrade, onDeleteTrade, onSelfTrade }: {
  roles: CompanyRole[]; trades: CompanyTrade[]; allowSelfTrade: boolean;
  onAddRole: (n: string, b: CompanyRole['base_role']) => void; onDeleteRole: (r: CompanyRole) => void;
  onAddTrade: (n: string) => void; onDeleteTrade: (t: CompanyTrade) => void; onSelfTrade: (v: boolean) => void;
}) {
  const [rn, setRn] = useState(''); const [rb, setRb] = useState<CompanyRole['base_role']>('employee'); const [tn, setTn] = useState('');
  return (
    <div className="card p-4 sm:p-5 grid md:grid-cols-2 gap-6">
      <div>
        <h3 className="font-display text-base font-semibold text-white mb-1 flex items-center gap-2"><UserCog className="w-4 h-4 text-accent-400" /> Custom roles</h3>
        <p className="text-xs text-steel-500 mb-2">Your own titles (Lead Hand, Foreman...). Each maps to a permission level.</p>
        <ul className="mb-2 space-y-1">{roles.map((r) => <li key={r.id} className="flex items-center justify-between text-sm text-steel-200"><span>{r.name} <span className="text-[11px] text-steel-500">· {ROLE_LABEL[r.base_role]} permissions</span></span><button onClick={() => onDeleteRole(r)} aria-label="Delete role" className="text-steel-500 hover:text-error-400"><Trash2 className="w-3.5 h-3.5" /></button></li>)}</ul>
        <form className="flex flex-wrap gap-2" onSubmit={(e) => { e.preventDefault(); if (rn.trim()) { onAddRole(rn.trim(), rb); setRn(''); } }}><input aria-label="New role name" name="role-name" className="input flex-1 min-w-0 text-sm" value={rn} onChange={(e) => setRn(e.target.value)} placeholder="Role name" />
          <select aria-label="Permissions for new role" name="role-base" className="input !w-auto text-sm" value={rb} onChange={(e) => setRb(e.target.value as CompanyRole['base_role'])}><option value="employee">Employee</option><option value="supervisor">Supervisor</option><option value="admin">Admin</option></select>
          <button type="submit" className="btn-secondary text-sm" disabled={!rn.trim()}>Add</button></form>
      </div>
      <div>
        <h3 className="font-display text-base font-semibold text-white mb-1 flex items-center gap-2"><Wrench className="w-4 h-4 text-accent-400" /> Trades</h3>
        <p className="text-xs text-steel-500 mb-2">Built in: {TRADE_PRESETS.join(', ')}. Add your own:</p>
        <ul className="mb-2 space-y-1">{trades.map((t) => <li key={t.id} className="flex items-center justify-between text-sm text-steel-200">{t.name}<button onClick={() => onDeleteTrade(t)} aria-label="Delete trade" className="text-steel-500 hover:text-error-400"><Trash2 className="w-3.5 h-3.5" /></button></li>)}</ul>
        <form className="flex gap-2" onSubmit={(e) => { e.preventDefault(); if (tn.trim()) { onAddTrade(tn.trim()); setTn(''); } }}><input aria-label="New trade name" name="trade-name" className="input flex-1 min-w-0 text-sm" value={tn} onChange={(e) => setTn(e.target.value)} placeholder="Trade name" /><button type="submit" className="btn-secondary text-sm" disabled={!tn.trim()}>Add</button></form>
        <label className="flex items-center gap-2 mt-3 text-sm text-steel-200"><input type="checkbox" name="allow-self-trade" checked={allowSelfTrade} onChange={(e) => onSelfTrade(e.target.checked)} /> Let employees set their own trade</label>
      </div>
    </div>
  );
}

/* ---------------- Group assign + bulk invite ---------------- */
export function GroupAssignDialog({ courseTitles, trades, roles, onCancel, onAssign, busy }: {
  courseTitles: Record<string, string>; trades: string[]; roles: CompanyRole[]; busy: boolean;
  onCancel: () => void; onAssign: (courseId: string, trade: string | null, role: string | null, due: string | null) => void;
}) {
  const [course, setCourse] = useState(''); const [trade, setTrade] = useState(''); const [role, setRole] = useState(''); const [due, setDue] = useState('');
  return (
    <Modal title="Assign a course to a trade or role" onClose={onCancel}
      footer={<><button onClick={onCancel} className="btn-ghost text-sm">Cancel</button>
        <button disabled={busy || !course || (!trade && !role)} onClick={() => onAssign(course, trade || null, role || null, due || null)} className="btn-primary text-sm px-4">{busy ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Assign'}</button></>}>
      <div className="space-y-3">
        <Field label="Course"><select className="input w-full" value={course} onChange={(e) => setCourse(e.target.value)}><option value="">Choose a course</option>{Object.entries(courseTitles).map(([id, t]) => <option key={id} value={id}>{t}</option>)}</select></Field>
        <Field label="Trade"><select className="input w-full" value={trade} onChange={(e) => setTrade(e.target.value)}><option value="">Any trade</option>{Array.from(new Set([...TRADE_PRESETS, ...trades])).map((t) => <option key={t}>{t}</option>)}</select></Field>
        <Field label="Role"><select className="input w-full" value={role} onChange={(e) => setRole(e.target.value)}><option value="">Any role</option>{(['admin', 'supervisor', 'employee'] as BaseRole[]).map((r) => <option key={r} value={r}>{ROLE_LABEL[r]}</option>)}{roles.map((r) => <option key={r.id} value={r.name}>{r.name}</option>)}</select></Field>
        <Field label="Due date (optional)"><input type="date" className="input w-full" value={due} onChange={(e) => setDue(e.target.value)} /></Field>
      </div>
      {!trade && !role && <p className="mt-3 text-[11px] text-steel-500">Pick a trade, a role, or both.</p>}
    </Modal>
  );
}

export function BulkInviteDialog({ seatsLeft, onCancel, onInvite }: {
  seatsLeft: number | null; onCancel: () => void;
  onInvite: (rows: { email: string; trade: string | null; role: 'supervisor' | 'employee' | null }[]) => Promise<{ email: string; ok: boolean; error?: string }[]>;
}) {
  const [text, setText] = useState(''); const [busy, setBusy] = useState(false);
  const [results, setResults] = useState<{ email: string; ok: boolean; error?: string }[] | null>(null);
  const rows = parseBulkInvites(text);
  const valid = rows.filter((r) => !r.error);
  const over = seatsLeft != null && valid.length > seatsLeft;
  async function onFile(f: File | undefined) { if (f) setText(await f.text()); }
  return (
    <Modal title="Bulk invite" onClose={onCancel} size="lg"
      footer={<><button onClick={onCancel} className="btn-ghost text-sm">{results ? 'Done' : 'Cancel'}</button>
        {!results && <button disabled={busy || valid.length === 0} onClick={async () => { setBusy(true); setResults(await onInvite(valid)); setBusy(false); }} className="btn-primary text-sm px-4">{busy ? <Loader2 className="w-4 h-4 animate-spin" /> : `Invite ${valid.length}`}</button>}</>}>
      <p className="text-xs text-steel-500 mb-2">Paste one per line or upload a CSV: <code className="text-steel-300">email, trade, role</code> (role = employee or supervisor). Pending invites use a seat.</p>
      <textarea aria-label="Invites, one per line" name="bulk-invites" className="input w-full min-h-[140px] font-mono text-xs" value={text} onChange={(e) => setText(e.target.value)} placeholder={'email,trade,role\njane@acme.com,Electrician,employee\nmo@acme.com,Millwright,supervisor'} />
      <input type="file" aria-label="Upload CSV" name="bulk-invites-csv" accept=".csv,text/csv,text/plain" className="mt-2 text-xs text-steel-400 max-w-full" onChange={(e) => void onFile(e.target.files?.[0])} />
      {rows.length > 0 && (
        <div className="mt-3 rounded border border-steel-700/50 text-xs">
          {rows.map((r, i) => { const res = results?.find((x) => x.email === r.email); return (
            <div key={i} className="flex justify-between gap-2 px-2 py-1 border-b border-steel-800 last:border-0">
              <span className="text-steel-200 min-w-0 break-all">{r.email} <span className="text-steel-500">{r.trade ?? ''} {r.role ?? ''}</span></span>
              <span className={r.error || res?.error ? 'text-error-400' : res?.ok ? 'text-success-400' : 'text-steel-500'}>{r.error ?? (res ? (res.ok ? 'Invited' : res.error) : 'Ready')}</span>
            </div>); })}
        </div>
      )}
      {over && <p className="mt-2 text-xs text-warning-400">Only {seatsLeft} seat{seatsLeft === 1 ? '' : 's'} left: the first {seatsLeft} will be invited, the rest will be refused until you free seats or add more.</p>}
    </Modal>
  );
}

/* ---------------- Manager Assistant ---------------- */
export interface AssistantMsg { role: 'user' | 'assistant'; content: string; proposals?: AssignmentProposal[]; draft?: Partial<NewTrainingRequest> | null; confirmed?: boolean }
export function ManagerAssistant({ ds, companyId, team, courseTitles, onConfirmAssignments, onUseDraft, initial, embedded }: {
  ds: AccountsDataSource; companyId: string; team: TeamMember[]; courseTitles: Record<string, string>;
  onConfirmAssignments: (p: AssignmentProposal[]) => Promise<boolean>; onUseDraft: (d: Partial<NewTrainingRequest>) => void; initial?: AssistantMsg[];
  /** Inside another scroll container (AI Tutor panel): fill it instead of using a fixed viewport height. */
  embedded?: boolean;
}) {
  const logRef = useRef<HTMLDivElement>(null);
  const [msgs, setMsgs] = useState<AssistantMsg[]>(initial ?? []);
  const [input, setInput] = useState(''); const [busy, setBusy] = useState(false); const [err, setErr] = useState<string | null>(null);
  const byId = new Map(team.map((m) => [m.user_id, m]));
  async function send(mode: 'chat' | 'daily_summary', text?: string) {
    const next: AssistantMsg[] = mode === 'chat' && text ? [...msgs, { role: 'user', content: text }] : [...msgs, { role: 'user', content: 'Daily summary' }];
    setMsgs(next); setInput(''); setBusy(true); setErr(null);
    const r = await ds.askAssistant(companyId, mode, next.map((m) => ({ role: m.role, content: m.content })));
    setBusy(false);
    if (!r.ok) { setErr(r.error); return; }
    setMsgs([...next, { role: 'assistant', content: r.reply, proposals: r.proposals, draft: r.draft }]);
  }
  // Keep the newest message in view (the log scrolls, not the page).
  useEffect(() => { const el = logRef.current; if (el) el.scrollTop = el.scrollHeight; }, [msgs, busy, err]);
  const suggestions = ["Who's behind or overdue?", 'Suggest courses for our electricians by client site', 'Whose contracts end this month?', 'Draft a custom training request for VFDs', 'How do I bulk invite?'];
  return (
    <div className={embedded ? 'flex flex-col flex-1 min-h-0' : 'card p-4 sm:p-5 flex flex-col h-[calc(100dvh-9rem)] min-h-[440px] max-h-[860px]'}>
      <div className="flex flex-wrap items-center gap-2 mb-3">
        <h2 className="font-display text-lg font-semibold text-white flex items-center gap-2"><Bot className="w-5 h-5 text-accent-400" /> Manager Assistant</h2>
        <span className="text-[11px] text-steel-500 basis-full sm:basis-auto order-last sm:order-none">Uses only your team's data. Never assigns or sends anything without your Confirm.</span>
        <div className="flex-1" />
        <button onClick={() => void send('daily_summary')} disabled={busy} className="btn-secondary text-xs px-3 py-1.5 flex items-center gap-1.5"><Sparkles className="w-3.5 h-3.5" /> Daily summary</button>
      </div>
      <div ref={logRef} className="flex-1 min-h-0 space-y-3 overflow-y-auto overscroll-contain pr-1" aria-live="polite">
        {msgs.length === 0 && <div className="flex flex-wrap gap-2">{suggestions.map((s) => <button key={s} onClick={() => void send('chat', s)} className="text-xs px-3 py-1.5 rounded-full border border-steel-600 text-steel-300 hover:border-accent-500">{s}</button>)}</div>}
        {msgs.map((m, i) => (
          <div key={i} className={m.role === 'user' ? 'flex justify-end' : ''}>
            <div className={`rounded-xl px-3 py-2 text-sm max-w-[90%] whitespace-pre-wrap break-words ${m.role === 'user' ? 'bg-accent-500/20 text-white' : 'bg-navy-950/60 border border-steel-700/50 text-steel-200'}`}>
              {m.content}
              {m.proposals && m.proposals.length > 0 && (
                <div className="mt-3 rounded-lg border border-warning-500/40 bg-warning-500/5 p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-wider text-warning-400 mb-2">Proposed assignments · awaiting your confirmation</p>
                  <ul className="space-y-1.5 mb-3">{m.proposals.map((p, j) => (
                    <li key={j} className="text-xs"><b className="text-white">{courseTitles[p.course_id] ?? 'Course'}</b> → {p.user_id ? memberName(byId.get(p.user_id)) : 'everyone'}{p.due_date ? `, due ${fmt(p.due_date)}` : ''}<div className="text-steel-500">{p.reason}</div></li>
                  ))}</ul>
                  {m.confirmed ? <span className="text-xs text-success-400 flex items-center gap-1"><Check className="w-3.5 h-3.5" /> Assigned</span> : (
                    <div className="flex gap-2">
                      <button onClick={async () => { if (await onConfirmAssignments(m.proposals!)) setMsgs((xs) => xs.map((x, k) => (k === i ? { ...x, confirmed: true } : x))); }} className="btn-primary text-xs px-3 py-1.5">Confirm & assign</button>
                      <button onClick={() => setMsgs((xs) => xs.map((x, k) => (k === i ? { ...x, proposals: [] } : x)))} className="btn-ghost text-xs">Dismiss</button>
                    </div>
                  )}
                </div>
              )}
              {m.draft && (
                <div className="mt-3 rounded-lg border border-accent-500/40 bg-accent-500/5 p-3 text-xs">
                  <p className="font-semibold text-accent-300 mb-1">Draft training request: {m.draft.topic}</p>
                  <p className="text-steel-300 mb-2">{m.draft.details}</p>
                  <button onClick={() => onUseDraft(m.draft!)} className="btn-secondary text-xs px-3 py-1.5">Review & submit</button>
                </div>
              )}
            </div>
          </div>
        ))}
        {busy && <Loader2 className="w-4 h-4 text-accent-400 animate-spin" />}
        {err && <p className="text-xs text-error-400">{err}</p>}
      </div>
      <form className="mt-3 flex gap-2" onSubmit={(e) => { e.preventDefault(); if (input.trim()) void send('chat', input.trim()); }}>
        <input aria-label="Message the Manager Assistant" name="assistant-message" className="input flex-1 min-w-0" value={input} onChange={(e) => setInput(e.target.value)} placeholder="Ask about your team, assignments, contracts, or how to do something" />
        <button disabled={busy || !input.trim()} className="btn-primary px-3" aria-label="Send"><Send className="w-4 h-4" /></button>
      </form>
    </div>
  );
}
