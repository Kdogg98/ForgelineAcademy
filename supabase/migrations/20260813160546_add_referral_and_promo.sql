-- ============ REFERRAL PROGRAM + PROMO CODES ============

-- referral_codes: each user gets a unique referral code
CREATE TABLE IF NOT EXISTS referral_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  code text NOT NULL UNIQUE,
  referrals_count integer NOT NULL DEFAULT 0,
  free_months_earned integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE referral_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "read_own_referral_code" ON referral_codes FOR SELECT
  TO authenticated USING (auth.uid() = user_id);

-- referral_redemptions: tracks each referral use
CREATE TABLE IF NOT EXISTS referral_redemptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  referred_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  code text NOT NULL,
  rewarded boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (referred_id)
);

ALTER TABLE referral_redemptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "read_own_referrals" ON referral_redemptions FOR SELECT
  TO authenticated USING (auth.uid() = referrer_id OR auth.uid() = referred_id);

-- promo_codes: admin-created codes mapping to Stripe coupons
CREATE TABLE IF NOT EXISTS promo_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  stripe_coupon_id text NOT NULL,
  description text,
  discount_percent integer,
  discount_amount_cents integer,
  max_redemptions integer,
  redemptions_count integer NOT NULL DEFAULT 0,
  active boolean NOT NULL DEFAULT true,
  expires_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES auth.users(id)
);

ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_read_promos" ON promo_codes FOR SELECT
  TO authenticated USING (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

CREATE POLICY "admin_insert_promos" ON promo_codes FOR INSERT
  TO authenticated WITH CHECK (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

CREATE POLICY "admin_update_promos" ON promo_codes FOR UPDATE
  TO authenticated USING (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  ) WITH CHECK (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

CREATE POLICY "admin_delete_promos" ON promo_codes FOR DELETE
  TO authenticated USING (
    (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

-- get_or_create_referral_code: ensures every user has a referral code
CREATE OR REPLACE FUNCTION get_or_create_referral_code(p_user_id uuid)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
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

-- validate_code: check a promo or referral code, return info
CREATE OR REPLACE FUNCTION validate_code(p_code text, p_user_id uuid)
RETURNS TABLE (
  code_type text,
  valid boolean,
  referrer_id uuid,
  stripe_coupon_id text,
  message text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  promo record;
  referral record;
BEGIN
  SELECT * INTO promo FROM promo_codes
    WHERE UPPER(code) = UPPER(p_code) AND active = true
    AND (expires_at IS NULL OR expires_at > now())
    AND (max_redemptions IS NULL OR redemptions_count < max_redemptions);

  IF FOUND THEN
    RETURN QUERY SELECT 'promo'::text, true, NULL::uuid, promo.stripe_coupon_id, 'Promo code applied'::text;
    RETURN;
  END IF;

  SELECT * INTO referral FROM referral_codes WHERE UPPER(code) = UPPER(p_code);

  IF FOUND THEN
    IF referral.user_id = p_user_id THEN
      RETURN QUERY SELECT 'referral'::text, false, NULL::uuid, NULL::text, 'You cannot use your own referral code'::text;
      RETURN;
    END IF;

    IF EXISTS (SELECT 1 FROM referral_redemptions WHERE referred_id = p_user_id) THEN
      RETURN QUERY SELECT 'referral'::text, false, NULL::uuid, NULL::text, 'You have already used a referral code'::text;
      RETURN;
    END IF;

    RETURN QUERY SELECT 'referral'::text, true, referral.user_id, NULL::text, 'Referral code applied — free month for both of you!'::text;
    RETURN;
  END IF;

  RETURN QUERY SELECT 'unknown'::text, false, NULL::uuid, NULL::text, 'Invalid code'::text;
END;
$$;

GRANT EXECUTE ON FUNCTION validate_code(text, uuid) TO authenticated;

-- record_referral_redemption: log a referral use and increment referrer count
CREATE OR REPLACE FUNCTION record_referral_redemption(
  p_referrer_id uuid,
  p_referred_id uuid,
  p_code text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  INSERT INTO referral_redemptions (referrer_id, referred_id, code)
  VALUES (p_referrer_id, p_referred_id, p_code)
  ON CONFLICT (referred_id) DO NOTHING;

  UPDATE referral_codes
  SET referrals_count = referrals_count + 1
  WHERE user_id = p_referrer_id
  AND NOT EXISTS (
    SELECT 1 FROM referral_redemptions
    WHERE referred_id = p_referred_id AND referrer_id = p_referrer_id
  );
END;
$$;

GRANT EXECUTE ON FUNCTION record_referral_redemption(uuid, uuid, text) TO authenticated;

-- increment_promo_redemption: bump redemption count
CREATE OR REPLACE FUNCTION increment_promo_redemption(p_code text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  UPDATE promo_codes
  SET redemptions_count = redemptions_count + 1
  WHERE UPPER(code) = UPPER(p_code);
END;
$$;

GRANT EXECUTE ON FUNCTION increment_promo_redemption(text) TO authenticated;
