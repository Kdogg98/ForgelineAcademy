import { useMemo, useState, useEffect, useRef } from 'react';
import {
  Wrench,
  Zap,
  Gauge,
  Cpu,
  Lock,
  ArrowRight,
  CheckCircle2,
  Clock,
  ChevronRight,
  Sparkles,
  X,
} from 'lucide-react';
import type { Course, Stage } from '@/lib/types';
import { STAGES, STAGE_LABEL } from '@/lib/types';
import { TierBadge, DifficultyBadge } from '@/components/ui/Badge';
import { ProgressBar } from '@/components/ui/ProgressBar';
import { useAuth } from '@/lib/auth';
import type { Route } from '@/components/Nav';
import { PlantFloorLinks } from '@/components/PlantFloorLinks';

interface PathsProps {
  courses: Course[];
  progressMap: Record<string, number>;
  onNavigate: (r: Route) => void;
  focusPath?: 'electrical' | 'mechanical';
  showWelcome?: boolean;
}

const STAGE_ICON: Record<Stage, typeof Wrench> = {
  mechanical: Wrench,
  electrical: Zap,
  ie: Gauge,
  engineering: Cpu,
};

const STAGE_ACCENT: Record<Stage, string> = {
  mechanical: 'border-l-premium-500',
  electrical: 'border-l-accent-500',
  ie: 'border-l-rok-500',
  engineering: 'border-l-crimson-500',
};

export function Paths({ courses, progressMap, onNavigate, focusPath, showWelcome }: PathsProps) {
  const { isPremium, isAdmin } = useAuth();
  const [welcomeVisible, setWelcomeVisible] = useState(true);
  const stageRefs = useRef<Record<string, HTMLDivElement | null>>({});

  useEffect(() => {
    if (focusPath && stageRefs.current[focusPath]) {
      stageRefs.current[focusPath]?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }, [focusPath]);

  const byStage = useMemo(() => {
    const m: Record<Stage, Course[]> = {
      mechanical: [],
      electrical: [],
      ie: [],
      engineering: [],
    };
    for (const c of courses) m[c.stage].push(c);
    return m;
  }, [courses]);

  const stageProgress = useMemo(() => {
    const m: Record<Stage, number> = { mechanical: 0, electrical: 0, ie: 0, engineering: 0 };
    for (const s of STAGES) {
      const list = byStage[s.key];
      if (list.length === 0) continue;
      const total = list.reduce((sum, c) => sum + (progressMap[c.id] ?? 0), 0);
      m[s.key] = Math.round(total / list.length);
    }
    return m;
  }, [byStage, progressMap]);

  const recommendedCourse = useMemo(() => {
    for (const stageKey of ['mechanical', 'electrical'] as Stage[]) {
      const list = byStage[stageKey];
      const incomplete = list.find((c) => (progressMap[c.id] ?? 0) < 100);
      if (incomplete) return incomplete;
    }
    return null;
  }, [byStage, progressMap]);

  return (
    <div className="pt-[100px] min-h-screen">
      <div className="border-b border-steel-700/60 bg-navy-950/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-12">
          <div className="rok-bar mb-4" />
          <h1 className="font-display text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-3">
            Learning Paths
          </h1>
          <p className="text-steel-300 max-w-2xl text-lg">
            One structured career ladder. Each stage builds on the last — move from
            mechanical fundamentals through to advanced engineering at your own pace.
          </p>
          <div className="mt-6 max-w-3xl">
            <PlantFloorLinks />
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-10 space-y-10">
        {showWelcome && welcomeVisible && (
          <div className="card border-rok-500/40 bg-gradient-to-r from-rok-500/10 via-rok-500/5 to-transparent p-5 flex items-start justify-between gap-4">
            <div className="flex items-start gap-3">
              <Sparkles className="w-5 h-5 text-rok-400 shrink-0 mt-0.5" />
              <div>
                <h3 className="font-semibold text-white text-sm mb-0.5">Start here — free plant-floor training</h3>
                <p className="text-sm text-steel-400">
                  You have full access to free Mechanical and Electrical courses. Upgrade later only if you want I&amp;E, Engineering, and AI Tutor.
                </p>
              </div>
            </div>
            <button onClick={() => setWelcomeVisible(false)} className="text-steel-500 hover:text-steel-300 shrink-0">
              <X className="w-4 h-4" />
            </button>
          </div>
        )}
        {recommendedCourse && (
          <div className="card border-rok-500/40 bg-gradient-to-r from-rok-500/10 via-transparent to-transparent p-5 sm:p-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-xl bg-rok-500/15 border border-rok-500/30 flex items-center justify-center shrink-0">
                <Sparkles className="w-5 h-5 text-rok-400" />
              </div>
              <div>
                <div className="text-xs font-bold uppercase tracking-wider text-rok-400 mb-1">
                  Recommended Next
                </div>
                <h3 className="font-semibold text-white text-lg">{recommendedCourse.title}</h3>
                <p className="text-sm text-steel-400 mt-0.5 line-clamp-1">
                  {recommendedCourse.short_description}
                </p>
              </div>
            </div>
            <button
              onClick={() => onNavigate({ name: 'course', courseId: recommendedCourse.id })}
              className="btn-primary shrink-0"
            >
              Continue
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        )}

        <div className="space-y-6">
          {STAGES.map((stage, idx) => {
            const Icon = STAGE_ICON[stage.key];
            const list = byStage[stage.key] ?? [];
            const prog = stageProgress[stage.key];
            const locked = stage.tier === 'premium' && !isPremium && !isAdmin;
            const isLast = idx === STAGES.length - 1;

            return (
              <div key={stage.key} ref={(el) => { stageRefs.current[stage.key] = el; }} className="relative">
                {!isLast && (
                  <div className="absolute left-6 top-full w-0.5 h-6 bg-gradient-to-b from-steel-600 to-steel-700/30 z-0" />
                )}

                <div
                  className={`relative card overflow-hidden border-l-4 ${STAGE_ACCENT[stage.key]} ${
                    locked ? 'opacity-90' : ''
                  } ${focusPath === stage.key ? 'ring-2 ring-rok-500/50' : ''}`}
                >
                  <div className="p-5 sm:p-6 border-b border-steel-700/50 bg-navy-900/40">
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                      <div className="flex items-start gap-4">
                        <div className="w-12 h-12 rounded-xl bg-navy-800 border border-steel-700 flex items-center justify-center shrink-0">
                          <Icon className="w-6 h-6 text-white" />
                        </div>
                        <div>
                          <div className="flex items-center gap-2 mb-1">
                            <span className="text-xs font-bold text-steel-500 tracking-wider">
                              STAGE 0{idx + 1}
                            </span>
                            {stage.tier === 'free' ? (
                              <span className="badge-free">Free</span>
                            ) : (
                              <span className="badge-premium">
                                <Lock className="w-3 h-3" /> Premium
                              </span>
                            )}
                          </div>
                          <h2 className="font-display text-xl sm:text-2xl font-bold text-white">
                            {stage.label}
                          </h2>
                          <p className="text-sm text-steel-400 mt-1 max-w-xl">
                            {stage.description}
                          </p>
                        </div>
                      </div>

                      <div className="flex items-center gap-4 sm:flex-col sm:items-end">
                        <div className="text-right">
                          <div className="text-2xl font-bold text-white">{prog}%</div>
                          <div className="text-xs text-steel-500">avg progress</div>
                        </div>
                        <div className="w-28">
                          <ProgressBar value={prog} size="sm" />
                        </div>
                      </div>
                    </div>
                  </div>

                  <div className="p-4 sm:p-5">
                    {list.length === 0 ? (
                      <p className="text-sm text-steel-500 py-4 text-center">
                        Courses coming soon for this stage.
                      </p>
                    ) : (
                      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
                        {list.map((course) => {
                          const p = progressMap[course.id] ?? 0;
                          const courseLocked =
                            course.tier === 'premium' && !isPremium && !isAdmin;
                          return (
                            <button
                              key={course.id}
                              onClick={() =>
                                onNavigate({ name: 'course', courseId: course.id })
                              }
                              disabled={courseLocked}
                              className={`group text-left p-4 rounded-lg border transition-all ${
                                courseLocked
                                  ? 'border-steel-700/40 bg-navy-900/40 cursor-not-allowed'
                                  : 'border-steel-700/50 bg-navy-900/30 hover:border-rok-500/40 hover:bg-navy-800/50'
                              }`}
                            >
                              <div className="flex items-start justify-between gap-2 mb-2">
                                <h3 className="font-medium text-white text-sm leading-snug group-hover:text-rok-300 transition-colors line-clamp-2">
                                  {course.title}
                                </h3>
                                {courseLocked ? (
                                  <Lock className="w-4 h-4 text-premium-400 shrink-0" />
                                ) : p === 100 ? (
                                  <CheckCircle2 className="w-4 h-4 text-success-400 shrink-0" />
                                ) : (
                                  <ChevronRight className="w-4 h-4 text-steel-500 group-hover:text-rok-400 shrink-0 transition-colors" />
                                )}
                              </div>
                              <div className="flex items-center gap-2 text-xs text-steel-500 mb-2">
                                <span className="inline-flex items-center gap-1">
                                  <Clock className="w-3 h-3" />
                                  {course.estimated_hours}h
                                </span>
                                <DifficultyBadge difficulty={course.difficulty} />
                              </div>
                              {p > 0 && !courseLocked && (
                                <ProgressBar value={p} size="sm" />
                              )}
                            </button>
                          );
                        })}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        <div className="card p-6 sm:p-8 text-center border-rok-500/20 bg-gradient-to-b from-rok-500/5 to-transparent">
          <h3 className="font-display text-xl font-bold text-white mb-2">
            Ready to climb the ladder?
          </h3>
          <p className="text-steel-400 mb-5 max-w-lg mx-auto">
            Start with free Mechanical and Electrical courses. Unlock I&amp;E and
            Engineering when you&apos;re ready to advance.
          </p>
          <div className="flex flex-wrap justify-center gap-3">
            <button
              onClick={() => onNavigate({ name: 'catalog' })}
              className="btn-primary"
            >
              Browse All Courses
              <ArrowRight className="w-4 h-4" />
            </button>
            <button
              onClick={() => onNavigate({ name: 'pricing' })}
              className="btn-secondary"
            >
              View Premium Plans
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}