import { useMemo, useState } from 'react';
import { ArrowLeft, Lock, Play, CheckCircle2 } from 'lucide-react';
import type { Route } from '@/components/Nav';
import { useAuth } from '@/lib/auth';
import { COURSE_ID, COURSE_TITLE, GAME_SET } from '@/lib/games/bearingsLubricationAlignment';
import { loadCourseGameProgress } from '@/lib/games/progress';
import type { GameResult } from '@/lib/games/types';
import { BearingTypeBoard } from '@/components/games/bearings/BearingTypeBoard';

interface CourseGamesProps {
  courseId: string;
  onNavigate: (r: Route) => void;
}

export function CourseGames({ courseId, onNavigate }: CourseGamesProps) {
  const { user } = useAuth();
  const userId = user?.id ?? null;
  const [activeGame, setActiveGame] = useState<string | null>(null);
  const [progressTick, setProgressTick] = useState(0);

  const playable = courseId === COURSE_ID;
  const progress = useMemo(
    () => loadCourseGameProgress(courseId, userId),
    [courseId, userId, progressTick],
  );

  const g1Passed = Boolean(progress['g1-crib-call']?.passed);

  function handleComplete(_result: GameResult) {
    setProgressTick((n) => n + 1);
  }

  return (
    <div className="min-h-screen pt-16">
      <div className="relative overflow-hidden border-b border-steel-700/60 bg-navy-950/40">
        <div className="absolute inset-0 bg-grid-steel bg-grid-32 opacity-20" />
        <div className="relative mx-auto max-w-7xl px-4 py-8 sm:px-6">
          <button
            type="button"
            onClick={() => onNavigate({ name: 'course', courseId })}
            className="mb-4 flex items-center gap-1.5 text-sm text-steel-400 transition-colors hover:text-white"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to course
          </button>
          <div className="text-[10px] font-mono uppercase tracking-[0.18em] text-rok-400">
            Shop-floor games
          </div>
          <h1 className="font-display text-2xl font-bold text-white sm:text-3xl">
            {playable ? COURSE_TITLE : 'Course games'}
          </h1>
          <p className="mt-2 max-w-2xl text-sm text-steel-300">
            {playable
              ? 'Ten crib-to-coupling drills for this course. Game 1 is live. Games 2 through 10 unlock after you confirm Game 1.'
              : 'Playable games are online for Bearings, Lubrication & Alignment Fundamentals. This course can open the floor, but Game 1 is not cut in yet.'}
          </p>
        </div>
      </div>

      <div className="mx-auto max-w-7xl space-y-8 px-4 py-8 sm:px-6">
        {playable && activeGame === 'g1-crib-call' && (
          <BearingTypeBoard
            courseId={courseId}
            userId={userId}
            onComplete={handleComplete}
          />
        )}

        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          {GAME_SET.map((game) => {
            const saved = progress[game.gameKey];
            const isG1 = game.id === 'g1-crib-call';
            const locked = !playable || !isG1;
            const open = playable && isG1 && activeGame === game.id;
            return (
              <div
                key={game.id}
                className={`card border-steel-600 p-5 ${open ? 'ring-1 ring-rok-500/50' : ''}`}
              >
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <div className="font-mono text-[10px] uppercase tracking-[0.16em] text-steel-500">
                      G{game.number} · {game.level}
                    </div>
                    <h2 className="mt-1 font-display text-lg font-semibold text-white">
                      {game.title}
                    </h2>
                  </div>
                  {saved?.passed ? (
                    <CheckCircle2 className="h-5 w-5 shrink-0 text-success-400" />
                  ) : locked ? (
                    <Lock className="h-5 w-5 shrink-0 text-steel-500" />
                  ) : null}
                </div>
                <p className="mt-2 text-sm text-steel-400">{game.summary}</p>
                {saved && (
                  <p className="mt-2 font-mono text-xs text-steel-300">
                    Last score {saved.score}/{saved.maxScore} {saved.passed ? 'passed' : 'not passed'}
                  </p>
                )}
                <div className="mt-4">
                  {playable && isG1 ? (
                    <button
                      type="button"
                      onClick={() => setActiveGame(open ? null : game.id)}
                      className="btn-primary"
                    >
                      <Play className="h-4 w-4" />
                      {open ? 'Hide board' : g1Passed ? 'Replay Game 1' : 'Launch Game 1'}
                    </button>
                  ) : (
                    <div className="rounded-md border border-steel-700 bg-navy-950/50 px-3 py-2 text-sm text-steel-400">
                      Next after you confirm Game 1
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
