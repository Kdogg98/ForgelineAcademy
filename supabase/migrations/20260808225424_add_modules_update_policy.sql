/*
# Add UPDATE policy for modules table (admin-only)

1. Security Changes
- Add an UPDATE policy on the `modules` table so authenticated admin users can update module records (specifically the video_url, video_filename, video_uploaded_at columns).
- Without this policy, RLS blocks all UPDATEs to the modules table — the admin video manager cannot save embedded URLs or uploaded video paths.
- Only users with is_admin=true in their profile can update modules.
*/

DROP POLICY IF EXISTS "admin_update_modules" ON modules;
CREATE POLICY "admin_update_modules"
ON modules FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
) WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
);
