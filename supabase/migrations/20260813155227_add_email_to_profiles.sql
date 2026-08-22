/*
# Add email to profiles + admin user list function

## Overview
Adds an `email` column to the profiles table and a SECURITY DEFINER function
that returns all users with their emails. This is needed by the admin custom
course builder to populate the "assign to user" dropdown.

## Changes
1. `profiles` table — new column `email` text, nullable
2. New function `list_users_for_admin()` — SECURITY DEFINER, returns all
   profiles with id, email, is_premium. Only callable by admins (self-checks).
3. Backfill: copies emails from auth.users into profiles.email

## Security
- The function is SECURITY DEFINER with search_path = 'public'
- It self-checks that the caller is an admin before returning any data
- EXECUTE granted to authenticated
*/

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS email text;

-- Backfill emails from auth.users
UPDATE profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id AND p.email IS NULL;

CREATE OR REPLACE FUNCTION list_users_for_admin()
RETURNS TABLE (id uuid, email text, is_premium boolean)
LANGUAGE sql
SECURITY DEFINER
SET search_path = 'public'
AS $$
  SELECT p.id, p.email, p.is_premium
  FROM profiles p
  WHERE (SELECT is_admin FROM profiles WHERE id = auth.uid()) = true
  ORDER BY p.email;
$$;

GRANT EXECUTE ON FUNCTION list_users_for_admin() TO authenticated;
