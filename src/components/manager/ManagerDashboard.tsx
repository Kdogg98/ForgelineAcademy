import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  Activity, AlertCircle, ArrowLeft, Award, BarChart3, BookOpen, Building2, CheckCircle2, ChevronRight,
  ClipboardCheck, ClipboardList, Download, Library, Loader2, Printer, Timer, Trash2, UserPlus, Users, X,
} from 'lucide-react';
import type { Company } from '@/lib/types';
import type { Route } from '@/components/Nav';
import {
  supabaseManagerData, inviteUrl, type AssignmentRow, type InviteRow, type ManagerDataSource, type TeamSnapshot, type RosterMember,
} from '@/lib/managerData';
import {
  AssignDialog, AssignmentsPanel, InvitesPanel, OverdueBanner, StatusPill, buildAuditRows, computeAssignments,
  downloadAuditCsv, fmtDue, printAuditReport, type AssignmentView,
} from '@/components/manager/ManagerExtras';
import {
  supabaseAccountsData, type AccountsDataSource, type AssignmentProposal, type BaseRole, type CompanyRole, type CompanyTrade,
  type NewTrainingRequest, type Placement, type TeamMember, type TrainingProfile, type TrainingRequest,
} from '@/lib/accountsData';
import {
  BulkInviteDialog, DailySummaryCard, EmployeeEditPanel, EmployeesTab, EndingSoonCard, GroupAssignDialog, ManagerAssistant,
  PlacementsPanel, RequestTrainingPanel, RolesTradesSettings, TrainingProfilePanel, memberName, type AssistantMsg,
} from '@/components/manager/AccountsPanels';

/**
 * Company Manager Dashboard: landing + /dashboard view for owners/admins of an
 * active company. No learner UI here (no Continue Learning, no my-progress, no
 * upsells). All reads/writes go through ManagerDataSource (RLS-scoped client).
 */

interface Props {
  company: Company;
  currentUserId: string;
  currentRole: 'owner' | 'admin' | 'supervisor';
  onNavigate: (r: Route) => void;
  dataSource?: ManagerDataSource;
  accounts?: AccountsDataSource;
  initialTab?: Tab;
  /** screenshot/demo only: seed the assistant conversation */
  initialAssistant?: AssistantMsg[];
  initialEditUserId?: string;
  /** Small banner text, e.g. "Sample data" in previews. */
  banner?: string;
}

const fmtDate = (d: string | null | undefined) => (d ? new Date(d).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' }) : '—');
const maxDate = (...ds: (string | null | undefined)[]) => {
  const s = ds.filter((d): d is string => !!d).sort();
  return s.length ? s[s.length - 1] : null;
};
const displayName = (m: Pick<RosterMember, 'full_name' | 'email'> | undefined) => m?.full_name || m?.email || 'Unknown';

type ActivityItem = { at: string; userId: string; kind: 'lesson' | 'cert' | 'quiz'; text: string; detail?: string; good?: boolean };

export const SEAT_REQUEST_HREF = '/request?seats=10';

export type Tab = 'overview' | 'employees' | 'clients' | 'training' | 'assistant' | 'settings';

export function ManagerDashboard({ company, currentUserId, currentRole, onNavigate, dataSource = supabaseManagerData, accounts = supabaseAccountsData, banner, initialTab = 'overview', initialAssistant, initialEditUserId }: Props) {
  const canManage = currentRole === 'owner' || currentRole === 'admin';
  const [tab, setTab] = useState<Tab>(initialTab);
  // v3 (migration 20261015120000); undefined = not applied, tabs hide themselves
  const [v3Team, setV3Team] = useState<TeamMember[] | undefined>(undefined);
  const [roles, setRoles] = useState<CompanyRole[]>([]);
  const [trades, setTrades] = useState<CompanyTrade[]>([]);
  const [placements, setPlacements] = useState<Placement[]>([]);
  const [profile, setProfile] = useState<TrainingProfile | null>(null);
  const [requests, setRequests] = useState<TrainingRequest[]>([]);
  const [selfTrade, setSelfTrade] = useState(false);
  const [editFor, setEditFor] = useState<string | null>(initialEditUserId ?? null);
  const [groupAssign, setGroupAssign] = useState(false);
  const [bulkInvite, setBulkInvite] = useState(false);
  const [draft, setDraft] = useState<Partial<NewTrainingRequest> | null>(null);
  const [draftKey, setDraftKey] = useState(0);
  const [assistantSeed, setAssistantSeed] = useState<AssistantMsg[] | undefined>(initialAssistant);
  const [team, setTeam] = useState<TeamSnapshot | null>(null);
  const [seatLimit, setSeatLimit] = useState<number | null | undefined>(company.seat_limit);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [selected, setSelected] = useState<string | null>(null);
  const [showAdd, setShowAdd] = useState(false);
  const [email, setEmail] = useState('');
  const [busy, setBusy] = useState(false);
  const [mutationsOff, setMutationsOff] = useState(false);
  // undefined = migration 20261014180000 not applied yet: hide those panels
  const [assignmentRows, setAssignmentRows] = useState<AssignmentRow[] | undefined>(undefined);
  const [invites, setInvites] = useState<InviteRow[] | undefined>(undefined);
  const [assignFor, setAssignFor] = useState<string | null | false>(false);
  const [lastLink, setLastLink] = useState<{ email: string; url: string; emailed: boolean; reason?: string } | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [t, lim, asg, inv] = await Promise.all([
        dataSource.loadTeam(company.id), dataSource.loadSeatLimit(company.id),
        dataSource.loadAssignments(company.id).catch(() => undefined),
        dataSource.loadInvites(company.id).catch(() => undefined),
      ]);
      setTeam(t);
      setSeatLimit(lim);
      const v3 = await accounts.loadTeam(company.id).catch(() => undefined);
      setV3Team(v3);
      if (v3) {
        const [r, tr, pl, pr, rq, st] = await Promise.all([
          accounts.loadRoles(company.id), accounts.loadTrades(company.id), accounts.loadPlacements(company.id),
          accounts.loadProfile(company.id), canManage ? accounts.loadRequests(company.id) : Promise.resolve([]), accounts.loadSettings(company.id),
        ]);
        setRoles(r ?? []); setTrades(tr ?? []); setPlacements(pl ?? []); setProfile(pr ?? null); setRequests(rq ?? []);
        setSelfTrade(!!st?.allow_employee_self_trade);
      }
      setAssignmentRows(asg);
      setInvites(inv);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load your team');
    } finally {
      setLoading(false);
    }
  }, [company.id, dataSource, accounts, canManage]);

  useEffect(() => { void load(); }, [load]);

  const members = useMemo(() => team?.members ?? [], [team]);
  const pendingInvites = useMemo(() => {
    const now = new Date().toISOString();
    return (invites ?? []).filter((i) => i.status === 'pending' && i.expires_at > now).length;
  }, [invites]);
  // pending invites hold a seat (same rule as the server)
  const seatsUsed = members.length + pendingInvites;
  const hasLimit = typeof seatLimit === 'number';
  const atLimit = hasLimit && seatsUsed >= (seatLimit as number);
  const byId = useMemo(() => new Map(members.map((m) => [m.user_id, m])), [members]);

  const courseRows = useCallback((userId: string) => {
    if (!team) return [];
    return team.rollups
      .filter((r) => r.user_id === userId)
      .map((r) => {
        const total = team.lessonTotals[r.course_id] ?? 0;
        const q = team.quizzes.filter((a) => a.user_id === userId && a.course_id === r.course_id);
        const cert = team.certs.find((c) => c.user_id === userId && c.course_id === r.course_id) ?? null;
        const pct = total > 0 ? Math.min(100, Math.round((r.lessons_completed / total) * 100)) : 0;
        return {
          ...r, total, pct, cert,
          title: team.courseTitles[r.course_id] ?? 'Course',
          bestQuiz: q.length ? Math.max(...q.map((a) => a.score)) : null,
          attempts: q.length,
          completed: !!cert || (total > 0 && r.lessons_completed >= total),
          last: maxDate(r.last_activity, ...q.map((a) => a.created_at), cert?.issued_at),
        };
      })
      .sort((a, b) => (b.last ?? '').localeCompare(a.last ?? ''));
  }, [team]);

  const summaries = useMemo(() => members.map((m) => {
    const rows = courseRows(m.user_id);
    const q = team?.quizzes.filter((x) => x.user_id === m.user_id) ?? [];
    return {
      m,
      courses: rows.length,
      completed: rows.filter((r) => r.completed).length,
      certs: team?.certs.filter((c) => c.user_id === m.user_id).length ?? 0,
      avgQuiz: q.length ? Math.round(q.reduce((n, x) => n + x.score, 0) / q.length) : null,
      last: maxDate(...rows.map((r) => r.last)),
    };
  }), [members, courseRows, team]);

  const totals = useMemo(() => ({
    inProgress: summaries.reduce((n, s) => n + (s.courses - s.completed), 0),
    completed: summaries.reduce((n, s) => n + s.completed, 0),
    certs: team?.certs.length ?? 0,
    avgQuiz: team && team.quizzes.length ? Math.round(team.quizzes.reduce((n, q) => n + q.score, 0) / team.quizzes.length) : null,
  }), [summaries, team]);

  const assignments: AssignmentView[] = useMemo(
    () => (team && assignmentRows ? computeAssignments(assignmentRows, team) : []),
    [team, assignmentRows],
  );
  const overdue = assignments.filter((a) => a.status === 'overdue').length;

  const activity: ActivityItem[] = useMemo(() => {
    if (!team) return [];
    const items: ActivityItem[] = [];
    for (const l of team.lessons) {
      if (l.completed && l.completed_at) items.push({ at: l.completed_at, userId: l.user_id, kind: 'lesson', text: `completed “${team.lessonTitles[l.lesson_id] ?? 'a lesson'}”`, detail: team.courseTitles[l.course_id] });
    }
    for (const c of team.certs) items.push({ at: c.issued_at, userId: c.user_id, kind: 'cert', text: `earned a certificate`, detail: `${team.courseTitles[c.course_id] ?? 'Course'} · ${c.certificate_number}`, good: true });
    for (const q of team.quizzes) items.push({ at: q.created_at, userId: q.user_id, kind: 'quiz', text: `${q.passed ? 'passed' : 'attempted'} a quiz · ${q.score}%`, detail: team.lessonTitles[q.lesson_id] ?? team.courseTitles[q.course_id], good: q.passed });
    return items.filter((i) => byId.has(i.userId)).sort((a, b) => b.at.localeCompare(a.at)).slice(0, 30);
  }, [team, byId]);

  async function addEmployee() {
    if (!email.trim() || atLimit) return;
    setBusy(true); setError(null); setNotice(null);
    const r = await dataSource.addMember(company.id, email.trim());
    setBusy(false);
    if (!r.ok) { setError(r.error); if (r.unavailable) setMutationsOff(true); return; }
    setNotice('Employee added.');
    setEmail(''); setShowAdd(false);
    await load();
  }

  async function removeEmployee(m: RosterMember) {
    if (!window.confirm(`Remove ${displayName(m)} from ${company.name}? They keep their account but lose company access.`)) return;
    setBusy(true); setError(null); setNotice(null);
    const r = await dataSource.removeMember(company.id, m.user_id);
    setBusy(false);
    if (!r.ok) { setError(r.error); if (r.unavailable) setMutationsOff(true); return; }
    setNotice(`${displayName(m)} was removed.`);
    if (selected === m.user_id) setSelected(null);
    await load();
  }

  async function assignCourse(courseId: string, userId: string | null, due: string | null) {
    setBusy(true); setError(null); setNotice(null);
    const r = await dataSource.assignCourse(company.id, courseId, userId, due);
    setBusy(false);
    if (!r.ok) { setError(r.error); return; }
    setAssignFor(false);
    setNotice(`Assigned “${team?.courseTitles[courseId] ?? 'course'}” to ${userId ? displayName(byId.get(userId)) : 'everyone on the team'}${due ? `, due ${fmtDue(due)}` : ''}.`);
    await load();
  }

  async function removeAssignment(a: AssignmentView) {
    if (!window.confirm(`Remove the “${team?.courseTitles[a.course_id] ?? 'course'}” assignment for ${displayName(byId.get(a.user_id))}? Their progress is kept.`)) return;
    setBusy(true); setError(null); setNotice(null);
    const r = await dataSource.removeAssignment(a.id);
    setBusy(false);
    if (!r.ok) { setError(r.error); return; }
    await load();
  }

  async function createInvite(addr: string): Promise<boolean> {
    setBusy(true); setError(null); setNotice(null); setLastLink(null);
    const r = await dataSource.createInvite(company.id, addr);
    if (!r.ok) { setBusy(false); setError(r.error); return false; }
    const url = inviteUrl(r.token);
    const mail = await dataSource.sendInviteEmail(r.id);
    setBusy(false);
    setLastLink({ email: addr.toLowerCase(), url, emailed: mail.sent, reason: mail.sent ? undefined : mail.reason });
    await load();
    return true;
  }

  async function revokeInvite(inv: InviteRow) {
    if (!window.confirm(`Revoke the invite for ${inv.email}? The link stops working and the seat is freed.`)) return;
    setBusy(true); setError(null); setNotice(null);
    const r = await dataSource.revokeInvite(inv.id);
    setBusy(false);
    if (!r.ok) { setError(r.error); return; }
    setNotice(`Invite for ${inv.email} revoked.`);
    if (lastLink?.email === inv.email) setLastLink(null);
    await load();
  }

  function exportCsv() {
    if (!team) return;
    downloadAuditCsv(company.name, buildAuditRows(team, assignments));
  }
  function exportPrint() {
    if (!team) return;
    if (!printAuditReport(company.name, buildAuditRows(team, assignments))) setError('Allow pop-ups for this site to open the printable report.');
  }

  const canRemove = (m: RosterMember) => canManage && m.user_id !== currentUserId && m.role !== 'owner';

  async function run(fn: () => Promise<{ ok: boolean; error?: string }>, okMsg?: string): Promise<boolean> {
    setBusy(true); setError(null); setNotice(null);
    const r = await fn();
    setBusy(false);
    if (!r.ok) { setError((r as { error?: string }).error ?? 'Something went wrong.'); return false; }
    if (okMsg) setNotice(okMsg);
    await load();
    return true;
  }
  async function confirmProposals(ps: AssignmentProposal[]) {
    for (const p of ps) {
      const r = await dataSource.assignCourse(company.id, p.course_id, p.user_id, p.due_date);
      if (!r.ok) { setError(r.error); await load(); return false; }
    }
    setNotice(`Assigned ${ps.length} course${ps.length === 1 ? '' : 's'} from the Manager Assistant.`);
    await load();
    return true;
  }
  async function bulkInviteRows(rows: { email: string; trade: string | null; role: 'supervisor' | 'employee' | null }[]) {
    const out: { email: string; ok: boolean; error?: string }[] = [];
    for (const row of rows) {
      const r = await dataSource.createInvite(company.id, row.email);
      if (!r.ok) { out.push({ email: row.email, ok: false, error: r.error }); continue; }
      if (row.trade || row.role) await accounts.setInviteExtras(r.id, row.trade, row.role);
      void dataSource.sendInviteEmail(r.id);
      out.push({ email: row.email, ok: true });
    }
    await load();
    return out;
  }
  const progressById = useMemo(() => Object.fromEntries(summaries.map((s) => [s.m.user_id, { courses: s.courses, completed: s.completed }])), [summaries]);
  const editMember = editFor && v3Team ? v3Team.find((m) => m.user_id === editFor) ?? null : null;
  const tabs: [Tab, string][] = v3Team
    ? ([['overview', 'Overview'], ['employees', 'Employees'], ['clients', 'Clients & sites'], ...(canManage ? [['training', 'Custom training']] : []), ['assistant', 'Manager Assistant'], ...(canManage ? [['settings', 'Roles & trades']] : [])] as [Tab, string][])
    : [];
  const sel = selected ? summaries.find((s) => s.m.user_id === selected) ?? null : null;

  return (
    <div className="pt-20 pb-16 min-h-screen">
      <div className="max-w-7xl mx-auto px-4 sm:px-6">
        {banner && (
          <div className="mb-4 rounded-lg border border-accent-500/40 bg-accent-500/10 px-3 py-2 text-xs font-semibold text-accent-300">{banner}</div>
        )}

        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center gap-4 mb-6">
          <div className="w-14 h-14 rounded-xl border border-steel-700/60 bg-navy-950/60 flex items-center justify-center overflow-hidden shrink-0">
            {company.logo_url ? <img src={company.logo_url} alt="" className="w-full h-full object-contain p-1.5" /> : <Building2 className="w-6 h-6 text-steel-500" />}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-[11px] font-semibold uppercase tracking-wider text-accent-400">Company Manager Dashboard</p>
            <h1 className="font-display text-2xl sm:text-3xl font-bold text-white truncate">{company.name}</h1>
            <p className="text-sm text-steel-400">Signed in as {currentRole} · you can see your own team only</p>
          </div>
          <div className="flex flex-wrap gap-2 self-start sm:self-auto">
            <button onClick={exportCsv} disabled={!team} className="btn-secondary flex items-center gap-2 text-sm" title="Employees, completions, quiz scores, certificates and assignments as CSV">
              <Download className="w-4 h-4" /> Export audit CSV
            </button>
            <button onClick={exportPrint} disabled={!team} className="btn-ghost flex items-center gap-2 text-sm" title="Printable report (save as PDF)">
              <Printer className="w-4 h-4" /> Print / PDF
            </button>
            <button onClick={() => onNavigate({ name: 'catalog' })} className="btn-secondary flex items-center gap-2 text-sm">
              <Library className="w-4 h-4" /> What your team can take
            </button>
          </div>
        </div>

        {error && (
          <div className="mb-4 flex items-start gap-2 rounded-lg border border-error-500/40 bg-error-500/10 px-3 py-2 text-sm text-error-400">
            <AlertCircle className="w-4 h-4 mt-0.5 shrink-0" /> <span className="flex-1">{error}</span>
            <button onClick={() => setError(null)} aria-label="Dismiss"><X className="w-4 h-4" /></button>
          </div>
        )}
        {notice && (
          <div className="mb-4 flex items-center gap-2 rounded-lg border border-success-500/40 bg-success-500/10 px-3 py-2 text-sm text-success-400">
            <CheckCircle2 className="w-4 h-4" /> {notice}
          </div>
        )}

        {tabs.length > 0 && (
          <div className="mb-5 -mx-1 flex gap-1 overflow-x-auto border-b border-steel-700/60" role="tablist">
            {tabs.map(([k, label]) => (
              <button key={k} role="tab" aria-selected={tab === k} onClick={() => { setTab(k); setSelected(null); }}
                className={`px-3 py-2 text-sm font-semibold whitespace-nowrap border-b-2 -mb-px ${tab === k ? 'border-accent-500 text-white' : 'border-transparent text-steel-400 hover:text-white'}`}>{label}</button>
            ))}
          </div>
        )}

        {loading && !team ? (
          <div className="card p-12 flex justify-center"><Loader2 className="w-6 h-6 text-accent-400 animate-spin" /></div>
        ) : sel && v3Team && tab !== 'overview' ? (
          <EmployeeDetail s={sel} rows={courseRows(sel.m.user_id)} team={team as TeamSnapshot} onBack={() => setSelected(null)}
            assignments={assignmentRows ? assignments.filter((a) => a.user_id === sel.m.user_id) : undefined} onAssign={() => setAssignFor(sel.m.user_id)} />
        ) : v3Team && tab === 'employees' ? (
          <EmployeesTab team={v3Team} placements={placements} roles={roles} currentUserId={currentUserId} canManage={canManage && !mutationsOff}
            progress={progressById} busy={busy} onEdit={setEditFor}
            onGroupAssign={assignmentRows ? () => setGroupAssign(true) : undefined}
            onBulkInvite={canManage && invites ? () => setBulkInvite(true) : undefined}
            onRemove={(m) => { const r = members.find((x) => x.user_id === m.user_id); if (r) void removeEmployee(r); }} />
        ) : v3Team && tab === 'clients' ? (
          <PlacementsPanel placements={placements} team={v3Team} canEdit={canManage}
            onSave={(p) => run(() => accounts.savePlacement({ ...p, company_id: company.id }), 'Client site saved.')}
            onDelete={(p) => { if (window.confirm(`Delete ${p.client_name}? Employees placed there keep their contract details.`)) void run(() => accounts.deletePlacement(p.id)); }} />
        ) : v3Team && tab === 'training' && canManage ? (
          <div className="grid grid-cols-1 xl:grid-cols-[1fr_24rem] gap-6">
            <RequestTrainingPanel key={draftKey} companyId={company.id} profile={profile} placements={placements} requests={requests} initialDraft={draft}
              onSubmit={async (r, files) => {
                setBusy(true); setError(null); setNotice(null);
                const res = await accounts.submitRequest(r, files);
                setBusy(false);
                if (!res.ok) { setError(res.error); return false; }
                setNotice(`Request sent to ForgeLine.${res.emailed ? ' Kris was emailed.' : ''}${res.uploadErrors ? ` ${res.uploadErrors} attachment(s) could not be uploaded; email them to kris@forgelineacademy.com.` : ''}`);
                setDraft(null); await load(); return true;
              }} />
            <TrainingProfilePanel profile={profile} companyId={company.id} canEdit={canManage}
              onSave={(p) => run(() => accounts.saveProfile(p), 'Training profile saved.')} />
          </div>
        ) : v3Team && tab === 'assistant' && team ? (
          <ManagerAssistant ds={accounts} companyId={company.id} team={v3Team} courseTitles={team.courseTitles} initial={assistantSeed}
            onConfirmAssignments={confirmProposals}
            onUseDraft={(d) => { setDraft({ ...d, source: 'assistant' }); setDraftKey((k) => k + 1); setTab('training'); }} />
        ) : v3Team && tab === 'settings' && canManage ? (
          <RolesTradesSettings roles={roles} trades={trades} allowSelfTrade={selfTrade}
            onAddRole={(n, b) => void run(() => accounts.addRole(company.id, n, b), `Role “${n}” added.`)}
            onDeleteRole={(r) => void run(() => accounts.deleteRole(r.id))}
            onAddTrade={(n) => void run(() => accounts.addTrade(company.id, n), `Trade “${n}” added.`)}
            onDeleteTrade={(t) => void run(() => accounts.deleteTrade(t.id))}
            onSelfTrade={(v) => void run(() => accounts.setSelfTrade(company.id, v))} />
        ) : (
          <>
            {/* Stats */}
            <div className={`grid grid-cols-2 ${assignmentRows ? 'lg:grid-cols-6' : 'lg:grid-cols-5'} gap-3 mb-6`}>
              <Stat icon={<Users className="w-4 h-4" />} label="Seats used" value={`${seatsUsed} of ${hasLimit ? seatLimit : 'Unlimited'}`} warn={atLimit} />
              <Stat icon={<BookOpen className="w-4 h-4" />} label="Courses in progress" value={String(totals.inProgress)} />
              <Stat icon={<CheckCircle2 className="w-4 h-4" />} label="Courses completed" value={String(totals.completed)} />
              <Stat icon={<Award className="w-4 h-4" />} label="Certificates" value={String(totals.certs)} />
              <Stat icon={<ClipboardCheck className="w-4 h-4" />} label="Avg quiz score" value={totals.avgQuiz != null ? `${totals.avgQuiz}%` : '—'} />
              {assignmentRows && <Stat icon={<Timer className="w-4 h-4" />} label="Overdue" value={String(overdue)} warn={overdue > 0} />}
            </div>
            {assignmentRows && <OverdueBanner count={overdue} onShow={() => { setSelected(null); setTimeout(() => document.getElementById('assignments')?.scrollIntoView({ behavior: 'smooth' }), 0); }} />}

            <div className="grid grid-cols-1 lg:grid-cols-[1fr_22rem] gap-6">
              <div className="min-w-0">
                {sel ? (
                  <EmployeeDetail
                    s={sel}
                    rows={courseRows(sel.m.user_id)}
                    team={team as TeamSnapshot}
                    onBack={() => setSelected(null)}
                    assignments={assignmentRows ? assignments.filter((a) => a.user_id === sel.m.user_id) : undefined}
                    onAssign={() => setAssignFor(sel.m.user_id)}
                  />
                ) : v3Team ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                    <DailySummaryCard ds={accounts} companyId={company.id}
                      onProposals={(p, text) => { setAssistantSeed([{ role: 'user', content: 'Daily summary' }, { role: 'assistant', content: text, proposals: p }]); }} />
                    <EndingSoonCard team={v3Team} placements={placements} onOpen={setEditFor} />
                  </div>
                ) : (
                  <div className="card p-4 sm:p-5">
                    <div className="flex flex-wrap items-center gap-3 mb-4">
                      <h2 className="font-display text-lg font-semibold text-white flex items-center gap-2"><Users className="w-5 h-5 text-accent-400" /> Employees</h2>
                      <span className={`text-xs font-semibold px-2 py-0.5 rounded-full border ${atLimit ? 'border-warning-500/50 text-warning-400 bg-warning-500/10' : 'border-steel-600 text-steel-300'}`}>
                        Seats used {seatsUsed} of {hasLimit ? seatLimit : 'Unlimited'}{pendingInvites > 0 ? ` · ${pendingInvites} pending` : ''}
                      </span>
                      <div className="flex-1" />
                      <button
                        onClick={() => setShowAdd((v) => !v)}
                        disabled={atLimit || mutationsOff}
                        className="btn-primary flex items-center gap-1.5 text-sm disabled:opacity-40 disabled:cursor-not-allowed"
                      >
                        <UserPlus className="w-4 h-4" /> Add employee
                      </button>
                    </div>

                    {atLimit && (
                      <div className="mb-4 rounded-lg border border-warning-500/40 bg-warning-500/10 px-3 py-2 text-sm text-warning-400">
                        You've reached your seat limit, <a href={SEAT_REQUEST_HREF} className="underline font-semibold text-accent-300 hover:text-accent-200">contact ForgeLine for more seats</a>.
                      </div>
                    )}

                    {showAdd && !atLimit && !mutationsOff && (
                      <div className="mb-4 rounded-lg border border-steel-700/60 bg-navy-950/40 p-3">
                        <div className="flex flex-col sm:flex-row gap-2">
                          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="employee@company.com" className="input flex-1" autoFocus
                            onKeyDown={(e) => { if (e.key === 'Enter') void addEmployee(); }} />
                          <button onClick={() => void addEmployee()} disabled={busy || !email.trim()} className="btn-primary text-sm px-4">
                            {busy ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Add'}
                          </button>
                          <button onClick={() => { setShowAdd(false); setEmail(''); }} className="btn-ghost text-sm">Cancel</button>
                        </div>
                        <p className="text-[11px] text-steel-500 mt-2">They need a ForgeLine account with this email first. New employees join as members.</p>
                      </div>
                    )}

                    {summaries.length === 0 ? (
                      <p className="text-sm text-steel-500 py-8 text-center">No employees yet.</p>
                    ) : (
                      <div className="space-y-1.5">
                        <div className="hidden md:grid grid-cols-[1fr_repeat(4,5rem)_2rem_1rem] gap-2 px-3 pb-1 text-[10px] font-semibold text-steel-500 uppercase tracking-wider">
                          <div>Employee</div><div className="text-center">Courses</div><div className="text-center">Done</div>
                          <div className="text-center">Avg quiz</div><div className="text-center">Last active</div><div /><div />
                        </div>
                        {summaries.map((s) => (
                          <div key={s.m.user_id} className="grid grid-cols-[1fr_auto_auto] md:grid-cols-[1fr_repeat(4,5rem)_2rem_1rem] gap-2 items-center p-3 rounded-lg border border-steel-700/40 bg-navy-950/30 hover:bg-navy-800/40 transition-colors">
                            <button onClick={() => setSelected(s.m.user_id)} className="min-w-0 text-left">
                              <div className="text-sm font-medium text-white truncate">{displayName(s.m)}</div>
                              <div className="text-[11px] text-steel-500 truncate">
                                {s.m.full_name && s.m.email ? `${s.m.email} · ` : ''}{s.m.role}{s.m.user_id === currentUserId ? ' · you' : ''}
                                <span className="md:hidden"> · {s.completed}/{s.courses} courses · {s.certs} certs</span>
                              </div>
                            </button>
                            <div className="hidden md:block text-center text-sm font-bold text-white">{s.courses}</div>
                            <div className="hidden md:block text-center text-sm font-bold text-white">{s.completed}</div>
                            <div className="hidden md:block text-center text-sm text-steel-300">{s.avgQuiz != null ? `${s.avgQuiz}%` : '—'}</div>
                            <div className="hidden md:block text-center text-xs text-steel-400">{fmtDate(s.last)}</div>
                            {canRemove(s.m) && !mutationsOff ? (
                              <button onClick={() => void removeEmployee(s.m)} disabled={busy} title="Remove from company" aria-label={`Remove ${displayName(s.m)}`}
                                className="p-1.5 rounded-md text-steel-500 hover:text-error-400 hover:bg-error-500/10 justify-self-center">
                                <Trash2 className="w-4 h-4" />
                              </button>
                            ) : <span />}
                            <button onClick={() => setSelected(s.m.user_id)} aria-label="Open details"><ChevronRight className="w-4 h-4 text-steel-500" /></button>
                          </div>
                        ))}
                      </div>
                    )}
                    {mutationsOff && (
                      <p className="mt-3 text-[11px] text-steel-500">Roster changes are temporarily unavailable here. Contact ForgeLine to add or remove employees.</p>
                    )}
                  </div>
                )}
                {!sel && assignmentRows && team && (
                  <div id="assignments">
                    <AssignmentsPanel items={assignments} byId={byId} courseTitles={team.courseTitles} busy={busy}
                      onAssign={() => setAssignFor(null)} onRemove={(a) => void removeAssignment(a)} onSelect={setSelected} />
                  </div>
                )}
                {!sel && invites && canManage && (
                  <InvitesPanel invites={invites} busy={busy} lastLink={lastLink}
                    seatsLeft={hasLimit ? (seatLimit as number) - seatsUsed : null}
                    onInvite={createInvite} onRevoke={(i) => void revokeInvite(i)} />
                )}
              </div>

              {/* Activity feed */}
              <div className="card p-4 sm:p-5 h-fit">
                <h2 className="font-display text-lg font-semibold text-white flex items-center gap-2 mb-3"><Activity className="w-5 h-5 text-accent-400" /> Recent activity</h2>
                {activity.length === 0 ? (
                  <p className="text-sm text-steel-500 py-6 text-center">No activity yet.</p>
                ) : (
                  <ol className="space-y-3">
                    {activity.map((a, i) => (
                      <li key={i} className="flex gap-3">
                        <div className={`mt-0.5 w-7 h-7 rounded-full flex items-center justify-center shrink-0 ${a.kind === 'cert' ? 'bg-premium-500/15 text-premium-400' : a.good ? 'bg-success-500/15 text-success-400' : 'bg-navy-800 text-steel-400'}`}>
                          {a.kind === 'cert' ? <Award className="w-3.5 h-3.5" /> : a.kind === 'quiz' ? <ClipboardCheck className="w-3.5 h-3.5" /> : <CheckCircle2 className="w-3.5 h-3.5" />}
                        </div>
                        <div className="min-w-0">
                          <p className="text-sm text-steel-200"><button className="font-semibold text-white hover:text-accent-300" onClick={() => setSelected(a.userId)}>{displayName(byId.get(a.userId))}</button> {a.text}</p>
                          {a.detail && <p className="text-[11px] text-steel-500 truncate">{a.detail}</p>}
                          <p className="text-[11px] text-steel-600">{fmtDate(a.at)}</p>
                        </div>
                      </li>
                    ))}
                  </ol>
                )}
              </div>
            </div>
          </>
        )}
      </div>
      {editMember && v3Team && (
        <EmployeeEditPanel member={editMember} team={v3Team} placements={placements} roles={roles} trades={trades}
          currentUserId={currentUserId} callerRole={currentRole as BaseRole} onClose={() => setEditFor(null)}
          onViewProgress={() => { setSelected(editMember.user_id); setEditFor(null); if (tab === 'overview') setTab('employees'); }}
          onSaveRole={(r, c) => run(() => accounts.setRole(company.id, editMember.user_id, r, c), `Role updated for ${memberName(editMember)}.`)}
          onSaveDetails={(d) => run(() => accounts.saveDetails(company.id, editMember.user_id, d), `Saved ${memberName(editMember)}.`)} />
      )}
      {groupAssign && team && (
        <GroupAssignDialog courseTitles={team.courseTitles} trades={trades.map((t) => t.name)} roles={roles} busy={busy}
          onCancel={() => setGroupAssign(false)}
          onAssign={async (c, tr, ro, due) => {
            setBusy(true); setError(null);
            const r = await accounts.assignToGroup(company.id, c, tr, ro, due);
            setBusy(false);
            if (!r.ok) { setError(r.error); return; }
            setGroupAssign(false);
            setNotice(`Assigned “${team.courseTitles[c] ?? 'course'}” to ${r.assigned} ${[tr, ro].filter(Boolean).join(' / ')} employee${r.assigned === 1 ? '' : 's'}.`);
            await load();
          }} />
      )}
      {bulkInvite && (
        <BulkInviteDialog seatsLeft={hasLimit ? Math.max(0, (seatLimit as number) - seatsUsed) : null} onCancel={() => setBulkInvite(false)} onInvite={bulkInviteRows} />
      )}
      {assignFor !== false && team && (
        <AssignDialog members={members} courseTitles={team.courseTitles} busy={busy} initialUserId={assignFor}
          onCancel={() => setAssignFor(false)} onAssign={(c, u, d) => void assignCourse(c, u, d)} />
      )}
    </div>
  );
}

function Stat({ icon, label, value, warn }: { icon: React.ReactNode; label: string; value: string; warn?: boolean }) {
  return (
    <div className={`card p-3 sm:p-4 ${warn ? 'border-warning-500/50' : ''}`}>
      <div className="flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-wider text-steel-400 mb-1">{icon}{label}</div>
      <div className={`text-xl sm:text-2xl font-bold ${warn ? 'text-warning-400' : 'text-white'}`}>{value}</div>
    </div>
  );
}

interface DetailRow {
  course_id: string; title: string; pct: number; total: number; lessons_completed: number;
  bestQuiz: number | null; attempts: number; completed: boolean; last: string | null;
  cert: { certificate_number: string; issued_at: string } | null;
}

function EmployeeDetail({ s, rows, team, onBack, assignments, onAssign }: {
  s: { m: RosterMember; courses: number; completed: number; certs: number; avgQuiz: number | null };
  rows: DetailRow[];
  team: TeamSnapshot;
  onBack: () => void;
  assignments?: AssignmentView[];
  onAssign: () => void;
}) {
  const quizzes = team.quizzes.filter((q) => q.user_id === s.m.user_id).sort((a, b) => b.created_at.localeCompare(a.created_at));
  const certs = team.certs.filter((c) => c.user_id === s.m.user_id).sort((a, b) => b.issued_at.localeCompare(a.issued_at));
  return (
    <div className="card p-4 sm:p-5">
      <button onClick={onBack} className="flex items-center gap-1.5 text-sm text-steel-400 hover:text-white mb-3"><ArrowLeft className="w-4 h-4" /> All employees</button>
      <h2 className="font-display text-xl font-semibold text-white">{displayName(s.m)}</h2>
      <p className="text-xs text-steel-500 mb-4">{s.m.full_name && s.m.email ? `${s.m.email} · ` : ''}{s.m.role}</p>
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 mb-5">
        <Mini label="Courses" value={s.courses} /><Mini label="Completed" value={s.completed} />
        <Mini label="Certificates" value={s.certs} /><Mini label="Avg quiz" value={s.avgQuiz != null ? `${s.avgQuiz}%` : '—'} />
      </div>

      {assignments && (
        <>
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-semibold text-white flex items-center gap-2"><ClipboardList className="w-4 h-4 text-accent-400" /> Assigned courses</h3>
            <button onClick={onAssign} className="text-xs text-accent-300 hover:text-accent-200 font-semibold">+ Assign course</button>
          </div>
          {assignments.length === 0 ? <p className="text-sm text-steel-500 mb-5">Nothing assigned.</p> : (
            <ul className="mb-5 divide-y divide-steel-700/40 rounded-lg border border-steel-700/40">
              {assignments.map((a) => (
                <li key={a.id} className="flex flex-wrap items-center justify-between gap-2 px-3 py-2 text-sm">
                  <span className="text-white">{team.courseTitles[a.course_id] ?? 'Course'}</span>
                  <span className="flex items-center gap-2 text-[11px] text-steel-400">{a.due_date ? `Due ${fmtDue(a.due_date)}` : 'No due date'} <StatusPill status={a.status} /></span>
                </li>
              ))}
            </ul>
          )}
        </>
      )}

      <h3 className="text-sm font-semibold text-white mb-2 flex items-center gap-2"><BarChart3 className="w-4 h-4 text-accent-400" /> Course progress</h3>
      {rows.length === 0 ? <p className="text-sm text-steel-500 mb-5">Hasn't started a course yet.</p> : (
        <div className="space-y-2 mb-5">
          {rows.map((r) => (
            <div key={r.course_id} className="rounded-lg border border-steel-700/40 bg-navy-950/30 p-3">
              <div className="flex items-start justify-between gap-2">
                <div className="text-sm font-medium text-white">{r.title}</div>
                {r.completed && <span className="text-[10px] font-semibold uppercase px-1.5 py-0.5 rounded bg-success-500/15 text-success-400 shrink-0">Completed</span>}
              </div>
              <div className="mt-2 h-1.5 rounded-full bg-navy-800 overflow-hidden"><div className="h-full bg-accent-500" style={{ width: `${r.pct}%` }} /></div>
              <div className="mt-1.5 flex flex-wrap gap-x-4 gap-y-1 text-[11px] text-steel-400">
                <span>{r.lessons_completed}/{r.total || '?'} lessons · {r.pct}%</span>
                <span>Best quiz {r.bestQuiz != null ? `${r.bestQuiz}%` : '—'} ({r.attempts} attempts)</span>
                <span>Last active {fmtDate(r.last)}</span>
              </div>
            </div>
          ))}
        </div>
      )}

      <h3 className="text-sm font-semibold text-white mb-2 flex items-center gap-2"><Award className="w-4 h-4 text-premium-400" /> Certificates</h3>
      {certs.length === 0 ? <p className="text-sm text-steel-500 mb-5">No certificates yet.</p> : (
        <ul className="mb-5 divide-y divide-steel-700/40 rounded-lg border border-steel-700/40">
          {certs.map((c) => (
            <li key={c.certificate_number} className="flex flex-wrap items-center justify-between gap-2 px-3 py-2 text-sm">
              <span className="text-white">{team.courseTitles[c.course_id] ?? 'Course'}</span>
              <span className="text-[11px] text-steel-400 font-mono">{c.certificate_number} · {fmtDate(c.issued_at)}</span>
            </li>
          ))}
        </ul>
      )}

      <h3 className="text-sm font-semibold text-white mb-2 flex items-center gap-2"><ClipboardCheck className="w-4 h-4 text-accent-400" /> Assessment & quiz results</h3>
      {quizzes.length === 0 ? <p className="text-sm text-steel-500">No quiz attempts yet.</p> : (
        <ul className="divide-y divide-steel-700/40 rounded-lg border border-steel-700/40">
          {quizzes.slice(0, 50).map((q, i) => (
            <li key={i} className="flex flex-wrap items-center justify-between gap-2 px-3 py-2 text-sm">
              <span className="text-steel-200 min-w-0 truncate">{team.lessonTitles[q.lesson_id] ?? 'Quiz'} <span className="text-steel-500 text-[11px]">· {team.courseTitles[q.course_id] ?? ''}</span></span>
              <span className={`text-xs font-semibold ${q.passed ? 'text-success-400' : 'text-error-400'}`}>{q.score}% {q.passed ? 'passed' : 'not passed'} <span className="text-steel-500 font-normal">· {fmtDate(q.created_at)}</span></span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

function Mini({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="rounded-lg border border-steel-700/40 bg-navy-950/30 p-2.5">
      <div className="text-[10px] uppercase tracking-wider text-steel-500 font-semibold">{label}</div>
      <div className="text-lg font-bold text-white">{value}</div>
    </div>
  );
}
