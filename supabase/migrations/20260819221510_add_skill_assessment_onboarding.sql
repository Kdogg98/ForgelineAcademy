/*
# Skill Assessment Onboarding

## Purpose
When a new user logs in for the first time, they must complete a skill assessment
before they can access the rest of the app. The AI Tutor asks a series of questions
to determine their skill level across mechanical, electrical, I&E, and engineering
disciplines. The assessment result is stored on their profile and used to recommend
courses at the right difficulty.

## Changes to `profiles` table
- `assessment_completed` (boolean, default false) — whether the user has completed the skill assessment
- `assessment_level` (text, nullable) — the determined skill level: 'novice', 'intermediate', 'advanced', or 'expert'
- `assessment_summary` (text, nullable) — AI-generated summary of the user's strengths and gaps
- `assessment_responses` (jsonb, nullable) — the full Q&A transcript from the assessment
- `assessed_at` (timestamptz, nullable) — when the assessment was completed

## Security
- No new tables. The profiles table already has RLS enabled with owner-scoped policies.
- The new columns are writable by the owner via the existing UPDATE policy.
*/

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS assessment_completed boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS assessment_level text,
  ADD COLUMN IF NOT EXISTS assessment_summary text,
  ADD COLUMN IF NOT EXISTS assessment_responses jsonb,
  ADD COLUMN IF NOT EXISTS assessed_at timestamptz;
