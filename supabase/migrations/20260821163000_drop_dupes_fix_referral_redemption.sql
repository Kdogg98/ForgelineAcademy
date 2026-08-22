/*
# Drop leftover duplicate tables, admin read of referral codes,
# fix record_referral_redemption increment on insert.

Do not apply from this file automatically; it is the next local migration.
*/

DROP TABLE IF EXISTS public.lessons02;
DROP TABLE IF EXISTS public.modules_duplicate;

CREATE POLICY admin_read_referral_codes ON referral_codes
  FOR SELECT
  TO authenticated
  USING ((SELECT is_admin FROM profiles WHERE id = auth.uid()));

CREATE OR REPLACE FUNCTION record_referral_redemption(
  p_referrer_id uuid,
  p_referred_id uuid,
  p_code text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO referral_redemptions (referrer_id, referred_id, code)
  VALUES (p_referrer_id, p_referred_id, p_code)
  ON CONFLICT (referred_id) DO NOTHING;

  IF FOUND THEN
    UPDATE referral_codes
    SET referrals_count = referrals_count + 1
    WHERE user_id = p_referrer_id;
  END IF;
END;
$$;
