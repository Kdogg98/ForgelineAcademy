import { supabase } from '@/lib/supabase';
import type { UserProgress, Certificate } from '@/lib/types';

export type AssessmentLevel = 'novice' | 'intermediate' | 'advanced' | 'expert';
export type AssessmentArea = 'mechanical' | 'electrical' | 'ie' | 'engineering';

export interface MCQuestion {
  question: string;
  options: string[];
  correctIndex: number;
  area: AssessmentArea;
  topic: string;
}

export interface AnswerRecord {
  questionIndex: number;
  selectedIndex: number;
  correct: boolean;
}

export interface AreaAssessment {
  level: AssessmentLevel;
  note: string;
}

export interface AssessmentEvaluation {
  level: AssessmentLevel;
  summary: string;
  recommendations: string;
  recommended_stage: AssessmentArea;
  areas: {
    mechanical: AreaAssessment;
    electrical: AreaAssessment;
    ie: AreaAssessment;
    engineering: AreaAssessment;
  };
}

export interface SavedAssessment {
  level: AssessmentLevel;
  summary: string;
  evaluation: AssessmentEvaluation | null;
  assessed_at: string | null;
}

async function extractError(error: unknown, data: unknown, fallback: string): Promise<string> {
  let errMsg = (data as { error?: string } | null)?.error;
  if (!errMsg) {
    const ctx = (error as { context?: Response }).context;
    if (ctx && typeof ctx.json === 'function') {
      try {
        const body = await ctx.json();
        errMsg = body?.error;
      } catch {
        // not JSON
      }
    }
  }
  return errMsg || (error instanceof Error ? error.message : '') || fallback;
}

export async function generateQuestions(): Promise<MCQuestion[]> {
  const { data, error } = await supabase.functions.invoke('skill-assessment', {
    body: { action: 'generate' },
  });

  if (error) {
    throw new Error(await extractError(error, data, 'Failed to generate questions.'));
  }

  const questions = (data as { questions?: MCQuestion[] })?.questions;
  if (!questions || !Array.isArray(questions) || questions.length === 0) {
    throw new Error('No questions returned.');
  }
  return questions;
}

export async function evaluateAssessment(
  questions: MCQuestion[],
  answers: AnswerRecord[],
): Promise<{ evaluation: AssessmentEvaluation; score: number; totalQuestions: number }> {
  const { data, error } = await supabase.functions.invoke('skill-assessment', {
    body: { action: 'evaluate', questions, answers },
  });

  if (error) {
    throw new Error(await extractError(error, data, 'Failed to evaluate assessment.'));
  }

  const evaluation = (data as { evaluation?: AssessmentEvaluation })?.evaluation;
  if (!evaluation) {
    throw new Error('No evaluation returned.');
  }

  return {
    evaluation,
    score: (data as { score?: number })?.score ?? 0,
    totalQuestions: (data as { totalQuestions?: number })?.totalQuestions ?? questions.length,
  };
}

export async function saveAssessmentResult(
  evaluation: AssessmentEvaluation,
  answers: AnswerRecord[],
  score: number,
  totalQuestions: number,
): Promise<void> {
  const { data: userData } = await supabase.auth.getUser();
  const userId = userData.user?.id;
  if (!userId) throw new Error('Not authenticated.');

  // Save to history table
  const { error: historyError } = await supabase
    .from('assessment_history')
    .insert({
      user_id: userId,
      level: evaluation.level,
      summary: evaluation.summary,
      evaluation,
      answers,
      score,
      total_questions: totalQuestions,
    });

  if (historyError) throw new Error(historyError.message);

  // Update profile
  const { error: profileError } = await supabase
    .from('profiles')
    .update({
      assessment_completed: true,
      assessment_level: evaluation.level,
      assessment_summary: evaluation.summary,
      assessment_responses: { evaluation, answers, score, totalQuestions },
      assessed_at: new Date().toISOString(),
    })
    .eq('id', userId);

  if (profileError) throw new Error(profileError.message);
}

export async function fetchSavedAssessment(): Promise<SavedAssessment | null> {
  const { data, error } = await supabase
    .from('profiles')
    .select('assessment_completed, assessment_level, assessment_summary, assessment_responses, assessed_at')
    .maybeSingle();

  if (error || !data || !data.assessment_completed) return null;

  const responses = data.assessment_responses as { evaluation?: AssessmentEvaluation } | null;

  return {
    level: data.assessment_level as AssessmentLevel,
    summary: data.assessment_summary ?? '',
    evaluation: responses?.evaluation ?? null,
    assessed_at: data.assessed_at,
  };
}

export interface RetakeEligibility {
  canRetake: boolean;
  reason: string;
  lessonsCompletedSinceAssessment: number;
  coursesCompletedSinceAssessment: number;
  isPremium: boolean;
}

export async function checkRetakeEligibility(
  isPremium: boolean,
  isAdmin: boolean,
): Promise<RetakeEligibility> {
  // Free users (non-premium, non-admin): no retakes allowed
  if (!isPremium && !isAdmin) {
    return {
      canRetake: false,
      reason: 'Retakes are a Premium feature. Upgrade to retake your assessment after completing more course material.',
      lessonsCompletedSinceAssessment: 0,
      coursesCompletedSinceAssessment: 0,
      isPremium: false,
    };
  }

  // Premium/admin: check progress since last assessment
  const { data: profile } = await supabase
    .from('profiles')
    .select('assessed_at')
    .maybeSingle();

  const assessedAt = profile?.assessed_at;

  // If no prior assessment, they can take it (first time)
  if (!assessedAt) {
    return {
      canRetake: true,
      reason: '',
      lessonsCompletedSinceAssessment: 0,
      coursesCompletedSinceAssessment: 0,
      isPremium: true,
    };
  }

  // Count lessons completed since assessment
  const { data: progress } = await supabase
    .from('user_progress')
    .select('completed, completed_at, course_id')
    .eq('completed', true)
    .gte('completed_at', assessedAt);

  const lessonsSince = progress?.length ?? 0;

  // Count certificates since assessment (course completions)
  const { data: certs } = await supabase
    .from('certificates')
    .select('issued_at')
    .gte('issued_at', assessedAt);

  const coursesSince = certs?.length ?? 0;

  // Retake unlocked if 5+ lessons or 1+ course completed since last assessment
  if (lessonsSince >= 5 || coursesSince >= 1) {
    return {
      canRetake: true,
      reason: '',
      lessonsCompletedSinceAssessment: lessonsSince,
      coursesCompletedSinceAssessment: coursesSince,
      isPremium: true,
    };
  }

  // Premium but not enough progress
  return {
    canRetake: false,
    reason: 'Complete more course material to unlock a retake and refresh your recommendations. You need 5+ lessons or 1 completed course since your last assessment.',
    lessonsCompletedSinceAssessment: lessonsSince,
    coursesCompletedSinceAssessment: coursesSince,
    isPremium: true,
  };
}

export async function resetAssessment(): Promise<void> {
  const { data: userData } = await supabase.auth.getUser();
  const userId = userData.user?.id;
  if (!userId) throw new Error('Not authenticated.');

  const { error } = await supabase
    .from('profiles')
    .update({
      assessment_completed: false,
      assessment_level: null,
      assessment_summary: null,
      assessment_responses: null,
      assessed_at: null,
    })
    .eq('id', userId);

  if (error) throw new Error(error.message);
}
