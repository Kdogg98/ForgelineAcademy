/*
# Add admin role to profiles

## Overview
Adds an `is_admin` boolean column to the `profiles` table. Admin users automatically
get premium access to all content. The first user to sign up is auto-promoted to
admin via a SECURITY DEFINER function (the client cannot count profiles through RLS,
so the check must run with elevated privileges).

## Changes
1. `profiles` table — new column `is_admin` boolean NOT NULL DEFAULT false.
2. New function `claim_admin_if_first()` — SECURITY DEFINER, runs as the server.
   Checks if any other profile already has `is_admin = true`. If none do, promotes
   the calling user to admin + premium. Safe to call on every signup.
3. RLS: existing owner-scoped policies already cover the new column (SELECT/UPDATE
   on own row). No policy changes needed.

## Notes
1. The function is `SECURITY DEFINER` so it can read ALL profiles (bypassing RLS)
   to determine if an admin already exists. It only writes to the calling user's own
   row, scoped by `auth.uid()`.
2. `search_path` is set to `'public'` to prevent path-injection attacks.
3. EXECUTE is granted to `authenticated` so any signed-in user can call it during
   signup — it is a no-op if an admin already exists.
*/

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_admin boolean NOT NULL DEFAULT false;

CREATE OR REPLACE FUNCTION claim_admin_if_first()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  admin_exists boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM profiles WHERE is_admin = true
  ) INTO admin_exists;

  IF admin_exists THEN
    RETURN false;
  END IF;

  UPDATE profiles
  SET is_admin = true, is_premium = true
  WHERE id = auth.uid();

  RETURN FOUND;
END;
$$;

GRANT EXECUTE ON FUNCTION claim_admin_if_first() TO authenticated;
