import { useCallback, useEffect, useMemo, useState } from 'react';
import { Loader2, Download, ArrowLeft, ChevronRight, BookOpen, BarChart3, Award, Clock, CheckCircle2, Users, AlertCircle } from 'lucide-react';
import { supabase } from '@/lib/supabase';

/**
 * Company manager view of their own team's learning records.
 * Member identities come from the existing get_company_members_details RPC
 * (checks is_company_admin). Learning rows are read DIRECTLY from
 * user_progress / quiz_attempts / certificates and the security_invoker view
 * company_member_course_progress, so RLS (is_company_manager_of) is what
 * limits the data to this manager's own company.
 */

interface Member {
  user_id: string;
  role: 'owner' | 'admin' | 'member';
  email: string | null;
  full_name: string | null;
}

interface CourseRollup {
  user_id: string;
  course_id: string;
  lessons_started: number;
  lessons_completed: number;
  avg_quiz_score: number | null;
  enrolled_at: string | null;
  last_activity: string | null;
}

interface QuizRow {
  user_id: string;
  lesson_id: string;
  course_id: string;
  score: number;
  passed: boolean;
  created_at: string;
}

interface CertRow {
  user_id: string;
  course_id: string;
  certificate_number: string;
  issued_at: string;
}

interface LessonRow {
  lesson_id: string;
  course_id: string;
  completed: boolean;
  quiz_score: number | null;
  completed_at: string | null;
  created_at: string | null;
}

interface EmployeeSummary {
  member: Member;
  enrollments: number;
  lessonsCompleted: number;
  avgQuizScore: number | null;
  quizAttempts: number;
  quizzesPassed: number;
  certificates: number;
  lastActivity: string | null;
}

const maxDate = (...ds: (string | null | undefined)[]): string | null => {
  const sorted = ds.filter((d): d is string => !!d).sort();
  return sorted.length ? sorted[sorted.length - 1] : null;
};

const fmtDate = (d: string | null) => (d ? new Date(d).toLocaleDateString() : '—');

function csvCell(v: unknown): string {
  const s = v === null || v === undefined ? '' : String(v);
  // Neutralize spreadsheet formula injection and quote everything.
  const safe = /^[=+\-@\t\r]/.test(s) ? `'${s}` : s;
  return `"${safe.replace(/"/g, '""')}"`;
}

function downloadCsv(filename: string, rows: (string | number | null)[][]) {
  const csv = rows.map((r) => r.map(csvCell).join(',')).join('\r\n');
  const blob = new Blob([`\uFEFF${csv}`], { type: 'text/csv;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

export function TeamTracking({ companyId, companyName }: { companyId: string; companyName: string }) {
  const [members, setMembers] = useState<Member[]>([]);
  const [rollups, setRollups] = useState<CourseRollup[]>([]);
  const [quizzes, setQuizzes] = useState<QuizRow[]>([]);
  const [certs, setCerts] = useState<CertRow[]>([]);
  const [courseTitles, setCourseTitles] = useState<Record<string, string>>({});
  const [lessonTotals, setLessonTotals] = useState<Record<string, number>>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selected, setSelected] = useState<string | null>(null);
  const [lessonRows, setLessonRows] = useState<LessonRow[]>([]);
  const [lessonTitles, setLessonTitles] = useState<Record<string, string>>({});
  const [detailLoading, setDetailLoading] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const { data: memberData, error: mErr } = await supabase.rpc('get_company_members_details', { target_company_id: companyId });
      if (mErr) throw mErr;
      const ms = ((memberData as Member[]) ?? []).map((m) => ({ user_id: m.user_id, role: m.role, email: m.email, full_name: m.full_name }));
      setMembers(ms);
      const ids = ms.map((m) => m.user_id);
      if (ids.length === 0) {
        setRollups([]); setQuizzes([]); setCerts([]);
        return;
      }
      const [roll, quiz, cert, courseRes, lessonRes] = await Promise.all([
        supabase.from('company_member_course_progress').select('*').in('user_id', ids),
        supabase.from('quiz_attempts').select('user_id, lesson_id, course_id, score, passed, created_at').in('user_id', ids),
        supabase.from('certificates').select('user_id, course_id, certificate_number, issued_at').in('user_id', ids),
        supabase.from('courses').select('id, title'),
        supabase.from('lessons').select('module_id, modules!inner(course_id)'),
      ]);
      if (roll.error) throw roll.error;
      if (quiz.error) throw quiz.error;
      if (cert.error) throw cert.error;
      setRollups((roll.data as CourseRollup[]) ?? []);
      setQuizzes((quiz.data as QuizRow[]) ?? []);
      setCerts((cert.data as CertRow[]) ?? []);
      const titles: Record<string, string> = {};
      for (const c of (courseRes.data ?? []) as { id: string; title: string }[]) titles[c.id] = c.title;
      setCourseTitles(titles);
      const totals: Record<string, number> = {};
      for (const row of (lessonRes.data ?? []) as unknown as { modules: { course_id: string } }[]) {
        totals[row.modules.course_id] = (totals[row.modules.course_id] ?? 0) + 1;
      }
      setLessonTotals(totals);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load team progress');
    } finally {
      setLoading(false);
    }
  }, [companyId]);

  useEffect(() => { void load(); }, [load]);

  const summaries: EmployeeSummary[] = useMemo(() => members.map((m) => {
    const r = rollups.filter((x) => x.user_id === m.user_id);
    const q = quizzes.filter((x) => x.user_id === m.user_id);
    const c = certs.filter((x) => x.user_id === m.user_id);
    return {
      member: m,
      enrollments: r.length,
      lessonsCompleted: r.reduce((n, x) => n + x.lessons_completed, 0),
      avgQuizScore: q.length ? Math.round(q.reduce((n, x) => n + x.score, 0) / q.length) : null,
      quizAttempts: q.length,
      quizzesPassed: new Set(q.filter((x) => x.passed).map((x) => x.lesson_id)).size,
      certificates: c.length,
      lastActivity: maxDate(...r.map((x) => x.last_activity), ...q.map((x) => x.created_at), ...c.map((x) => x.issued_at)),
    };
  }), [members, rollups, quizzes, certs]);

  function courseRowsFor(userId: string) {
    return rollups
      .filter((x) => x.user_id === userId)
      .map((x) => {
        const total = lessonTotals[x.course_id] ?? 0;
        const q = quizzes.filter((a) => a.user_id === userId && a.course_id === x.course_id);
        const cert = certs.find((c) => c.user_id === userId && c.course_id === x.course_id) ?? null;
        return {
          ...x,
          title: courseTitles[x.course_id] ?? 'Unknown course',
          totalLessons: total,
          pct: total > 0 ? Math.min(100, Math.round((x.lessons_completed / total) * 100)) : 0,
          bestQuiz: q.length ? Math.max(...q.map((a) => a.score)) : null,
          attempts: q.length,
          cert,
          last: maxDate(x.last_activity, ...q.map((a) => a.created_at), cert?.issued_at),
        };
      })
      .sort((a, b) => (b.last ?? '').localeCompare(a.last ?? ''));
  }

  async function openEmployee(userId: string) {
    setSelected(userId);
    setDetailLoading(true);
    try {
      const { data, error: pErr } = await supabase
        .from('user_progress')
        .select('lesson_id, course_id, completed, quiz_score, completed_at, created_at')
        .eq('user_id', userId);
      if (pErr) throw pErr;
      const rows = (data as LessonRow[]) ?? [];
      setLessonRows(rows);
      const lessonIds = Array.from(new Set([...rows.map((r) => r.lesson_id), ...quizzes.filter((q) => q.user_id === userId).map((q) => q.lesson_id)]));
      if (lessonIds.length) {
        const { data: ls } = await supabase.from('lessons').select('id, title').in('id', lessonIds);
        const t: Record<string, string> = {};
        for (const l of (ls ?? []) as { id: string; title: string }[]) t[l.id] = l.title;
        setLessonTitles(t);
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load employee detail');
    } finally {
      setDetailLoading(false);
    }
  }

  const slug = companyName.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'company';
  const today = new Date().toISOString().slice(0, 10);

  function exportSummary() {
    downloadCsv(`${slug}-team-summary-${today}.csv`, [
      ['Name', 'Email', 'Role', 'Courses enrolled', 'Lessons completed', 'Quiz attempts', 'Quizzes passed', 'Avg quiz score', 'Certificates', 'Last activity'],
      ...summaries.map((s) => [
        s.member.full_name ?? '', s.member.email ?? '', s.member.role, s.enrollments, s.lessonsCompleted,
        s.quizAttempts, s.quizzesPassed, s.avgQuizScore, s.certificates, s.lastActivity ?? '',
      ]),
    ]);
  }

  function exportDetail() {
    const rows: (string | number | null)[][] = [
      ['Name', 'Email', 'Course', 'Enrolled', 'Lessons completed', 'Total lessons', 'Progress %', 'Avg quiz score', 'Best quiz score', 'Quiz attempts', 'Certificate #', 'Certified on', 'Last activity'],
    ];
    for (const m of members) {
      for (const c of courseRowsFor(m.user_id)) {
        rows.push([
          m.full_name ?? '', m.email ?? '', c.title, c.enrolled_at ?? '', c.lessons_completed, c.totalLessons, c.pct,
          c.avg_quiz_score, c.bestQuiz, c.attempts, c.cert?.certificate_number ?? '', c.cert?.issued_at ?? '', c.last ?? '',
        ]);
      }
    }
    downloadCsv(`${slug}-team-courses-${today}.csv`, rows);
  }

  if (loading) {
    return <div className="card p-10 flex items-center justify-center"><Loader2 className="w-6 h-6 text-rok-400 animate-spin" /></div>;
  }

  const sel = selected ? summaries.find((s) => s.member.user_id === selected) : null;

  return (
    <div className="space-y-4">
      {error && (
        <div className="flex items-start gap-3 p-4 rounded-lg bg-error-500/10 border border-error-500/30">
          <AlertCircle className="w-5 h-5 text-error-400 flex-shrink-0 mt-0.5" />
          <p className="text-sm text-error-300">{error}</p>
        </div>
      )}

      {sel ? (
        <div className="card p-6">
          <div className="flex items-center gap-3 mb-4">
            <button onClick={() => setSelected(null)} className="btn-ghost text-sm"><ArrowLeft className="w-4 h-4" /> Team</button>
            <div className="min-w-0">
              <h2 className="text-lg font-bold text-white truncate">{sel.member.full_name || sel.member.email || 'Employee'}</h2>
              <p className="text-xs text-steel-500">{sel.member.email} · Last active {fmtDate(sel.lastActivity)}</p>
            </div>
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-5">
            {[
              { icon: BookOpen, label: 'Courses', value: sel.enrollments },
              { icon: CheckCircle2, label: 'Lessons done', value: sel.lessonsCompleted },
              { icon: BarChart3, label: 'Avg quiz', value: sel.avgQuizScore != null ? `${sel.avgQuizScore}%` : '—' },
              { icon: Award, label: 'Certificates', value: sel.certificates },
            ].map(({ icon: Icon, label, value }) => (
              <div key={label} className="rounded-lg bg-navy-950/40 border border-steel-700/40 p-3 text-center">
                <Icon className="w-5 h-5 mx-auto mb-1" style={{ color: 'var(--brand-accent, #EC682B)' }} />
                <div className="text-xl font-bold text-white">{value}</div>
                <div className="text-[10px] text-steel-500 uppercase tracking-wider">{label}</div>
              </div>
            ))}
          </div>

          <h3 className="text-sm font-semibold text-steel-300 uppercase tracking-wider mb-2">Courses</h3>
          <div className="space-y-1.5 mb-5">
            {courseRowsFor(sel.member.user_id).map((c) => (
              <div key={c.course_id} className="p-3 rounded-lg border border-steel-700/40 bg-navy-950/30">
                <div className="flex items-center gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="text-sm font-medium text-white truncate">{c.title}</div>
                    <div className="text-xs text-steel-500">
                      {c.lessons_completed}/{c.totalLessons || '?'} lessons · {c.attempts} quiz attempts{c.bestQuiz != null ? ` · best ${c.bestQuiz}%` : ''} · last {fmtDate(c.last)}
                    </div>
                  </div>
                  {c.cert && <span className="flex items-center gap-1 text-xs text-premium-400"><Award className="w-3.5 h-3.5" /> Certified</span>}
                  <span className="text-sm font-bold text-white w-12 text-right">{c.pct}%</span>
                </div>
                <div className="mt-2 h-1.5 rounded-full bg-navy-700 overflow-hidden">
                  <div className="h-full rounded-full" style={{ width: `${c.pct}%`, background: 'var(--brand-accent, #EC682B)' }} />
                </div>
              </div>
            ))}
            {courseRowsFor(sel.member.user_id).length === 0 && <p className="text-sm text-steel-500">Not enrolled in any course yet.</p>}
          </div>

          <h3 className="text-sm font-semibold text-steel-300 uppercase tracking-wider mb-2">Lesson progress</h3>
          {detailLoading ? (
            <div className="flex justify-center py-6"><Loader2 className="w-5 h-5 text-rok-400 animate-spin" /></div>
          ) : lessonRows.length === 0 ? (
            <p className="text-sm text-steel-500">No lesson activity yet.</p>
          ) : (
            <div className="space-y-1">
              {lessonRows
                .slice()
                .sort((a, b) => (b.completed_at ?? b.created_at ?? '').localeCompare(a.completed_at ?? a.created_at ?? ''))
                .map((l) => (
                  <div key={l.lesson_id} className="flex items-center gap-3 px-3 py-2 rounded-md bg-navy-950/30 text-sm">
                    <span className="flex-1 min-w-0 truncate text-steel-200">
                      {lessonTitles[l.lesson_id] ?? 'Lesson'} <span className="text-steel-500">· {courseTitles[l.course_id] ?? ''}</span>
                    </span>
                    {l.quiz_score != null && <span className="text-xs text-steel-400">{l.quiz_score}%</span>}
                    {l.completed ? <CheckCircle2 className="w-4 h-4 text-success-400" /> : <Clock className="w-4 h-4 text-steel-500" />}
                  </div>
                ))}
            </div>
          )}
        </div>
      ) : (
        <div className="card p-6">
          <div className="flex flex-wrap items-center justify-between gap-2 mb-4">
            <h2 className="text-sm font-semibold text-steel-300 uppercase tracking-wider">Team Progress ({members.length})</h2>
            <div className="flex gap-2">
              <button onClick={exportSummary} disabled={!members.length} className="btn-secondary text-xs px-3 py-1.5"><Download className="w-3.5 h-3.5" /> Summary CSV</button>
              <button onClick={exportDetail} disabled={!members.length} className="btn-secondary text-xs px-3 py-1.5"><Download className="w-3.5 h-3.5" /> Course detail CSV</button>
            </div>
          </div>
          {members.length === 0 ? (
            <div className="text-center py-10">
              <Users className="w-10 h-10 text-steel-600 mx-auto mb-3" />
              <p className="text-sm text-steel-500">No team members yet.</p>
            </div>
          ) : (
            <div className="space-y-1.5">
              <div className="hidden sm:grid grid-cols-[1fr_repeat(5,5.5rem)_1rem] gap-2 px-3 pb-2 text-[10px] font-semibold text-steel-500 uppercase tracking-wider">
                <div>Employee</div><div className="text-center">Courses</div><div className="text-center">Lessons</div>
                <div className="text-center">Avg quiz</div><div className="text-center">Certs</div><div className="text-center">Last active</div><div />
              </div>
              {summaries.map((s) => (
                <button
                  key={s.member.user_id}
                  onClick={() => void openEmployee(s.member.user_id)}
                  className="w-full grid grid-cols-[1fr_auto] sm:grid-cols-[1fr_repeat(5,5.5rem)_1rem] gap-2 items-center p-3 rounded-lg border border-steel-700/40 bg-navy-950/30 hover:bg-navy-800/40 transition-colors text-left"
                >
                  <div className="min-w-0">
                    <div className="text-sm font-medium text-white truncate">{s.member.full_name || s.member.email || 'Unknown'}</div>
                    <div className="text-[11px] text-steel-500 truncate">{s.member.email} · {s.member.role}</div>
                  </div>
                  <div className="hidden sm:block text-center text-sm font-bold text-white">{s.enrollments}</div>
                  <div className="hidden sm:block text-center text-sm font-bold text-white">{s.lessonsCompleted}</div>
                  <div className="hidden sm:block text-center text-sm text-steel-300">{s.avgQuizScore != null ? `${s.avgQuizScore}%` : '—'}</div>
                  <div className="hidden sm:block text-center text-sm text-premium-400 font-bold">{s.certificates}</div>
                  <div className="hidden sm:block text-center text-xs text-steel-400">{fmtDate(s.lastActivity)}</div>
                  <ChevronRight className="w-4 h-4 text-steel-500" />
                </button>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
