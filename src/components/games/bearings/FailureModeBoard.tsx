import { useMemo, useState } from 'react';
import { GameShell, type GameFeedback } from '@/components/games/GameShell';
import { DEFAULT_PASS_THRESHOLD, isPassedScore, saveGameResult } from '@/lib/games/progress';
import type { GameResult } from '@/lib/games/types';

type Mode = 'spall' | 'true-brinell' | 'false-brinell' | 'smear' | 'starve' | 'corrosion';

const MODES: { id: Mode; label: string }[] = [
  { id: 'spall', label: 'Fatigue spall' },
  { id: 'true-brinell', label: 'True brinell (overload dent)' },
  { id: 'false-brinell', label: 'False brinell (fretting)' },
  { id: 'smear', label: 'Smear / skid' },
  { id: 'starve', label: 'Lubricant starve' },
  { id: 'corrosion', label: 'Etch / corrosion' },
];

const CASES: {
  id: string;
  tag: string;
  evidence: string;
  correct: Mode;
  why: Record<Mode, string>;
}[] = [
  {
    id: 'de-fan',
    tag: 'Cooling-tower fan DE',
    evidence: 'Flakes out of the load zone. Crater has a sharp beach mark. No heat color.',
    correct: 'spall',
    why: {
      spall: 'That is a fatigue flake. Do not pack grease and send it back.',
      'true-brinell': 'True brinell is a plastic dent from a hit, not a flake with a beach mark.',
      'false-brinell': 'False brinell is a rusty fretting band from vibration at rest.',
      smear: 'Smear is metal wiped from skid, usually shiny and smeared, not flaked.',
      starve: 'Starve polishes and blues. It does not throw fatigue flakes.',
      corrosion: 'Corrosion is etch and rust bloom, not a beach-marked crater.',
    },
  },
  {
    id: 'forklift',
    tag: 'Forklift dropped a bearing in the crate',
    evidence: 'One dent per ball, spaced like the complement, bright, no rust.',
    correct: 'true-brinell',
    why: {
      spall: 'Spall is a flake. These are matching dents from an impact.',
      'true-brinell': 'Complement-spaced bright dents: the race took a static overload.',
      'false-brinell': 'False brinell rusts and frets. These dents are clean and bright.',
      smear: 'No wipe. The metal was punched, not skidded.',
      starve: 'No heat tint or polish path.',
      corrosion: 'No etch. The dents are mechanical.',
    },
  },
  {
    id: 'standby-pump',
    tag: 'Standby pump, ran once a month',
    evidence: 'Red-brown bands at ball spacing. Race not dented through. Sits next to a running fan.',
    correct: 'false-brinell',
    why: {
      spall: 'No flake. This is fretting from vibration at rest.',
      'true-brinell': 'True brinell goes plastic. These are rust bands, not punch marks.',
      'false-brinell': 'Idle machine, neighbor vibration, rust at ball pitch: false brinell.',
      smear: 'Smear needs rotation under slip.',
      starve: 'It barely ran. This is not a lube-film fail.',
      corrosion: 'Moisture etch is blotchy, not locked to ball pitch.',
    },
  },
  {
    id: 'accel',
    tag: 'VFD, fast accel, coupling just installed',
    evidence: 'Rollers smeared, ends polished, no fatigue pit yet.',
    correct: 'smear',
    why: {
      spall: 'No fatigue crater. The metal was wiped.',
      'true-brinell': 'Not a static dent pattern.',
      'false-brinell': 'This unit was running, not sitting.',
      smear: 'Skid on accel: rollers smeared before the film built.',
      starve: 'Starve is dry polish and heat. This is a slip wipe on start.',
      corrosion: 'No rust.',
    },
  },
  {
    id: 'high-speed',
    tag: '3600 RPM motor, overdue grease',
    evidence: 'Race glazed, straw to blue tint, grease dry and caked at the shield.',
    correct: 'starve',
    why: {
      spall: 'Glaze and color first. Flakes come later if you keep running it.',
      'true-brinell': 'No impact dents.',
      'false-brinell': 'This motor ran, hard.',
      smear: 'Smear is local wipe. This is a whole-race heat/polish.',
      starve: 'Dry cake, heat color, glaze: the film left.',
      corrosion: 'Blue is heat, not rust.',
    },
  },
  {
    id: 'washdown',
    tag: 'Washdown pillow block, missing cap',
    evidence: 'Gray etch, rust bloom at the water line, no load-zone flake.',
    correct: 'corrosion',
    why: {
      spall: 'No beach mark. This is chemistry.',
      'true-brinell': 'No punch pattern.',
      'false-brinell': 'False brinell is at ball pitch from vibration, not a water line.',
      smear: 'No wipe.',
      starve: 'Not a heat glaze.',
      corrosion: 'Open cap plus washdown: etch and rust. Replace, do not polish and reuse.',
    },
  },
];

const GAME_KEY = 'g2-spall-or-smear';
const MAX_SCORE = 100;
const WHY =
  'If you call a spall a lube issue and pack it, the next shift eats the shaft. Name the evidence before you name the grease gun.';

interface Props {
  courseId: string;
  userId: string | null;
  onComplete?: (result: GameResult) => void;
}

export function FailureModeBoard({ courseId, userId, onComplete }: Props) {
  const [picks, setPicks] = useState<Record<string, Mode | null>>(
    Object.fromEntries(CASES.map((c) => [c.id, null])),
  );
  const [result, setResult] = useState<GameResult | null>(null);
  const [attempts, setAttempts] = useState(0);
  const [feedback, setFeedback] = useState<GameFeedback>({
    tone: 'info',
    message: 'Read the evidence. Pick the failure mode. Do not guess from the machine name.',
  });

  const assigned = useMemo(() => CASES.filter((c) => picks[c.id]).length, [picks]);
  const liveScore = useMemo(
    () => CASES.reduce((sum, c) => sum + (picks[c.id] === c.correct ? 100 / CASES.length : 0), 0),
    [picks],
  );

  function resetBoard() {
    if (result?.passed) return;
    setPicks(Object.fromEntries(CASES.map((c) => [c.id, null])));
    setResult(null);
    setFeedback({
      tone: 'info',
      message: 'Board reset. Read the evidence and name every job before you submit.',
    });
  }

  function choose(caseId: string, mode: Mode) {
    if (result?.passed) return;
    const card = CASES.find((c) => c.id === caseId);
    if (!card) return;
    setPicks((prev) => ({ ...prev, [caseId]: mode }));
    const ok = mode === card.correct;
    setFeedback({ tone: ok ? 'ok' : 'bad', message: card.why[mode] });
  }

  function submit() {
    if (result?.passed) return;
    if (assigned < CASES.length) {
      setFeedback({
        tone: 'info',
        message: `Call all ${CASES.length} jobs. ${assigned} of ${CASES.length} named.`,
      });
      return;
    }
    const score = Math.round(liveScore);
    const passed = isPassedScore(score, MAX_SCORE);
    const next = saveGameResult({
      courseId,
      gameKey: GAME_KEY,
      score,
      maxScore: MAX_SCORE,
      passed,
      completedAt: new Date().toISOString(),
      userId,
    });
    setAttempts((n) => n + 1);
    setResult(next);
    setFeedback({
      tone: passed ? 'ok' : 'bad',
      message: passed
        ? `All six calls hold. ${score}/${MAX_SCORE}.`
        : `Score ${score}/${MAX_SCORE}. Need ${DEFAULT_PASS_THRESHOLD}% to pass. Recut the misses and submit again.`,
    });
    onComplete?.(next);
  }

  return (
    <GameShell
      title="Spall or Smear: Failure Mode ID"
      subtitle="Six jobs. Name the mode from the evidence, not the department."
      score={result?.passed ? result.score : Math.round(liveScore)}
      maxScore={MAX_SCORE}
      attempts={attempts}
      feedback={feedback}
      whyThisMatters={result ? WHY : undefined}
      onComplete={submit}
      completeDisabled={assigned < CASES.length || Boolean(result?.passed)}
      completeLabel={result?.passed ? 'Calls locked' : 'Submit failure calls'}
      onReset={result?.passed ? undefined : resetBoard}
    >
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        {CASES.map((c) => {
          const pick = picks[c.id];
          const locked = Boolean(result?.passed);
          return (
            <div key={c.id} className="rounded-lg border border-steel-600 bg-navy-900/70 p-4">
              <div className="font-mono text-[10px] uppercase tracking-wider text-steel-500">{c.tag}</div>
              <p className="mt-2 text-sm text-steel-200">{c.evidence}</p>
              <div className="mt-3 grid grid-cols-2 gap-2">
                {MODES.map((m) => {
                  const on = pick === m.id;
                  const ok = result && pick === c.correct && on;
                  const bad = result && pick && pick !== c.correct && on;
                  return (
                    <button
                      key={m.id}
                      type="button"
                      disabled={locked}
                      onClick={() => choose(c.id, m.id)}
                      className={`rounded border px-2 py-1.5 text-left text-[11px] ${
                        ok
                          ? 'border-success-500/60 text-success-300'
                          : bad
                            ? 'border-error-500/60 text-error-300'
                            : on
                              ? 'border-rok-500 text-white'
                              : 'border-steel-700 text-steel-300 hover:border-steel-500'
                      }`}
                    >
                      {m.label}
                    </button>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>
    </GameShell>
  );
}
