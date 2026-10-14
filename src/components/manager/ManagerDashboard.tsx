import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  Activity, AlertCircle, ArrowLeft, Award, BarChart3, BookOpen, Building2, CheckCircle2, ChevronRight,
  ClipboardCheck, Library, Loader2, Trash2, UserPlus, Users, X,
} from 'lucide-react';
import type { Company } from '@/lib/types';
import type { Route } from '@/components/Nav';
import { supabaseManagerData, type ManagerDataSource, type TeamSnapshot, type RosterMember } from '@/lib/managerData';

/**
 * Company Manager Dashboard: landing + /dashboard view for owners/admins of an
 * active company. No learner UI here (no Continue Learning, no my-progress, no
 * upsells). All reads/writes go through ManagerDataSource (RLS-scoped client).
 */

interface Props {
  company: Company;
  currentUserId: string;
  currentRole: 'owner' | 'admin';
  onNavigate: (r: Route) => void;
  dataSource?: ManagerDataSource;
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

export function ManagerDashboard({ company, currentUserId, currentRole, onNavigate, dataSource = supabaseManagerData, banner }: Props) {
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

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [t, lim] = await Promise.all([dataSource.loadTeam(company.id), dataSource.loadSeatLimit(company.id)]);
      setTeam(t);
      setSeatLimit(lim);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load your team');
    } finally {
      setLoading(false);
    }
  }, [company.id, dataSource]);

  useEffect(() => { void load(); }, [load]);

  const members = useMemo(() => team?.members ?? [], [team]);
  const seatsUsed = members.length;
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

  const canRemove = (m: RosterMember) => m.user_id !== currentUserId && m.role !== 'owner';
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
            <p className="text-sm text-steel-400">Signed in as {currentRole === 'owner' ? 'owner' : 'admin'} · you can see your own team only</p>
          </div>
          <button onClick={() => onNavigate({ name: 'catalog' })} className="btn-secondary flex items-center gap-2 self-start sm:self-auto">
            <Library className="w-4 h-4" /> What your team can take
          </button>
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

        {loading && !team ? (
          <div className="card p-12 flex justify-center"><Loader2 className="w-6 h-6 text-accent-400 animate-spin" /></div>
        ) : (
          <>
            {/* Stats */}
            <div className="grid grid-cols-2 lg:grid-cols-5 gap-3 mb-6">
              <Stat icon={<Users className="w-4 h-4" />} label="Seats used" value={`${seatsUsed} of ${hasLimit ? seatLimit : 'Unlimited'}`} warn={atLimit} />
              <Stat icon={<BookOpen className="w-4 h-4" />} label="Courses in progress" value={String(totals.inProgress)} />
              <Stat icon={<CheckCircle2 className="w-4 h-4" />} label="Courses completed" value={String(totals.completed)} />
              <Stat icon={<Award className="w-4 h-4" />} label="Certificates" value={String(totals.certs)} />
              <Stat icon={<ClipboardCheck className="w-4 h-4" />} label="Avg quiz score" value={totals.avgQuiz != null ? `${totals.avgQuiz}%` : '—'} />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-[1fr_22rem] gap-6">
              <div className="min-w-0">
                {sel ? (
                  <EmployeeDetail
                    s={sel}
                    rows={courseRows(sel.m.user_id)}
                    team={team as TeamSnapshot}
                    onBack={() => setSelected(null)}
                  />
                ) : (
                  <div className="card p-4 sm:p-5">
                    <div className="flex flex-wrap items-center gap-3 mb-4">
                      <h2 className="font-display text-lg font-semibold text-white flex items-center gap-2"><Users className="w-5 h-5 text-accent-400" /> Employees</h2>
                      <span className={`text-xs font-semibold px-2 py-0.5 rounded-full border ${atLimit ? 'border-warning-500/50 text-warning-400 bg-warning-500/10' : 'border-steel-600 text-steel-300'}`}>
                        Seats used {seatsUsed} of {hasLimit ? seatLimit : 'Unlimited'}
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

function EmployeeDetail({ s, rows, team, onBack }: {
  s: { m: RosterMember; courses: number; completed: number; certs: number; avgQuiz: number | null };
  rows: DetailRow[];
  team: TeamSnapshot;
  onBack: () => void;
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
