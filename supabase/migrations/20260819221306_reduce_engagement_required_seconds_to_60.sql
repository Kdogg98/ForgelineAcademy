-- Override the required engagement time to a flat 60 seconds for all lessons
CREATE OR REPLACE FUNCTION get_required_engagement_seconds(p_lesson_id uuid)
RETURNS int
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT 60;
$$;
