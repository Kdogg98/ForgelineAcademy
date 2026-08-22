/*
# Skill Assessment History & Retake Tracking

## Purpose
Track assessment history so retake eligibility can be checked against learning
progress since the last assessment. The latest result always drives the
Home "For You" tab.

## Changes to `profiles` table
- `assessment_responses` already stores the full evaluation (added in prior migration).
  No column changes needed — the existing `assessment_responses` jsonb now stores
  `{ messages, evaluation, answers }` where `answers` is the MC answer record.

## New table: `assessment_history`
- `id` (uuid, primary key)
- `user_id` (uuid, not null, references auth.users, ON DELETE CASCADE)
- `level` (text) — novice | intermediate | advanced | expert
- `summary` (text)
- `evaluation` (jsonb) — full evaluation object including per-area breakdown
- `answers` (jsonb) — array of { questionIndex, selectedIndex, correct }
- `score` (integer) — number correct
- `total_questions` (integer) — total questions asked
- `taken_at` (timestamptz, default now())

## Security
- RLS enabled on `assessment_history`.
- Owner-scoped CRUD: users can read/insert their own history. Updates/deletes
  are not needed (history is append-only), but we include them for completeness.
*/

CREATE TABLE IF NOT EXISTS assessment_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  level text,
  summary text,
  evaluation jsonb,
  answers jsonb,
  score integer,
  total_questions integer,
  taken_at timestamptz DEFAULT now()
);

ALTER TABLE assessment_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_assessment_history" ON assessment_history;
CREATE POLICY "select_own_assessment_history" ON assessment_history
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "insert_own_assessment_history" ON assessment_history;
CREATE POLICY "insert_own_assessment_history" ON assessment_history
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "update_own_assessment_history" ON assessment_history;
CREATE POLICY "update_own_assessment_history" ON assessment_history
  FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "delete_own_assessment_history" ON assessment_history;
CREATE POLICY "delete_own_assessment_history" ON assessment_history
  FOR DELETE TO authenticated USING (auth.uid() = user_id);
