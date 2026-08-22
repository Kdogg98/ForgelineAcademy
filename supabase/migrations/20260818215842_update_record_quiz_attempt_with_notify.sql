/*
# Update record_quiz_attempt to send retake notification
When a company user gets locked after 3 fails, fire an http notification to the
notify edge function which emails company admins.
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
  admin_emails jsonb;
  lesson_title text;
  course_title text;
  member_name text;
  member_email text;
  notify_url text;
  notify_payload jsonb;
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

        -- Gather admin emails for notification
        SELECT COALESCE(jsonb_agg(au.email), '[]'::jsonb) INTO admin_emails
        FROM company_members cm
        JOIN auth.users au ON au.id = cm.user_id
        WHERE cm.company_id = company_id
          AND cm.role IN ('owner', 'admin');

        -- Get lesson/course/member info for the email
        SELECT l.title INTO lesson_title FROM lessons l WHERE l.id = p_lesson_id;
        SELECT c.title INTO course_title FROM courses c WHERE c.id = p_course_id;
        SELECT COALESCE(p.full_name, au.email) INTO member_name
        FROM profiles p
        JOIN auth.users au ON au.id = p.id
        WHERE p.id = auth.uid();

        SELECT au.email INTO member_email
        FROM auth.users au
        WHERE au.id = auth.uid();

        -- Fire notification to edge function (best-effort, don't fail the quiz submit)
        notify_url := (SELECT current_setting('app.supabase_url', true));
        IF notify_url IS NULL OR notify_url = '' THEN
          notify_url := 'https://placeholder.supabase.co';
        END IF;

        notify_payload := jsonb_build_object(
          'type', 'retake_request',
          'member_name', member_name,
          'member_email', member_email,
          'course_title', course_title,
          'lesson_title', lesson_title,
          'failed_attempts', new_failed_count,
          'admin_emails', admin_emails
        );

        BEGIN
          PERFORM net.http_post(
            url := notify_url || '/functions/v1/notify',
            headers := jsonb_build_object(
              'Content-Type', 'application/json',
              'Authorization', 'Bearer ' || current_setting('app.service_role_key', true)
            ),
            body := notify_payload
          );
        EXCEPTION WHEN OTHERS THEN
          -- net.http_post not available or failed — log and continue
          RAISE NOTICE 'Failed to send retake notification: %', SQLERRM;
        END;
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
