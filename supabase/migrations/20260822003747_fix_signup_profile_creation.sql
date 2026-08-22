-- Fix 1: mint_referral_code_for_profile can't find gen_random_bytes because
-- its search_path is 'public' but the function lives in the 'extensions' schema.
-- Recreate with schema-qualified call so new signups don't fail.
CREATE OR REPLACE FUNCTION mint_referral_code_for_profile()
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
    new_code := upper(substr(encode(extensions.gen_random_bytes(6), 'base64'), 1, 8));
    new_code := replace(replace(new_code, '/', 'X'), '+', 'Y');
    EXIT WHEN NOT EXISTS (SELECT 1 FROM referral_codes WHERE code = new_code);
  END LOOP;
  INSERT INTO referral_codes (user_id, code) VALUES (NEW.id, new_code);
  RETURN NEW;
END;
$$;

-- Fix 2: get_or_create_referral_code has the same gen_random_bytes issue.
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
  SELECT code INTO existing_code FROM referral_codes WHERE user_id = p_user_id;
  IF existing_code IS NOT NULL THEN
    RETURN existing_code;
  END IF;

  LOOP
    new_code := upper(substr(encode(extensions.gen_random_bytes(6), 'base64'), 1, 8));
    new_code := replace(new_code, '/', 'X');
    new_code := replace(new_code, '+', 'Y');
    EXIT WHEN NOT EXISTS (SELECT 1 FROM referral_codes WHERE code = new_code);
  END LOOP;

  INSERT INTO referral_codes (user_id, code) VALUES (p_user_id, new_code);
  RETURN new_code;
END;
$$;

GRANT EXECUTE ON FUNCTION get_or_create_referral_code(uuid) TO authenticated;

-- Fix 3: Auto-create a profiles row whenever a new auth.users row is inserted,
-- so signup doesn't depend on a client-side upsert that can fail silently
-- when the session isn't established yet.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, is_premium, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    false,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NULL)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Fix 4: Backfill profiles for existing auth.users who are missing one.
INSERT INTO public.profiles (id, email, is_premium, full_name)
SELECT u.id, u.email, false, COALESCE(u.raw_user_meta_data->>'full_name', NULL)
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = u.id)
ON CONFLICT (id) DO NOTHING;
