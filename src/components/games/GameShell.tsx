import type { ReactNode } from 'react';
import { CheckCircle2, Heart, RotateCcw, ShieldAlert } from 'lucide-react';

export type FeedbackTone = 'ok' | 'bad' | 'info';

export interface GameFeedback {
  tone: FeedbackTone;
  message: string;
}

interface GameShellProps {
  title: string;
  subtitle?: string;
  score: number;
  maxScore: number;
  lives?: number;
  attempts?: number;
  feedback?: GameFeedback | null;
  whyThisMatters?: ReactNode;
  onComplete?: () => void;
  completeDisabled?: boolean;
  completeLabel?: string;
  onReset?: () => void;
  children: ReactNode;
}

const TONE_CLASS: Record<FeedbackTone, string> = {
  ok: 'border-success-500/40 bg-success-500/10 text-success-400',
  bad: 'border-error-500/40 bg-error-500/10 text-error-400',
  info: 'border-steel-600 bg-navy-900/70 text-steel-200',
};

export function GameShell({
  title,
  subtitle,
  score,
  maxScore,
  lives,
  attempts,
  feedback,
  whyThisMatters,
  onComplete,
  completeDisabled,
  completeLabel = 'Complete',
  onReset,
  children,
}: GameShellProps) {
  return (
    <div className="card overflow-hidden border-steel-600">
      <div className="flex flex-col gap-4 border-b border-steel-700/70 bg-navy-950/50 px-5 py-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="min-w-0">
          <div className="text-[10px] font-mono uppercase tracking-[0.18em] text-rok-400">
            Shop-floor game
          </div>
          <h2 className="font-display text-xl font-bold text-white">{title}</h2>
          {subtitle && <p className="mt-1 text-sm text-steel-400">{subtitle}</p>}
        </div>
        <div className="flex flex-wrap items-center gap-3">
          <div className="rounded-md border border-steel-600 bg-navy-900 px-3 py-2">
            <div className="text-[10px] font-mono uppercase tracking-wider text-steel-500">Score</div>
            <div className="font-mono text-lg font-semibold tabular-nums text-white">
              {score}
              <span className="text-steel-500">/{maxScore}</span>
            </div>
          </div>
          {typeof lives === 'number' && (
            <div className="rounded-md border border-steel-600 bg-navy-900 px-3 py-2">
              <div className="text-[10px] font-mono uppercase tracking-wider text-steel-500">Lives</div>
              <div className="flex items-center gap-1 font-mono text-sm text-rok-300">
                {Array.from({ length: Math.max(lives, 0) }).map((_, i) => (
                  <Heart key={i} className="h-3.5 w-3.5 fill-rok-500 text-rok-500" />
                ))}
                {lives === 0 && <span className="text-steel-500">0</span>}
              </div>
            </div>
          )}
          {typeof attempts === 'number' && (
            <div className="rounded-md border border-steel-600 bg-navy-900 px-3 py-2">
              <div className="text-[10px] font-mono uppercase tracking-wider text-steel-500">Attempts</div>
              <div className="font-mono text-lg font-semibold tabular-nums text-white">{attempts}</div>
            </div>
          )}
        </div>
      </div>

      <div className="p-5 sm:p-6">{children}</div>

      <div className="space-y-4 border-t border-steel-700/70 px-5 py-5 sm:px-6">
        <div className={`rounded-lg border px-4 py-3 text-sm ${feedback ? TONE_CLASS[feedback.tone] : TONE_CLASS.info}`}>
          <div className="mb-1 flex items-center gap-2 text-[10px] font-mono uppercase tracking-wider">
            <ShieldAlert className="h-3.5 w-3.5" />
            Feedback
          </div>
          <p>{feedback?.message ?? 'Assign a bearing family to a machine card to get a call from the crib.'}</p>
        </div>

        {whyThisMatters && (
          <div className="rounded-lg border border-rok-500/30 bg-rok-500/5 px-4 py-3">
            <div className="mb-1 text-[10px] font-mono uppercase tracking-wider text-rok-400">
              Why this matters
            </div>
            <div className="text-sm leading-relaxed text-steel-200">{whyThisMatters}</div>
          </div>
        )}

        <div className="flex flex-wrap gap-3">
          {onReset && (
            <button type="button" onClick={onReset} className="btn-secondary">
              <RotateCcw className="h-4 w-4" />
              Reset
            </button>
          )}
          {onComplete && (
            <button type="button" onClick={onComplete} disabled={completeDisabled} className="btn-primary">
              <CheckCircle2 className="h-4 w-4" />
              {completeLabel}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
