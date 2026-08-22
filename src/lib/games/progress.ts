import type { CourseGameProgress, GameResult } from './types';
import { DEFAULT_PASS_THRESHOLD } from './types';

const STORAGE_PREFIX = 'forgeline.academy.games';

function storageUserKey(userId: string | null | undefined): string {
  return userId && userId.trim() ? userId : 'anon';
}

function storageKey(userId: string | null | undefined, courseId: string): string {
  return `${STORAGE_PREFIX}:${storageUserKey(userId)}:${courseId}`;
}

function readStore(courseId: string, userId: string | null | undefined): CourseGameProgress {
  if (typeof window === 'undefined' || !window.localStorage) return {};
  try {
    const raw = window.localStorage.getItem(storageKey(userId, courseId));
    if (!raw) return {};
    const parsed = JSON.parse(raw) as CourseGameProgress;
    return parsed && typeof parsed === 'object' ? parsed : {};
  } catch {
    return {};
  }
}

function writeStore(courseId: string, userId: string | null | undefined, data: CourseGameProgress) {
  if (typeof window === 'undefined' || !window.localStorage) return;
  window.localStorage.setItem(storageKey(userId, courseId), JSON.stringify(data));
}

export function isPassedScore(score: number, maxScore: number, threshold = DEFAULT_PASS_THRESHOLD): boolean {
  if (maxScore <= 0) return false;
  return (score / maxScore) * 100 >= threshold;
}

export function saveGameResult(
  input: {
    courseId: string;
    gameKey: string;
    score: number;
    maxScore: number;
    passed: boolean;
    completedAt: string;
    userId?: string | null;
  },
): GameResult {
  const result: GameResult = {
    courseId: input.courseId,
    gameKey: input.gameKey,
    score: input.score,
    maxScore: input.maxScore,
    passed: input.passed,
    completedAt: input.completedAt,
  };
  const store = readStore(input.courseId, input.userId ?? null);
  store[input.gameKey] = result;
  writeStore(input.courseId, input.userId ?? null, store);
  return result;
}

export function loadCourseGameProgress(
  courseId: string,
  userId: string | null,
): CourseGameProgress {
  return readStore(courseId, userId);
}

export { DEFAULT_PASS_THRESHOLD };
