-- Fix storage policies for module-videos bucket to use the is_admin() SECURITY DEFINER function
-- The previous policies used a subquery on profiles, but profiles has RLS enabled which blocks the subquery.

DROP POLICY IF EXISTS "module_videos_upload" ON storage.objects;
CREATE POLICY "module_videos_upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'module-videos' AND is_admin());

DROP POLICY IF EXISTS "module_videos_update" ON storage.objects;
CREATE POLICY "module_videos_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'module-videos' AND is_admin()) WITH CHECK (bucket_id = 'module-videos' AND is_admin());

DROP POLICY IF EXISTS "module_videos_delete" ON storage.objects;
CREATE POLICY "module_videos_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'module-videos' AND is_admin());
