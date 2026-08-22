/*
# Lesson Engagement Gating

## Purpose
Prevents users from skipping lesson content and going straight to the quiz.
Users must open the lesson content and spend a minimum active time before the quiz unlocks.

## New Tables
- `lesson_engagement`
  - `user_id` (uuid, FK to auth.users, NOT NULL, DEFAULT auth.uid())
  - `lesson_id` (uuid, FK to lessons, NOT NULL)
  - `seconds_viewed` (int, NOT NULL, DEFAULT 0) — accumulated active time on lesson content
  - `content_opened` (boolean, NOT NULL, DEFAULT false) — whether the user opened/viewed the lesson content section
  - `quiz_unlocked` (boolean, NOT NULL, DEFAULT false) — whether engagement requirement was met
  - `relock_refresh_seconds` (int, NOT NULL, DEFAULT 0) — additional seconds required after a fail/study-again gate (0 when no re-lock active)
  - `updated_at` (timestamptz, DEFAULT now())
  - Unique constraint on (user_id, lesson_id)

## New Functions
- `upsert_lesson_engagement(p_lesson_id, p_content_opened, p_seconds_to_add)`
  - Upserts engagement row for the current user.
  - Adds seconds_to_add to seconds_viewed (capped at 999999).
  - Sets content_opened = true if p_content_opened is true.
  - Computes quiz_unlocked based on engagement requirement.
  - Returns the engagement row as jsonb.
- `get_lesson_engagement(p_lesson_id)`
  - Returns the engagement row for the current user as jsonb (or null).
- `check_lesson_engagement(p_lesson_id)`
  - Returns jsonb with { engaged: boolean, seconds_viewed: int, required_seconds: int, quiz_unlocked: boolean }.
  - engaged is true if content_opened AND seconds_viewed >= required_seconds.
  - required_seconds = LEAST(GREATEST(60, floor(estimated_minutes * 60 * 0.2)), 240) — min 60s, 20% of estimated time, capped at 4 minutes.
  - If relock_refresh_seconds > 0 (re-lock after fail), required_seconds = seconds_viewed + relock_refresh_seconds (must accumulate more time).
- `relock_lesson_quiz(p_lesson_id)`
  - Called after a fail when the user needs to study again.
  - Sets quiz_unlocked = false and relock_refresh_seconds = 45 (short re-engagement: 45 seconds).
  - Returns void.

## Modified Functions
- `record_quiz_attempt` — now checks engagement BEFORE recording the attempt.
  - If engagement requirement not met, raises an exception with a descriptive message.
  - Otherwise proceeds with existing logic.

## Security
- RLS enabled on `lesson_engagement`.
- 4 owner-scoped policies (SELECT, INSERT, UPDATE, DELETE) for authenticated users.
- All functions are SECURITY DEFINER (run with elevated privileges) to read engagement data.
*/

-- ============================================================
-- 1. Create lesson_engagement table
-- ============================================================
CREATE TABLE IF NOT EXISTS lesson_engagement (
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  seconds_viewed int NOT NULL DEFAULT 0,
  content_opened boolean NOT NULL DEFAULT false,
  quiz_unlocked boolean NOT NULL DEFAULT false,
  relock_refresh_seconds int NOT NULL DEFAULT 0,
  updated_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, lesson_id)
);

ALTER TABLE lesson_engagement ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_engagement" ON lesson_engagement;
CREATE POLICY "select_own_engagement" ON lesson_engagement FOR SELECT
  TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "insert_own_engagement" ON lesson_engagement;
CREATE POLICY "insert_own_engagement" ON lesson_engagement FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "update_own_engagement" ON lesson_engagement;
CREATE POLICY "update_own_engagement" ON lesson_engagement FOR UPDATE
  TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "delete_own_engagement" ON lesson_engagement;
CREATE POLICY "delete_own_engagement" ON lesson_engagement FOR DELETE
  TO authenticated USING (auth.uid() = user_id);

-- ============================================================
-- 2. Helper: compute required seconds for a lesson
-- ============================================================
CREATE OR REPLACE FUNCTION get_required_engagement_seconds(p_lesson_id uuid)
RETURNS int
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    LEAST(GREATEST(60, floor(l.estimated_minutes * 60 * 0.2)), 240),
    60
  )
  FROM lessons l
  WHERE l.id = p_lesson_id;
$$;

-- ============================================================
-- 3. Upsert engagement (called by heartbeat pings)
-- ============================================================
CREATE OR REPLACE FUNCTION upsert_lesson_engagement(
  p_lesson_id uuid,
  p_content_opened boolean DEFAULT false,
  p_seconds_to_add int DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_seconds int := 0;
  v_required int;
  v_engaged boolean := false;
  v_row lesson_engagement%ROWTYPE;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  v_required := get_required_engagement_seconds(p_lesson_id);

  -- Upsert engagement row
  INSERT INTO lesson_engagement (user_id, lesson_id, seconds_viewed, content_opened, quiz_unlocked, relock_refresh_seconds, updated_at)
  VALUES (v_user_id, p_lesson_id, LEAST(p_seconds_to_add, 999999), p_content_opened, false, 0, now())
  ON CONFLICT (user_id, lesson_id)
  DO UPDATE SET
    seconds_viewed = LEAST(lesson_engagement.seconds_viewed + p_seconds_to_add, 999999),
    content_opened = lesson_engagement.content_opened OR p_content_opened,
    updated_at = now()
  RETURNING * INTO v_row;

  -- Check if engagement requirement met (considering relock)
  IF v_row.relock_refresh_seconds > 0 THEN
    -- After a fail re-lock: need to accumulate relock_refresh_seconds MORE seconds
    v_engaged := v_row.content_opened AND v_row.seconds_viewed >= (v_required + v_row.relock_refresh_seconds);
  ELSE
    v_engaged := v_row.content_opened AND v_row.seconds_viewed >= v_required;
  END IF;

  IF v_engaged AND NOT v_row.quiz_unlocked THEN
    UPDATE lesson_engagement SET quiz_unlocked = true, updated_at = now()
    WHERE user_id = v_user_id AND lesson_id = p_lesson_id
    RETURNING * INTO v_row;
  END IF;

  RETURN jsonb_build_object(
    'user_id', v_row.user_id,
    'lesson_id', v_row.lesson_id,
    'seconds_viewed', v_row.seconds_viewed,
    'content_opened', v_row.content_opened,
    'quiz_unlocked', v_row.quiz_unlocked,
    'relock_refresh_seconds', v_row.relock_refresh_seconds,
    'required_seconds', v_required,
    'engaged', v_engaged,
    'updated_at', v_row.updated_at
  );
END;
$$;

-- ============================================================
-- 4. Get engagement for a lesson (for client UI)
-- ============================================================
CREATE OR REPLACE FUNCTION get_lesson_engagement(p_lesson_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_row lesson_engagement%ROWTYPE;
  v_required int;
  v_engaged boolean := false;
BEGIN
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('engaged', false, 'seconds_viewed', 0, 'required_seconds', 60, 'quiz_unlocked', false, 'content_opened', false, 'relock_refresh_seconds', 0);
  END IF;

  v_required := get_required_engagement_seconds(p_lesson_id);

  SELECT * INTO v_row FROM lesson_engagement WHERE user_id = v_user_id AND lesson_id = p_lesson_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('engaged', false, 'seconds_viewed', 0, 'required_seconds', v_required, 'quiz_unlocked', false, 'content_opened', false, 'relock_refresh_seconds', 0);
  END IF;

  IF v_row.relock_refresh_seconds > 0 THEN
    v_engaged := v_row.content_opened AND v_row.seconds_viewed >= (v_required + v_row.relock_refresh_seconds);
  ELSE
    v_engaged := v_row.content_opened AND v_row.seconds_viewed >= v_required;
  END IF;

  RETURN jsonb_build_object(
    'engaged', v_engaged,
    'seconds_viewed', v_row.seconds_viewed,
    'required_seconds', v_required,
    'quiz_unlocked', v_row.quiz_unlocked,
    'content_opened', v_row.content_opened,
    'relock_refresh_seconds', v_row.relock_refresh_seconds
  );
END;
$$;

-- ============================================================
-- 5. Re-lock quiz after fail (shorter re-engagement)
-- ============================================================
CREATE OR REPLACE FUNCTION relock_lesson_quiz(p_lesson_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE lesson_engagement
  SET quiz_unlocked = false,
      relock_refresh_seconds = 45,
      updated_at = now()
  WHERE user_id = v_user_id AND lesson_id = p_lesson_id;

  -- If no row exists yet, create one in relocked state
  IF NOT FOUND THEN
    INSERT INTO lesson_engagement (user_id, lesson_id, quiz_unlocked, relock_refresh_seconds)
    VALUES (v_user_id, p_lesson_id, false, 45)
    ON CONFLICT (user_id, lesson_id) DO NOTHING;
  END IF;
END;
$$;

-- ============================================================
-- 6. Update record_quiz_attempt to check engagement first
-- ============================================================
CREATE OR REPLACE FUNCTION record_quiz_attempt(
  p_lesson_id uuid,
  p_course_id uuid,
  p_score int,
  p_passed boolean
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  new_failed_count int;
  new_locked boolean;
  is_company_member boolean;
  company_id uuid;
  v_engagement jsonb;
  v_engaged boolean;
  v_required int;
BEGIN
  -- Check engagement requirement
  v_engagement := get_lesson_engagement(p_lesson_id);
  v_engaged := (v_engagement ->> 'engaged')::boolean;
  v_required := (v_engagement ->> 'required_seconds')::int;

  IF NOT v_engaged THEN
    RAISE EXCEPTION 'Quiz locked — review the lesson material first. You need to spend more time on the lesson content before attempting the knowledge check.';
  END IF;

  -- Insert permanent attempt record
  INSERT INTO quiz_attempts (user_id, lesson_id, course_id, score, passed)
  VALUES (auth.uid(), p_lesson_id, p_course_id, p_score, p_passed);

  -- Get user's company
  SELECT c.id INTO company_id
  FROM profiles p
  JOIN company_members cm ON cm.user_id = p.id
  JOIN companies c ON c.id = cm.company_id
  WHERE p.id = auth.uid()
  LIMIT 1;

  is_company_member := company_id IS NOT NULL;

  IF p_passed THEN
    -- Passing resets fail-cycle and unlocks
    UPDATE quiz_lock_state
    SET failed_in_cycle = 0, locked = false, updated_at = now()
    WHERE user_id = auth.uid() AND lesson_id = p_lesson_id;

    -- Clear any relock state
    UPDATE lesson_engagement
    SET relock_refresh_seconds = 0, quiz_unlocked = true, updated_at = now()
    WHERE user_id = auth.uid() AND lesson_id = p_lesson_id;

    RETURN jsonb_build_object('passed', true, 'locked', false, 'failed_in_cycle', 0);
  ELSE
    -- Failed: increment fail-cycle
    INSERT INTO quiz_lock_state (user_id, lesson_id, failed_in_cycle, locked)
    VALUES (auth.uid(), p_lesson_id, 1, false)
    ON CONFLICT (user_id, lesson_id)
    DO UPDATE SET
      failed_in_cycle = quiz_lock_state.failed_in_cycle + 1,
      updated_at = now()
    RETURNING failed_in_cycle INTO new_failed_count;

    -- Lock after 3 fails
    IF new_failed_count >= 3 THEN
      new_locked := true;
      UPDATE quiz_lock_state
      SET locked = true, updated_at = now()
      WHERE user_id = auth.uid() AND lesson_id = p_lesson_id;

      -- If company member, auto-create a retake request
      IF is_company_member THEN
        INSERT INTO quiz_retake_requests (user_id, lesson_id, course_id, company_id, status, failed_attempt_count)
        VALUES (auth.uid(), p_lesson_id, p_course_id, company_id, 'pending', new_failed_count);
      END IF;
    ELSE
      new_locked := false;
    END IF;

    -- Re-lock quiz engagement (shorter re-engagement required)
    PERFORM relock_lesson_quiz(p_lesson_id);

    RETURN jsonb_build_object(
      'passed', false,
      'locked', new_locked,
      'failed_in_cycle', new_failed_count,
      'company_id', company_id
    );
  END IF;
END;
$$;

-- ============================================================
-- 7. Update reset_quiz_fail_cycle to also clear relock state
-- ============================================================
CREATE OR REPLACE FUNCTION reset_quiz_fail_cycle(p_lesson_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE quiz_lock_state
  SET failed_in_cycle = 0, locked = false, updated_at = now()
  WHERE user_id = auth.uid() AND lesson_id = p_lesson_id;

  -- Clear relock so quiz is immediately available again
  UPDATE lesson_engagement
  SET relock_refresh_seconds = 0, quiz_unlocked = true, updated_at = now()
  WHERE user_id = auth.uid() AND lesson_id = p_lesson_id;
END;
$$;
