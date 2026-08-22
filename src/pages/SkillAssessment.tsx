import { useEffect, useRef, useState } from 'react';
import {
  Sparkles,
  Loader2,
  CheckCircle2,
  ArrowRight,
  ArrowLeft,
  Wrench,
  Zap,
  Gauge,
  Cpu,
  Award,
  Hexagon,
  Check,
  X,
  RotateCcw,
  Lock,
} from 'lucide-react';
import {
  generateQuestions,
  evaluateAssessment,
  saveAssessmentResult,
  checkRetakeEligibility,
  resetAssessment,
  type MCQuestion,
  type AnswerRecord,
  type AssessmentEvaluation,
  type AssessmentArea,
  type RetakeEligibility,
} from '@/lib/assessment';
import { useAuth } from '@/lib/auth';
import type { Route } from '@/components/Nav';

interface SkillAssessmentProps {
  onComplete: () => void;
  onNavigate: (r: Route) => void;
}

const LEVEL_META: Record<
  string,
  { label: string; color: string; ring: string; bar: string; icon: typeof Award }
> = {
  novice: {
    label: 'Novice',
    color: 'text-emerald-300',
    ring: 'ring-emerald-500/30',
    bar: 'from-emerald-500 to-emerald-400',
    icon: Sparkles,
  },
  intermediate: {
    label: 'Intermediate',
    color: 'text-sky-300',
    ring: 'ring-sky-500/30',
    bar: 'from-sky-500 to-accent-400',
    icon: Zap,
  },
  advanced: {
    label: 'Advanced',
    color: 'text-rok-300',
    ring: 'ring-rok-500/30',
    bar: 'from-rok-500 to-rok-400',
    icon: Gauge,
  },
  expert: {
    label: 'Expert',
    color: 'text-violet-300',
    ring: 'ring-violet-500/30',
    bar: 'from-violet-500 to-premium-400',
    icon: Award,
  },
};

const AREA_META: Record<AssessmentArea, { icon: typeof Wrench; label: string; color: string }> = {
  mechanical: { icon: Wrench, label: 'Mechanical', color: 'text-premium-400' },
  electrical: { icon: Zap, label: 'Electrical', color: 'text-accent-400' },
  ie: { icon: Gauge, label: 'I&E', color: 'text-rok-400' },
  engineering: { icon: Cpu, label: 'Engineering', color: 'text-crimson-400' },
};

export function SkillAssessment({ onComplete }: SkillAssessmentProps) {
  const { refreshPremium, isPremium, isAdmin } = useAuth();
  const [phase, setPhase] = useState<'loading' | 'quiz' | 'evaluating' | 'result'>('loading');
  const [error, setError] = useState<string | null>(null);
  const [questions, setQuestions] = useState<MCQuestion[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState<AnswerRecord[]>([]);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [evaluation, setEvaluation] = useState<AssessmentEvaluation | null>(null);
  const [score, setScore] = useState(0);
  const [eligibility, setEligibility] = useState<RetakeEligibility | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    void loadQuestions();
  }, []);

  async function loadQuestions() {
    setPhase('loading');
    setError(null);
    try {
      const qs = await generateQuestions();
      setQuestions(qs);
      setCurrentIndex(0);
      setAnswers([]);
      setSelectedOption(null);
      setPhase('quiz');
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load assessment.');
      setPhase('loading');
    }
  }

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = 0;
    }
  }, [currentIndex, phase]);

  async function handleNext() {
    if (selectedOption === null) return;

    const q = questions[currentIndex];
    const isCorrect = selectedOption === q.correctIndex;
    const answer: AnswerRecord = {
      questionIndex: currentIndex,
      selectedIndex: selectedOption,
      correct: isCorrect,
    };

    const newAnswers = [...answers, answer];
    setAnswers(newAnswers);

    if (currentIndex + 1 < questions.length) {
      setCurrentIndex(currentIndex + 1);
      setSelectedOption(null);
    } else {
      // All questions answered — evaluate
      setPhase('evaluating');
      try {
        const result = await evaluateAssessment(questions, newAnswers);
        await saveAssessmentResult(result.evaluation, newAnswers, result.score, result.totalQuestions);
        await refreshPremium();
        setEvaluation(result.evaluation);
        setScore(result.score);
        setPhase('result');

        // Check retake eligibility for the result screen
        const elig = await checkRetakeEligibility(isPremium, isAdmin);
        setEligibility(elig);
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Failed to evaluate assessment.');
        setPhase('quiz');
      }
    }
  }

  function handleBack() {
    if (currentIndex === 0) return;
    setCurrentIndex(currentIndex - 1);
    // Restore previous answer selection
    const prevAnswer = answers[currentIndex - 1];
    setSelectedOption(prevAnswer ? prevAnswer.selectedIndex : null);
    // Remove the answer for the question we're going back to (so it can be re-answered)
    setAnswers(answers.slice(0, currentIndex - 1));
  }

  async function handleRetake() {
    if (!eligibility?.canRetake) return;
    setPhase('loading');
    await resetAssessment();
    await loadQuestions();
  }

  /* ─── LOADING ─── */
  if (phase === 'loading') {
    return (
      <div className="pt-16 min-h-screen flex items-center justify-center relative">
        <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_center,_rgba(56,189,248,0.06),_transparent_50%)]" />
        <div className="relative flex flex-col items-center gap-4">
          <div className="relative">
            <div className="absolute inset-0 rounded-full bg-accent-500/20 blur-xl" />
            <Loader2 className="relative h-10 w-10 text-accent-400 animate-spin" />
          </div>
          <p className="text-sm text-steel-400 tracking-wide">
            {error ? error : 'Preparing your assessment…'}
          </p>
          {error && (
            <button onClick={() => loadQuestions()} className="btn-primary text-sm mt-2">
              Try again
            </button>
          )}
          {!error && (
            <button onClick={onComplete} className="text-xs text-steel-500 hover:text-steel-300 transition-colors mt-1">
              Skip for now
            </button>
          )}
        </div>
      </div>
    );
  }

  /* ─── EVALUATING ─── */
  if (phase === 'evaluating') {
    return (
      <div className="pt-16 min-h-screen flex items-center justify-center relative">
        <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_center,_rgba(56,189,248,0.06),_transparent_50%)]" />
        <div className="relative flex flex-col items-center gap-4">
          <div className="relative">
            <div className="absolute inset-0 rounded-full bg-accent-500/20 blur-xl" />
            <Loader2 className="relative h-10 w-10 text-accent-400 animate-spin" />
          </div>
          <p className="text-sm text-steel-400 tracking-wide">Evaluating your responses…</p>
        </div>
      </div>
    );
  }

  /* ─── RESULT ─── */
  if (phase === 'result' && evaluation) {
    const meta = LEVEL_META[evaluation.level] ?? LEVEL_META.novice;
    const LevelIcon = meta.icon;
    const totalQs = questions.length || answers.length;
    const scorePct = totalQs > 0 ? Math.round((score / totalQs) * 100) : 0;

    return (
      <div className="pt-16 min-h-screen relative overflow-hidden">
        <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_top,_rgba(236,104,43,0.08),_transparent_55%)]" />
        <div className="pointer-events-none absolute inset-0 bg-grid-steel bg-grid-32 opacity-20" />

        <div ref={scrollRef} className="relative max-w-xl mx-auto px-4 py-12 max-h-screen overflow-y-auto">
          <div className="rounded-2xl border border-steel-700/60 bg-navy-900/80 backdrop-blur-xl shadow-2xl overflow-hidden">
            <div className={`h-1 w-full bg-gradient-to-r ${meta.bar}`} />

            <div className="p-8 sm:p-10 text-center">
              <div className={`mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-navy-950 ring-1 ${meta.ring}`}>
                <LevelIcon className={`h-8 w-8 ${meta.color}`} />
              </div>

              <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-steel-500 mb-2">
                Assessment complete
              </p>
              <h1 className={`font-display text-3xl font-bold ${meta.color} mb-1`}>
                {meta.label}
              </h1>
              <p className="text-sm text-steel-400 mb-2">
                You scored {score} out of {totalQs} ({scorePct}%)
              </p>

              {/* Per-area breakdown */}
              {evaluation.areas && (
                <div className="rounded-xl border border-steel-700/50 bg-navy-950/70 p-5 text-left mb-4 mt-6">
                  <h3 className="text-[11px] font-semibold uppercase tracking-wider text-steel-500 mb-3">
                    Area Breakdown
                  </h3>
                  <div className="space-y-3">
                    {(Object.keys(AREA_META) as AssessmentArea[]).map((key) => {
                      const areaData = evaluation.areas[key];
                      if (!areaData) return null;
                      const areaMeta = AREA_META[key];
                      const areaLevelMeta = LEVEL_META[areaData.level] ?? LEVEL_META.novice;
                      const AreaIcon = areaMeta.icon;
                      return (
                        <div key={key} className="flex items-start gap-3">
                          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-navy-900 border border-steel-700/50">
                            <AreaIcon className={`h-4 w-4 ${areaMeta.color}`} />
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2 mb-0.5">
                              <span className="text-sm font-semibold text-white">{areaMeta.label}</span>
                              <span className={`text-[10px] font-bold uppercase tracking-wider ${areaLevelMeta.color}`}>
                                {areaLevelMeta.label}
                              </span>
                            </div>
                            <p className="text-xs text-steel-400 leading-relaxed">{areaData.note}</p>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}

              <div className="rounded-xl border border-steel-700/50 bg-navy-950/70 p-5 text-left mb-4">
                <h3 className="text-[11px] font-semibold uppercase tracking-wider text-steel-500 mb-2">
                  Summary
                </h3>
                <p className="text-sm text-steel-200 leading-relaxed">{evaluation.summary}</p>
              </div>

              <div className="rounded-xl border border-steel-700/50 bg-navy-950/70 p-5 text-left mb-8">
                <h3 className="text-[11px] font-semibold uppercase tracking-wider text-steel-500 mb-2">
                  Recommended starting points
                </h3>
                <p className="text-sm text-steel-200 leading-relaxed">
                  {evaluation.recommendations}
                </p>
              </div>

              {/* Retake section */}
              {eligibility && (
                <div className="mb-6">
                  {eligibility.canRetake ? (
                    <button
                      onClick={handleRetake}
                      className="w-full inline-flex items-center justify-center gap-2 rounded-xl border border-steel-700/60 bg-navy-900/80 px-4 py-3 text-sm font-medium text-steel-300 hover:border-steel-500 hover:text-white transition-all mb-3"
                    >
                      <RotateCcw className="h-4 w-4" />
                      Retake assessment
                    </button>
                  ) : (
                    <div className="rounded-xl border border-steel-700/50 bg-navy-950/60 px-4 py-3 text-left">
                      <div className="flex items-center gap-2 mb-1.5">
                        <Lock className="h-4 w-4 text-steel-500" />
                        <span className="text-xs font-semibold text-steel-400">Retake locked</span>
                      </div>
                      <p className="text-xs text-steel-500 leading-relaxed">{eligibility.reason}</p>
                    </div>
                  )}
                </div>
              )}

              <button
                onClick={onComplete}
                className="btn-primary w-full inline-flex items-center justify-center gap-2"
              >
                Enter ForgeLine Academy
                <ArrowRight className="h-4 w-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  /* ─── QUIZ ─── */
  const q = questions[currentIndex];
  if (!q) return null;

  const areaMeta = AREA_META[q.area] ?? AREA_META.mechanical;
  const AreaIcon = areaMeta.icon;
  const progress = ((currentIndex + 1) / questions.length) * 100;

  return (
    <div className="pt-16 min-h-screen flex flex-col relative">
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_top,_rgba(236,104,43,0.05),_transparent_50%)]" />

      {/* Header */}
      <header className="relative border-b border-steel-700/50 bg-navy-950/70 backdrop-blur-md">
        <div className="max-w-2xl mx-auto px-4 sm:px-6 py-6">
          <div className="flex items-start gap-3 mb-5">
            <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-rok-500/20 to-accent-500/10 ring-1 ring-rok-500/30">
              <Hexagon className="h-5 w-5 text-rok-400" strokeWidth={1.75} />
            </div>
            <div>
              <h1 className="font-display text-xl sm:text-2xl font-bold text-white tracking-tight">
                Skill Assessment
              </h1>
              <p className="text-sm text-steel-400 mt-0.5">
                Select the best answer for each question.
              </p>
            </div>
          </div>

          <div className="flex items-center justify-between gap-3">
            {/* Progress */}
            <div className="flex-1 h-1.5 rounded-full bg-navy-800 overflow-hidden ring-1 ring-steel-700/40">
              <div
                className="h-full rounded-full bg-gradient-to-r from-rok-500 to-accent-400 transition-all duration-500 ease-out"
                style={{ width: `${progress}%` }}
              />
            </div>
            <span className="text-[11px] font-semibold tabular-nums text-steel-400 min-w-[2.5rem] text-right">
              {currentIndex + 1}/{questions.length}
            </span>
            <button onClick={onComplete} className="text-xs text-steel-500 hover:text-steel-300 transition-colors whitespace-nowrap">
              Skip
            </button>
          </div>
        </div>
      </header>

      {/* Question */}
      <div ref={scrollRef} className="relative flex-1 overflow-y-auto">
        <div className="max-w-2xl mx-auto px-4 sm:px-6 py-6">
          {/* Area badge */}
          <div className="inline-flex items-center gap-1.5 rounded-full border border-steel-700/60 bg-navy-900/80 px-3 py-1 mb-4">
            <AreaIcon className={`h-3.5 w-3.5 ${areaMeta.color}`} />
            <span className="text-[11px] font-medium text-steel-300">{areaMeta.label}</span>
            <span className="text-[11px] text-steel-600">·</span>
            <span className="text-[11px] text-steel-500">{q.topic}</span>
          </div>

          {/* Question text */}
          <h2 className="font-display text-lg sm:text-xl font-semibold text-white leading-snug mb-6">
            {q.question}
          </h2>

          {/* Options */}
          <div className="space-y-3">
            {q.options.map((opt, i) => {
              const isSelected = selectedOption === i;
              return (
                <button
                  key={i}
                  onClick={() => setSelectedOption(i)}
                  className={`w-full text-left flex items-center gap-3 rounded-xl border px-4 py-3.5 transition-all ${
                    isSelected
                      ? 'border-rok-500/60 bg-rok-500/15 text-white shadow-[0_0_20px_rgba(236,104,43,0.12)]'
                      : 'border-steel-700/60 bg-navy-900/80 text-steel-200 hover:border-steel-500 hover:bg-navy-800/80'
                  }`}
                >
                  <div className={`flex h-7 w-7 shrink-0 items-center justify-center rounded-lg border text-xs font-bold transition-all ${
                    isSelected
                      ? 'border-rok-500 bg-rok-500/20 text-rok-200'
                      : 'border-steel-600 bg-navy-950 text-steel-400'
                  }`}>
                    {String.fromCharCode(65 + i)}
                  </div>
                  <span className="text-sm leading-relaxed flex-1">{opt}</span>
                  {isSelected && <Check className="h-4 w-4 text-rok-400 shrink-0" />}
                </button>
              );
            })}
          </div>

          {error && (
            <div className="mt-4 rounded-xl border border-error-500/30 bg-error-500/10 px-4 py-3 text-sm text-error-300">
              {error}
            </div>
          )}
        </div>
      </div>

      {/* Footer nav */}
      <div className="relative border-t border-steel-700/50 bg-navy-950/85 backdrop-blur-md">
        <div className="max-w-2xl mx-auto px-4 sm:px-6 py-4 flex items-center gap-3">
          {currentIndex > 0 && (
            <button
              onClick={handleBack}
              className="inline-flex items-center gap-1.5 rounded-xl border border-steel-700/60 bg-navy-900/80 px-4 py-3 text-sm font-medium text-steel-300 hover:border-steel-500 hover:text-white transition-all"
            >
              <ArrowLeft className="h-4 w-4" />
              Back
            </button>
          )}
          <button
            onClick={handleNext}
            disabled={selectedOption === null}
            className="flex-1 inline-flex items-center justify-center gap-2 rounded-xl bg-gradient-to-br from-rok-500 to-rok-600 px-6 py-3 text-sm font-semibold text-white shadow-lg shadow-rok-500/20 hover:from-rok-400 hover:to-rok-500 disabled:opacity-40 disabled:cursor-not-allowed disabled:shadow-none transition-all"
          >
            {currentIndex + 1 === questions.length ? 'Finish & Evaluate' : 'Next Question'}
            <ArrowRight className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
