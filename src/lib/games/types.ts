export type GameId =
  | 'g1-crib-call'
  | 'g2-spall-or-smear'
  | 'g3-grease-or-oil'
  | 'g4-fit-and-clearance'
  | 'g5-soft-foot'
  | 'g6-rim-face-laser'
  | 'g7-thermal-growth'
  | 'g8-hot-bearing'
  | 'g9-coupling-walk'
  | 'g10-train-alignment';

export type GameLevel = 'foundational' | 'intermediate' | 'advanced';

export interface GameBlueprint {
  id: GameId;
  gameKey: GameId;
  number: number;
  title: string;
  shortTitle: string;
  level: GameLevel;
  summary: string;
  implemented: boolean;
}

export interface GameResult {
  courseId: string;
  gameKey: string;
  score: number;
  maxScore: number;
  passed: boolean;
  completedAt: string;
}

export interface CourseGameProgress {
  [gameKey: string]: GameResult;
}

export const DEFAULT_PASS_THRESHOLD = 80;
