/*
# Harden RPC grants, auto-mint referral codes, FK indexes

Already applied live. This file documents that migration so the repo matches production.

## Applied live
1. REVOKE EXECUTE FROM PUBLIC/anon on public SECURITY DEFINER functions
   (default Postgres grants EXECUTE to PUBLIC; authenticated grants stay).
2. get_or_create_referral_code: caller must be p_user_id = auth.uid().
3. Mint referral codes for existing profiles that did not have one.
4. Trigger profiles_mint_referral_code AFTER INSERT ON profiles.
5. FK indexes on lessons, modules, user_progress, certificates,
   lesson_engagement, quiz_attempts.
*/

-- 1. Revoke anon/PUBLIC execute on security definer functions in public
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT n.nspname AS schema_name,
           p.proname AS func_name,
           pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prosecdef
  LOOP
    EXECUTE format(
      'REVOKE EXECUTE ON FUNCTION %I.%I(%s) FROM PUBLIC, anon',
      r.schema_name, r.func_name, r.args
    );
  END LOOP;
END $$;

-- 2. Restrict get_or_create_referral_code to the calling user
CREATE OR REPLACE FUNCTION get_or_create_referral_code(p_user_id uuid)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  existing_code text;
  new_code text;
BEGIN
  IF p_user_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'not authorized';
  END IF;

  SELECT code INTO existing_code FROM referral_codes WHERE user_id = p_user_id;
  IF existing_code IS NOT NULL THEN
    RETURN existing_code;
  END IF;

  LOOP
    new_code := upper(substr(encode(gen_random_bytes(6), 'base64'), 1, 8));
    new_code := replace(new_code, '/', 'X');
    new_code := replace(new_code, '+', 'Y');
    EXIT WHEN NOT EXISTS (SELECT 1 FROM referral_codes WHERE code = new_code);
  END LOOP;

  INSERT INTO referral_codes (user_id, code) VALUES (p_user_id, new_code);
  RETURN new_code;
END;
$$;

GRANT EXECUTE ON FUNCTION get_or_create_referral_code(uuid) TO authenticated;
REVOKE EXECUTE ON FUNCTION get_or_create_referral_code(uuid) FROM PUBLIC, anon;

-- 3. Mint codes for existing profiles that do not have one
DO $$
DECLARE
  r record;
  new_code text;
BEGIN
  FOR r IN
    SELECT p.id
    FROM profiles p
    WHERE NOT EXISTS (
      SELECT 1 FROM referral_codes rc WHERE rc.user_id = p.id
    )
  LOOP
    LOOP
      new_code := upper(substr(encode(gen_random_bytes(6), 'base64'), 1, 8));
      new_code := replace(new_code, '/', 'X');
      new_code := replace(new_code, '+', 'Y');
      EXIT WHEN NOT EXISTS (SELECT 1 FROM referral_codes WHERE code = new_code);
    END LOOP;
    INSERT INTO referral_codes (user_id, code) VALUES (r.id, new_code);
  END LOOP;
END $$;

-- 4. Auto-mint a referral code when a profile is created
CREATE OR REPLACE FUNCTION trg_profiles_mint_referral_code()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  new_code text;
BEGIN
  IF EXISTS (SELECT 1 FROM referral_codes WHERE user_id = NEW.id) THEN
    RETURN NEW;
  END IF;

  LOOP
    new_code := upper(substr(encode(gen_random_bytes(6), 'base64'), 1, 8));
    new_code := replace(new_code, '/', 'X');
    new_code := replace(new_code, '+', 'Y');
    EXIT WHEN NOT EXISTS (SELECT 1 FROM referral_codes WHERE code = new_code);
  END LOOP;

  INSERT INTO referral_codes (user_id, code) VALUES (NEW.id, new_code);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_mint_referral_code ON profiles;
CREATE TRIGGER profiles_mint_referral_code
  AFTER INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION trg_profiles_mint_referral_code();

-- 5. FK indexes (IF NOT EXISTS so re-documenting is a no-op)
CREATE INDEX IF NOT EXISTS idx_lessons_module_id ON lessons(module_id);
CREATE INDEX IF NOT EXISTS idx_modules_course_id ON modules(course_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_lesson_id ON user_progress(lesson_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_course_id ON user_progress(course_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_certificates_course_id ON certificates(course_id);
CREATE INDEX IF NOT EXISTS idx_certificates_user_id ON certificates(user_id);
CREATE INDEX IF NOT EXISTS idx_lesson_engagement_lesson_id ON lesson_engagement(lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_engagement_user_id ON lesson_engagement(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_lesson_id ON quiz_attempts(lesson_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_course_id ON quiz_attempts(course_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user_id ON quiz_attempts(user_id);
