/*
# ForgeLine Academy — core schema

## Overview
Creates the data model for an industrial maintenance training platform.
Courses are organized into a 4-stage career ladder (Mechanical → Electrical → I&E → Engineering).
Each course has lessons grouped into modules. Authenticated users track per-lesson
progress and earn certificates on course completion.

## Tables

1. `courses` — top-level training units
   - `id` uuid PK
   - `title` text not null
   - `description` text not null
   - `stage` text not null — one of 'mechanical' | 'electrical' | 'ie' | 'engineering'
   - `tier` text not null — 'free' | 'premium'
   - `difficulty` text not null — 'beginner' | 'intermediate' | 'advanced'
   - `estimated_hours` numeric not null
   - `short_description` text — used on cards
   - `sort_order` int — ordering within a stage
   - `created_at` timestamptz
   - `updated_at` timestamptz

2. `modules` — groups of lessons inside a course
   - `id` uuid PK
   - `course_id` uuid FK → courses(id) ON DELETE CASCADE
   - `title` text not null
   - `sort_order` int not null

3. `lessons` — individual units of content inside a module
   - `id` uuid PK
   - `module_id` uuid FK → modules(id) ON DELETE CASCADE
   - `title` text not null
   - `content` text — rich text/markdown body
   - `estimated_minutes` int not null default 30
   - `has_video` boolean default true
   - `has_pdf` boolean default true
   - `quiz` jsonb — array of {question, options[], correctIndex}
   - `pass_threshold` int default 80
   - `sort_order` int not null

4. `user_progress` — per-user per-lesson completion state
   - `id` uuid PK
   - `user_id` uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE
   - `lesson_id` uuid FK → lessons(id) ON DELETE CASCADE
   - `course_id` uuid FK → courses(id) ON DELETE CASCADE
   - `quiz_score` int — last quiz score %
   - `completed` boolean default false
   - `completed_at` timestamptz
   - `created_at` timestamptz
   - UNIQUE(user_id, lesson_id)

5. `certificates` — issued when a user completes all lessons in a course
   - `id` uuid PK
   - `user_id` uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE
   - `course_id` uuid FK → courses(id) ON DELETE CASCADE
   - `certificate_number` text not null
   - `issued_at` timestamptz default now()
   - UNIQUE(user_id, course_id)

## Security (RLS)
- `courses`, `modules`, `lessons` are read-only catalog data. SELECT is public
  (anon + authenticated) so the catalog renders without sign-in. No INSERT/UPDATE/DELETE
  policies — catalog is managed server-side only.
- `user_progress` is owner-scoped: each authenticated user can only see and modify
  their own rows. `user_id` defaults to `auth.uid()` so inserts from the client succeed.
- `certificates` is owner-scoped: authenticated users read/insert only their own.
  Certificate numbers are generated server-side via a default expression.

## Notes
1. Catalog tables (courses/modules/lessons) have NO write policies — they are
   intentionally read-only from the anon-key frontend. Manage via SQL/seed only.
2. `user_progress.user_id` and `certificates.user_id` use `DEFAULT auth.uid()` so
   client inserts that omit the column still satisfy the WITH CHECK ownership predicate.
3. Certificate numbers use a gen_random_uuid-based prefix for uniqueness.
*/

-- ---------- courses ----------
CREATE TABLE IF NOT EXISTS courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  short_description text NOT NULL,
  stage text NOT NULL CHECK (stage IN ('mechanical','electrical','ie','engineering')),
  tier text NOT NULL CHECK (tier IN ('free','premium')),
  difficulty text NOT NULL CHECK (difficulty IN ('beginner','intermediate','advanced')),
  estimated_hours numeric NOT NULL DEFAULT 2,
  sort_order int NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "catalog_courses_read" ON courses;
CREATE POLICY "catalog_courses_read" ON courses FOR SELECT
  TO anon, authenticated USING (true);

-- ---------- modules ----------
CREATE TABLE IF NOT EXISTS modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title text NOT NULL,
  sort_order int NOT NULL DEFAULT 0
);
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "catalog_modules_read" ON modules;
CREATE POLICY "catalog_modules_read" ON modules FOR SELECT
  TO anon, authenticated USING (true);

-- ---------- lessons ----------
CREATE TABLE IF NOT EXISTS lessons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  title text NOT NULL,
  content text,
  estimated_minutes int NOT NULL DEFAULT 30,
  has_video boolean NOT NULL DEFAULT true,
  has_pdf boolean NOT NULL DEFAULT true,
  quiz jsonb NOT NULL DEFAULT '[]'::jsonb,
  pass_threshold int NOT NULL DEFAULT 80,
  sort_order int NOT NULL DEFAULT 0
);
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "catalog_lessons_read" ON lessons;
CREATE POLICY "catalog_lessons_read" ON lessons FOR SELECT
  TO anon, authenticated USING (true);

-- ---------- user_progress ----------
CREATE TABLE IF NOT EXISTS user_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  quiz_score int,
  completed boolean NOT NULL DEFAULT false,
  completed_at timestamptz,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, lesson_id)
);
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_progress" ON user_progress;
CREATE POLICY "select_own_progress" ON user_progress FOR SELECT
  TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "insert_own_progress" ON user_progress;
CREATE POLICY "insert_own_progress" ON user_progress FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "update_own_progress" ON user_progress;
CREATE POLICY "update_own_progress" ON user_progress FOR UPDATE
  TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "delete_own_progress" ON user_progress;
CREATE POLICY "delete_own_progress" ON user_progress FOR DELETE
  TO authenticated USING (auth.uid() = user_id);

-- ---------- certificates ----------
CREATE TABLE IF NOT EXISTS certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  certificate_number text NOT NULL DEFAULT ('FL-' || upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 6))),
  issued_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, course_id)
);
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_certificates" ON certificates;
CREATE POLICY "select_own_certificates" ON certificates FOR SELECT
  TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "insert_own_certificates" ON certificates;
CREATE POLICY "insert_own_certificates" ON certificates FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "delete_own_certificates" ON certificates;
CREATE POLICY "delete_own_certificates" ON certificates FOR DELETE
  TO authenticated USING (auth.uid() = user_id);
