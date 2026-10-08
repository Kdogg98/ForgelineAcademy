-- =============================================================================
-- ForgeLine Academy: SECURITY HARDENING (recommended, ships with company builder)
--
-- Finding (live DB, 2026-10-08): the policy "update_own_profile" lets a signed-in
-- user UPDATE any column of their own profiles row, and the authenticated role
-- has column UPDATE/INSERT privileges on is_admin, is_premium and company_id.
-- That means any user can self-grant master admin (is_admin), premium
-- (is_premium) or attach themselves to a company (company_id) straight from the
-- browser console. Every admin check (incl. the new company-builder edge
-- function and RPCs) trusts profiles.is_admin, so this must be closed.
--
-- Fix: a BEFORE INSERT/UPDATE trigger that, for end-user API roles
-- (authenticated / anon) who are not master admins, pins those three columns
-- to their previous values (or safe defaults on insert).
-- Unaffected: service_role (stripe-webhook, edge functions), and SECURITY
-- DEFINER RPCs such as add_company_member_by_email / claim_admin_if_first,
-- because inside those current_user is the function owner, not 'authenticated'.
--
-- The trigger function is deliberately SECURITY INVOKER so current_user is the
-- real caller role.
-- =============================================================================

create or replace function public.protect_profile_privileged_columns()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if current_user in ('authenticated', 'anon') and not public.is_admin() then
    if tg_op = 'INSERT' then
      new.is_admin   := false;
      new.is_premium := false;
      new.company_id := null;
    else
      new.is_admin   := old.is_admin;
      new.is_premium := old.is_premium;
      new.company_id := old.company_id;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_protect_privileged_columns on public.profiles;
create trigger profiles_protect_privileged_columns
  before insert or update on public.profiles
  for each row execute function public.protect_profile_privileged_columns();
