/*
# Multi-Company / Team Branding Support

## Purpose
Adds multi-tenant company support so a company can buy access for employees
and brand the ForgeLine experience with their company logo.

## New Tables
### companies — id, name, logo_url, premium, active, created_by, created_at
### company_members — id, company_id, user_id, role (owner/admin/member), created_at; unique (company_id, user_id)

## Modified Tables
### profiles — added company_id (nullable uuid FK -> companies.id ON DELETE SET NULL)

## Security
- companies: members can SELECT; super-admin can INSERT/UPDATE/DELETE
- company_members: members can SELECT their company's members; super-admin can direct-mutate
- All owner/admin mutations go through SECURITY DEFINER RPC functions
- Storage bucket "company-logos" (public read, company admin write)

## Notes
1. companies.premium = true => all members treated as premium (runtime check, does not change profiles.is_premium)
2. Platform super-admin = profiles.is_admin (existing)
*/

-- ============================================================
-- 1. companies table
-- ============================================================
CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  logo_url text,
  premium boolean NOT NULL DEFAULT false,
  active boolean NOT NULL DEFAULT true,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2. company_members table (must exist before policies that reference it)
-- ============================================================
CREATE TABLE IF NOT EXISTS company_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
  created_at timestamptz DEFAULT now(),
  UNIQUE (company_id, user_id)
);

ALTER TABLE company_members ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 3. profiles: add company_id column
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'company_id'
  ) THEN
    ALTER TABLE profiles ADD COLUMN company_id uuid REFERENCES companies(id) ON DELETE SET NULL;
  END IF;
END $$;

-- ============================================================
-- 4. RLS Policies — companies
-- ============================================================
DROP POLICY IF EXISTS "members_can_read_companies" ON companies;
CREATE POLICY "members_can_read_companies"
ON companies FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM company_members cm
    WHERE cm.company_id = companies.id AND cm.user_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true
  )
);

DROP POLICY IF EXISTS "admin_can_insert_companies" ON companies;
CREATE POLICY "admin_can_insert_companies"
ON companies FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
);

DROP POLICY IF EXISTS "admin_can_update_companies" ON companies;
CREATE POLICY "admin_can_update_companies"
ON companies FOR UPDATE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
);

DROP POLICY IF EXISTS "admin_can_delete_companies" ON companies;
CREATE POLICY "admin_can_delete_companies"
ON companies FOR DELETE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
);

-- ============================================================
-- 5. RLS Policies — company_members
-- ============================================================
DROP POLICY IF EXISTS "members_can_read_company_members" ON company_members;
CREATE POLICY "members_can_read_company_members"
ON company_members FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM company_members cm2
    WHERE cm2.company_id = company_members.company_id AND cm2.user_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true
  )
);

DROP POLICY IF EXISTS "admin_can_insert_company_members" ON company_members;
CREATE POLICY "admin_can_insert_company_members"
ON company_members FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
);

DROP POLICY IF EXISTS "admin_can_update_company_members" ON company_members;
CREATE POLICY "admin_can_update_company_members"
ON company_members FOR UPDATE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
);

DROP POLICY IF EXISTS "admin_can_delete_company_members" ON company_members;
CREATE POLICY "admin_can_delete_company_members"
ON company_members FOR DELETE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
);

-- ============================================================
-- 6. Storage bucket for company logos
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('company-logos', 'company-logos', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "company_logos_public_read" ON storage.objects;
CREATE POLICY "company_logos_public_read"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'company-logos');

DROP POLICY IF EXISTS "company_logos_admin_upload" ON storage.objects;
CREATE POLICY "company_logos_admin_upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'company-logos'
  AND (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
    OR EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin')
        AND (storage.foldername(name))[1] = cm.company_id::text
    )
  )
);

DROP POLICY IF EXISTS "company_logos_admin_update" ON storage.objects;
CREATE POLICY "company_logos_admin_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'company-logos'
  AND (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
    OR EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin')
        AND (storage.foldername(name))[1] = cm.company_id::text
    )
  )
)
WITH CHECK (
  bucket_id = 'company-logos'
  AND (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
    OR EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin')
        AND (storage.foldername(name))[1] = cm.company_id::text
    )
  )
);

DROP POLICY IF EXISTS "company_logos_admin_delete" ON storage.objects;
CREATE POLICY "company_logos_admin_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'company-logos'
  AND (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true)
    OR EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin')
        AND (storage.foldername(name))[1] = cm.company_id::text
    )
  )
);

-- ============================================================
-- 7. SECURITY DEFINER functions for company management
-- ============================================================

CREATE OR REPLACE FUNCTION is_company_admin(check_company_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM company_members
    WHERE company_id = check_company_id
      AND user_id = auth.uid()
      AND role IN ('owner', 'admin')
  ) OR EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true
  );
$$;

CREATE OR REPLACE FUNCTION update_company_logo(
  target_company_id uuid,
  new_logo_url text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_company_admin(target_company_id) THEN
    RAISE EXCEPTION 'Not authorized to manage this company';
  END IF;
  UPDATE companies SET logo_url = new_logo_url WHERE id = target_company_id;
END;
$$;

CREATE OR REPLACE FUNCTION update_company_name(
  target_company_id uuid,
  new_name text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_company_admin(target_company_id) THEN
    RAISE EXCEPTION 'Not authorized to manage this company';
  END IF;
  UPDATE companies SET name = new_name WHERE id = target_company_id;
END;
$$;

CREATE OR REPLACE FUNCTION add_company_member_by_email(
  target_company_id uuid,
  member_email text,
  member_role text DEFAULT 'member'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  target_user record;
  existing_member record;
BEGIN
  IF NOT is_company_admin(target_company_id) THEN
    RAISE EXCEPTION 'Not authorized to manage this company';
  END IF;

  IF member_role NOT IN ('owner', 'admin', 'member') THEN
    RAISE EXCEPTION 'Invalid role';
  END IF;

  SELECT id INTO target_user FROM auth.users WHERE email = member_email;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'No user found with that email. Ask them to create an account first.');
  END IF;

  SELECT * INTO existing_member FROM company_members
  WHERE company_id = target_company_id AND user_id = target_user.id;
  IF FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'User is already a member of this company.');
  END IF;

  INSERT INTO company_members (company_id, user_id, role)
  VALUES (target_company_id, target_user.id, member_role);

  UPDATE profiles SET company_id = target_company_id WHERE id = target_user.id;

  RETURN jsonb_build_object('success', true, 'user_id', target_user.id);
END;
$$;

CREATE OR REPLACE FUNCTION remove_company_member(
  target_company_id uuid,
  target_user_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  is_target_owner boolean;
  owner_count int;
BEGIN
  IF NOT is_company_admin(target_company_id) THEN
    RAISE EXCEPTION 'Not authorized to manage this company';
  END IF;

  SELECT (role = 'owner') INTO is_target_owner
  FROM company_members WHERE company_id = target_company_id AND user_id = target_user_id;

  IF is_target_owner THEN
    SELECT count(*) INTO owner_count
    FROM company_members WHERE company_id = target_company_id AND role = 'owner';

    IF owner_count <= 1 THEN
      RAISE EXCEPTION 'Cannot remove the last owner of the company';
    END IF;
  END IF;

  DELETE FROM company_members WHERE company_id = target_company_id AND user_id = target_user_id;
  UPDATE profiles SET company_id = NULL WHERE id = target_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION update_company_member_role(
  target_company_id uuid,
  target_user_id uuid,
  new_role text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_company_admin(target_company_id) THEN
    RAISE EXCEPTION 'Not authorized to manage this company';
  END IF;

  IF new_role NOT IN ('owner', 'admin', 'member') THEN
    RAISE EXCEPTION 'Invalid role';
  END IF;

  UPDATE company_members SET role = new_role
  WHERE company_id = target_company_id AND user_id = target_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION create_company_with_owner(
  company_name text,
  owner_email text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  new_company_id uuid;
  owner_user record;
  is_admin boolean;
BEGIN
  SELECT is_admin INTO is_admin FROM profiles WHERE id = auth.uid();
  IF NOT COALESCE(is_admin, false) THEN
    RAISE EXCEPTION 'Only platform admins can create companies';
  END IF;

  INSERT INTO companies (name, created_by)
  VALUES (company_name, auth.uid())
  RETURNING id INTO new_company_id;

  IF owner_email IS NOT NULL AND owner_email <> '' THEN
    SELECT id INTO owner_user FROM auth.users WHERE email = owner_email;
    IF FOUND THEN
      INSERT INTO company_members (company_id, user_id, role)
      VALUES (new_company_id, owner_user.id, 'owner');
      UPDATE profiles SET company_id = new_company_id WHERE id = owner_user.id;
    END IF;
  END IF;

  RETURN jsonb_build_object('success', true, 'company_id', new_company_id);
END;
$$;

GRANT EXECUTE ON FUNCTION is_company_admin(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION update_company_logo(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION update_company_name(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION add_company_member_by_email(uuid, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION remove_company_member(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION update_company_member_role(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION create_company_with_owner(text, text) TO authenticated;
