import type { ReactNode } from 'react';
import { Lock, CheckCircle2 } from 'lucide-react';
import type { Tier, Difficulty } from '@/lib/types';
import { difficultyLabel } from '@/lib/types';

export function TierBadge({ tier }: { tier: Tier }) {
  return tier === 'free' ? (
    <span className="badge-free">Free</span>
  ) : (
    <span className="badge-premium">
      <Lock className="w-3 h-3" />
      Premium
    </span>
  );
}

export function DifficultyBadge({ difficulty }: { difficulty: Difficulty }) {
  const cls =
    difficulty === 'beginner'
      ? 'badge-beginner'
      : difficulty === 'intermediate'
        ? 'badge-intermediate'
        : 'badge-advanced';
  return <span className={cls}>{difficultyLabel(difficulty)}</span>;
}

export function CertificateIndicator({ has }: { has: boolean }) {
  if (!has) return null;
  return (
    <span className="inline-flex items-center gap-1 text-premium-400 text-xs font-semibold">
      <CheckCircle2 className="w-3.5 h-3.5" />
      Certificate
    </span>
  );
}

export function IconBadge({
  children,
  tone = 'steel',
}: {
  children: ReactNode;
  tone?: 'steel' | 'accent' | 'premium' | 'success';
}) {
  const tones: Record<string, string> = {
    steel: 'bg-steel-700/50 text-steel-300 border-steel-600/50',
    accent: 'bg-accent-500/15 text-accent-300 border-accent-500/30',
    premium: 'bg-premium-500/15 text-premium-400 border-premium-500/30',
    success: 'bg-success-500/15 text-success-400 border-success-500/30',
  };
  return (
    <span className={`badge border ${tones[tone]}`}>{children}</span>
  );
}
