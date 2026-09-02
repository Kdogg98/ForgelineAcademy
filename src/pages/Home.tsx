import { useEffect, useMemo, useState } from 'react';
import {
  ArrowRight,
  Wrench,
  Zap,
  Gauge,
  Cpu,
  Lock,
  CheckCircle2,
  TrendingUp,
  ShieldCheck,
  BookOpen,
  Award,
  Target,
  Stethoscope,
  Sparkles,
  Loader2,
  RotateCcw,
  Construction,
} from 'lucide-react';
import type { Course, Stage } from '@/lib/types';
import { STAGES, STAGE_LABEL } from '@/lib/types';
import { Carousel } from '@/components/ui/Carousel';
import { CourseCard } from '@/components/CourseCard';
import { useAuth } from '@/lib/auth';
import {
  fetchSavedAssessment,
  checkRetakeEligibility,
  type SavedAssessment,
  type AssessmentLevel,
  type RetakeEligibility,
} from '@/lib/assessment';
import type { Route } from '@/components/Nav';
import { PlantFloorLinks } from '@/components/PlantFloorLinks';

interface HomeProps {
  courses: Course[];
  loading: boolean;
  progressMap: Record<string, number>;
  certCourseIds: Set<string>;
  onNavigate: (r: Route) => void;
}

const STAGE_ICON: Record<Stage, typeof Wrench> = {
  mechanical: Wrench,
  electrical: Zap,
  ie: Gauge,
  engineering: Cpu,
};

const STAGE_COLOR: Record<Stage, string> = {
  mechanical: 'from-premium-500/20 to-premium-600/5 border-premium-500/30',
  electrical: 'from-accent-500/20 to-accent-600/5 border-accent-500/30',
  ie: 'from-rok-500/20 to-rok-600/5 border-rok-500/30',
  engineering: 'from-crimson-500/20 to-crimson-600/5 border-crimson-500/30',
};

const LEVEL_META: Record<string, { label: string; color: string; icon: typeof Award }> = {
  novice: { label: 'Novice', color: 'text-emerald-300', icon: Sparkles },
  intermediate: { label: 'Intermediate', color: 'text-sky-300', icon: Zap },
  advanced: { label: 'Advanced', color: 'text-rok-300', icon: Gauge },
  expert: { label: 'Expert', color: 'text-violet-300', icon: Award },
};

const AREA_META = [
  { key: 'mechanical' as const, icon: Wrench, label: 'Mechanical' },
  { key: 'electrical' as const, icon: Zap, label: 'Electrical' },
  { key: 'ie' as const, icon: Gauge, label: 'I&E' },
  { key: 'engineering' as const, icon: Cpu, label: 'Engineering' },
];

type Tab = 'overview' | 'foryou';

export function Home({
  courses,
  loading,
  progressMap,
  certCourseIds,
  onNavigate,
}: HomeProps) {
  const { user, isPremium, isAdmin, assessmentCompleted } = useAuth();
  const [tab, setTab] = useState<Tab>('overview');
  const [assessment, setAssessment] = useState<SavedAssessment | null>(null);
  const [assessmentLoading, setAssessmentLoading] = useState(false);
  const [retaking, setRetaking] = useState(false);
  const [eligibility, setEligibility] = useState<RetakeEligibility | null>(null);

  useEffect(() => {
    if (!user || !assessmentCompleted) {
      setAssessment(null);
      setEligibility(null);
      return;
    }
    let cancelled = false;
    setAssessmentLoading(true);
    (async () => {
      try {
        const saved = await fetchSavedAssessment();
        if (!cancelled) setAssessment(saved);
        if (saved) {
          const elig = await checkRetakeEligibility(isPremium, isAdmin);
          if (!cancelled) setEligibility(elig);
        }
      } catch {
        if (!cancelled) setAssessment(null);
      } finally {
        if (!cancelled) setAssessmentLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [user, assessmentCompleted, isPremium, isAdmin]);

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

  const featuredFree = useMemo(
    () => [...byStage.mechanical.slice(0, 4), ...byStage.electrical.slice(0, 4)],
    [byStage],
  );
  const startPath = useMemo(
    () => [...byStage.mechanical.slice(4, 8), ...byStage.electrical.slice(4, 8)],
    [byStage],
  );
  const mostPopular = useMemo(() => {
    const used = new Set<string>();
    const pick = (list: Course[], idx: number) => {
      const c = list[idx];
      if (!c || used.has(c.id)) return null;
      used.add(c.id);
      return c;
    };
    const mixed = [
      pick(byStage.electrical, 1),
      pick(byStage.ie, 0),
      pick(byStage.mechanical, 2),
      pick(byStage.engineering, 0),
      pick(byStage.electrical, 3),
      pick(byStage.ie, 1),
      pick(byStage.mechanical, 5),
      pick(byStage.engineering, 1),
    ].filter((c): c is Course => Boolean(c));
    if (mixed.length < 8) {
      for (const c of courses) {
        if (used.has(c.id)) continue;
        mixed.push(c);
        used.add(c.id);
        if (mixed.length >= 8) break;
      }
    }
    return mixed;
  }, [byStage, courses]);
  const recentlyAdded = useMemo(
    () =>
      [...courses]
        .sort((a, b) => (b.created_at || '').localeCompare(a.created_at || '') || b.sort_order - a.sort_order)
        .slice(0, 8),
    [courses],
  );

  function openCourse(id: string) {
    onNavigate({ name: 'course', courseId: id });
  }

  function renderCards(list: Course[]) {
    if (loading) {
      return Array.from({ length: 5 }).map((_, i) => (
        <div
          key={i}
          className="w-[300px] shrink-0 rounded-xl overflow-hidden border border-steel-700/60"
        >
          <div className="skeleton h-28 w-full" />
          <div className="p-4 space-y-3">
            <div className="skeleton h-3 w-20" />
            <div className="skeleton h-4 w-full" />
            <div className="skeleton h-3 w-full" />
            <div className="skeleton h-3 w-2/3" />
          </div>
        </div>
      ));
    }
    return list.map((c) => (
      <CourseCard
        key={c.id}
        course={c}
        progress={progressMap[c.id] ?? 0}
        hasCertificate={certCourseIds.has(c.id)}
        locked={c.tier === 'premium' && !isPremium && !isAdmin}
        onClick={() => openCourse(c.id)}
      />
    ));
  }

  async function handleRetake() {
    if (!eligibility?.canRetake) return;
    setRetaking(true);
    try {
      onNavigate({ name: 'assessment' });
    } finally {
      setRetaking(false);
    }
  }

  /* ─── FOR YOU TAB ─── */
  function renderForYou() {
    if (!user) {
      return (
        <div className="pt-16 min-h-screen flex items-center justify-center px-4">
          <div className="card p-8 max-w-md text-center">
            <Sparkles className="w-12 h-12 text-accent-400 mx-auto mb-4" />
            <h2 className="text-xl font-semibold text-white mb-2">Sign in for personalized recommendations</h2>
            <p className="text-steel-400 mb-5">
              Take the skill assessment and get AI-powered course recommendations tailored to your experience.
            </p>
            <button onClick={() => onNavigate({ name: 'auth' })} className="btn-primary">
              Sign in / Create account
            </button>
          </div>
        </div>
      );
    }

    if (assessmentLoading) {
      return (
        <div className="pt-16 min-h-screen flex items-center justify-center">
          <Loader2 className="h-8 w-8 text-accent-400 animate-spin" />
        </div>
      );
    }

    if (!assessmentCompleted || !assessment) {
      return (
        <div className="pt-16 min-h-screen flex items-center justify-center px-4 py-8">
          <div className="max-w-lg w-full">
            <div className="card p-8 text-center border-accent-500/30 bg-accent-500/5">
              <div className="w-16 h-16 rounded-2xl bg-accent-500/15 flex items-center justify-center mx-auto mb-5">
                <Sparkles className="w-8 h-8 text-accent-300" />
              </div>
              <h2 className="font-display text-2xl font-bold text-white mb-2">
                Take the Skill Assessment
              </h2>
              <p className="text-steel-400 mb-6 leading-relaxed">
                Answer a few questions about your experience across Mechanical, Electrical,
                I&amp;E, and Engineering. Our AI will evaluate your skill level and recommend
                the best courses to start with.
              </p>
              <button
                onClick={() => onNavigate({ name: 'assessment' })}
                className="btn-primary inline-flex items-center gap-2"
              >
                Start Assessment
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      );
    }

    const meta = LEVEL_META[assessment.level] ?? LEVEL_META.novice;
    const LevelIcon = meta.icon;
    const evalData = assessment.evaluation;

    return (
      <div className="pt-[100px] min-h-screen">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 py-8 space-y-6">
          {/* Header */}
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-2">
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-accent-500/15 border border-accent-500/30 text-accent-300 text-[10px] font-bold uppercase tracking-wider">
                <Sparkles className="w-3 h-3" />
                Personalized
              </span>
            </div>
            {eligibility && (
              eligibility.canRetake ? (
                <button
                  onClick={handleRetake}
                  disabled={retaking}
                  className="inline-flex items-center gap-1.5 text-xs text-steel-400 hover:text-white transition-colors disabled:opacity-40"
                >
                  {retaking ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <RotateCcw className="w-3.5 h-3.5" />}
                  Retake assessment
                </button>
              ) : (
                <div className="inline-flex items-center gap-1.5 text-xs text-steel-500 cursor-not-allowed" title={eligibility.reason}>
                  <Lock className="w-3.5 h-3.5" />
                  Retake locked
                </div>
              )
            )}
          </div>

          {/* Retake locked message */}
          {eligibility && !eligibility.canRetake && (
            <div className="rounded-xl border border-steel-700/50 bg-navy-950/60 px-4 py-3">
              <div className="flex items-center gap-2 mb-1">
                <Lock className="h-4 w-4 text-steel-500" />
                <span className="text-xs font-semibold text-steel-400">Retake not available yet</span>
              </div>
              <p className="text-xs text-steel-500 leading-relaxed">{eligibility.reason}</p>
              {eligibility.isPremium && (eligibility.lessonsCompletedSinceAssessment > 0 || eligibility.coursesCompletedSinceAssessment > 0) && (
                <p className="text-xs text-steel-600 mt-1.5">
                  Progress since last assessment: {eligibility.lessonsCompletedSinceAssessment} lessons, {eligibility.coursesCompletedSinceAssessment} courses completed
                </p>
              )}
            </div>
          )}

          {/* Skill level card */}
          <div className="card p-6 sm:p-8 relative overflow-hidden">
            <div className="absolute -right-16 -top-16 w-48 h-48 rounded-full bg-accent-500/8 blur-3xl" />
            <div className="relative flex flex-col sm:flex-row items-center sm:items-start gap-5">
              <div className={`flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-navy-950 ring-1 ${meta.color.includes('emerald') ? 'ring-emerald-500/30' : meta.color.includes('sky') ? 'ring-sky-500/30' : meta.color.includes('rok') ? 'ring-rok-500/30' : 'ring-violet-500/30'}`}>
                <LevelIcon className={`h-8 w-8 ${meta.color}`} />
              </div>
              <div className="text-center sm:text-left flex-1">
                <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-steel-500 mb-1">
                  Your skill level
                </p>
                <h2 className={`font-display text-2xl font-bold ${meta.color} mb-2`}>
                  {meta.label}
                </h2>
                <p className="text-sm text-steel-300 leading-relaxed">
                  {assessment.summary}
                </p>
                {assessment.assessed_at && (
                  <p className="text-[11px] text-steel-600 mt-3">
                    Assessed {new Date(assessment.assessed_at).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
                  </p>
                )}
              </div>
            </div>
          </div>

          {/* Per-area breakdown */}
          {evalData?.areas && (
            <div className="card p-6">
              <h3 className="text-sm font-semibold text-white mb-4 flex items-center gap-2">
                <Target className="w-4 h-4 text-accent-400" />
                Area Breakdown
              </h3>
              <div className="grid sm:grid-cols-2 gap-4">
                {AREA_META.map((area) => {
                  const areaData = evalData.areas[area.key];
                  if (!areaData) return null;
                  const areaMeta = LEVEL_META[areaData.level] ?? LEVEL_META.novice;
                  const AreaIcon = area.icon;
                  return (
                    <div key={area.key} className="rounded-xl border border-steel-700/50 bg-navy-950/50 p-4">
                      <div className="flex items-center gap-2.5 mb-2">
                        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-navy-900 border border-steel-700/50">
                          <AreaIcon className="h-4 w-4 text-steel-300" />
                        </div>
                        <div>
                          <span className="text-sm font-semibold text-white">{area.label}</span>
                          <span className={`ml-2 text-[10px] font-bold uppercase tracking-wider ${areaMeta.color}`}>
                            {areaMeta.label}
                          </span>
                        </div>
                      </div>
                      <p className="text-xs text-steel-400 leading-relaxed">{areaData.note}</p>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* Recommendations */}
          {evalData?.recommendations && (
            <div className="card p-6 border-accent-500/20">
              <h3 className="text-sm font-semibold text-white mb-3 flex items-center gap-2">
                <TrendingUp className="w-4 h-4 text-accent-400" />
                Recommended Starting Points
              </h3>
              <p className="text-sm text-steel-300 leading-relaxed mb-5">
                {evalData.recommendations}
              </p>

              {/* CTA buttons to recommended stages */}
              <div className="flex flex-wrap gap-3">
                {STAGES.map((stage) => {
                  const Icon = STAGE_ICON[stage.key];
                  const isRecommended = evalData.recommended_stage === stage.key;
                  return (
                    <button
                      key={stage.key}
                      onClick={() => onNavigate({ name: 'paths', focusPath: stage.key === 'ie' ? 'electrical' : stage.key === 'engineering' ? 'mechanical' : stage.key as 'electrical' | 'mechanical' })}
                      className={`inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all border ${
                        isRecommended
                          ? 'border-accent-500/50 bg-accent-500/15 text-accent-200 shadow-[0_0_20px_rgba(56,189,248,0.12)]'
                          : 'border-steel-700/60 bg-navy-900/80 text-steel-300 hover:border-steel-500 hover:text-white'
                      }`}
                    >
                      <Icon className="w-4 h-4" />
                      {stage.label}
                      {isRecommended && <span className="text-[10px] font-bold uppercase tracking-wider">Start here</span>}
                    </button>
                  );
                })}
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

  /* ─── OVERVIEW TAB ─── */
  function renderOverview() {
    return (
      <div className="pt-[100px]">
        {/* Hero */}
        <section className="relative overflow-hidden">
          <div className="absolute inset-0">
            <img
              src="/hero-plant-floor.webp"
              alt="Industrial plant floor"
              className="w-full h-full object-cover opacity-35"
            />
            <div className="absolute inset-0 bg-gradient-to-r from-navy-950 via-navy-900/90 to-navy-900/60" />
            <div className="absolute inset-0 geometric-overlay" />
            <div className="absolute inset-0 bg-grid-steel bg-grid-32 opacity-20" />
            <div className="absolute -right-32 top-0 w-[55%] h-full bg-gradient-to-l from-rok-500/25 via-crimson-500/10 to-transparent skew-x-[-12deg] origin-top" />
          </div>

          <div className="relative max-w-7xl mx-auto px-4 sm:px-6 py-20 sm:py-28 lg:py-32">
            <div className="max-w-3xl">
              <div className="mb-6 rounded-lg border border-rok-500/40 bg-navy-950/80 px-4 py-3 text-sm text-steel-200 animate-fade-in">
                <p className="flex items-start gap-2 leading-relaxed">
                  <Construction className="w-4 h-4 text-rok-400 shrink-0 mt-0.5" />
                  <span>
                    <span className="font-semibold text-white">This site is in beta testing.</span>
                    {' '}Training is live while we continue improving the experience. Use code{' '}
                    <span className="font-bold text-rok-300 tracking-wider">75OFF</span>{' '}
                    for discounted premium features.
                  </span>
                </p>
              </div>
              <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-rok-500/15 border border-rok-500/40 text-rok-300 text-xs font-semibold uppercase tracking-wider mb-6 animate-fade-in">
                <ShieldCheck className="w-3.5 h-3.5" />
                Plant-floor proven · Built by industrial electricians and engineers
              </div>
              <h1 className="font-display text-4xl sm:text-5xl lg:text-6xl xl:text-7xl font-bold text-white leading-[1.05] mb-6 animate-fade-in">
                Master the Plant Floor
                <span className="block text-steel-200 text-2xl sm:text-3xl lg:text-4xl font-semibold mt-3">
                  From Mechanical Foundations to Engineering Excellence
                </span>
              </h1>
              <p className="text-lg sm:text-xl text-steel-300 leading-relaxed max-w-2xl mb-8 animate-fade-in">
                The structured career ladder for industrial electricians, millwrights,
                I&amp;E technicians, and maintenance engineers. Start free. Advance when
                you're ready. Real skills for real plants.
              </p>
              <div className="flex flex-wrap gap-3 animate-fade-in">
                <button
                  onClick={() => onNavigate(user ? { name: 'paths', focusPath: 'electrical' } : { name: 'auth', mode: 'signup', path: 'electrical' } as Route & { mode?: string; path?: string })}
                  className="btn-primary text-base px-7 py-3.5 shadow-rok-lg"
                >
                  Start Free — Electrical Path
                  <ArrowRight className="w-4 h-4" />
                </button>
                <button
                  onClick={() => onNavigate(user ? { name: 'paths', focusPath: 'mechanical' } : { name: 'auth', mode: 'signup', path: 'mechanical' } as Route & { mode?: string; path?: string })}
                  className="btn-outline-rok text-base px-6 py-3.5"
                >
                  Start Free — Mechanical Path
                </button>
              </div>

              <div className="mt-10 flex flex-wrap items-center gap-x-6 gap-y-2 text-xs text-steel-500 animate-fade-in">
                <div className="flex items-center gap-1.5">
                  <ShieldCheck className="w-3.5 h-3.5 text-rok-400" />
                  <span>Built by working industrial electricians for plant-floor techs</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <Award className="w-3.5 h-3.5 text-rok-400" />
                  <span>Certificates of completion for your records</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <BookOpen className="w-3.5 h-3.5 text-rok-400" />
                  <span>Free Mechanical &amp; Electrical paths</span>
                </div>
              </div>

              <div className="mt-8 flex flex-wrap items-center gap-x-8 gap-y-3 text-sm text-steel-400 animate-fade-in">
                <div className="flex items-center gap-2">
                  <BookOpen className="w-4 h-4 text-rok-400" />
                  <span>{courses.length || 78} structured courses</span>
                </div>
                <div className="flex items-center gap-2">
                  <Target className="w-4 h-4 text-rok-400" />
                  <span>4 progressive stages</span>
                </div>
                <div className="flex items-center gap-2">
                  <Award className="w-4 h-4 text-rok-400" />
                  <span>Certificates on completion</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Career Ladder Overview */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 py-16">
          <div className="text-center mb-12">
            <div className="rok-bar mx-auto mb-4" />
            <h2 className="font-display text-3xl sm:text-4xl font-bold text-white mb-3">
              One Career Ladder. Four Stages.
            </h2>
            <p className="text-steel-400 max-w-2xl mx-auto text-lg">
              Every stage builds on the last. Start with free Mechanical and Electrical
              foundations, then unlock premium I&amp;E and Engineering when you&apos;re ready
              to move up.
            </p>
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {STAGES.map((stage, idx) => {
              const Icon = STAGE_ICON[stage.key];
              const STAGE_COURSE_FALLBACK: Record<Stage, number> = {
                mechanical: 22,
                electrical: 22,
                ie: 18,
                engineering: 16,
              };
              const count = byStage[stage.key]?.length || STAGE_COURSE_FALLBACK[stage.key];
              return (
                <button
                  key={stage.key}
                  onClick={() => onNavigate({ name: 'paths' })}
                  className={`group relative text-left card p-6 border bg-gradient-to-b ${STAGE_COLOR[stage.key]} card-hover`}
                >
                  <div className="flex items-start justify-between mb-4">
                    <div className="w-12 h-12 rounded-xl bg-navy-900/60 border border-steel-700/50 flex items-center justify-center group-hover:scale-110 transition-transform">
                      <Icon className="w-6 h-6 text-white" />
                    </div>
                    <span className="text-xs font-bold text-steel-500">0{idx + 1}</span>
                  </div>
                  <h3 className="font-display text-lg font-bold text-white mb-1">
                    {stage.label}
                  </h3>
                  <p className="text-sm text-steel-400 mb-4 line-clamp-2">
                    {stage.tagline}
                  </p>
                  <div className="flex items-center justify-between">
                    {stage.tier === 'free' ? (
                      <span className="badge-free">Free</span>
                    ) : (
                      <span className="badge-premium">
                        <Lock className="w-3 h-3" /> Premium
                      </span>
                    )}
                    <span className="text-xs text-steel-500">
                      {count} course{count !== 1 ? 's' : ''}
                    </span>
                  </div>
                </button>
              );
            })}
          </div>

          <div className="mt-10 text-center">
            <button
              onClick={() => onNavigate({ name: 'paths' })}
              className="btn-primary px-6 py-3"
            >
              View Full Learning Paths
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
          <div className="mt-10 max-w-3xl mx-auto">
            <PlantFloorLinks />
          </div>
        </section>

        {/* Course carousels */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 pb-8">
          <Carousel title="Featured Free Courses" subtitle="Start learning today — no payment required">
            {renderCards(featuredFree)}
          </Carousel>
          <Carousel title="Start Your Path" subtitle="The first steps on the career ladder">
            {renderCards(startPath)}
          </Carousel>
          <Carousel title="Most Popular" subtitle="What technicians and engineers are working through right now">
            {renderCards(mostPopular)}
          </Carousel>
          <Carousel title="Recently Added" subtitle="Newest content across all stages">
            {renderCards(recentlyAdded)}
          </Carousel>
        </section>

        {/* Value props */}
        <section className="border-y border-steel-700/40 bg-navy-950/50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 py-14">
            <div className="grid md:grid-cols-3 gap-8">
              <div className="flex gap-4">
                <div className="w-11 h-11 rounded-lg bg-rok-500/15 border border-rok-500/30 flex items-center justify-center shrink-0">
                  <ShieldCheck className="w-5 h-5 text-rok-400" />
                </div>
                <div>
                  <h3 className="font-semibold text-white mb-1">Plant-Floor Realism</h3>
                  <p className="text-sm text-steel-400 leading-relaxed">
                    Content written by working industrial electricians and I&amp;E techs —
                    not generic theory. Real procedures, real troubleshooting.
                  </p>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="w-11 h-11 rounded-lg bg-rok-500/15 border border-rok-500/30 flex items-center justify-center shrink-0">
                  <TrendingUp className="w-5 h-5 text-rok-400" />
                </div>
                <div>
                  <h3 className="font-semibold text-white mb-1">Clear Career Ladder</h3>
                  <p className="text-sm text-steel-400 leading-relaxed">
                    Progressive stages from Mechanical → Electrical → I&amp;E → Engineering.
                    Know exactly where you stand and what comes next.
                  </p>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="w-11 h-11 rounded-lg bg-rok-500/15 border border-rok-500/30 flex items-center justify-center shrink-0">
                  <CheckCircle2 className="w-5 h-5 text-rok-400" />
                </div>
                <div>
                  <h3 className="font-semibold text-white mb-1">Certificates of Completion</h3>
                  <p className="text-sm text-steel-400 leading-relaxed">
                    Finish a course and the quizzes, get a numbered certificate for your training records.
                    It documents what you completed. It is not a license or a plant qualification.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Proof / trust section */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 py-14">
          <div className="text-center mb-8">
            <div className="rok-bar mx-auto mb-3" />
            <h2 className="font-display text-2xl sm:text-3xl font-bold text-white mb-2">Built for the Plant Floor</h2>
            <p className="text-sm text-steel-400">Real experience, real training, real support.</p>
          </div>
          <div className="grid sm:grid-cols-3 gap-4 mb-8">
            {[
              { icon: Wrench, text: 'Built by working industrial electricians for plant-floor crews' },
              { icon: CheckCircle2, text: 'Certificates of completion for training records' },
              { icon: Zap, text: 'Online training + on-site classes + troubleshooting support' },
            ].map((item, i) => {
              const Icon = item.icon;
              return (
                <div key={i} className="rounded-lg border border-steel-700/40 bg-navy-950/30 p-4 text-center">
                  <Icon className="w-6 h-6 text-rok-400 mx-auto mb-2" />
                  <p className="text-sm text-steel-300 leading-relaxed">{item.text}</p>
                </div>
              );
            })}
          </div>
        </section>

        {/* On-site & Troubleshooting section */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 py-16">
          <div className="text-center mb-10">
            <div className="rok-bar mx-auto mb-4" />
            <h2 className="font-display text-3xl sm:text-4xl font-bold text-white mb-3">
              Need more than online training?
            </h2>
            <p className="text-steel-400 max-w-2xl mx-auto text-lg">
              ForgeLine also comes to your facility. On-site classes and plant
              troubleshooting support for when online courses aren&apos;t enough.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-6">
            <div className="card p-7 border-rok-500/20 relative overflow-hidden">
              <div className="absolute -right-16 -top-16 w-40 h-40 rounded-full bg-rok-500/8 blur-3xl" />
              <div className="relative">
                <div className="w-12 h-12 rounded-xl bg-rok-500/15 border border-rok-500/30 flex items-center justify-center mb-5">
                  <Wrench className="w-6 h-6 text-rok-400" />
                </div>
                <h3 className="font-display text-xl font-bold text-white mb-2">On-Site Training</h3>
                <p className="text-sm text-steel-400 mb-4 leading-relaxed">
                  Practical classes at your facility. Motor control, VFDs, troubleshooting
                  methods, instrumentation basics. Half-day to multi-day options.
                </p>
                <button onClick={() => onNavigate({ name: 'services' })} className="btn-primary text-sm">
                  Request on-site training
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </div>

            <div className="card p-7 border-accent-500/20 relative overflow-hidden">
              <div className="absolute -right-16 -top-16 w-40 h-40 rounded-full bg-accent-500/8 blur-3xl" />
              <div className="relative">
                <div className="w-12 h-12 rounded-xl bg-accent-500/15 border border-accent-500/30 flex items-center justify-center mb-5">
                  <Stethoscope className="w-6 h-6 text-accent-400" />
                </div>
                <h3 className="font-display text-xl font-bold text-white mb-2">Plant Troubleshooting Support</h3>
                <p className="text-sm text-steel-400 mb-4 leading-relaxed">
                  Remote or on-site help when equipment won&apos;t run. Diagnostic support
                  for electrical, motor control, VFD, and industrial systems. Priority
                  retainers available.
                </p>
                <button onClick={() => onNavigate({ name: 'services' })} className="btn-secondary text-sm">
                  Request troubleshooting help
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </section>

        {/* CTA banner */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 py-16">
          <div className="relative overflow-hidden rounded-2xl border border-rok-500/30 bg-gradient-to-br from-navy-800 via-navy-900 to-navy-950 p-8 sm:p-12">
            <div className="absolute inset-0 bg-grid-steel bg-grid-32 opacity-15" />
            <div className="absolute -right-20 -top-20 w-72 h-72 rounded-full bg-rok-500/15 blur-3xl" />
            <div className="absolute -left-16 bottom-0 w-56 h-56 rounded-full bg-crimson-500/10 blur-3xl" />
            <div className="relative flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
              <div className="max-w-xl">
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-premium-500/15 border border-premium-500/30 text-premium-400 text-xs font-semibold uppercase tracking-wider mb-4">
                  <TrendingUp className="w-3.5 h-3.5" />
                  Unlock Advanced Skills
                </div>
                <h3 className="font-display text-2xl sm:text-3xl font-bold text-white mb-2">
                  Ready for Instrumentation &amp; Engineering?
                </h3>
                <p className="text-steel-300 leading-relaxed">
                  Premium unlocks I&amp;E and Engineering — smart instrumentation, DCS
                  troubleshooting, PLC best practices, reliability engineering, and
                  functional safety. The skills that move you from tech to engineer.
                </p>
              </div>
              <button onClick={() => onNavigate({ name: 'pricing' })} className="btn-premium text-base px-7 py-3.5 shrink-0">
                View Plans
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        </section>
      </div>
    );
  }

  /* ─── RENDER ─── */
  return (
    <>
      {/* Tab bar */}
      {user && (
        <div className="fixed top-[64px] inset-x-0 z-40 bg-navy-900/95 backdrop-blur-md border-b border-steel-700/50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6">
            <div className="flex items-center gap-1">
              <TabButton active={tab === 'overview'} onClick={() => setTab('overview')}>
                Overview
              </TabButton>
              <TabButton active={tab === 'foryou'} onClick={() => setTab('foryou')}>
                <span className="inline-flex items-center gap-1.5">
                  For You
                  {assessment && (
                    <span className="inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded-full bg-accent-500/15 border border-accent-500/30 text-accent-300 text-[9px] font-bold uppercase tracking-wider">
                      <Sparkles className="w-2.5 h-2.5" />
                      Personalized
                    </span>
                  )}
                </span>
              </TabButton>
            </div>
          </div>
        </div>
      )}

      {tab === 'overview' ? renderOverview() : renderForYou()}
    </>
  );
}

function TabButton({ active, onClick, children }: { active: boolean; onClick: () => void; children: React.ReactNode }) {
  return (
    <button
      onClick={onClick}
      className={`relative px-4 py-3 text-sm font-medium transition-colors ${
        active ? 'text-white' : 'text-steel-400 hover:text-steel-200'
      }`}
    >
      {children}
      {active && (
        <span className="absolute bottom-0 left-2 right-2 h-0.5 rounded-full bg-gradient-to-r from-rok-500 to-accent-400" />
      )}
    </button>
  );
}
