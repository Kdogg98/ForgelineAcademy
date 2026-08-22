/*
# Create profiles table for premium tier tracking

## Overview
Adds a `profiles` table that stores whether a user has premium access. One row per
authenticated user, keyed by the auth.users id. The auth.tsx context reads and writes
this table to gate I&E and Engineering content.

## Tables
- `profiles`
  - `id` uuid PK, references auth.users(id) ON DELETE CASCADE
  - `is_premium` boolean NOT NULL DEFAULT false
  - `created_at` timestamptz

## Security
- RLS enabled. Owner-scoped CRUD: a user can read and update only their own profile row.
- `id` defaults to `auth.uid()` so client upserts that omit the id still satisfy the
  WITH CHECK ownership predicate.
*/

CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  is_premium boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_profile" ON profiles;
CREATE POLICY "select_own_profile" ON profiles FOR SELECT
  TO authenticated USING (auth.uid() = id);

DROP POLICY IF EXISTS "insert_own_profile" ON profiles;
CREATE POLICY "insert_own_profile" ON profiles FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "update_own_profile" ON profiles;
CREATE POLICY "update_own_profile" ON profiles FOR UPDATE
  TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "delete_own_profile" ON profiles;
CREATE POLICY "delete_own_profile" ON profiles FOR DELETE
  TO authenticated USING (auth.uid() = id);
