/*
# Update approve_retake_request to send notification email to member
*/

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
  member_name text;
  member_email text;
  lesson_title text;
  notify_url text;
  notify_payload jsonb;
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

    -- Send notification to member
    SELECT COALESCE(p.full_name, au.email) INTO member_name
    FROM profiles p
    JOIN auth.users au ON au.id = p.id
    WHERE p.id = req.user_id;

    SELECT au.email INTO member_email
    FROM auth.users au
    WHERE au.id = req.user_id;

    SELECT l.title INTO lesson_title
    FROM lessons l
    WHERE l.id = req.lesson_id;

    notify_url := 'https://placeholder.supabase.co';

    notify_payload := jsonb_build_object(
      'type', 'retake_approved',
      'member_name', member_name,
      'member_email', member_email,
      'lesson_title', lesson_title
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
      RAISE NOTICE 'Failed to send approval notification: %', SQLERRM;
    END;
  ELSE
    UPDATE quiz_retake_requests
    SET status = 'denied', reviewed_at = now(), reviewed_by = auth.uid(), note = p_note
    WHERE id = p_request_id;
  END IF;
END;
$$;
