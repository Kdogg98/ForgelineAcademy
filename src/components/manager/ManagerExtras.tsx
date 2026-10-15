import { Modal } from '@/components/ui/Modal';
import { useMemo, useState } from 'react';
import { AlertTriangle, CalendarClock, Check, ClipboardList, Copy, Loader2, Mail, Trash2 } from 'lucide-react';
import type { AssignmentRow, InviteRow, RosterMember, TeamSnapshot } from '@/lib/managerData';
import { inviteUrl } from '@/lib/managerData';

/* ----------------------------------------------------------------------------
 * Assignment status (done = existing completion data: certificate, or every
 * lesson of the course completed).
 * -------------------------------------------------------------------------- */
export type AssignmentStatus = 'not_started' | 'in_progress' | 'done' | 'overdue';

export const STATUS_LABEL: Record<AssignmentStatus, string> = {
  not_started: 'Not started', in_progress: 'In progress', done: 'Done', overdue: 'Overdue',
};
const STATUS_CLASS: Record<AssignmentStatus, string> = {
  not_started: 'bg-navy-800 text-steel-300 border-steel-600',
  in_progress: 'bg-accent-500/10 text-accent-300 border-accent-500/40',
  done: 'bg-success-500/10 text-success-400 border-success-500/40',
  overdue: 'bg-error-500/10 text-error-400 border-error-500/50',
};

/** Local calendar date YYYY-MM-DD (due dates are plain dates). */
export const todayISO = (now = new Date()) =>
  `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;

export interface AssignmentView extends AssignmentRow {
  status: AssignmentStatus;
  completedAt: string | null;
  lessonsCompleted: number;
  total: number;
}

export function computeAssignments(rows: AssignmentRow[], team: TeamSnapshot, today = todayISO()): AssignmentView[] {
  return rows.map((a) => {
    const total = team.lessonTotals[a.course_id] ?? 0;
    const roll = team.rollups.find((r) => r.user_id === a.user_id && r.course_id === a.course_id);
    const cert = team.certs.find((c) => c.user_id === a.user_id && c.course_id === a.course_id);
    const lessonsCompleted = roll?.lessons_completed ?? 0;
    const done = !!cert || (total > 0 && lessonsCompleted >= total);
    let completedAt: string | null = cert?.issued_at ?? null;
    if (done && !completedAt) {
      const ds = team.lessons.filter((l) => l.user_id === a.user_id && l.course_id === a.course_id && l.completed_at).map((l) => l.completed_at as string).sort();
      completedAt = ds.length ? ds[ds.length - 1] : null;
    }
    let status: AssignmentStatus;
    if (done) status = 'done';
    else if (a.due_date && a.due_date < today) status = 'overdue';
    else if ((roll?.lessons_started ?? 0) > 0 || lessonsCompleted > 0) status = 'in_progress';
    else status = 'not_started';
    return { ...a, status, completedAt, lessonsCompleted, total };
  });
}

export const fmtDue = (d: string | null) =>
  d ? new Date(`${d}T12:00:00`).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' }) : 'No due date';

export function StatusPill({ status }: { status: AssignmentStatus }) {
  return <span className={`text-[10px] font-semibold uppercase tracking-wide px-1.5 py-0.5 rounded border ${STATUS_CLASS[status]}`}>{STATUS_LABEL[status]}</span>;
}

const nameOf = (m: Pick<RosterMember, 'full_name' | 'email'> | undefined) => m?.full_name || m?.email || 'Former employee';

/* ----------------------------------------------------------------------------
 * Assign dialog
 * -------------------------------------------------------------------------- */
export function AssignDialog({ members, courseTitles, busy, onCancel, onAssign, initialUserId }: {
  members: RosterMember[];
  courseTitles: Record<string, string>;
  busy: boolean;
  onCancel: () => void;
  onAssign: (courseId: string, userId: string | null, due: string | null) => void;
  initialUserId?: string | null;
}) {
  const courses = useMemo(() => Object.entries(courseTitles).sort((a, b) => a[1].localeCompare(b[1])), [courseTitles]);
  const [courseId, setCourseId] = useState('');
  const [who, setWho] = useState<string>(initialUserId ?? 'all');
  const [due, setDue] = useState('');
  const count = who === 'all' ? members.length : 1;
  return (
    <Modal title="Assign a course" icon={<ClipboardList className="w-5 h-5 text-accent-400" />} onClose={onCancel}
      footer={<>
        <button onClick={onCancel} className="btn-ghost text-sm">Cancel</button>
        <button disabled={!courseId || busy} onClick={() => onAssign(courseId, who === 'all' ? null : who, due || null)} className="btn-primary text-sm px-4 disabled:opacity-40">
          {busy ? <Loader2 className="w-4 h-4 animate-spin" /> : `Assign to ${count} ${count === 1 ? 'person' : 'people'}`}
        </button>
      </>}>
      <label className="block text-xs font-semibold text-steel-300 mb-1" htmlFor="assign-course">Course</label>
      <select id="assign-course" name="course" className="input w-full mb-3" value={courseId} onChange={(e) => setCourseId(e.target.value)}>
        <option value="">Choose a course…</option>
        {courses.map(([id, t]) => <option key={id} value={id}>{t}</option>)}
      </select>
      <label className="block text-xs font-semibold text-steel-300 mb-1" htmlFor="assign-who">Assign to</label>
      <select id="assign-who" name="assignee" className="input w-full mb-3" value={who} onChange={(e) => setWho(e.target.value)}>
        <option value="all">Everyone on the team ({members.length})</option>
        {members.map((m) => <option key={m.user_id} value={m.user_id}>{nameOf(m)}</option>)}
      </select>
      <label className="block text-xs font-semibold text-steel-300 mb-1" htmlFor="assign-due">Due date <span className="font-normal text-steel-500">(optional)</span></label>
      <input id="assign-due" name="due" type="date" className="input w-full mb-4" value={due} min={todayISO()} onChange={(e) => setDue(e.target.value)} />
      <p className="text-[11px] text-steel-500">Assigning a course someone already has updates its due date. It counts as done when they finish every lesson or earn the certificate.</p>
    </Modal>
  );
}

/* ----------------------------------------------------------------------------
 * Assignments panel
 * -------------------------------------------------------------------------- */
export function AssignmentsPanel({ items, byId, courseTitles, onAssign, onRemove, onSelect, busy }: {
  items: AssignmentView[];
  byId: Map<string, RosterMember>;
  courseTitles: Record<string, string>;
  onAssign: () => void;
  onRemove: (a: AssignmentView) => void;
  onSelect: (userId: string) => void;
  busy: boolean;
}) {
  const [filter, setFilter] = useState<'all' | AssignmentStatus>('all');
  const order: Record<AssignmentStatus, number> = { overdue: 0, in_progress: 1, not_started: 2, done: 3 };
  const shown = items
    .filter((a) => filter === 'all' || a.status === filter)
    .sort((a, b) => order[a.status] - order[b.status] || (a.due_date ?? '9999').localeCompare(b.due_date ?? '9999'));
  const counts = items.reduce((m, a) => ({ ...m, [a.status]: (m[a.status] ?? 0) + 1 }), {} as Record<string, number>);
  return (
    <div className="card p-4 sm:p-5 mt-6">
      <div className="flex flex-wrap items-center gap-3 mb-3">
        <h2 className="font-display text-lg font-semibold text-white flex items-center gap-2"><CalendarClock className="w-5 h-5 text-accent-400" /> Assigned courses</h2>
        <div className="flex-1" />
        <button onClick={onAssign} className="btn-primary flex items-center gap-1.5 text-sm"><ClipboardList className="w-4 h-4" /> Assign course</button>
      </div>
      <div className="flex flex-wrap gap-1.5 mb-3">
        {(['all', 'overdue', 'in_progress', 'not_started', 'done'] as const).map((f) => (
          <button key={f} onClick={() => setFilter(f)}
            className={`text-xs px-2.5 py-1 rounded-full border ${filter === f ? 'border-accent-500 text-white bg-accent-500/15' : 'border-steel-700 text-steel-400 hover:text-white'}`}>
            {f === 'all' ? `All ${items.length}` : `${STATUS_LABEL[f]} ${counts[f] ?? 0}`}
          </button>
        ))}
      </div>
      {shown.length === 0 ? (
        <p className="text-sm text-steel-500 py-6 text-center">{items.length === 0 ? 'No courses assigned yet. Assign one to an employee or the whole team.' : 'Nothing in this filter.'}</p>
      ) : (
        <ul className="space-y-1.5">
          {shown.map((a) => (
            <li key={a.id} className={`grid grid-cols-[1fr_auto] sm:grid-cols-[1fr_9rem_7rem_2rem] gap-x-3 gap-y-1 items-center p-3 rounded-lg border ${a.status === 'overdue' ? 'border-error-500/40 bg-error-500/5' : 'border-steel-700/40 bg-navy-950/30'}`}>
              <div className="min-w-0">
                <div className="text-sm font-medium text-white truncate">{courseTitles[a.course_id] ?? 'Course'}</div>
                <button onClick={() => onSelect(a.user_id)} className="text-[11px] text-steel-400 hover:text-accent-300 truncate">
                  {nameOf(byId.get(a.user_id))} · {a.lessonsCompleted}/{a.total || '?'} lessons
                </button>
              </div>
              <div className={`text-xs sm:text-right ${a.status === 'overdue' ? 'text-error-400 font-semibold' : 'text-steel-400'} order-3 sm:order-none`}>
                {a.status === 'done' && a.completedAt ? `Done ${fmtDue(a.completedAt.slice(0, 10))}` : a.due_date ? `Due ${fmtDue(a.due_date)}` : 'No due date'}
              </div>
              <div className="justify-self-end"><StatusPill status={a.status} /></div>
              <button onClick={() => onRemove(a)} disabled={busy} aria-label="Remove assignment" title="Remove assignment"
                className="hidden sm:block p-1.5 rounded-md text-steel-500 hover:text-error-400 hover:bg-error-500/10 justify-self-center"><Trash2 className="w-4 h-4" /></button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

/* ----------------------------------------------------------------------------
 * Invites panel
 * -------------------------------------------------------------------------- */
export function InvitesPanel({ invites, seatsLeft, busy, onInvite, onRevoke, lastLink }: {
  invites: InviteRow[];
  seatsLeft: number | null;
  busy: boolean;
  onInvite: (email: string) => Promise<boolean>;
  onRevoke: (inv: InviteRow) => void;
  lastLink: { email: string; url: string; emailed: boolean; reason?: string } | null;
}) {
  const [email, setEmail] = useState('');
  const [copied, setCopied] = useState<string | null>(null);
  const now = new Date().toISOString();
  const pending = invites.filter((i) => i.status === 'pending' && i.expires_at > now);
  const full = seatsLeft !== null && seatsLeft <= 0;
  async function copy(url: string) {
    try { await navigator.clipboard.writeText(url); setCopied(url); setTimeout(() => setCopied(null), 2000); } catch { window.prompt('Copy this invite link', url); }
  }
  async function submit() {
    if (!email.trim() || full) return;
    if (await onInvite(email.trim())) setEmail('');
  }
  return (
    <div className="card p-4 sm:p-5 mt-6" id="invites">
      <div className="flex flex-wrap items-center gap-3 mb-3">
        <h2 className="font-display text-lg font-semibold text-white flex items-center gap-2"><Mail className="w-5 h-5 text-accent-400" /> Invite by email</h2>
        <span className="text-xs text-steel-400">{pending.length} pending · {seatsLeft === null ? 'unlimited seats' : `${Math.max(0, seatsLeft)} seat${seatsLeft === 1 ? '' : 's'} left`}</span>
      </div>
      <div className="flex flex-col sm:flex-row gap-2">
        <input type="email" name="invite-email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="new.hire@company.com" className="input flex-1" disabled={full}
          onKeyDown={(e) => { if (e.key === 'Enter') void submit(); }} aria-label="Invite email" />
        <button onClick={() => void submit()} disabled={busy || !email.trim() || full} className="btn-primary text-sm px-4 disabled:opacity-40">
          {busy ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Create invite'}
        </button>
      </div>
      <p className="text-[11px] text-steel-500 mt-2">
        {full ? 'All seats are in use. Pending invites hold a seat; revoke one or contact ForgeLine for more seats.'
          : 'Pending invites hold a seat for 14 days. When they sign up or sign in with this email (once verified), they join your team automatically.'}
      </p>
      {lastLink && (
        <div className="mt-3 rounded-lg border border-accent-500/40 bg-accent-500/10 p-3 text-sm">
          <p className="text-steel-200 mb-2">
            {lastLink.emailed ? <>Invite emailed to <b className="text-white">{lastLink.email}</b>. You can also share the link:</>
              : <>Invite created for <b className="text-white">{lastLink.email}</b>. Copy this link and send it to them yourself:</>}
          </p>
          <div className="flex gap-2">
            <code className="flex-1 min-w-0 truncate rounded bg-navy-950/70 px-2 py-1.5 text-xs text-accent-200">{lastLink.url}</code>
            <button onClick={() => void copy(lastLink.url)} className="btn-secondary text-xs flex items-center gap-1">{copied === lastLink.url ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />} Copy</button>
          </div>
        </div>
      )}
      {pending.length > 0 && (
        <ul className="mt-4 divide-y divide-steel-700/40 rounded-lg border border-steel-700/40">
          {pending.map((i) => (
            <li key={i.id} className="flex flex-wrap items-center gap-2 px-3 py-2">
              <div className="flex-1 min-w-0">
                <div className="text-sm text-white truncate">{i.email}</div>
                <div className="text-[11px] text-steel-500">Pending · expires {new Date(i.expires_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}</div>
              </div>
              <button onClick={() => void copy(inviteUrl(i.token))} className="btn-ghost text-xs flex items-center gap-1">{copied === inviteUrl(i.token) ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />} Copy link</button>
              <button onClick={() => onRevoke(i)} disabled={busy} className="text-xs px-2 py-1 rounded-md text-error-400 hover:bg-error-500/10">Revoke</button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

/* ----------------------------------------------------------------------------
 * Audit export (client-side, from the same RLS-scoped data the dashboard shows)
 * -------------------------------------------------------------------------- */
export interface AuditRow {
  record_type: 'employee' | 'course_completed' | 'quiz' | 'certificate' | 'assignment';
  employee: string; email: string; role: string; course: string; detail: string;
  score: string; date: string; certificate_id: string; due_date: string; status: string;
}
const AUDIT_COLS: (keyof AuditRow)[] = ['record_type', 'employee', 'email', 'role', 'course', 'detail', 'score', 'date', 'certificate_id', 'due_date', 'status'];
const isoDay = (d: string | null | undefined) => (d ? d.slice(0, 10) : '');

export function buildAuditRows(team: TeamSnapshot, assignments: AssignmentView[]): AuditRow[] {
  const rows: AuditRow[] = [];
  const blank = { course: '', detail: '', score: '', date: '', certificate_id: '', due_date: '', status: '' };
  for (const m of team.members) {
    const who = { employee: m.full_name ?? '', email: m.email ?? '', role: m.role };
    rows.push({ record_type: 'employee', ...who, ...blank, date: isoDay(m.created_at), detail: 'joined company' });
    for (const r of team.rollups.filter((x) => x.user_id === m.user_id)) {
      const total = team.lessonTotals[r.course_id] ?? 0;
      const cert = team.certs.find((c) => c.user_id === m.user_id && c.course_id === r.course_id);
      if (!cert && !(total > 0 && r.lessons_completed >= total)) continue;
      const last = cert?.issued_at ?? team.lessons.filter((l) => l.user_id === m.user_id && l.course_id === r.course_id && l.completed_at).map((l) => l.completed_at as string).sort().pop() ?? null;
      rows.push({ record_type: 'course_completed', ...who, ...blank, course: team.courseTitles[r.course_id] ?? r.course_id, detail: `${r.lessons_completed}/${total} lessons`, date: isoDay(last), score: r.avg_quiz_score != null ? String(r.avg_quiz_score) : '' });
    }
    for (const q of team.quizzes.filter((x) => x.user_id === m.user_id)) {
      rows.push({ record_type: 'quiz', ...who, ...blank, course: team.courseTitles[q.course_id] ?? q.course_id, detail: team.lessonTitles[q.lesson_id] ?? q.lesson_id, score: String(q.score), status: q.passed ? 'passed' : 'not passed', date: isoDay(q.created_at) });
    }
    for (const c of team.certs.filter((x) => x.user_id === m.user_id)) {
      rows.push({ record_type: 'certificate', ...who, ...blank, course: team.courseTitles[c.course_id] ?? c.course_id, certificate_id: c.certificate_number, date: isoDay(c.issued_at) });
    }
    for (const a of assignments.filter((x) => x.user_id === m.user_id)) {
      rows.push({ record_type: 'assignment', ...who, ...blank, course: team.courseTitles[a.course_id] ?? a.course_id, detail: `${a.lessonsCompleted}/${a.total} lessons`, due_date: a.due_date ?? '', status: STATUS_LABEL[a.status], date: isoDay(a.completedAt) });
    }
  }
  return rows;
}

export function toCsv(rows: AuditRow[]): string {
  const esc = (v: string) => {
    // neutralise spreadsheet formulas, then quote
    const safe = /^[=+\-@\t\r]/.test(v) ? `'${v}` : v;
    return /[",\n\r]/.test(safe) ? `"${safe.replace(/"/g, '""')}"` : safe;
  };
  return [AUDIT_COLS.join(','), ...rows.map((r) => AUDIT_COLS.map((c) => esc(r[c])).join(','))].join('\r\n') + '\r\n';
}

const slug = (s: string) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'company';

export function downloadAuditCsv(companyName: string, rows: AuditRow[]) {
  const blob = new Blob(['\ufeff' + toCsv(rows)], { type: 'text/csv;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `${slug(companyName)}-training-audit-${todayISO()}.csv`;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

const html = (s: string) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

/** Opens a plain, print-friendly report in a new tab and triggers the print dialog (Save as PDF). */
export function printAuditReport(companyName: string, rows: AuditRow[]): boolean {
  const w = window.open('', '_blank');
  if (!w) return false;
  const section = (type: AuditRow['record_type'], title: string, cols: (keyof AuditRow)[]) => {
    const rs = rows.filter((r) => r.record_type === type);
    return `<h2>${title} (${rs.length})</h2>` + (rs.length === 0 ? '<p class="none">None</p>' :
      `<table><thead><tr>${cols.map((c) => `<th>${html(c.replace(/_/g, ' '))}</th>`).join('')}</tr></thead><tbody>${rs.map((r) => `<tr>${cols.map((c) => `<td>${html(r[c])}</td>`).join('')}</tr>`).join('')}</tbody></table>`);
  };
  w.document.write(`<!doctype html><html><head><meta charset="utf-8"><title>${html(companyName)} training audit ${todayISO()}</title>
<style>body{font:12px/1.4 system-ui,sans-serif;color:#111;margin:24px}h1{font-size:20px;margin:0}h2{font-size:14px;margin:20px 0 6px;border-bottom:1px solid #999}
table{width:100%;border-collapse:collapse}th,td{border:1px solid #ccc;padding:3px 6px;text-align:left;vertical-align:top}th{background:#eee;text-transform:capitalize}
tr{page-break-inside:avoid}.meta{color:#555}.none{color:#777}@media print{body{margin:0}}</style></head><body>
<h1>${html(companyName)}: training audit</h1><p class="meta">Generated ${html(new Date().toLocaleString())} from ForgeLine Academy. Contains this company's employees only.</p>
${section('employee', 'Employees', ['employee', 'email', 'role', 'date'])}
${section('course_completed', 'Courses completed', ['employee', 'course', 'detail', 'score', 'date'])}
${section('certificate', 'Certificates', ['employee', 'course', 'certificate_id', 'date'])}
${section('assignment', 'Assignments', ['employee', 'course', 'due_date', 'status', 'detail', 'date'])}
${section('quiz', 'Quiz results', ['employee', 'course', 'detail', 'score', 'status', 'date'])}
<script>window.onload=function(){window.print()}</script></body></html>`);
  w.document.close();
  return true;
}

export function OverdueBanner({ count, onShow }: { count: number; onShow: () => void }) {
  if (count === 0) return null;
  return (
    <button onClick={onShow} className="mb-4 w-full flex items-center gap-2 rounded-lg border border-error-500/40 bg-error-500/10 px-3 py-2 text-sm text-error-400 text-left">
      <AlertTriangle className="w-4 h-4 shrink-0" /> {count} assigned course{count === 1 ? ' is' : 's are'} overdue. View assignments
    </button>
  );
}
