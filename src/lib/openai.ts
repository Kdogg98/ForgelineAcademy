import { supabase } from '@/lib/supabase';

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface CourseContext {
  courseTitle: string;
  stage: string;
  lessonTitle?: string | null;
  lessonSummary?: string | null;
  firstName?: string | null;
}

export async function chatWithTutor(
  messages: ChatMessage[],
  ctx: CourseContext,
): Promise<string> {
  const { data, error } = await supabase.functions.invoke('ai-tutor', {
    body: { messages, context: ctx },
  });

  if (error) {
    let errMsg = (data as { error?: string } | null)?.error;
    if (!errMsg) {
      const ctx = (error as { context?: Response }).context;
      if (ctx && typeof ctx.json === 'function') {
        try {
          const body = await ctx.json();
          errMsg = body?.error;
        } catch {
          // response body was not JSON
        }
      }
    }
    throw new Error(errMsg || error.message || 'Failed to reach AI tutor.');
  }

  const reply = (data as { reply?: string })?.reply;
  if (!reply) {
    const errMsg = (data as { error?: string })?.error;
    throw new Error(errMsg || 'No response from AI tutor.');
  }

  return reply;
}
