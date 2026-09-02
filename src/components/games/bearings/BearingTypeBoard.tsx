import { useMemo, useState, type DragEvent } from 'react';
import { GameShell, type GameFeedback } from '@/components/games/GameShell';
import { DEFAULT_PASS_THRESHOLD, isPassedScore, saveGameResult } from '@/lib/games/progress';
import type { GameResult } from '@/lib/games/types';

type BearingId = 'deep-groove' | 'spherical' | 'tapered' | 'needle';

interface BearingType {
  id: BearingId;
  nameplate: string;
  family: string;
  spec: string;
}

interface MachineCard {
  id: string;
  label: string;
  duty: string;
  correct: BearingId;
  whyCorrect: string;
  whyWrong: Record<BearingId, string>;
}

const BEARINGS: BearingType[] = [
  {
    id: 'deep-groove',
    nameplate: '6205',
    family: 'Deep-groove ball',
    spec: 'Radial, high speed, modest axial',
  },
  {
    id: 'spherical',
    nameplate: '22215',
    family: 'Spherical roller',
    spec: 'Misalignment, heavy radial',
  },
  {
    id: 'tapered',
    nameplate: '32210',
    family: 'Tapered roller',
    spec: 'Combined radial + thrust',
  },
  {
    id: 'needle',
    nameplate: 'NK25/20',
    family: 'Needle',
    spec: 'High radial, compact, almost no thrust',
  },
];

const MACHINES: MachineCard[] = [
  {
    id: 'tefc-de',
    label: '75 HP TEFC motor DE',
    duty: '1780 RPM, mainly radial',
    correct: 'deep-groove',
    whyCorrect: 'Deep-groove ball is the high-speed radial call for a motor drive end.',
    whyWrong: {
      'deep-groove': 'Deep-groove ball is the high-speed radial call for a motor drive end.',
      spherical: 'Spherical roller is overkill here. This DE sees speed and radial load, not frame flex.',
      tapered: 'Tapered roller is for combined thrust. A TEFC DE is mainly radial at 1780 RPM.',
      needle: 'Needle has almost no thrust capacity and is the wrong envelope for a motor DE.',
    },
  },
  {
    id: 'screw-conveyor',
    label: 'Screw conveyor pillow block',
    duty: 'Shaft walk about 2 degrees',
    correct: 'spherical',
    whyCorrect: 'Spherical roller swallows the shaft walk so the seal stays concentric.',
    whyWrong: {
      'deep-groove': 'A deep-groove in a walking pillow block binds the inner ring and wipes the seal.',
      spherical: 'Spherical roller swallows the shaft walk so the seal stays concentric.',
      tapered: 'Tapered roller fights the walk and dumps thrust into the housing.',
      needle: 'Needle cannot take the misalignment. The shaft walk will brinell the rollers.',
    },
  },
  {
    id: 'helical-pinion',
    label: 'Helical reducer input pinion',
    duty: 'High thrust from helix angle',
    correct: 'tapered',
    whyCorrect: 'Tapered roller is built for combined radial and helix thrust.',
    whyWrong: {
      'deep-groove': 'Deep-groove only takes modest axial. Helix thrust will walk the pinion.',
      spherical: 'Spherical roller is not the thrust family for an input pinion.',
      tapered: 'Tapered roller is built for combined radial and helix thrust.',
      needle: 'Needle has almost no thrust capacity. The pinion will walk and chew the mesh.',
    },
  },
  {
    id: 'hydraulic-cam',
    label: 'Compact hydraulic cam',
    duty: 'High radial, no thrust, tight envelope',
    correct: 'needle',
    whyCorrect: 'Needle carries high radial in a short stack when thrust is essentially zero.',
    whyWrong: {
      'deep-groove': 'Deep-groove needs more width and is not the compact high-radial pick.',
      spherical: 'Spherical roller is too tall for this cam pocket and is built for misalignment.',
      tapered: 'Tapered roller expects thrust. This cam is radial only.',
      needle: 'Needle carries high radial in a short stack when thrust is essentially zero.',
    },
  },
  {
    id: 'ct-fan',
    label: 'Cooling-tower fan',
    duty: 'Slow speed, self-aligning housing',
    correct: 'spherical',
    whyCorrect: 'Slow fan, flexing stack: spherical belongs where the frame flexes.',
    whyWrong: {
      'deep-groove': 'Deep-groove will not follow a flexing fan stack. The housing is self-aligning for a reason.',
      spherical: 'Slow fan, flexing stack: spherical belongs where the frame flexes.',
      tapered: 'Tapered roller fights housing rock and is the wrong family for a slow fan.',
      needle: 'Needle cannot take the housing rock on a cooling-tower stack.',
    },
  },
];

const POINTS = 20;
const MAX_SCORE = MACHINES.length * POINTS;
const GAME_KEY = 'g1-crib-call';
const WHY_MATTERS =
  'Wrong family on a pillow block walks the shaft and wipes the seal. Spherical belongs where the frame flexes.';

interface BearingTypeBoardProps {
  courseId: string;
  userId: string | null;
  onComplete?: (result: GameResult) => void;
}

export function BearingTypeBoard({ courseId, userId, onComplete }: BearingTypeBoardProps) {
  const [assignments, setAssignments] = useState<Record<string, BearingId | null>>(() =>
    Object.fromEntries(MACHINES.map((m) => [m.id, null])),
  );
  const [picked, setPicked] = useState<BearingId | null>(null);
  const [feedback, setFeedback] = useState<GameFeedback | null>({
    tone: 'info',
    message:
      '4 families, 5 machines on purpose. Reuse spherical 22215 on two machines. Tap a crib family, then tap a machine card.',
  });
  const [cardTone, setCardTone] = useState<Record<string, 'ok' | 'bad' | null>>({});
  const [attempts, setAttempts] = useState(0);
  const [submitted, setSubmitted] = useState(false);
  const [result, setResult] = useState<GameResult | null>(null);

  const assignedCount = useMemo(
    () => MACHINES.filter((m) => assignments[m.id] != null).length,
    [assignments],
  );

  const liveScore = useMemo(
    () => MACHINES.reduce((sum, m) => sum + (assignments[m.id] === m.correct ? POINTS : 0), 0),
    [assignments],
  );

  function applyAssignment(machineId: string, bearingId: BearingId) {
    if (result?.passed) return;
    const machine = MACHINES.find((m) => m.id === machineId);
    if (!machine) return;
    const ok = bearingId === machine.correct;
    setAssignments((prev) => ({ ...prev, [machineId]: bearingId }));
    setCardTone((prev) => ({ ...prev, [machineId]: ok ? 'ok' : 'bad' }));
    setFeedback({
      tone: ok ? 'ok' : 'bad',
      message: ok ? machine.whyCorrect : machine.whyWrong[bearingId],
    });
    setPicked(null);
    setSubmitted(false);
    setResult(null);
  }

  function resetCard(machineId: string) {
    if (result?.passed) return;
    setAssignments((prev) => ({ ...prev, [machineId]: null }));
    setCardTone((prev) => ({ ...prev, [machineId]: null }));
    setFeedback({ tone: 'info', message: 'Card cleared. Pull another family from the crib.' });
    setSubmitted(false);
    setResult(null);
  }

  function resetBoard() {
    if (result?.passed) return;
    setAssignments(Object.fromEntries(MACHINES.map((m) => [m.id, null])));
    setCardTone({});
    setPicked(null);
    setFeedback({ tone: 'info', message: 'Board reset. Seat all 5. Reuse spherical 22215 on two machines.' });
    setSubmitted(false);
    setResult(null);
  }

  function onDragStart(e: DragEvent, bearingId: BearingId) {
    e.dataTransfer.setData('text/plain', bearingId);
    e.dataTransfer.effectAllowed = 'copy';
    setPicked(bearingId);
  }

  function onDrop(e: DragEvent, machineId: string) {
    e.preventDefault();
    const id = (e.dataTransfer.getData('text/plain') || picked) as BearingId | '';
    if (!id || !BEARINGS.some((b) => b.id === id)) return;
    applyAssignment(machineId, id);
  }

  function submitAll() {
    if (result?.passed) return;
    if (assignedCount < MACHINES.length) {
      setFeedback({
        tone: 'info',
        message: `Assign all ${MACHINES.length} machines before you submit. ${assignedCount} of ${MACHINES.length} seated.`,
      });
      return;
    }
    const score = liveScore;
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
    setSubmitted(true);
    setResult(next);
    setFeedback({
      tone: passed ? 'ok' : 'bad',
      message: passed
        ? `Crib call confirmed. ${score}/${MAX_SCORE}. ${score === MAX_SCORE ? "All five machines are in the right family." : "Enough cards are correct to pass. Recut the red ones if you want a clean book."}`
        : `Score ${score}/${MAX_SCORE}. Need ${DEFAULT_PASS_THRESHOLD}% to pass (4 of 5 cards). Reset the red cards and recut the match.`,
    });
    onComplete?.(next);
  }

  return (
    <GameShell
      title="Crib Call: Right Bearing, Right Machine"
      subtitle="4 families, 5 machines. Reuse spherical 22215 on two cards. Tap a crib family, then tap a machine. Drag also works. 4 of 5 (80%) is a pass."
      score={submitted ? (result?.score ?? liveScore) : liveScore}
      maxScore={MAX_SCORE}
      attempts={attempts}
      feedback={feedback}
      whyThisMatters={submitted ? WHY_MATTERS : undefined}
      onComplete={submitAll}
      completeDisabled={assignedCount < MACHINES.length || Boolean(result?.passed)}
      completeLabel={result?.passed ? 'Crib call locked' : assignedCount < MACHINES.length ? `Seat all 5 (${assignedCount}/5)` : 'Submit crib call'}
      onReset={result?.passed ? undefined : resetBoard}
    >
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-12">
        <section className="lg:col-span-4">
          <div className="mb-3 flex items-baseline justify-between">
            <h3 className="font-mono text-[11px] uppercase tracking-[0.16em] text-steel-400">Crib rack</h3>
            <span className="font-mono text-[10px] text-steel-500">4 families, reuse is allowed</span>
          </div>
          <div className="space-y-3">
            {BEARINGS.map((b) => {
              const active = picked === b.id;
              return (
                <button
                  key={b.id}
                  type="button"
                  draggable
                  onDragStart={(e) => onDragStart(e, b.id)}
                  onClick={() => setPicked((cur) => (cur === b.id ? null : b.id))}
                  className={`w-full rounded-lg border bg-navy-900/80 px-3 py-3 text-left transition-colors ${
                    active
                      ? 'border-rok-500 shadow-rok'
                      : 'border-steel-600 hover:border-steel-400'
                  }`}
                >
                  <div className="flex items-center justify-between gap-2">
                    <span className="font-mono text-sm font-semibold tracking-wide text-white">
                      {b.nameplate}
                    </span>
                    <span className="rounded border border-steel-600 px-1.5 py-0.5 font-mono text-[10px] uppercase text-steel-400">
                      {active ? 'Selected' : 'Drag / tap'}
                    </span>
                  </div>
                  <div className="mt-1 text-sm font-medium text-steel-100">{b.family}</div>
                  <div className="mt-0.5 text-xs text-steel-400">{b.spec}</div>
                </button>
              );
            })}
          </div>
          {picked && (
            <p className="mt-3 text-xs text-rok-300">
              {BEARINGS.find((b) => b.id === picked)?.nameplate} selected. Tap a machine card to seat it.
            </p>
          )}
        </section>

        <section className="lg:col-span-8">
          <div className="mb-3 flex items-baseline justify-between">
            <h3 className="font-mono text-[11px] uppercase tracking-[0.16em] text-steel-400">
              Machine cards — 5 cards. One family seats two machines.
            </h3>
            <span className="font-mono text-[10px] text-steel-500">
              {assignedCount}/{MACHINES.length} seated
            </span>
          </div>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
            {MACHINES.map((m) => {
              const seated = assignments[m.id];
              const seatedMeta = BEARINGS.find((b) => b.id === seated);
              const tone = cardTone[m.id];
              const border =
                tone === 'ok'
                  ? 'border-success-500/60 bg-success-500/5'
                  : tone === 'bad'
                    ? 'border-error-500/60 bg-error-500/5'
                    : 'border-steel-600 bg-navy-900/60';
              return (
                <div
                  key={m.id}
                  onDragOver={(e) => {
                    e.preventDefault();
                    e.dataTransfer.dropEffect = 'copy';
                  }}
                  onDrop={(e) => onDrop(e, m.id)}
                  onClick={() => {
                    if (picked) applyAssignment(m.id, picked);
                  }}
                  className={`rounded-lg border p-4 ${border}`}
                >
                  <div className="font-mono text-[10px] uppercase tracking-wider text-steel-500">
                    Machine
                  </div>
                  <div className="mt-1 font-display text-base font-semibold text-white">{m.label}</div>
                  <div className="mt-1 text-xs text-steel-400">{m.duty}</div>
                  <div className="mt-3 flex items-center justify-between gap-2">
                    <div
                      className={`min-h-[40px] flex-1 rounded border border-dashed px-2 py-2 font-mono text-xs ${
                        seatedMeta
                          ? 'border-steel-500 text-white'
                          : 'border-steel-700 text-steel-500'
                      }`}
                    >
                      {seatedMeta
                        ? `${seatedMeta.nameplate}  ${seatedMeta.family}`
                        : picked
                          ? 'Tap to seat selected family'
                          : 'Tap a crib family first'}
                    </div>
                    {seated && (
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          resetCard(m.id);
                        }}
                        className="btn-ghost px-2 py-1 text-[11px]"
                      >
                        Reset card
                      </button>
                    )}
                  </div>
                  {tone && seated && (
                    <p className={`mt-2 text-xs ${tone === 'ok' ? 'text-success-400' : 'text-error-400'}`}>
                      {tone === 'ok' ? m.whyCorrect : m.whyWrong[seated]}
                    </p>
                  )}
                </div>
              );
            })}
          </div>
        </section>
      </div>
    </GameShell>
  );
}
