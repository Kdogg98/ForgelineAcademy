/*
# Fix: Company RLS recursion + ambiguous is_admin

## Problems
1. `company_members` SELECT policy self-references `company_members` in a
   subquery, causing infinite recursion during policy evaluation.
2. `create_company_with_owner` function has ambiguous `is_admin` column
   reference (could be profiles column or PL/pgSQL variable).

## Fixes
1. Replace the self-referencing `company_members` SELECT policy with one
   that checks `profiles.company_id` instead — the user's profile already
   stores their company_id, so we can check membership without querying
   the same table the policy is on.
2. Qualify the `is_admin` column reference as `profiles.is_admin` in the
   `create_company_with_owner` function.
*/

-- ============================================================
-- 1. Fix company_members SELECT policy (infinite recursion)
-- ============================================================
ALTER TABLE company_members DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "members_can_read_company_members" ON company_members;
CREATE POLICY "members_can_read_company_members"
ON company_members FOR SELECT
TO authenticated
USING (
  -- Check via profiles.company_id instead of self-referencing company_members
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
      AND profiles.company_id = company_members.company_id
  )
  OR EXISTS (
    SELECT 1 FROM profiles p2
    WHERE p2.id = auth.uid() AND p2.is_admin = true
  )
);

ALTER TABLE company_members ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2. Fix ambiguous is_admin in create_company_with_owner
-- ============================================================
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
  admin_check boolean;
BEGIN
  SELECT is_admin INTO admin_check FROM profiles WHERE id = auth.uid();
  IF NOT COALESCE(admin_check, false) THEN
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

-- ============================================================
-- 3. Also fix is_company_admin to avoid potential ambiguity
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
    WHERE company_members.company_id = is_company_admin.check_company_id
      AND company_members.user_id = auth.uid()
      AND company_members.role IN ('owner', 'admin')
  ) OR EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  );
$$;
