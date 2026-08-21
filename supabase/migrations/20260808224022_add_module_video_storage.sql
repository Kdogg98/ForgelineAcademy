/*
# Add video storage support for modules

1. Schema Changes
- Add `video_url` column (text, nullable) to the `modules` table to store the path/URL of an uploaded video.
- Add `video_filename` column (text, nullable) to store the original filename for display.
- Add `video_uploaded_at` column (timestamptz, nullable) to track when the video was last updated.

2. Storage
- Create a public storage bucket `module-videos` for storing video files.
- Storage policies: only authenticated users can read; only admin users can upload/delete.

3. Security
- No RLS changes to modules table (existing policies remain).
- Storage bucket policies enforce admin-only uploads.
*/

-- Add video columns to modules
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'modules' AND column_name = 'video_url'
  ) THEN
    ALTER TABLE modules ADD COLUMN video_url text;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'modules' AND column_name = 'video_filename'
  ) THEN
    ALTER TABLE modules ADD COLUMN video_filename text;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'modules' AND column_name = 'video_uploaded_at'
  ) THEN
    ALTER TABLE modules ADD COLUMN video_uploaded_at timestamptz;
  END IF;
END $$;

-- Create storage bucket for module videos
INSERT INTO storage.buckets (id, name, public)
VALUES ('module-videos', 'module-videos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies: authenticated users can read, admin can upload/update/delete
DROP POLICY IF EXISTS "module_videos_read" ON storage.objects;
CREATE POLICY "module_videos_read"
ON storage.objects FOR SELECT
TO anon, authenticated
USING (bucket_id = 'module-videos');

DROP POLICY IF EXISTS "module_videos_upload" ON storage.objects;
CREATE POLICY "module_videos_upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'module-videos' AND EXISTS (
  SELECT 1 FROM profiles
  WHERE profiles.id = auth.uid() AND profiles.is_admin = true
));

DROP POLICY IF EXISTS "module_videos_update" ON storage.objects;
CREATE POLICY "module_videos_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'module-videos' AND EXISTS (
  SELECT 1 FROM profiles
  WHERE profiles.id = auth.uid() AND profiles.is_admin = true
)) WITH CHECK (bucket_id = 'module-videos' AND EXISTS (
  SELECT 1 FROM profiles
  WHERE profiles.id = auth.uid() AND profiles.is_admin = true
));

DROP POLICY IF EXISTS "module_videos_delete" ON storage.objects;
CREATE POLICY "module_videos_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'module-videos' AND EXISTS (
  SELECT 1 FROM profiles
  WHERE profiles.id = auth.uid() AND profiles.is_admin = true
));
