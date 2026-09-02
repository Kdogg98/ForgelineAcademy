import { useEffect, useMemo, useState, useCallback } from 'react';
import {
  ArrowLeft,
  Clock,
  Lock,
  CheckCircle2,
  Circle,
  FileText,
  HelpCircle,
  Award,
  ChevronDown,
  ChevronRight,
  Download,
  AlertCircle,
  BookOpen,
  PlayCircle,
  Loader2,
  Eye,
  Timer,
  Wrench,
} from 'lucide-react';
import type { Course, LessonWithModule, UserProgress, QuizLockState, EngagementState } from '@/lib/types';
import { STAGE_LABEL } from '@/lib/types';
import { getEmbedUrl } from '@/lib/video';
import {
  fetchCourse,
  fetchLessons,
  fetchLessonContent,
  fetchProgress,
  upsertProgress,
  issueCertificate,
} from '@/lib/data';
import { TierBadge, DifficultyBadge } from '@/components/ui/Badge';
import { ProgressBar } from '@/components/ui/ProgressBar';
import { useAuth } from '@/lib/auth';
import { supabase } from '@/lib/supabase';
import { AICourseTutor } from '@/components/AICourseTutor';
import { useLessonEngagement } from '@/lib/engagement';
import type { Route } from '@/components/Nav';
import { isBearingsGamesCourse } from '@/lib/games/bearingsLubricationAlignment';
import { getFlagshipStory } from '@/lib/seo/flagshipStories';
import { FlagshipCourseIntro } from '@/components/FlagshipCourseIntro';

interface CourseDetailProps {
  courseId: string;
  preloadedCourse?: Course | null;
  onNavigate: (r: Route) => void;
  onProgressChanged: () => void;
}

interface ModuleGroup {
  title: string;
  sort_order: number;
  lessons: LessonWithModule[];
}

export function CourseDetail({ courseId, preloadedCourse, onNavigate, onProgressChanged }: CourseDetailProps) {
  const { user, isPremium, isAdmin, company } = useAuth();
  const [course, setCourse] = useState<Course | null>(preloadedCourse ?? null);
  const [lessons, setLessons] = useState<LessonWithModule[]>([]);
  const [progress, setProgress] = useState<UserProgress[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeLesson, setActiveLesson] = useState<LessonWithModule | null>(null);
  const [openModules, setOpenModules] = useState<Set<string>>(new Set());
  const [quizAnswers, setQuizAnswers] = useState<Record<string, number>>({});
  const [quizResult, setQuizResult] = useState<{ score: number; passed: boolean } | null>(null);
  const [certIssued, setCertIssued] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lockState, setLockState] = useState<QuizLockState | null>(null);
  const [lockLoading, setLockLoading] = useState(false);
  const [pendingRetake, setPendingRetake] = useState(false);
  const [soloReviewed, setSoloReviewed] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [quizError, setQuizError] = useState<string | null>(null);
  const locked = course?.tier === 'premium' && !isPremium && !isAdmin;
  const engagementEnabled = Boolean(user) && !locked && Boolean(activeLesson);
  const { engagement, loading: engagementLoading, markContentOpened, relockQuiz, fetchEngagement } = useLessonEngagement(
    activeLesson?.id ?? null,
    true, // count while the lesson is open; pause only on hidden tab / leaving lesson
    engagementEnabled,
  );

  useEffect(() => {
    if (preloadedCourse && preloadedCourse.id === courseId) setCourse(preloadedCourse);
  }, [preloadedCourse, courseId]);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError(null);
    setActiveLesson(null);
    setQuizResult(null);
    setQuizAnswers({});
    (async () => {
      try {
        const [c, ls] = await Promise.all([
          preloadedCourse?.id === courseId ? Promise.resolve(preloadedCourse) : fetchCourse(courseId),
          fetchLessons(courseId),
        ]);
        if (cancelled) return;
        setCourse(c);
        setLessons(ls);
        if (user?.id) {
          const p = await fetchProgress(courseId);
          if (cancelled) return;
          setProgress(p);
        } else {
          setProgress([]);
        }
        if (ls.length > 0) {
          setOpenModules(new Set([ls[0].module_id]));
        }
      } catch (e) {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Failed to load course');
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [courseId, user?.id, preloadedCourse]);

  useEffect(() => {
    if (!activeLesson?.id || activeLesson.content) return;
    let cancelled = false;
    (async () => {
      try {
        const content = await fetchLessonContent(activeLesson.id);
        if (cancelled || content == null) return;
        setLessons((ls) => ls.map((l) => (l.id === activeLesson.id ? { ...l, content } : l)));
        setActiveLesson((cur) => (cur && cur.id === activeLesson.id ? { ...cur, content } : cur));
      } catch {
        // lesson body is optional; keep the shell
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [activeLesson?.id, activeLesson?.content]);

  const progressMap = useMemo(() => {
    const m: Record<string, UserProgress> = {};
    for (const p of progress) m[p.lesson_id] = p;
    return m;
  }, [progress]);

  const courseProgress = useMemo(() => {
    if (lessons.length === 0) return 0;
    const completed = lessons.filter((l) => progressMap[l.id]?.completed).length;
    return Math.round((completed / lessons.length) * 100);
  }, [lessons, progressMap]);

  const modules = useMemo<ModuleGroup[]>(() => {
    const map = new Map<string, ModuleGroup>();
    for (const l of lessons) {
      let g = map.get(l.module_id);
      if (!g) {
        g = { title: l.module_title, sort_order: l.module_sort_order, lessons: [] };
        map.set(l.module_id, g);
      }
      g.lessons.push(l);
    }
    return Array.from(map.values()).sort((a, b) => a.sort_order - b.sort_order);
  }, [lessons]);

  function toggleModule(id: string) {
    setOpenModules((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  async function loadLockState(lessonId: string) {
    if (!user) { setLockState(null); return; }
    setLockLoading(true);
    try {
      const { data, error: rpcErr } = await supabase.rpc('get_quiz_lock_state', { target_lesson_id: lessonId });
      if (rpcErr) throw rpcErr;
      setLockState(data as QuizLockState);
      // Check for pending retake request
      const { data: pending } = await supabase.rpc('get_pending_retake_request', { p_lesson_id: lessonId });
      setPendingRetake(pending !== null);
    } catch {
      setLockState(null);
      setPendingRetake(false);
    } finally {
      setLockLoading(false);
    }
  }

  useEffect(() => {
    if (activeLesson && activeLesson.quiz.length > 0) {
      void loadLockState(activeLesson.id);
      setSoloReviewed(false);
    } else {
      setLockState(null);
    }
  }, [activeLesson?.id, user]);

  // Mark content as opened when a lesson is selected (required for unlock)
  useEffect(() => {
    if (activeLesson?.id && engagementEnabled) {
      void markContentOpened(activeLesson.id);
    }
  }, [activeLesson?.id, engagementEnabled, markContentOpened]);

  async function handleSoloReviewConfirm(lesson: LessonWithModule) {
    try {
      await supabase.rpc('reset_quiz_fail_cycle', { p_lesson_id: lesson.id });
      await loadLockState(lesson.id);
      await fetchEngagement(lesson.id);
      setSoloReviewed(false);
      setQuizAnswers({});
      setQuizResult(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to reset');
    }
  }

  async function handleMarkComplete(lesson: LessonWithModule, score?: number) {
    if (!user) return;
    try {
      await upsertProgress({
        lesson_id: lesson.id,
        course_id: courseId,
        quiz_score: score ?? null,
        completed: true,
      });
      const p = await fetchProgress(courseId);
      setProgress(p);
      onProgressChanged();

      // Check if course complete
      const completedCount = lessons.filter((l) => {
        if (l.id === lesson.id) return true;
        return p.some((pp) => pp.lesson_id === l.id && pp.completed);
      }).length;

      if (completedCount === lessons.length && lessons.length > 0) {
        await issueCertificate(courseId);
        setCertIssued(true);
      }
    } catch (e) {
      setQuizError(e instanceof Error ? e.message : 'Failed to save progress');
    }
  }

  async function submitQuiz(lesson: LessonWithModule) {
    if (lesson.quiz.length === 0) {
      handleMarkComplete(lesson);
      return;
    }
    // Block if locked (3-fail lock)
    if (lockState?.locked) return;
    // Block if engagement not met
    if (!engagement.engaged) {
      setQuizError('Quiz locked — review the lesson material first.');
      return;
    }
    setSubmitting(true);
    setQuizError(null);
    let correct = 0;
    for (const [i, q] of lesson.quiz.entries()) {
      if (quizAnswers[`${lesson.id}-${i}`] === q.correctIndex) correct++;
    }
    const score = Math.round((correct / lesson.quiz.length) * 100);
    const passed = score >= lesson.pass_threshold;
    setQuizResult({ score, passed });
    try {
      const { data, error: rpcErr } = await supabase.rpc('record_quiz_attempt', {
        p_lesson_id: lesson.id,
        p_course_id: courseId,
        p_score: score,
        p_passed: passed,
      });
      if (rpcErr) throw rpcErr;
      const result = data as { locked: boolean; failed_in_cycle: number; company_id: string | null };
      setLockState({
        failed_in_cycle: result.failed_in_cycle,
        locked: result.locked,
        updated_at: new Date().toISOString(),
      });
      if (passed) {
        void handleMarkComplete(lesson, score);
      } else {
        // Re-lock engagement (shorter re-engagement required before retry)
        await relockQuiz(lesson.id);
        if (result.locked) {
          setPendingRetake(company != null);
          // Fire-and-forget retake notification (don't block on email failure)
          if (result.company_id) {
            supabase.functions.invoke('notify', {
              body: {
                type: 'retake_request',
                member_name: user?.email ?? 'Team member',
                member_email: user?.email ?? null,
                course_title: course?.title ?? 'Unknown course',
                lesson_title: lesson.title,
                failed_attempts: result.failed_in_cycle,
              },
            }).catch(() => {});
          }
        }
      }
    } catch (e) {
      setQuizError(e instanceof Error ? e.message : 'Failed to record attempt');
    } finally {
      setSubmitting(false);
    }
  }

  if (loading && !course) {
    return (
      <div className="pt-16 min-h-screen">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8">
          <div className="skeleton h-6 w-24 mb-6" />
          <div className="skeleton h-48 w-full mb-6 rounded-xl" />
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2 space-y-4">
              <div className="skeleton h-8 w-3/4" />
              <div className="skeleton h-4 w-full" />
              <div className="skeleton h-4 w-2/3" />
            </div>
            <div className="skeleton h-64 w-full rounded-xl" />
          </div>
        </div>
      </div>
    );
  }

  if (error || !course) {
    return (
      <div className="pt-16 min-h-screen flex items-center justify-center">
        <div className="text-center">
          <AlertCircle className="w-12 h-12 text-error-500 mx-auto mb-4" />
          <h2 className="text-xl font-semibold text-white mb-2">Course not found</h2>
          <p className="text-steel-400 mb-4">{error ?? 'This course may have been moved.'}</p>
          <button onClick={() => onNavigate({ name: 'catalog' })} className="btn-secondary">
            Back to Catalog
          </button>
        </div>
      </div>
    );
  }

  const flagship = getFlagshipStory(courseId);

  return (
    <div className="pt-16 min-h-screen">
      {/* Course header */}
      <div className="relative border-b border-steel-700/60 bg-navy-950/40 overflow-hidden">
        <div className="absolute inset-0 bg-grid-steel bg-grid-32 opacity-20" />
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 py-8">
          <button
            onClick={() => onNavigate({ name: 'catalog' })}
            className="flex items-center gap-1.5 text-sm text-steel-400 hover:text-white mb-4 transition-colors"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Catalog
          </button>

          <div className="flex flex-col lg:flex-row lg:items-start justify-between gap-6">
            <div className="flex-1">
              {flagship ? (
                <div className="text-xs font-semibold uppercase tracking-wider text-accent-300 mb-3">
                  {flagship.eyebrow}
                </div>
              ) : (
              <div className="flex flex-wrap items-center gap-2 mb-3">
                <span className="text-xs font-semibold uppercase tracking-wider text-accent-300">
                  {STAGE_LABEL[course.stage]} Stage
                </span>
                <TierBadge tier={course.tier} />
                <DifficultyBadge difficulty={course.difficulty} />
                <span className="flex items-center gap-1 text-xs text-steel-400">
                  <Clock className="w-3.5 h-3.5" />
                  {course.estimated_hours} hours
                </span>
              </div>
              )}
              <h1 className="font-display text-2xl sm:text-3xl font-bold text-white mb-3">
                {course.title}
              </h1>
              {flagship ? (
                <>
                  <p className="text-steel-300 leading-relaxed max-w-3xl text-lg">
                    {flagship.dek}
                  </p>
                  <FlagshipCourseIntro story={flagship} onNavigate={onNavigate} />
                </>
              ) : (
              <>
              <p className="text-steel-300 leading-relaxed max-w-3xl">
                {course.description}
              </p>

              {isBearingsGamesCourse(courseId) && (
              <div className="mt-5">
                <button
                  type="button"
                  onClick={() => onNavigate({ name: 'games', courseId })}
                  className="btn-primary"
                >
                  <Wrench className="w-4 h-4" />
                  Shop-floor games
                </button>
              </div>
              )}
              </>
              )}
            </div>

            {user && !locked && (
              <div className="lg:w-72 shrink-0">
                <div className="card p-5">
                  {courseProgress === 0 ? (
                    <>
                      <div className="text-xs text-steel-400 mb-2">Not started</div>
                      <div className="text-xs text-steel-400">
                        {lessons.length} lessons · start the first one
                      </div>
                    </>
                  ) : (
                    <>
                      <div className="text-xs text-steel-400 mb-2">Your progress</div>
                      <div className="flex items-center gap-3 mb-3">
                        <ProgressBar value={courseProgress} />
                        <span className="text-lg font-bold text-white tabular-nums">
                          {courseProgress}%
                        </span>
                      </div>
                      <div className="text-xs text-steel-400">
                        {lessons.filter((l) => progressMap[l.id]?.completed).length} of{' '}
                        {lessons.length} lessons complete
                      </div>
                      {courseProgress === 100 && (
                        <div className="mt-3 flex items-center gap-2 text-sm text-premium-400 font-semibold">
                          <Award className="w-4 h-4" />
                          Certificate earned
                        </div>
                      )}
                    </>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Locked banner */}
      {locked && (
        <div className="max-w-7xl mx-auto px-4 sm:px-6 pt-8">
          <div className="card border-premium-500/30 bg-premium-500/5 p-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex items-start gap-3">
              <Lock className="w-6 h-6 text-premium-400 shrink-0 mt-0.5" />
              <div>
                <h3 className="font-semibold text-white mb-1">Premium Course</h3>
                <p className="text-sm text-steel-300">
                  This course is part of the {STAGE_LABEL[course.stage]} stage. Upgrade
                  to Premium to unlock all I&amp;E and Engineering content.
                </p>
              </div>
            </div>
            <button
              onClick={() => onNavigate({ name: 'pricing' })}
              className="btn-premium shrink-0"
            >
              Upgrade to unlock
            </button>
          </div>
        </div>
      )}

      {/* Main content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Lesson list */}
          <div className="lg:col-span-1 lg:order-2">
            <div className="card overflow-hidden lg:sticky lg:top-24">
              <div className="p-4 border-b border-steel-700/60">
                <h2 className="font-display text-lg font-semibold text-white">
                  Course Content
                </h2>
                <p className="text-xs text-steel-400 mt-0.5">
                  {modules.length} modules · {lessons.length} lessons
                </p>
              </div>
              <div className="max-h-[600px] overflow-y-auto">
                {modules.map((mod) => {
                  const open = openModules.has(mod.lessons[0]?.module_id ?? '');
                  const moduleId = mod.lessons[0]?.module_id ?? '';
                  return (
                    <div key={moduleId} className="border-b border-steel-700/40 last:border-0">
                      <button
                        onClick={() => toggleModule(moduleId)}
                        className="flex items-center gap-2 w-full p-3.5 hover:bg-navy-700/40 transition-colors text-left"
                      >
                        {open ? (
                          <ChevronDown className="w-4 h-4 text-steel-400 shrink-0" />
                        ) : (
                          <ChevronRight className="w-4 h-4 text-steel-400 shrink-0" />
                        )}
                        <span className="text-sm font-semibold text-white flex-1">
                          {mod.title}
                        </span>
                        <span className="text-xs text-steel-500">
                          {mod.lessons.filter((l) => progressMap[l.id]?.completed).length}/
                          {mod.lessons.length}
                        </span>
                      </button>
                      {open && (
                        <div className="pb-2">
                          {mod.lessons.map((l) => {
                            const done = progressMap[l.id]?.completed;
                            const isActive = activeLesson?.id === l.id;
                            return (
                              <button
                                key={l.id}
                                onClick={() => {
                                  setActiveLesson(l);
                                  setQuizResult(null);
                                  setQuizAnswers({});
                                }}
                                className={`flex items-start gap-2.5 w-full px-4 py-2.5 text-left transition-colors ${
                                  isActive
                                    ? 'bg-accent-500/10 border-l-2 border-accent-500'
                                    : 'hover:bg-navy-700/30 border-l-2 border-transparent'
                                }`}
                              >
                                {done ? (
                                  <CheckCircle2 className="w-4 h-4 text-success-500 shrink-0 mt-0.5" />
                                ) : locked ? (
                                  <Lock className="w-4 h-4 text-premium-400/50 shrink-0 mt-0.5" />
                                ) : (
                                  <Circle className="w-4 h-4 text-steel-600 shrink-0 mt-0.5" />
                                )}
                                <div className="flex-1 min-w-0">
                                  <div className={`text-sm ${done ? 'text-steel-400' : 'text-steel-100'} leading-snug`}>
                                    {l.title}
                                  </div>
                                  <div className="flex items-center gap-2 mt-1">
                                    <span className="text-[11px] text-steel-500">
                                      {l.estimated_minutes} min
                                    </span>
                                    {l.has_pdf && (
                                      <FileText className="w-3 h-3 text-steel-600" />
                                    )}
                                    {l.quiz.length > 0 && (
                                      <HelpCircle className="w-3 h-3 text-steel-600" />
                                    )}
                                  </div>
                                </div>
                              </button>
                            );
                          })}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Lesson content */}
          <div className="lg:col-span-2 lg:order-1">
            {!user ? (
              <div className="card p-8 text-center">
                <AlertCircle className="w-10 h-10 text-accent-400 mx-auto mb-4" />
                <h3 className="text-lg font-semibold text-white mb-2">
                  Sign in to start this course
                </h3>
                <p className="text-steel-400 mb-5 max-w-md mx-auto">
                  Create a free account to track your progress, complete knowledge
                  checks, and earn certificates. {course.tier === 'free' ? 'This course is free.' : 'This is a premium course.'}
                </p>
                <button
                  onClick={() => onNavigate({ name: 'auth' })}
                  className="btn-primary"
                >
                  Sign in / Create account
                </button>
              </div>
            ) : locked ? (
              activeLesson ? (
                <LockedLessonUpsell lesson={activeLesson} onNavigate={onNavigate} />
              ) : (
                <div className="card p-8 text-center">
                  <Lock className="w-10 h-10 text-premium-400 mx-auto mb-4" />
                  <h3 className="text-lg font-semibold text-white mb-2">
                    Browse the course structure
                  </h3>
                  <p className="text-steel-400 max-w-md mx-auto">
                    Click any lesson on the right to see what's included. Upgrade
                    to Premium to unlock all content.
                  </p>
                </div>
              )
            ) : activeLesson ? (
              <LessonView
                key={activeLesson.id}
                lesson={activeLesson}
                quizAnswers={quizAnswers}
                setQuizAnswers={setQuizAnswers}
                quizResult={quizResult}
                setQuizResult={setQuizResult}
                onSubmitQuiz={() => submitQuiz(activeLesson)}
                isCompleted={Boolean(progressMap[activeLesson.id]?.completed)}
                onMarkComplete={() => handleMarkComplete(activeLesson)}
                onNavigate={onNavigate}
                certIssued={certIssued}
                courseProgress={courseProgress}
                lockState={lockState}
                lockLoading={lockLoading}
                pendingRetake={pendingRetake}
                isCompanyUser={company != null}
                soloReviewed={soloReviewed}
                setSoloReviewed={setSoloReviewed}
                onSoloReviewConfirm={() => handleSoloReviewConfirm(activeLesson)}
                submitting={submitting}
                quizError={quizError}
                engagement={engagement}
                engagementLoading={engagementLoading}
              />
            ) : (
              <div className="card p-8 text-center">
                <BookOpen className="w-10 h-10 text-accent-400 mx-auto mb-4" />
                <h3 className="text-lg font-semibold text-white mb-2">
                  Select a lesson to begin
                </h3>
                <p className="text-steel-400">
                  Choose any lesson from the course content to start learning. Each
                  lesson includes in-depth reading material and a knowledge check.
                </p>
              </div>
            )}
          </div>
        </div>
      </div>

      <AICourseTutor
        courseTitle={course.title}
        stage={course.stage}
        lessonTitle={activeLesson?.title}
        lessonContent={activeLesson?.content}
        onUpgrade={() => onNavigate({ name: 'pricing' })}
      />
    </div>
  );
}

function LessonView({
  lesson,
  quizAnswers,
  setQuizAnswers,
  quizResult,
  setQuizResult,
  onSubmitQuiz,
  isCompleted,
  onMarkComplete,
  onNavigate,
  certIssued,
  courseProgress,
  lockState,
  lockLoading,
  pendingRetake,
  isCompanyUser,
  soloReviewed,
  setSoloReviewed,
  onSoloReviewConfirm,
  submitting,
  quizError,
  engagement,
  engagementLoading,
}: {
  lesson: LessonWithModule;
  quizAnswers: Record<string, number>;
  setQuizAnswers: (a: Record<string, number>) => void;
  quizResult: { score: number; passed: boolean } | null;
  setQuizResult: (r: { score: number; passed: boolean } | null) => void;
  onSubmitQuiz: () => void;
  isCompleted: boolean;
  onMarkComplete: () => void;
  onNavigate: (r: Route) => void;
  certIssued: boolean;
  courseProgress: number;
  lockState: QuizLockState | null;
  lockLoading: boolean;
  pendingRetake: boolean;
  isCompanyUser: boolean;
  soloReviewed: boolean;
  setSoloReviewed: (v: boolean) => void;
  onSoloReviewConfirm: () => void;
  submitting: boolean;
  quizError: string | null;
  engagement: EngagementState;
  engagementLoading: boolean;
}) {
  const downloadStudyNotes = useCallback((l: LessonWithModule) => {
    const date = new Date().toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });

    const divider = '═'.repeat(72);
    const thinDivider = '─'.repeat(72);

    const lines: string[] = [];

    // Branding header
    lines.push(divider);
    lines.push('  FORGELINE ACADEMY — STUDY NOTES');
    lines.push('  Industrial Maintenance & Controls Training');
    lines.push(divider);
    lines.push('');

    // Lesson header block
    lines.push('MODULE:      ' + l.module_title);
    lines.push('LESSON:      ' + l.title);
    lines.push('EST. TIME:   ' + l.estimated_minutes + ' minutes');
    lines.push('GENERATED:   ' + date);
    lines.push('');

    // Full lesson content
    if (l.content && l.content.length > 0) {
      lines.push(divider);
      lines.push('  LESSON CONTENT');
      lines.push(divider);
      lines.push('');
      // If content has ## markdown-style headers, format them
      const raw = l.content;
      if (raw.includes('##')) {
        const blocks = raw.split(/\n(?=##\s)/);
        blocks.forEach((block) => {
          const m = block.match(/^##\s+(.+)\n([\s\S]*)$/);
          if (m) {
            lines.push(m[1].toUpperCase());
            lines.push(thinDivider);
            lines.push(m[2].trim());
          } else {
            lines.push(block.trim());
          }
          lines.push('');
        });
      } else {
        lines.push(raw);
        lines.push('');
      }
    }

    // Key Study Focus
    lines.push(divider);
    lines.push('  KEY STUDY FOCUS');
    lines.push(divider);
    lines.push('');
    lines.push('1. UNDERSTAND THE WHY');
    lines.push('   Don\'t just memorize the procedure — understand the principle behind it.');
    lines.push('   If you know why a step matters, you can adapt when conditions change.');
    lines.push('   Ask yourself: what is the core concept here, and why does it exist?');
    lines.push('');
    lines.push('2. COMMON MISTAKES');
    lines.push('   Identify the top 2–3 errors technicians make with this material.');
    lines.push('   Think about what goes wrong when steps are skipped or done out of order.');
    lines.push('   Note the failure mode each mistake produces.');
    lines.push('');
    lines.push('3. SAFETY FIRST');
    lines.push('   What PPE is required? What energy sources must be isolated?');
    lines.push('   Never bypass safety interlocks or skip LOTO — even for a "quick check."');
    lines.push('   Know your site\'s emergency stop and isolation procedure before touching gear.');
    lines.push('');
    lines.push('4. EXPLAIN IT TO AN APPRENTICE');
    lines.push('   If you can\'t explain this in plain words to a first-year tech, you don\'t fully');
    lines.push('   understand it yet. Practice teaching the concept out loud — it exposes gaps.');
    lines.push('');

    // Review Questions (no answers)
    if (l.quiz.length > 0) {
      lines.push(divider);
      lines.push('  REVIEW QUESTIONS');
      lines.push('  (Answer these from memory — do not peek at the lesson above)');
      lines.push(divider);
      lines.push('');
      l.quiz.forEach((q, i) => {
        lines.push(`Q${i + 1}. ${q.question}`);
        q.options.forEach((opt, oi) => {
          lines.push(`    ${String.fromCharCode(65 + oi)}) ${opt}`);
        });
        lines.push('');
      });
    }

    // Field Application Check
    lines.push(divider);
    lines.push('  FIELD APPLICATION CHECK');
    lines.push('  (Self-check: you should be able to answer these after studying)');
    lines.push(divider);
    lines.push('');
    lines.push('1. Can I identify this equipment/component on my plant floor and explain its function?');
    lines.push('2. Can I perform the key procedure from this lesson safely and in the correct order?');
    lines.push('3. Can I troubleshoot the top failure modes described here without referring to notes?');
    lines.push('4. Can I explain the safety considerations and required PPE to a coworker before starting?');
    lines.push('');

    // Safety disclaimer
    lines.push(divider);
    lines.push('  SAFETY DISCLAIMER');
    lines.push(divider);
    lines.push('');
    lines.push('These study notes are a training aid and do NOT replace your site\'s Lockout/Tagout');
    lines.push('(LOTO) procedures, site-specific safety rules, OEM manuals, or any required licenses');
    lines.push('or certifications. Always follow your facility\'s safety procedures and consult');
    lines.push('qualified personnel before performing any work on industrial equipment.');
    lines.push('');

    // Branding footer
    lines.push(divider);
    lines.push('  FORGELINE ACADEMY — forgelineacademy.com');
    lines.push('  Plant-floor training for industrial maintenance & controls technicians');
    lines.push(divider);

    const content = lines.join('\n');

    // Build filename from lesson title
    const slug = l.title
      .replace(/[^a-zA-Z0-9\s]/g, '')
      .trim()
      .replace(/\s+/g, '_');
    const filename = `${slug}_Study_Notes.txt`;

    // Trigger download
    const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }, []);

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Lesson header */}
      <div className="card p-6">
        <div className="text-xs font-semibold uppercase tracking-wider text-steel-500 mb-2">
          {lesson.module_title}
        </div>
        <h2 className="font-display text-xl font-bold text-white mb-3">
          {lesson.title}
        </h2>
        <div className="flex flex-wrap items-center gap-3 text-xs text-steel-400">
          <span className="flex items-center gap-1">
            <Clock className="w-3.5 h-3.5" />
            {lesson.estimated_minutes} minutes
          </span>
          {lesson.has_pdf && (
            <span className="flex items-center gap-1">
              <FileText className="w-3.5 h-3.5" />
              PDF notes
            </span>
          )}
          {lesson.quiz.length > 0 && (
            <span className="flex items-center gap-1">
              <HelpCircle className="w-3.5 h-3.5" />
              Knowledge check ({lesson.pass_threshold}% to pass)
            </span>
          )}
          {isCompleted && (
            <span className="flex items-center gap-1 text-success-400 font-semibold">
              <CheckCircle2 className="w-3.5 h-3.5" />
              Completed
            </span>
          )}
        </div>
      </div>

      {/* Video */}
      {(() => {
        const embed = lesson.video_url ? getEmbedUrl(lesson.video_url) : null;
        if (!embed) return null;
        return (
          <div className="card overflow-hidden p-0">
            <div className="flex items-center gap-2 px-5 py-3 border-b border-steel-700/60 bg-navy-800/40">
              <PlayCircle className="w-5 h-5 text-accent-400" />
              <h3 className="font-display text-sm font-semibold text-white">
                Module Video
              </h3>
            </div>
            <div className="relative w-full bg-black" style={{ aspectRatio: '16 / 9' }}>
              {embed.type === 'iframe' ? (
                <iframe
                  src={embed.src}
                  className="absolute inset-0 w-full h-full"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                  allowFullScreen
                  title={`${lesson.module_title} video`}
                />
              ) : (
                <video
                  src={embed.src}
                  className="absolute inset-0 w-full h-full"
                  controls
                  playsInline
                  preload="metadata"
                />
              )}
            </div>
          </div>
        );
      })()}

      {/* Text content */}
      {lesson.content && (
        <div className="card p-6 sm:p-8">
          <h3 className="font-display text-lg font-semibold text-white mb-5 flex items-center gap-2">
            <BookOpen className="w-5 h-5 text-accent-400" />
            Lesson Material
          </h3>
          <div className="max-w-none">
            <p className="text-steel-200 leading-[1.75] text-[15px] whitespace-pre-line">
              {lesson.content}
            </p>
          </div>
        </div>
      )}

      {/* Study notes download */}
      {(lesson.has_pdf || (lesson.content && lesson.content.length > 0)) && (
        <div className="card p-5 flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-11 h-11 rounded-lg bg-accent-500/15 flex items-center justify-center">
              <FileText className="w-5 h-5 text-accent-300" />
            </div>
            <div>
              <div className="text-sm font-semibold text-white">
                {lesson.title} — Study Notes
              </div>
              <div className="text-xs text-steel-400 mt-0.5">
                Downloadable reference for offline study
              </div>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <span className="hidden sm:inline text-[10px] font-bold uppercase tracking-wider text-accent-300 bg-accent-500/10 px-2 py-1 rounded">
              TXT
            </span>
            <button
              onClick={() => downloadStudyNotes(lesson)}
              className="btn-secondary text-sm"
            >
              <Download className="w-4 h-4" />
              Download
            </button>
          </div>
        </div>
      )}

      {/* Knowledge check / quiz */}
      {lesson.quiz.length > 0 && (
        <div className="card p-6">
          <div className="flex items-center gap-2 mb-1">
            <HelpCircle className="w-5 h-5 text-accent-400" />
            <h3 className="font-display text-lg font-semibold text-white">
              Knowledge Check
            </h3>
          </div>
          <p className="text-sm text-steel-400 mb-3">
            Score {lesson.pass_threshold}% or higher to mark this lesson complete.
          </p>

          {/* Engagement lock banner */}
          {!engagementLoading && !engagement.engaged && !lockState?.locked && (
            <div className="mb-4 p-4 rounded-lg bg-navy-700/40 border border-steel-600/50">
              <div className="flex items-center gap-2 text-accent-300 font-semibold mb-2">
                <Lock className="w-5 h-5" />
                Quiz locked — review the lesson material first
              </div>
              {!engagement.content_opened ? (
                <p className="text-sm text-steel-300 mb-2">
                  Scroll up and read the lesson material above. The knowledge check
                  will unlock once you've opened and spent time on the content.
                </p>
              ) : (
                <p className="text-sm text-steel-300 mb-2">
                  Keep reading. The knowledge check will unlock shortly.
                </p>
              )}
              {/* Progress indicator */}
              <div className="mt-3">
                <div className="flex items-center justify-between text-xs text-steel-400 mb-1.5">
                  <span className="flex items-center gap-1.5">
                    <Timer className="w-3.5 h-3.5" />
                    Time on lesson
                  </span>
                  <span className="tabular-nums">
                    {Math.min(engagement.seconds_viewed, engagement.required_seconds)}s / {engagement.required_seconds}s
                  </span>
                </div>
                <div className="h-2 rounded-full bg-navy-800 overflow-hidden">
                  <div
                    className="h-full bg-accent-500 rounded-full transition-all duration-500"
                    style={{
                      width: `${Math.min(100, Math.round((engagement.seconds_viewed / engagement.required_seconds) * 100))}%`,
                    }}
                  />
                </div>
                {engagement.relock_refresh_seconds > 0 && (
                  <p className="text-xs text-warning-400 mt-2 flex items-center gap-1.5">
                    <AlertCircle className="w-3.5 h-3.5" />
                    Re-review required: spend {engagement.relock_refresh_seconds}s more before retrying.
                  </p>
                )}
              </div>
            </div>
          )}

          {/* Engagement unlocked indicator */}
          {!engagementLoading && engagement.engaged && !lockState?.locked && (
            <div className="mb-4 flex items-center gap-2 text-xs font-semibold text-success-400">
              <Eye className="w-4 h-4" />
              Lesson engagement complete — quiz unlocked
            </div>
          )}

          {/* Attempt counter */}
          {!lockLoading && lockState && !lockState.locked && (
            <div className="mb-4 text-xs font-semibold text-steel-400">
              Attempt {(lockState.failed_in_cycle ?? 0) + 1} of 3
              {lockState.failed_in_cycle > 0 && (
                <span className="text-error-400 ml-2">({lockState.failed_in_cycle} failed)</span>
              )}
            </div>
          )}

          {/* Locked: company user */}
          {lockState?.locked && isCompanyUser && (
            <div className="mb-4 p-4 rounded-lg bg-warning-500/10 border border-warning-500/30">
              <div className="flex items-center gap-2 text-warning-400 font-semibold mb-2">
                <AlertCircle className="w-5 h-5" />
                3 failed attempts — admin approval required
              </div>
              <p className="text-sm text-steel-300 mb-3">
                You've reached 3 failed attempts on this knowledge check. Your company admin must approve a retake before you can try again.
              </p>
              {pendingRetake ? (
                <div className="flex items-center gap-2 text-sm text-steel-400">
                  <Loader2 className="w-4 h-4 animate-spin" />
                  Retake request pending admin approval
                </div>
              ) : (
                <div className="text-sm text-steel-500">
                  A retake request has been sent to your company admin. You'll be able to retry once it's approved.
                </div>
              )}
            </div>
          )}

          {/* Locked: solo user */}
          {lockState?.locked && !isCompanyUser && (
            <div className="mb-4 p-4 rounded-lg bg-warning-500/10 border border-warning-500/30">
              <div className="flex items-center gap-2 text-warning-400 font-semibold mb-2">
                <AlertCircle className="w-5 h-5" />
                3 failed attempts — review required
              </div>
              <p className="text-sm text-steel-300 mb-3">
                You've missed this knowledge check 3 times. Review the lesson material carefully, then try again.
              </p>
              {!soloReviewed ? (
                <label className="flex items-center gap-2 text-sm text-steel-300 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={false}
                    onChange={(e) => setSoloReviewed(e.target.checked)}
                    className="w-4 h-4 rounded border-steel-600"
                  />
                  I reviewed the lesson material again
                </label>
              ) : (
                <button onClick={onSoloReviewConfirm} className="btn-primary text-sm">
                  Try again
                </button>
              )}
            </div>
          )}

          {/* Quiz questions - hidden when locked or engagement not met */}
          {(!lockState?.locked || lockLoading) && engagement.engaged && (
          <div className="space-y-5">
            {lesson.quiz.map((q, qi) => (
              <div key={qi}>
                <div className="text-sm font-medium text-white mb-3">
                  {qi + 1}. {q.question}
                </div>
                <div className="space-y-2">
                  {q.options.map((opt, oi) => {
                    const selected = quizAnswers[`${lesson.id}-${qi}`] === oi;
                    const showResult = quizResult !== null;
                    const isCorrect = oi === q.correctIndex;
                    const wasSelected = selected;
                    let cls = 'border-steel-700 hover:border-accent-500/50 text-steel-200';
                    if (showResult) {
                      if (isCorrect) {
                        cls = 'border-success-500/50 bg-success-500/10 text-success-400';
                      } else if (wasSelected) {
                        cls = 'border-error-500/50 bg-error-500/10 text-error-400';
                      } else {
                        cls = 'border-steel-700 text-steel-500';
                      }
                    } else if (selected) {
                      cls = 'border-accent-500 bg-accent-500/10 text-white';
                    }
                    return (
                      <button
                        key={oi}
                        disabled={showResult}
                        onClick={() =>
                          setQuizAnswers({ ...quizAnswers, [`${lesson.id}-${qi}`]: oi })
                        }
                        className={`flex items-center gap-3 w-full text-left p-3 rounded-lg border transition-colors ${cls} ${
                          showResult ? 'cursor-default' : 'cursor-pointer'
                        }`}
                      >
                        <div
                          className={`w-5 h-5 rounded-full border-2 shrink-0 flex items-center justify-center ${
                            selected || (showResult && isCorrect)
                              ? 'border-current'
                              : 'border-steel-600'
                          }`}
                        >
                          {(selected || (showResult && isCorrect)) && (
                            <div className="w-2 h-2 rounded-full bg-current" />
                          )}
                        </div>
                        <span className="text-sm">{opt}</span>
                      </button>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
          )}

          {quizResult && (
            <div
              className={`mt-5 p-4 rounded-lg border ${
                quizResult.passed
                  ? 'bg-success-500/10 border-success-500/30 text-success-400'
                  : 'bg-error-500/10 border-error-500/30 text-error-400'
              }`}
            >
              <div className="flex items-center gap-2 font-semibold">
                {quizResult.passed ? (
                  <>
                    <CheckCircle2 className="w-5 h-5" />
                    Passed with {quizResult.score}%
                  </>
                ) : (
                  <>
                    <AlertCircle className="w-5 h-5" />
                    Scored {quizResult.score}% — need {lesson.pass_threshold}% to pass
                  </>
                )}
              </div>
              {!quizResult.passed && (
                <p className="text-sm mt-2 opacity-80">
                  Review the material and try again. You can retake the knowledge check
                  as many times as needed.
                </p>
              )}
            </div>
          )}

          {quizError && (
            <div className="mt-4 p-3 rounded-lg bg-error-500/10 border border-error-500/30 text-sm text-error-400 flex items-center gap-2">
              <AlertCircle className="w-4 h-4 shrink-0" />
              {quizError}
            </div>
          )}

          <div className="mt-5 flex gap-3">
            {quizResult?.passed ? (
              <button onClick={onMarkComplete} className="btn-primary">
                <CheckCircle2 className="w-4 h-4" />
                Mark as Complete
              </button>
            ) : (
              <button
                onClick={() => {
                  setQuizResult(null);
                  onSubmitQuiz();
                }}
                className="btn-primary"
                disabled={Object.keys(quizAnswers).length < lesson.quiz.length || submitting || (lockState?.locked ?? false) || !engagement.engaged}
              >
                {submitting ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Submit Knowledge Check'}
              </button>
            )}
            {quizResult?.passed === false && !lockState?.locked && (
              <button
                onClick={() => {
                  setQuizAnswers({});
                  setQuizResult(null);
                }}
                className="btn-secondary"
              >
                Retry
              </button>
            )}
          </div>
        </div>
      )}

      {/* Mark complete (no quiz) */}
      {lesson.quiz.length === 0 && !isCompleted && (
        <button onClick={onMarkComplete} className="btn-primary w-full">
          <CheckCircle2 className="w-4 h-4" />
          Mark Lesson Complete
        </button>
      )}
      {lesson.quiz.length === 0 && isCompleted && (
        <div className="card p-4 flex items-center gap-2 text-success-400">
          <CheckCircle2 className="w-5 h-5" />
          <span className="text-sm font-semibold">Lesson complete</span>
        </div>
      )}

      {/* Course complete + certificate */}
      {certIssued && courseProgress === 100 && (
        <div className="card border-premium-500/30 bg-premium-500/5 p-6">
          <div className="flex items-start gap-4">
            <Award className="w-8 h-8 text-premium-400 shrink-0" />
            <div className="flex-1">
              <h3 className="font-display text-lg font-semibold text-white mb-1">
                Course Complete — Certificate Earned!
              </h3>
              <p className="text-sm text-steel-300 mb-4">
                You've completed all lessons. Your Certificate of Completion has been
                issued. View and download it from your Certificates page.
              </p>
              <button
                onClick={() => onNavigate({ name: 'certificates' })}
                className="btn-premium"
              >
                <Award className="w-4 h-4" />
                View Certificate
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function LockedLessonUpsell({
  lesson,
  onNavigate,
}: {
  lesson: LessonWithModule;
  onNavigate: (r: Route) => void;
}) {
  return (
    <div className="space-y-6 animate-fade-in">
      <div className="card p-6">
        <div className="text-xs font-semibold uppercase tracking-wider text-steel-500 mb-2">
          {lesson.module_title}
        </div>
        <h2 className="font-display text-xl font-bold text-white mb-3">
          {lesson.title}
        </h2>
        <div className="flex flex-wrap items-center gap-3 text-xs text-steel-400">
          <span className="flex items-center gap-1">
            <Clock className="w-3.5 h-3.5" />
            {lesson.estimated_minutes} minutes
          </span>
          {lesson.has_pdf && (
            <span className="flex items-center gap-1">
              <FileText className="w-3.5 h-3.5" />
              PDF notes
            </span>
          )}
          {lesson.quiz.length > 0 && (
            <span className="flex items-center gap-1">
              <HelpCircle className="w-3.5 h-3.5" />
              Knowledge check
            </span>
          )}
        </div>
      </div>

      <div className="card border-premium-500/30 bg-premium-500/5 p-8">
        <div className="flex flex-col items-center text-center max-w-md mx-auto">
          <div className="w-14 h-14 rounded-full bg-premium-500/15 flex items-center justify-center mb-4">
            <Lock className="w-7 h-7 text-premium-400" />
          </div>
          <h3 className="font-display text-lg font-bold text-white mb-2">
            This lesson is locked
          </h3>
          <p className="text-sm text-steel-300 mb-6">
            This is a premium course lesson. Upgrade to unlock the full
            lesson material, knowledge check, and certificate of completion.
          </p>
          <div className="flex flex-col sm:flex-row gap-3 w-full">
            <button
              onClick={() => onNavigate({ name: 'pricing' })}
              className="btn-premium flex-1"
            >
              Upgrade to unlock
            </button>
            <button
              onClick={() => onNavigate({ name: 'catalog' })}
              className="btn-secondary flex-1"
            >
              Browse free courses
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
