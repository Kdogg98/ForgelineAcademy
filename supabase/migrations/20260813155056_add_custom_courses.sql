/*
# Add Custom Courses Feature

## Overview
Adds support for custom courses that admins can create and assign to specific
premium users. Custom courses are only visible to the assigned user and admins.

## Changes

### 1. courses table — new columns
- `is_custom` boolean NOT NULL DEFAULT false — marks a course as custom
- `assigned_user_id` uuid nullable — the user this custom course belongs to

### 2. Updated SELECT policies
- courses: visible to everyone when not custom; custom courses only visible
  to the assigned user or admins
- modules: inherits visibility through the parent course
- lessons: inherits visibility through the parent module → course

### 3. New admin write policies
- courses, modules, lessons: INSERT/UPDATE/DELETE for admin users only
  (checked via is_admin() function)

### 4. New SECURITY DEFINER function: create_custom_course()
- Takes course metadata + a JSON array of modules (each with title + lessons)
- Creates the course, all modules, and all lessons in one transaction
- Only callable by admins (is_admin() check inside)
- Returns the new course UUID

## Security
- Custom courses are hidden from everyone except the assigned user and admins
- Only admins can create, modify, or delete custom courses and their content
- The create_custom_course function is SECURITY DEFINER with search_path = 'public'
- EXECUTE granted to authenticated (function self-checks admin status)
*/

-- Add columns to courses
ALTER TABLE courses
  ADD COLUMN IF NOT EXISTS is_custom boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS assigned_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL;

-- Update courses SELECT policy: custom courses only visible to assigned user or admin
DROP POLICY IF EXISTS "catalog_courses_read" ON courses;
CREATE POLICY "catalog_courses_read" ON courses FOR SELECT
  TO anon, authenticated USING (
    is_custom = false
    OR assigned_user_id = auth.uid()
    OR (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

-- Update modules SELECT policy: inherit from parent course visibility
DROP POLICY IF EXISTS "catalog_modules_read" ON modules;
CREATE POLICY "catalog_modules_read" ON modules FOR SELECT
  TO anon, authenticated USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = modules.course_id
      AND (
        courses.is_custom = false
        OR courses.assigned_user_id = auth.uid()
        OR (SELECT is_admin FROM profiles WHERE id = auth.uid())
      )
    )
  );

-- Update lessons SELECT policy: inherit from parent module → course visibility
DROP POLICY IF EXISTS "catalog_lessons_read" ON lessons;
CREATE POLICY "catalog_lessons_read" ON lessons FOR SELECT
  TO anon, authenticated USING (
    EXISTS (
      SELECT 1 FROM modules
      JOIN courses ON courses.id = modules.course_id
      WHERE modules.id = lessons.module_id
      AND (
        courses.is_custom = false
        OR courses.assigned_user_id = auth.uid()
        OR (SELECT is_admin FROM profiles WHERE id = auth.uid())
      )
    )
  );

-- Admin write policies on courses
DROP POLICY IF EXISTS "admin_insert_courses" ON courses;
CREATE POLICY "admin_insert_courses" ON courses FOR INSERT
  TO authenticated WITH CHECK (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

DROP POLICY IF EXISTS "admin_update_courses" ON courses;
CREATE POLICY "admin_update_courses" ON courses FOR UPDATE
  TO authenticated USING (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  ) WITH CHECK (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

DROP POLICY IF EXISTS "admin_delete_courses" ON courses;
CREATE POLICY "admin_delete_courses" ON courses FOR DELETE
  TO authenticated USING (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

-- Admin write policies on modules
DROP POLICY IF EXISTS "admin_insert_modules" ON modules;
CREATE POLICY "admin_insert_modules" ON modules FOR INSERT
  TO authenticated WITH CHECK (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

DROP POLICY IF EXISTS "admin_update_modules" ON modules;
CREATE POLICY "admin_update_modules" ON modules FOR UPDATE
  TO authenticated USING (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  ) WITH CHECK (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

DROP POLICY IF EXISTS "admin_delete_modules" ON modules;
CREATE POLICY "admin_delete_modules" ON modules FOR DELETE
  TO authenticated USING (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

-- Admin write policies on lessons (INSERT and DELETE; UPDATE already exists)
DROP POLICY IF EXISTS "admin_insert_lessons" ON lessons;
CREATE POLICY "admin_insert_lessons" ON lessons FOR INSERT
  TO authenticated WITH CHECK (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

DROP POLICY IF EXISTS "admin_delete_lessons" ON lessons;
CREATE POLICY "admin_delete_lessons" ON lessons FOR DELETE
  TO authenticated USING (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

-- Create the create_custom_course function
CREATE OR REPLACE FUNCTION create_custom_course(
  p_title text,
  p_description text,
  p_short_description text,
  p_stage text,
  p_difficulty text,
  p_estimated_hours numeric,
  p_assigned_user_id uuid,
  p_modules jsonb
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  new_course_id uuid;
  mod_count int;
  lesson_count int;
  mod_row jsonb;
  lesson_row jsonb;
  new_module_id uuid;
  max_sort_order int;
BEGIN
  -- Verify caller is admin
  IF NOT (SELECT is_admin FROM profiles WHERE id = auth.uid()) THEN
    RAISE EXCEPTION 'Only admins can create custom courses';
  END IF;

  -- Determine next sort_order for this stage
  SELECT COALESCE(MAX(sort_order), 0) + 1 INTO max_sort_order
  FROM courses WHERE stage = p_stage;

  -- Create the course
  INSERT INTO courses (
    title, description, short_description, stage, tier,
    difficulty, estimated_hours, sort_order, is_custom, assigned_user_id
  )
  VALUES (
    p_title, p_description, p_short_description, p_stage, 'premium',
    p_difficulty, p_estimated_hours, max_sort_order, true, p_assigned_user_id
  )
  RETURNING id INTO new_course_id;

  -- Create modules and lessons
  FOR mod_row IN SELECT * FROM jsonb_array_elements(p_modules)
  LOOP
    INSERT INTO modules (course_id, title, sort_order)
    VALUES (
      new_course_id,
      mod_row->>'title',
      COALESCE((mod_row->>'sort_order')::int, 0)
    )
    RETURNING id INTO new_module_id;

    IF mod_row->'lessons' IS NOT NULL THEN
      FOR lesson_row IN SELECT * FROM jsonb_array_elements(mod_row->'lessons')
      LOOP
        INSERT INTO lessons (
          module_id, title, content, estimated_minutes, has_video, has_pdf,
          quiz, pass_threshold, sort_order
        )
        VALUES (
          new_module_id,
          lesson_row->>'title',
          COALESCE(lesson_row->>'content', ''),
          COALESCE((lesson_row->>'estimated_minutes')::int, 30),
          COALESCE((lesson_row->>'has_video')::boolean, false),
          COALESCE((lesson_row->>'has_pdf')::boolean, false),
          COALESCE(lesson_row->'quiz', '[]'::jsonb),
          COALESCE((lesson_row->>'pass_threshold')::int, 80),
          COALESCE((lesson_row->>'sort_order')::int, 0)
        );
      END LOOP;
    END IF;
  END LOOP;

  RETURN new_course_id;
END;
$$;

GRANT EXECUTE ON FUNCTION create_custom_course(
  text, text, text, text, text, numeric, uuid, jsonb
) TO authenticated;
