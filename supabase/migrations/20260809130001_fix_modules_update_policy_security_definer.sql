/*
# Fix modules UPDATE policy using a SECURITY DEFINER function

The previous policy used a subquery on profiles, but profiles has RLS enabled
which can block the subquery. Using a SECURITY DEFINER function bypasses RLS
on profiles and reliably checks admin status.
*/

-- Create a SECURITY DEFINER function that checks if the current user is an admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  );
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;

-- Replace the modules UPDATE policy to use the function
DROP POLICY IF EXISTS "admin_update_modules" ON modules;
CREATE POLICY "admin_update_modules"
ON modules FOR UPDATE
TO authenticated
USING (is_admin()) WITH CHECK (is_admin());
