import { useEffect, useState } from 'react';
import { CalendarClock, ChevronRight } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import type { Course, Certificate } from '@/lib/types';
import type { Route } from '@/components/Nav';
import { STATUS_LABEL, StatusPill, fmtDue, todayISO, type AssignmentStatus } from '@/components/manager/ManagerExtras';

/**
 * Learner view: courses the user's company manager assigned to them. Reads only
 * the user's own course_assignments rows (RLS). Renders nothing if there are
 * none or the table does not exist yet.
 */
export function AssignedToYou({ userId, courses, progressMap, certs, onNavigate }: {
  userId: string | undefined;
  courses: Course[];
  progressMap: Record<string, number>;
  certs: Certificate[];
  onNavigate: (r: Route) => void;
}) {
  const [rows, setRows] = useState<{ id: string; course_id: string; due_date: string | null }[]>([]);
  useEffect(() => {
    if (!userId) { setRows([]); return; }
    let cancelled = false;
    void (async () => {
      const { data, error } = await supabase.from('course_assignments').select('id, course_id, due_date').eq('user_id', userId);
      if (!cancelled) setRows(error ? [] : ((data as typeof rows) ?? []));
    })();
    return () => { cancelled = true; };
  }, [userId]);

  if (rows.length === 0) return null;
  const today = todayISO();
  const items = rows.map((a) => {
    const pct = progressMap[a.course_id] ?? 0;
    const done = pct >= 100 || certs.some((c) => c.course_id === a.course_id);
    const status: AssignmentStatus = done ? 'done' : a.due_date && a.due_date < today ? 'overdue' : pct > 0 ? 'in_progress' : 'not_started';
    return { ...a, pct, status, course: courses.find((c) => c.id === a.course_id) };
  }).sort((a, b) => Number(a.status === 'done') - Number(b.status === 'done') || (a.due_date ?? '9999').localeCompare(b.due_date ?? '9999'));

  return (
    <section aria-label="Assigned to you">
      <h2 className="section-title mb-4 flex items-center gap-2"><CalendarClock className="w-5 h-5 text-accent-400" /> Assigned to you</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        {items.map((a) => (
          <button key={a.id} onClick={() => onNavigate({ name: 'course', courseId: a.course_id })}
            className={`card card-hover p-4 flex items-center gap-4 text-left ${a.status === 'overdue' ? 'border-error-500/50' : ''}`}>
            <div className="flex-1 min-w-0">
              <div className="text-sm font-semibold text-white truncate">{a.course?.title ?? 'Assigned course'}</div>
              <div className={`text-xs mt-0.5 ${a.status === 'overdue' ? 'text-error-400 font-semibold' : 'text-steel-400'}`}>
                {a.due_date ? `Due ${fmtDue(a.due_date)}` : 'No due date'} · {a.pct}% complete
              </div>
            </div>
            <StatusPill status={a.status} />
            <span className="sr-only">{STATUS_LABEL[a.status]}</span>
            <ChevronRight className="w-4 h-4 text-steel-500 shrink-0" />
          </button>
        ))}
      </div>
    </section>
  );
}
