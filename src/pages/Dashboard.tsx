import { useMemo, useState } from 'react';
import {
  Wrench,
  Zap,
  Gauge,
  Cpu,
  ArrowRight,
  Award,
  PlayCircle,
  Lock,
  TrendingUp,
  BookOpen,
  CheckCircle2,
  Sparkles,
  User,
  Pencil,
  Loader2,
} from 'lucide-react';
import type { Course, Stage, Certificate } from '@/lib/types';
import { STAGES, STAGE_LABEL } from '@/lib/types';
import { ProgressBar } from '@/components/ui/ProgressBar';
import { TierBadge } from '@/components/ui/Badge';
import { useAuth } from '@/lib/auth';
import type { Route } from '@/components/Nav';

interface DashboardProps {
  courses: Course[];
  onNavigate: (r: Route) => void;
  progressMap: Record<string, number>;
  certs: Certificate[];
}

const STAGE_ICON: Record<Stage, typeof Wrench> = {
  mechanical: Wrench,
  electrical: Zap,
  ie: Gauge,
  engineering: Cpu,
};

export function Dashboard({ courses, onNavigate, progressMap, certs }: DashboardProps) {
  const { user, isPremium, isAdmin, fullName, updateFullName } = useAuth();
  const [editingName, setEditingName] = useState(false);
  const [nameInput, setNameInput] = useState('');
  const [savingName, setSavingName] = useState(false);

  const courseProgressMap = progressMap;


  const stageProgress = useMemo(() => {
    const m: Record<Stage, number> = { mechanical: 0, electrical: 0, ie: 0, engineering: 0 };
    for (const s of STAGES) {
      const stageCourses = courses.filter((c) => c.stage === s.key);
      if (stageCourses.length === 0) continue;
      const total = stageCourses.reduce((sum, c) => sum + (courseProgressMap[c.id] ?? 0), 0);
      m[s.key] = Math.round(total / stageCourses.length);
    }
    return m;
  }, [courses, courseProgressMap]);

  const continueLearning = useMemo(
    () =>
      courses
        .filter((c) => {
          const p = courseProgressMap[c.id] ?? 0;
          return p > 0 && p < 100;
        })
        .sort((a, b) => (courseProgressMap[b.id] ?? 0) - (courseProgressMap[a.id] ?? 0)),
    [courses, courseProgressMap],
  );

  const completedCourses = useMemo(
    () => courses.filter((c) => (courseProgressMap[c.id] ?? 0) === 100),
    [courses, courseProgressMap],
  );

  const recommendations = useMemo(() => {
    // Recommend free courses not started, prioritizing the next stage
    const notStarted = courses.filter(
      (c) => (courseProgressMap[c.id] ?? 0) === 0 && c.tier === 'free',
    );
    // Sort by stage order then sort_order
    const stageOrder: Record<Stage, number> = { mechanical: 0, electrical: 1, ie: 2, engineering: 3 };
    return notStarted
      .sort((a, b) => stageOrder[a.stage] - stageOrder[b.stage] || a.sort_order - b.sort_order)
      .slice(0, 4);
  }, [courses, courseProgressMap]);

  const certCourseIds = useMemo(() => new Set(certs.map((c) => c.course_id)), [certs]);

  const myCustomCourses = useMemo(
    () => courses.filter((c) => c.is_custom && c.assigned_user_id === user?.id),
    [courses, user],
  );

  if (!user) {
    return (
      <div className="pt-16 min-h-screen flex items-center justify-center">
        <div className="card p-8 max-w-md text-center">
          <BookOpen className="w-12 h-12 text-accent-400 mx-auto mb-4" />
          <h2 className="text-xl font-semibold text-white mb-2">Sign in to view your dashboard</h2>
          <p className="text-steel-400 mb-5">
            Track your progress across the career ladder, view certificates, and get
            personalized recommendations.
          </p>
          <button onClick={() => onNavigate({ name: 'auth' })} className="btn-primary">
            Sign in / Create account
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="pt-16 min-h-screen">
      <div className="border-b border-steel-700/60 bg-navy-950/40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8">
          <h1 className="font-display text-3xl font-bold text-white mb-1">
            My Learning
          </h1>
          <p className="text-steel-400">
            Welcome back. Track your progress across the ForgeLine career ladder.
          </p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8 space-y-8">
        {/* Welcome banner for new users */}
        {Object.values(courseProgressMap).every((v) => v === 0) && (
          <div className="card border-accent-500/30 bg-accent-500/5 p-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-lg bg-accent-500/15 flex items-center justify-center shrink-0">
                <Wrench className="w-5 h-5 text-accent-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">Welcome to ForgeLine Academy</h3>
                <p className="text-sm text-steel-300">
                  Your career ladder starts here. Begin with Mechanical Maintenance —
                  the foundation stage. It's free and takes about 4 hours.
                </p>
              </div>
            </div>
            <button
              onClick={() => {
                const firstMech = courses.find((c) => c.stage === 'mechanical');
                if (firstMech) onNavigate({ name: 'course', courseId: firstMech.id });
              }}
              className="btn-primary shrink-0"
            >
              Start First Course
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        )}

        {/* Profile name card */}
      <section>
        <div className="card p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg bg-accent-500/15 flex items-center justify-center shrink-0">
              <User className="w-5 h-5 text-accent-300" />
            </div>
            <div>
              <h3 className="text-sm font-semibold text-white">
                {fullName || 'Add your name'}
              </h3>
              <p className="text-xs text-steel-500">
                {fullName
                  ? 'This name appears on your certificates.'
                  : 'Add your full name so it appears on your certificates.'}
              </p>
            </div>
          </div>
          {editingName ? (
            <div className="flex items-center gap-2 w-full sm:w-auto">
              <input
                type="text"
                value={nameInput}
                onChange={(e) => setNameInput(e.target.value)}
                placeholder="Your full name"
                className="input flex-1 sm:w-56"
                autoFocus
              />
              <button
                onClick={async () => {
                  setSavingName(true);
                  await updateFullName(nameInput.trim());
                  setSavingName(false);
                  setEditingName(false);
                }}
                disabled={savingName || !nameInput.trim()}
                className="btn-primary shrink-0"
              >
                {savingName ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Save'}
              </button>
              <button
                onClick={() => { setEditingName(false); setNameInput(''); }}
                className="btn-ghost shrink-0"
              >
                Cancel
              </button>
            </div>
          ) : (
            <button
              onClick={() => { setNameInput(fullName ?? ''); setEditingName(true); }}
              className="btn-ghost shrink-0 flex items-center gap-1.5"
            >
              <Pencil className="w-3.5 h-3.5" />
              {fullName ? 'Edit' : 'Add name'}
            </button>
          )}
        </div>
      </section>

      {/* Career ladder progress */}
        <section>
          <h2 className="section-title mb-4">Career Ladder Progress</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {STAGES.map((stage, i) => {
              const Icon = STAGE_ICON[stage.key];
              const pct = stageProgress[stage.key];
              const isLocked = stage.tier === 'premium' && !isPremium && !isAdmin;
              return (
                <div key={stage.key} className="card p-5">
                  <div className="flex items-center justify-between mb-3">
                    <div
                      className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                        stage.tier === 'free'
                          ? 'bg-accent-500/15 text-accent-300'
                          : 'bg-premium-500/15 text-premium-400'
                      }`}
                    >
                      <Icon className="w-5 h-5" />
                    </div>
                    <span className="text-xs font-bold text-steel-600">
                      Stage {i + 1}
                    </span>
                  </div>
                  <h3 className="text-sm font-semibold text-white mb-1">
                    {STAGE_LABEL[stage.key]}
                  </h3>
                  <div className="flex items-center gap-2 mt-3 mb-1">
                    <ProgressBar value={pct} size="sm" />
                    <span className="text-sm font-bold text-white tabular-nums w-9 text-right">
                      {pct}%
                    </span>
                  </div>
                  {isLocked && (
                    <div className="flex items-center gap-1 text-xs text-premium-400 mt-2">
                      <Lock className="w-3 h-3" />
                      Premium
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </section>

        {/* Continue learning */}
        {continueLearning.length > 0 && (
          <section>
            <h2 className="section-title mb-4">Continue Learning</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {continueLearning.map((c) => (
                <button
                  key={c.id}
                  onClick={() => onNavigate({ name: 'course', courseId: c.id })}
                  className="card card-hover p-4 flex items-center gap-4 text-left"
                >
                  <div className="w-12 h-12 rounded-lg bg-accent-500/15 flex items-center justify-center shrink-0">
                    <PlayCircle className="w-6 h-6 text-accent-300" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-xs text-steel-500 mb-0.5">
                      {STAGE_LABEL[c.stage]}
                    </div>
                    <h3 className="text-sm font-semibold text-white truncate">
                      {c.title}
                    </h3>
                    <div className="flex items-center gap-2 mt-2">
                      <ProgressBar value={courseProgressMap[c.id] ?? 0} size="sm" />
                      <span className="text-xs text-steel-400 tabular-nums">
                        {courseProgressMap[c.id] ?? 0}%
                      </span>
                    </div>
                  </div>
                  <ArrowRight className="w-5 h-5 text-steel-500 shrink-0" />
                </button>
              ))}
            </div>
          </section>
        )}

        {/* My Custom Courses */}
        {myCustomCourses.length > 0 && (
          <section>
            <div className="flex items-center gap-2 mb-4">
              <Sparkles className="w-5 h-5 text-premium-400" />
              <h2 className="section-title">My Custom Courses</h2>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {myCustomCourses.map((c) => {
                const pct = courseProgressMap[c.id] ?? 0;
                return (
                  <button
                    key={c.id}
                    onClick={() => onNavigate({ name: 'course', courseId: c.id })}
                    className="card card-hover p-4 text-left border-premium-500/20"
                  >
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-[10px] font-bold uppercase tracking-wider text-premium-400 bg-premium-500/15 border border-premium-500/30 px-1.5 py-0.5 rounded">
                        Custom
                      </span>
                      <span className="text-xs text-steel-500">{STAGE_LABEL[c.stage]}</span>
                    </div>
                    <h3 className="text-sm font-semibold text-white leading-snug mb-1 line-clamp-2">
                      {c.title}
                    </h3>
                    <p className="text-xs text-steel-400 line-clamp-2 mb-3">
                      {c.short_description}
                    </p>
                    <div className="flex items-center gap-2">
                      <ProgressBar value={pct} size="sm" />
                      <span className="text-xs text-steel-400 tabular-nums">{pct}%</span>
                    </div>
                  </button>
                );
              })}
            </div>
          </section>
        )}

        {/* Certificates */}
        <section>
          <div className="flex items-center justify-between mb-4">
            <h2 className="section-title">My Certificates</h2>
            {certs.length > 0 && (
              <button
                onClick={() => onNavigate({ name: 'certificates' })}
                className="text-sm text-accent-400 hover:text-accent-300 flex items-center gap-1"
              >
                View all
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            )}
          </div>
          {certs.length === 0 ? (
            <div className="card p-8 text-center">
              <Award className="w-10 h-10 text-steel-600 mx-auto mb-3" />
              <h3 className="text-sm font-semibold text-white mb-1">No certificates yet</h3>
              <p className="text-sm text-steel-400">
                Complete a course to earn your first Certificate of Completion.
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {certs.slice(0, 3).map((cert) => (
                <button
                  key={cert.id}
                  onClick={() => onNavigate({ name: 'certificates' })}
                  className="card card-hover p-5 text-left"
                >
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-lg bg-premium-500/15 flex items-center justify-center shrink-0">
                      <Award className="w-5 h-5 text-premium-400" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="text-sm font-semibold text-white line-clamp-2">
                        {cert.course?.title ?? 'Course'}
                      </h3>
                      <div className="text-xs text-steel-500 mt-1">
                        {cert.certificate_number}
                      </div>
                      <div className="text-xs text-steel-400 mt-0.5">
                        {new Date(cert.issued_at).toLocaleDateString('en-US', {
                          year: 'numeric',
                          month: 'long',
                          day: 'numeric',
                        })}
                      </div>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </section>

        {/* Completed courses */}
        {completedCourses.length > 0 && (
          <section>
            <h2 className="section-title mb-4">Completed Courses</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {completedCourses.map((c) => (
                <button
                  key={c.id}
                  onClick={() => onNavigate({ name: 'course', courseId: c.id })}
                  className="card p-4 flex items-center gap-3 text-left"
                >
                  <CheckCircle2 className="w-5 h-5 text-success-500 shrink-0" />
                  <div className="flex-1 min-w-0">
                    <h3 className="text-sm font-semibold text-white truncate">
                      {c.title}
                    </h3>
                    <div className="text-xs text-steel-500">{STAGE_LABEL[c.stage]}</div>
                  </div>
                  {certCourseIds.has(c.id) && (
                    <Award className="w-4 h-4 text-premium-400 shrink-0" />
                  )}
                </button>
              ))}
            </div>
          </section>
        )}

        {/* Recommendations */}
        {recommendations.length > 0 && (
          <section>
            <div className="flex items-center gap-2 mb-4">
              <TrendingUp className="w-5 h-5 text-accent-400" />
              <h2 className="section-title">Recommended Next</h2>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              {recommendations.map((c) => (
                <button
                  key={c.id}
                  onClick={() => onNavigate({ name: 'course', courseId: c.id })}
                  className="card card-hover p-4 text-left"
                >
                  <div className="flex items-center gap-2 mb-2">
                    <TierBadge tier={c.tier} />
                    <span className="text-xs text-steel-500">{STAGE_LABEL[c.stage]}</span>
                  </div>
                  <h3 className="text-sm font-semibold text-white leading-snug mb-1 line-clamp-2">
                    {c.title}
                  </h3>
                  <p className="text-xs text-steel-400 line-clamp-2">
                    {c.short_description}
                  </p>
                </button>
              ))}
            </div>
          </section>
        )}

        {/* Empty state */}
        {continueLearning.length === 0 && completedCourses.length === 0 && recommendations.length === 0 && myCustomCourses.length === 0 && (
          <div className="card p-8 text-center">
            <BookOpen className="w-10 h-10 text-accent-400 mx-auto mb-3" />
            <h3 className="text-lg font-semibold text-white mb-1">Start your journey</h3>
            <p className="text-steel-400 mb-4">
              You haven't started any courses yet. Begin with Mechanical Maintenance — it's free.
            </p>
            <button onClick={() => onNavigate({ name: 'catalog' })} className="btn-primary">
              Browse Catalog
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
