-- =============================================================================
-- Company manager: course assignments with due dates + email invites.
--
-- NOT APPLIED AUTOMATICALLY. Review, then apply (after 20261014120000) before
-- merging the manager-assignments-export-invites PR. The dashboard degrades
-- gracefully (hides assignments / invites) until this is applied.
--
-- 1. course_assignments: a manager assigns a course to an employee of THEIR
--    company with an optional due date. Managers of that company manage their
--    own company's rows; employees read their own rows only. "Done" is not
--    stored: the client derives it from existing completion data
--    (certificates row, or every lesson of the course completed in user_progress).
-- 2. manager_assign_course(company, course, user|null, due): assign to one
--    employee or (user = null) every current member. Upserts the due date.
-- 3. company_invites: pending email invites (token, expires in 14 days). Read by
--    that company's managers only; written only through the RPCs below.
-- 4. company_seats_used(company) = members + pending unexpired invites.
--    manager_add_company_member is redefined to count pending invites too.
-- 5. manager_create_invite / manager_revoke_invite (manager of that company).
-- 6. claim_my_company_invites(): the signed-in user joins the company that
--    invited their VERIFIED auth email (auth.users.email_confirmed_at not null).
--    The app calls it on sign-in; an AFTER INSERT trigger on profiles also runs
--    it for accounts whose email is already confirmed at profile creation.
-- 7. Removing someone from a company deletes their assignments for that company.
-- All SECURITY DEFINER functions pin search_path and check auth.uid().
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. course_assignments
-- ---------------------------------------------------------------------------
create table if not exists public.course_assignments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete cascade,
  due_date date,
  assigned_by uuid references auth.users(id) on delete set null default auth.uid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id, user_id, course_id)
);
create index if not exists course_assignments_user_idx on public.course_assignments (user_id);
create index if not exists course_assignments_company_idx on public.course_assignments (company_id);

alter table public.course_assignments enable row level security;
revoke all on public.course_assignments from anon;
grant select, insert, update, delete on public.course_assignments to authenticated;

-- assignee must be a member of the company the row belongs to
create or replace function public.is_member_of_company(p_company_id uuid, p_user_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.company_members where company_id = p_company_id and user_id = p_user_id);
$$;
revoke all on function public.is_member_of_company(uuid, uuid) from public, anon;
grant execute on function public.is_member_of_company(uuid, uuid) to authenticated;

drop policy if exists course_assignments_manager_select on public.course_assignments;
create policy course_assignments_manager_select on public.course_assignments for select to authenticated
  using (public.is_manager_of_company(company_id) or public.is_admin());
drop policy if exists course_assignments_own_select on public.course_assignments;
create policy course_assignments_own_select on public.course_assignments for select to authenticated
  using (user_id = auth.uid());
drop policy if exists course_assignments_manager_insert on public.course_assignments;
create policy course_assignments_manager_insert on public.course_assignments for insert to authenticated
  with check (public.is_manager_of_company(company_id) and public.is_member_of_company(company_id, user_id));
drop policy if exists course_assignments_manager_update on public.course_assignments;
create policy course_assignments_manager_update on public.course_assignments for update to authenticated
  using (public.is_manager_of_company(company_id))
  with check (public.is_manager_of_company(company_id) and public.is_member_of_company(company_id, user_id));
drop policy if exists course_assignments_manager_delete on public.course_assignments;
create policy course_assignments_manager_delete on public.course_assignments for delete to authenticated
  using (public.is_manager_of_company(company_id));

drop trigger if exists course_assignments_updated_at on public.course_assignments;
create trigger course_assignments_updated_at before update on public.course_assignments
  for each row execute function public.update_updated_at_column();

-- ---------------------------------------------------------------------------
-- 2. manager_assign_course
-- ---------------------------------------------------------------------------
create or replace function public.manager_assign_course(
  p_company_id uuid, p_course_id uuid, p_user_id uuid default null, p_due_date date default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_count int;
begin
  if auth.uid() is null or not public.is_manager_of_company(p_company_id) then
    raise exception 'Not authorized to manage this company' using errcode = '42501';
  end if;
  if not exists (select 1 from public.courses where id = p_course_id) then
    return jsonb_build_object('success', false, 'error', 'Course not found.');
  end if;
  if p_user_id is not null and not public.is_member_of_company(p_company_id, p_user_id) then
    raise exception 'That person is not on this company' using errcode = '42501';
  end if;

  insert into public.course_assignments (company_id, user_id, course_id, due_date, assigned_by)
  select p_company_id, cm.user_id, p_course_id, p_due_date, auth.uid()
    from public.company_members cm
   where cm.company_id = p_company_id and (p_user_id is null or cm.user_id = p_user_id)
  on conflict (company_id, user_id, course_id)
  do update set due_date = excluded.due_date, assigned_by = excluded.assigned_by;
  get diagnostics v_count = row_count;
  return jsonb_build_object('success', true, 'assigned', v_count);
end;
$$;
revoke all on function public.manager_assign_course(uuid, uuid, uuid, date) from public, anon;
grant execute on function public.manager_assign_course(uuid, uuid, uuid, date) to authenticated;

-- ---------------------------------------------------------------------------
-- 3. company_invites
-- ---------------------------------------------------------------------------
create table if not exists public.company_invites (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  email text not null check (email = lower(trim(email)) and email like '%_@_%'),
  token text not null unique default (replace(gen_random_uuid()::text, '-', '') || replace(gen_random_uuid()::text, '-', '')),
  status text not null default 'pending' check (status in ('pending', 'accepted', 'revoked')),
  invited_by uuid references auth.users(id) on delete set null default auth.uid(),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '14 days'),
  accepted_at timestamptz,
  accepted_by uuid references auth.users(id) on delete set null,
  revoked_at timestamptz
);
create unique index if not exists company_invites_one_pending_per_email
  on public.company_invites (company_id, email) where status = 'pending';
create index if not exists company_invites_email_idx on public.company_invites (email) where status = 'pending';

alter table public.company_invites enable row level security;
revoke all on public.company_invites from anon, authenticated;
grant select on public.company_invites to authenticated;   -- writes only via RPCs
drop policy if exists company_invites_manager_select on public.company_invites;
create policy company_invites_manager_select on public.company_invites for select to authenticated
  using (public.is_manager_of_company(company_id) or public.is_admin());

-- ---------------------------------------------------------------------------
-- 4. seats used = members + pending unexpired invites
-- ---------------------------------------------------------------------------
create or replace function public.company_seats_used(p_company_id uuid)
returns integer language sql stable security definer set search_path = public as $$
  select (select count(*) from public.company_members where company_id = p_company_id)::int
       + (select count(*) from public.company_invites
           where company_id = p_company_id and status = 'pending' and expires_at > now())::int;
$$;
revoke all on function public.company_seats_used(uuid) from public, anon;
grant execute on function public.company_seats_used(uuid) to authenticated;

-- same as 20261014120000, but pending invites count toward the seat limit
-- (an invite for this exact email is not double counted)
create or replace function public.manager_add_company_member(p_company_id uuid, p_email text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_company record;
  v_uid uuid;
  v_used int;
  v_email text := lower(trim(p_email));
begin
  if auth.uid() is null or not public.is_manager_of_company(p_company_id) then
    raise exception 'Not authorized to manage this company' using errcode = '42501';
  end if;

  select id, active, seat_limit into v_company from public.companies where id = p_company_id for update;
  if not found then raise exception 'Company not found'; end if;
  if not v_company.active then
    return jsonb_build_object('success', false, 'error', 'This company is not active.');
  end if;

  select id into v_uid from auth.users where lower(email) = v_email limit 1;
  if v_uid is null then
    return jsonb_build_object('success', false, 'error', 'No account found with that email. Send them an invite instead.');
  end if;
  if exists (select 1 from public.company_members where company_id = p_company_id and user_id = v_uid) then
    return jsonb_build_object('success', false, 'error', 'That person is already on your team.');
  end if;
  if exists (select 1 from public.company_members where user_id = v_uid) then
    return jsonb_build_object('success', false, 'error', 'That account already belongs to another company.');
  end if;

  v_used := public.company_seats_used(p_company_id)
          - (select count(*) from public.company_invites
              where company_id = p_company_id and email = v_email and status = 'pending' and expires_at > now())::int;
  if v_company.seat_limit is not null and v_used >= v_company.seat_limit then
    return jsonb_build_object('success', false, 'error', format('All %s seats are in use (pending invites count). Remove someone, revoke an invite, or contact ForgeLine to add seats.', v_company.seat_limit));
  end if;

  insert into public.company_members (company_id, user_id, role) values (p_company_id, v_uid, 'member');
  update public.profiles set company_id = p_company_id where id = v_uid;
  update public.company_invites set status = 'accepted', accepted_at = now(), accepted_by = v_uid
   where company_id = p_company_id and email = v_email and status = 'pending';
  return jsonb_build_object('success', true, 'user_id', v_uid);
end;
$$;
revoke all on function public.manager_add_company_member(uuid, text) from public, anon;
grant execute on function public.manager_add_company_member(uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 5. create / revoke invites
-- ---------------------------------------------------------------------------
create or replace function public.manager_create_invite(p_company_id uuid, p_email text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_company record;
  v_email text := lower(trim(p_email));
  v_uid uuid;
  v_inv record;
begin
  if auth.uid() is null or not public.is_manager_of_company(p_company_id) then
    raise exception 'Not authorized to manage this company' using errcode = '42501';
  end if;
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    return jsonb_build_object('success', false, 'error', 'Enter a valid email address.');
  end if;

  select id, name, active, seat_limit into v_company from public.companies where id = p_company_id for update;
  if not found then raise exception 'Company not found'; end if;
  if not v_company.active then
    return jsonb_build_object('success', false, 'error', 'This company is not active.');
  end if;

  select id into v_uid from auth.users where lower(email) = v_email limit 1;
  if v_uid is not null and exists (select 1 from public.company_members where company_id = p_company_id and user_id = v_uid) then
    return jsonb_build_object('success', false, 'error', 'That person is already on your team.');
  end if;
  if v_uid is not null and exists (select 1 from public.company_members where user_id = v_uid) then
    return jsonb_build_object('success', false, 'error', 'That account already belongs to another company.');
  end if;

  -- an expired pending invite for this email is closed out so a fresh one can be created
  update public.company_invites set status = 'revoked', revoked_at = now()
   where company_id = p_company_id and email = v_email and status = 'pending' and expires_at <= now();
  if exists (select 1 from public.company_invites where company_id = p_company_id and email = v_email and status = 'pending') then
    return jsonb_build_object('success', false, 'error', 'An invite for that email is already pending.');
  end if;

  if v_company.seat_limit is not null and public.company_seats_used(p_company_id) >= v_company.seat_limit then
    return jsonb_build_object('success', false, 'error', format('All %s seats are in use (pending invites count). Remove someone, revoke an invite, or contact ForgeLine to add seats.', v_company.seat_limit));
  end if;

  insert into public.company_invites (company_id, email, invited_by)
  values (p_company_id, v_email, auth.uid())
  returning id, token, expires_at into v_inv;
  return jsonb_build_object('success', true, 'invite_id', v_inv.id, 'token', v_inv.token,
                            'expires_at', v_inv.expires_at, 'company_name', v_company.name);
end;
$$;
revoke all on function public.manager_create_invite(uuid, text) from public, anon;
grant execute on function public.manager_create_invite(uuid, text) to authenticated;

create or replace function public.manager_revoke_invite(p_invite_id uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_company uuid;
begin
  select company_id into v_company from public.company_invites where id = p_invite_id for update;
  if auth.uid() is null or v_company is null or not public.is_manager_of_company(v_company) then
    raise exception 'Not authorized to manage this invite' using errcode = '42501';
  end if;
  update public.company_invites set status = 'revoked', revoked_at = now()
   where id = p_invite_id and status = 'pending';
  return jsonb_build_object('success', found);
end;
$$;
revoke all on function public.manager_revoke_invite(uuid) from public, anon;
grant execute on function public.manager_revoke_invite(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 6. claim invites for a user with a verified email
-- ---------------------------------------------------------------------------
-- internal: not callable by API roles
create or replace function public._claim_company_invites_for(p_uid uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_email text;
  v_confirmed timestamptz;
  v_inv record;
  v_company record;
begin
  if p_uid is null then return jsonb_build_object('joined', false); end if;
  select lower(email), email_confirmed_at into v_email, v_confirmed from auth.users where id = p_uid;
  if v_email is null or v_confirmed is null then
    return jsonb_build_object('joined', false, 'reason', 'email_not_verified');
  end if;
  if exists (select 1 from public.company_members where user_id = p_uid) then
    return jsonb_build_object('joined', false, 'reason', 'already_in_company');
  end if;

  select * into v_inv from public.company_invites
   where email = v_email and status = 'pending' and expires_at > now()
   order by created_at limit 1 for update;
  if not found then return jsonb_build_object('joined', false, 'reason', 'no_invite'); end if;

  select id, active, seat_limit into v_company from public.companies where id = v_inv.company_id for update;
  if not v_company.active then
    return jsonb_build_object('joined', false, 'reason', 'company_inactive');
  end if;
  -- the invite already holds a seat; only refuse if members alone fill the cap
  -- (e.g. a master admin lowered seat_limit after inviting)
  if v_company.seat_limit is not null
     and (select count(*) from public.company_members where company_id = v_inv.company_id) >= v_company.seat_limit then
    return jsonb_build_object('joined', false, 'reason', 'no_seats');
  end if;

  insert into public.company_members (company_id, user_id, role) values (v_inv.company_id, p_uid, 'member');
  update public.profiles set company_id = v_inv.company_id where id = p_uid;
  update public.company_invites set status = 'accepted', accepted_at = now(), accepted_by = p_uid where id = v_inv.id;
  return jsonb_build_object('joined', true, 'company_id', v_inv.company_id);
end;
$$;
revoke all on function public._claim_company_invites_for(uuid) from public, anon, authenticated;

create or replace function public.claim_my_company_invites()
returns jsonb language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'Not signed in' using errcode = '42501'; end if;
  return public._claim_company_invites_for(auth.uid());
end;
$$;
revoke all on function public.claim_my_company_invites() from public, anon;
grant execute on function public.claim_my_company_invites() to authenticated;

create or replace function public.profiles_claim_company_invites()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.company_id is null then
    perform public._claim_company_invites_for(new.id);
  end if;
  return new;
end;
$$;
revoke all on function public.profiles_claim_company_invites() from public, anon, authenticated;
drop trigger if exists profiles_claim_company_invites on public.profiles;
create trigger profiles_claim_company_invites after insert on public.profiles
  for each row execute function public.profiles_claim_company_invites();

-- ---------------------------------------------------------------------------
-- 7. leaving a company drops that company's assignments for the person
-- ---------------------------------------------------------------------------
create or replace function public.company_members_cleanup_assignments()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  delete from public.course_assignments where company_id = old.company_id and user_id = old.user_id;
  return old;
end;
$$;
revoke all on function public.company_members_cleanup_assignments() from public, anon, authenticated;
drop trigger if exists company_members_cleanup_assignments on public.company_members;
create trigger company_members_cleanup_assignments after delete on public.company_members
  for each row execute function public.company_members_cleanup_assignments();
