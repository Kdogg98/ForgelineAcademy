-- =============================================================================
-- Company manager roster: seat limit + safe add/remove RPCs for managers.
--
-- NOT APPLIED AUTOMATICALLY. Review, then apply before merging the
-- company-manager dashboard PR. Additive only: no existing function, policy or
-- row is changed. Old admin RPCs (add_company_member_by_email,
-- remove_company_member) stay as they are for the super-admin /company page.
--
-- 1. companies.seat_limit (nullable int). NULL = no limit recorded; the UI
--    then shows usage without a cap. Only master admins can set it (the existing
--    admin_can_update_companies policy is the only UPDATE path on companies).
-- 2. manager_add_company_member(company, email): an owner/admin of THAT company
--    adds an EXISTING account as a plain 'member'. Enforces seat_limit under a
--    row lock on the company. Does not touch a user who already belongs to
--    another company.
-- 3. manager_remove_company_member(company, user): an owner/admin of THAT
--    company removes a member. Cannot remove yourself or any owner.
-- Both are SECURITY DEFINER, pinned search_path, and gate on the caller's own
-- company_members row plus is_company_manager_of(target) for removal.
-- =============================================================================

alter table public.companies add column if not exists seat_limit integer
  check (seat_limit is null or seat_limit >= 0);
comment on column public.companies.seat_limit is
  'Max company_members rows (all roles). NULL = unlimited / not recorded. Set by master admins only.';

-- caller is owner/admin of the given company (company-scoped manager check)
create or replace function public.is_manager_of_company(p_company_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select auth.uid() is not null and exists (
    select 1 from public.company_members
     where company_id = p_company_id and user_id = auth.uid() and role in ('owner','admin'));
$$;
revoke all on function public.is_manager_of_company(uuid) from public, anon;
grant execute on function public.is_manager_of_company(uuid) to authenticated;

create or replace function public.manager_add_company_member(p_company_id uuid, p_email text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_company record;
  v_uid uuid;
  v_used int;
begin
  if auth.uid() is null or not public.is_manager_of_company(p_company_id) then
    raise exception 'Not authorized to manage this company' using errcode = '42501';
  end if;

  -- lock the company row so concurrent adds cannot exceed the seat limit
  select id, active, seat_limit into v_company from public.companies where id = p_company_id for update;
  if not found then raise exception 'Company not found'; end if;
  if not v_company.active then
    return jsonb_build_object('success', false, 'error', 'This company is not active.');
  end if;

  select id into v_uid from auth.users where lower(email) = lower(trim(p_email)) limit 1;
  if v_uid is null then
    return jsonb_build_object('success', false, 'error', 'No account found with that email. Ask them to sign up first, then add them.');
  end if;

  if exists (select 1 from public.company_members where company_id = p_company_id and user_id = v_uid) then
    return jsonb_build_object('success', false, 'error', 'That person is already on your team.');
  end if;
  if exists (select 1 from public.company_members where user_id = v_uid) then
    return jsonb_build_object('success', false, 'error', 'That account already belongs to another company.');
  end if;

  select count(*) into v_used from public.company_members where company_id = p_company_id;
  if v_company.seat_limit is not null and v_used >= v_company.seat_limit then
    return jsonb_build_object('success', false, 'error', format('All %s seats are in use. Remove someone or contact ForgeLine to add seats.', v_company.seat_limit));
  end if;

  insert into public.company_members (company_id, user_id, role) values (p_company_id, v_uid, 'member');
  -- keep the denormalized pointer in sync (the profile guard trigger only blocks self-edits)
  update public.profiles set company_id = p_company_id where id = v_uid;

  return jsonb_build_object('success', true, 'user_id', v_uid);
end;
$$;
revoke all on function public.manager_add_company_member(uuid, text) from public, anon;
grant execute on function public.manager_add_company_member(uuid, text) to authenticated;

create or replace function public.manager_remove_company_member(p_company_id uuid, p_user_id uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_role text;
begin
  if auth.uid() is null or not public.is_manager_of_company(p_company_id)
     or not public.is_company_manager_of(p_user_id) then
    raise exception 'Not authorized to manage this company' using errcode = '42501';
  end if;
  if p_user_id = auth.uid() then
    raise exception 'You cannot remove yourself' using errcode = '42501';
  end if;

  select role into v_role from public.company_members
   where company_id = p_company_id and user_id = p_user_id for update;
  if v_role is null then
    raise exception 'That person is not on this company' using errcode = '42501';
  end if;
  if v_role = 'owner' then
    raise exception 'The company owner cannot be removed' using errcode = '42501';
  end if;

  delete from public.company_members where company_id = p_company_id and user_id = p_user_id;
  update public.profiles set company_id = null where id = p_user_id and company_id = p_company_id;
  return jsonb_build_object('success', true);
end;
$$;
revoke all on function public.manager_remove_company_member(uuid, uuid) from public, anon;
grant execute on function public.manager_remove_company_member(uuid, uuid) to authenticated;

-- -----------------------------------------------------------------------------
-- 4. seat_limit is master-admin only. RLS already restricts direct UPDATEs on
--    companies to master admins (admin_can_update_companies); this trigger is
--    defense in depth so no future policy or invoker-rights path lets an owner
--    or manager raise their own cap. Same pattern as
--    protect_profile_privileged_columns: SECURITY INVOKER so current_user is the
--    real API role; SECURITY DEFINER RPCs and service_role are unaffected.
-- -----------------------------------------------------------------------------
create or replace function public.protect_company_seat_limit()
returns trigger language plpgsql set search_path = public as $$
begin
  if current_user in ('authenticated', 'anon') and not public.is_admin() then
    if tg_op = 'INSERT' then
      new.seat_limit := null;
    else
      new.seat_limit := old.seat_limit;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists companies_protect_seat_limit on public.companies;
create trigger companies_protect_seat_limit
  before insert or update on public.companies
  for each row execute function public.protect_company_seat_limit();
