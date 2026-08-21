/*
# Quiz attempt limits, retake approval, and admin attempt visibility

## Tables
- quiz_attempts: permanent record of every quiz submit
- quiz_retake_requests: company admin approval workflow
- quiz_lock_state: fail-cycle counter + lock status per user/lesson

## RLS
- Users read/insert their own quiz_attempts
- Users read their own lock state; can update their own lock (reset solo)
- Users create retake requests for themselves
- Company admins read attempts + lock state + retake requests for members
- Company admins approve/deny retake requests
- Super-admin full access
*/

-- ============================================================
-- 1. quiz_attempts
-- ============================================================
CREATE TABLE quiz_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  score int NOT NULL,
  passed boolean NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_quiz_attempts_user_lesson ON quiz_attempts(user_id, lesson_id);
CREATE INDEX idx_quiz_attempts_user_course ON quiz_attempts(user_id, course_id);

ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_attempts" ON quiz_attempts
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "users_insert_own_attempts" ON quiz_attempts
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- Company admins read attempts for their members via SECURITY DEFINER function
-- (direct RLS can't check company membership without recursion risk)

-- ============================================================
-- 2. quiz_retake_requests
-- ============================================================
CREATE TABLE quiz_retake_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','denied')),
  failed_attempt_count int NOT NULL,
  requested_at timestamptz NOT NULL DEFAULT now(),
  reviewed_at timestamptz NULL,
  reviewed_by uuid NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  note text NULL
);

CREATE INDEX idx_retake_requests_company ON quiz_retake_requests(company_id, status);
CREATE INDEX idx_retake_requests_user ON quiz_retake_requests(user_id, lesson_id);

ALTER TABLE quiz_retake_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_retake_requests" ON quiz_retake_requests
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "users_insert_own_retake_requests" ON quiz_retake_requests
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 3. quiz_lock_state
-- ============================================================
CREATE TABLE quiz_lock_state (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  failed_in_cycle int NOT NULL DEFAULT 0,
  locked boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, lesson_id)
);

ALTER TABLE quiz_lock_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_lock" ON quiz_lock_state
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "users_upsert_own_lock" ON quiz_lock_state
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_update_own_lock" ON quiz_lock_state
  FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 4. SECURITY DEFINER functions
-- ============================================================

-- Get quiz lock state for a user+lesson (or create default)
CREATE OR REPLACE FUNCTION get_quiz_lock_state(target_lesson_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result jsonb;
BEGIN
  -- Upsert a default row if not exists
  INSERT INTO quiz_lock_state (user_id, lesson_id, failed_in_cycle, locked)
  VALUES (auth.uid(), target_lesson_id, 0, false)
  ON CONFLICT (user_id, lesson_id) DO NOTHING;

  SELECT jsonb_build_object(
    'failed_in_cycle', qls.failed_in_cycle,
    'locked', qls.locked,
    'updated_at', qls.updated_at
  ) INTO result
  FROM quiz_lock_state qls
  WHERE qls.user_id = auth.uid() AND qls.lesson_id = target_lesson_id;

  RETURN result;
END;
$$;

-- Record a quiz attempt and update lock state
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
BEGIN
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

    RETURN jsonb_build_object(
      'passed', false,
      'locked', new_locked,
      'failed_in_cycle', new_failed_count
    );
  END IF;
END;
$$;

-- Reset fail-cycle (solo user confirms review, or company admin approves retake)
CREATE OR REPLACE FUNCTION reset_quiz_fail_cycle(
  p_lesson_id uuid,
  p_user_id uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  target_uid uuid;
BEGIN
  target_uid := COALESCE(p_user_id, auth.uid());

  -- If resetting someone else, must be company admin or super-admin
  IF p_user_id IS NOT NULL AND p_user_id <> auth.uid() THEN
    IF NOT is_company_admin(
      (SELECT cm.company_id FROM company_members cm WHERE cm.user_id = p_user_id LIMIT 1)
    ) THEN
      RAISE EXCEPTION 'Not authorized to reset this user''s quiz lock';
    END IF;
  END IF;

  UPDATE quiz_lock_state
  SET failed_in_cycle = 0, locked = false, updated_at = now()
  WHERE user_id = target_uid AND lesson_id = p_lesson_id;
END;
$$;

-- Approve a retake request (company admin)
CREATE OR REPLACE FUNCTION approve_retake_request(
  p_request_id uuid,
  p_approved boolean,
  p_note text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  req record;
BEGIN
  SELECT * INTO req FROM quiz_retake_requests WHERE id = p_request_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Retake request not found';
  END IF;

  -- Must be company admin of the request's company
  IF NOT is_company_admin(req.company_id) THEN
    RAISE EXCEPTION 'Not authorized to approve this request';
  END IF;

  IF p_approved THEN
    UPDATE quiz_retake_requests
    SET status = 'approved', reviewed_at = now(), reviewed_by = auth.uid(), note = p_note
    WHERE id = p_request_id;

    -- Unlock the learner
    UPDATE quiz_lock_state
    SET failed_in_cycle = 0, locked = false, updated_at = now()
    WHERE user_id = req.user_id AND lesson_id = req.lesson_id;
  ELSE
    UPDATE quiz_retake_requests
    SET status = 'denied', reviewed_at = now(), reviewed_by = auth.uid(), note = p_note
    WHERE id = p_request_id;
  END IF;
END;
$$;

-- Get retake requests for a company (admin view)
CREATE OR REPLACE FUNCTION get_company_retake_requests(target_company_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result jsonb;
BEGIN
  IF NOT is_company_admin(target_company_id) THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', rqr.id,
      'user_id', rqr.user_id,
      'lesson_id', rqr.lesson_id,
      'course_id', rqr.course_id,
      'status', rqr.status,
      'failed_attempt_count', rqr.failed_attempt_count,
      'requested_at', rqr.requested_at,
      'reviewed_at', rqr.reviewed_at,
      'note', rqr.note,
      'member_email', p.email,
      'member_name', p.full_name,
      'lesson_title', l.title,
      'course_title', c.title,
      'total_attempts', (
        SELECT COUNT(*) FROM quiz_attempts qa
        WHERE qa.user_id = rqr.user_id AND qa.lesson_id = rqr.lesson_id
      ),
      'last_score', (
        SELECT qa.score FROM quiz_attempts qa
        WHERE qa.user_id = rqr.user_id AND qa.lesson_id = rqr.lesson_id
        ORDER BY qa.created_at DESC LIMIT 1
      )
    )
    ORDER BY
      CASE WHEN rqr.status = 'pending' THEN 0 ELSE 1 END,
      rqr.requested_at DESC
  ), '[]'::jsonb) INTO result
  FROM quiz_retake_requests rqr
  LEFT JOIN profiles p ON p.id = rqr.user_id
  LEFT JOIN lessons l ON l.id = rqr.lesson_id
  LEFT JOIN courses c ON c.id = rqr.course_id
  WHERE rqr.company_id = target_company_id;

  RETURN result;
END;
$$;

-- Get quiz attempt stats for a company member (admin view)
CREATE OR REPLACE FUNCTION get_member_quiz_attempts(
  target_company_id uuid,
  target_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result jsonb;
BEGIN
  IF NOT is_company_admin(target_company_id) THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM company_members
    WHERE company_id = target_company_id AND user_id = target_user_id
  ) THEN
    RAISE EXCEPTION 'User is not a member of this company';
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'lesson_id', qa.lesson_id,
      'course_id', qa.course_id,
      'lesson_title', l.title,
      'course_title', c.title,
      'total_attempts', cnt.total,
      'failed_count', cnt.failed,
      'passed', cnt.passed,
      'best_score', cnt.best,
      'latest_score', cnt.latest,
      'last_attempt_at', cnt.last_at,
      'lock_status', COALESCE(qls.locked, false),
      'failed_in_cycle', COALESCE(qls.failed_in_cycle, 0)
    )
    ORDER BY c.title, l.sort_order
  ), '[]'::jsonb) INTO result
  FROM (
    SELECT
      lesson_id,
      course_id,
      COUNT(*) AS total,
      COUNT(*) FILTER (WHERE passed = false) AS failed,
      bool_or(passed) AS passed,
      MAX(score) AS best,
      (array_agg(score ORDER BY created_at DESC))[1] AS latest,
      MAX(created_at) AS last_at
    FROM quiz_attempts
    WHERE user_id = target_user_id
    GROUP BY lesson_id, course_id
  ) cnt
  JOIN lessons l ON l.id = cnt.lesson_id
  JOIN courses c ON c.id = cnt.course_id
  LEFT JOIN quiz_lock_state qls ON qls.user_id = target_user_id AND qls.lesson_id = cnt.lesson_id;

  RETURN result;
END;
$$;

-- Check for pending retake request
CREATE OR REPLACE FUNCTION get_pending_retake_request(p_lesson_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT jsonb_build_object(
    'id', rqr.id,
    'status', rqr.status
  ) INTO result
  FROM quiz_retake_requests rqr
  WHERE rqr.user_id = auth.uid()
    AND rqr.lesson_id = p_lesson_id
    AND rqr.status = 'pending'
  ORDER BY rqr.requested_at DESC
  LIMIT 1;

  RETURN COALESCE(result, 'null'::jsonb);
END;
$$;

GRANT EXECUTE ON FUNCTION get_quiz_lock_state(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION record_quiz_attempt(uuid, uuid, int, boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION reset_quiz_fail_cycle(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION approve_retake_request(uuid, boolean, text) TO authenticated;
GRANT EXECUTE ON FUNCTION get_company_retake_requests(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_member_quiz_attempts(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_retake_request(uuid) TO authenticated;
