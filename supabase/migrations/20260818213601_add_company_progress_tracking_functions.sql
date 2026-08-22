/*
# Company member details + progress tracking functions

## Purpose
Company admins need to see member emails/names and track employee learning
progress. Standard RLS blocks reading other users' profiles and progress,
so we use SECURITY DEFINER functions that enforce company admin/owner
authorization server-side before returning data.

## New Functions
1. get_company_members_details — returns member profiles (email, name, role, joined date)
   for a company. Caller must be company admin/owner or super-admin.
2. get_company_member_progress — returns progress summary per member (lessons completed,
   courses started, certificates count, last activity). Caller must be company admin/owner
   or super-admin.
3. get_member_lesson_progress — returns detailed lesson-by-lesson progress for a specific
   member in a company. Caller must be company admin/owner or super-admin.
4. get_all_companies_with_stats — returns all companies with member counts and owner emails.
   Caller must be super-admin only.
*/

-- ============================================================
-- 1. get_company_members_details
-- ============================================================
CREATE OR REPLACE FUNCTION get_company_members_details(target_company_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result jsonb;
BEGIN
  IF NOT is_company_admin(target_company_id) THEN
    RAISE EXCEPTION 'Not authorized to manage this company';
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'member_id', cm.id,
      'user_id', cm.user_id,
      'role', cm.role,
      'created_at', cm.created_at,
      'email', p.email,
      'full_name', p.full_name
    )
    ORDER BY cm.created_at ASC
  ), '[]'::jsonb) INTO result
  FROM company_members cm
  LEFT JOIN profiles p ON p.id = cm.user_id
  WHERE cm.company_id = target_company_id;

  RETURN result;
END;
$$;

-- ============================================================
-- 2. get_company_member_progress
-- ============================================================
CREATE OR REPLACE FUNCTION get_company_member_progress(target_company_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result jsonb;
BEGIN
  IF NOT is_company_admin(target_company_id) THEN
    RAISE EXCEPTION 'Not authorized to manage this company';
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'user_id', cm.user_id,
      'email', p.email,
      'full_name', p.full_name,
      'role', cm.role,
      'lessons_completed', COALESCE(prog.lessons_completed, 0),
      'courses_started', COALESCE(prog.courses_started, 0),
      'certificates_count', COALESCE(cert.cert_count, 0),
      'last_activity', prog.last_activity
    )
    ORDER BY cm.created_at ASC
  ), '[]'::jsonb) INTO result
  FROM company_members cm
  LEFT JOIN profiles p ON p.id = cm.user_id
  LEFT JOIN (
    SELECT
      up.user_id,
      COUNT(*) FILTER (WHERE up.completed = true) AS lessons_completed,
      COUNT(DISTINCT up.course_id) AS courses_started,
      MAX(up.completed_at) AS last_activity
    FROM user_progress up
    GROUP BY up.user_id
  ) prog ON prog.user_id = cm.user_id
  LEFT JOIN (
    SELECT user_id, COUNT(*) AS cert_count
    FROM certificates
    GROUP BY user_id
  ) cert ON cert.user_id = cm.user_id
  WHERE cm.company_id = target_company_id;

  RETURN result;
END;
$$;

-- ============================================================
-- 3. get_member_lesson_progress
-- ============================================================
CREATE OR REPLACE FUNCTION get_member_lesson_progress(
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
    RAISE EXCEPTION 'Not authorized to manage this company';
  END IF;

  -- Verify target_user is actually in this company
  IF NOT EXISTS (
    SELECT 1 FROM company_members
    WHERE company_id = target_company_id AND user_id = target_user_id
  ) THEN
    RAISE EXCEPTION 'User is not a member of this company';
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'progress_id', up.id,
      'lesson_id', up.lesson_id,
      'course_id', up.course_id,
      'course_title', c.title,
      'lesson_title', l.title,
      'completed', up.completed,
      'quiz_score', up.quiz_score,
      'completed_at', up.completed_at
    )
    ORDER BY c.title ASC, l.sort_order ASC
  ), '[]'::jsonb) INTO result
  FROM user_progress up
  LEFT JOIN courses c ON c.id = up.course_id
  LEFT JOIN lessons l ON l.id = up.lesson_id
  WHERE up.user_id = target_user_id;

  RETURN result;
END;
$$;

-- ============================================================
-- 4. get_all_companies_with_stats (super-admin only)
-- ============================================================
CREATE OR REPLACE FUNCTION get_all_companies_with_stats()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  admin_check boolean;
  result jsonb;
BEGIN
  SELECT is_admin INTO admin_check FROM profiles WHERE id = auth.uid();
  IF NOT COALESCE(admin_check, false) THEN
    RAISE EXCEPTION 'Only platform admins can access all companies';
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', c.id,
      'name', c.name,
      'logo_url', c.logo_url,
      'premium', c.premium,
      'active', c.active,
      'created_at', c.created_at,
      'member_count', COALESCE(mc.cnt, 0),
      'owner_email', owner_prof.email
    )
    ORDER BY c.created_at DESC
  ), '[]'::jsonb) INTO result
  FROM companies c
  LEFT JOIN (
    SELECT company_id, COUNT(*) AS cnt
    FROM company_members
    GROUP BY company_id
  ) mc ON mc.company_id = c.id
  LEFT JOIN (
    SELECT cm.company_id, au.email
    FROM company_members cm
    JOIN auth.users au ON au.id = cm.user_id
    WHERE cm.role = 'owner'
  ) owner_prof ON owner_prof.company_id = c.id;

  RETURN result;
END;
$$;

-- Also allow super-admin to manage members of ANY company via existing functions
-- (is_company_admin already checks for super-admin, so no changes needed there)

GRANT EXECUTE ON FUNCTION get_company_members_details(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_company_member_progress(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_member_lesson_progress(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_companies_with_stats() TO authenticated;
