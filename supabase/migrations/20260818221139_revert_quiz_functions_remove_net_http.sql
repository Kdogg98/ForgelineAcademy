/*
# Revert record_quiz_attempt to remove net.http_post dependency
# pg_net extension is not available — notifications handled from frontend instead
*/

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
      'failed_in_cycle', new_failed_count,
      'company_id', company_id
    );
  END IF;
END;
$$;

-- Revert approve_retake_request to remove net.http_post
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
