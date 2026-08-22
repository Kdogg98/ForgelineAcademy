/*
# Add per-lesson video support

1. Schema Changes
- Add `video_url` (text, nullable) to the `lessons` table — stores either a Supabase Storage public URL (uploaded file) or an external embed URL (YouTube, Vimeo, Loom).
- Add `video_filename` (text, nullable) to `lessons` — original filename for uploaded files, or the URL for embedded links.
- Add `video_uploaded_at` (timestamptz, nullable) to `lessons` — timestamp of the last video update.

2. Security
- Add an UPDATE policy on `lessons` so authenticated admin users can update lesson video columns.
- Uses the existing `is_admin()` SECURITY DEFINER function to bypass RLS on profiles.
- The existing `catalog_lessons_read` SELECT policy (anon + authenticated) already covers reads.
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'lessons' AND column_name = 'video_url'
  ) THEN
    ALTER TABLE lessons ADD COLUMN video_url text;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'lessons' AND column_name = 'video_filename'
  ) THEN
    ALTER TABLE lessons ADD COLUMN video_filename text;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'lessons' AND column_name = 'video_uploaded_at'
  ) THEN
    ALTER TABLE lessons ADD COLUMN video_uploaded_at timestamptz;
  END IF;
END $$;

-- Admin-only UPDATE policy for lessons (uses SECURITY DEFINER is_admin() function)
DROP POLICY IF EXISTS "admin_update_lessons" ON lessons;
CREATE POLICY "admin_update_lessons"
ON lessons FOR UPDATE
TO authenticated
USING (is_admin()) WITH CHECK (is_admin());
