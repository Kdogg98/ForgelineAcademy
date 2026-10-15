-- =============================================================================
-- Company accounts v3: roles, custom roles, trades, client placements +
-- contracts, company training profile, custom training requests (+ private
-- storage bucket), bulk assign by trade/role, bulk invite with trade/role.
--
-- NOT APPLIED AUTOMATICALLY. Review, then apply after 20261014180000.
-- Additive and safe for existing rows: no existing row is rewritten; every new
-- column is nullable or defaulted. Legacy role value 'member' stays valid and
-- means "employee". is_manager_of_company() keeps meaning owner/admin.
--
-- Role levels (rank): owner 4 > admin 3 > supervisor 2 > employee/member 1.
--   owner/admin  : manage people, roles, settings, placements, requests
--   supervisor   : view team + progress + placements, assign courses
--   employee     : learns; sees own placement/contract
-- Custom roles (company_roles) are labels that map onto a base level; setting a
-- custom role sets company_members.role to its base level, so every existing
-- check keeps working unchanged.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 0. helpers
-- ---------------------------------------------------------------------------
create or replace function public.fl_try_uuid(p text)
returns uuid language plpgsql immutable set search_path = public as $$
begin return p::uuid; exception when others then return null; end; $$;

create or replace function public.company_role_rank(p_role text)
returns int language sql immutable set search_path = public as $$
  select case p_role when 'owner' then 4 when 'admin' then 3 when 'supervisor' then 2
                     when 'employee' then 1 when 'member' then 1 else 0 end;
$$;

-- ---------------------------------------------------------------------------
-- 1. roles
-- ---------------------------------------------------------------------------
alter table public.company_members drop constraint if exists company_members_role_check;
alter table public.company_members add constraint company_members_role_check
  check (role in ('owner', 'admin', 'supervisor', 'employee', 'member'));

create table if not exists public.company_roles (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 60),
  base_role text not null default 'employee' check (base_role in ('admin', 'supervisor', 'employee')),
  created_at timestamptz not null default now()
);
create unique index if not exists company_roles_name_uq on public.company_roles (company_id, lower(name));

alter table public.company_members add column if not exists custom_role_id uuid
  references public.company_roles(id) on delete set null;

-- caller is owner/admin/supervisor of the company
create or replace function public.is_supervisor_of_company(p_company_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select auth.uid() is not null and exists (
    select 1 from public.company_members
     where company_id = p_company_id and user_id = auth.uid() and role in ('owner','admin','supervisor'));
$$;
revoke all on function public.is_supervisor_of_company(uuid) from public, anon;
grant execute on function public.is_supervisor_of_company(uuid) to authenticated;

-- supervisors may now read their team's progress/quizzes/certs (existing
-- policies call this). Owner/admin behavior is unchanged.
create or replace function public.is_company_manager_of(target_user uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select auth.uid() is not null and target_user is not null and exists (
    select 1 from public.company_members mgr
      join public.company_members emp on emp.company_id = mgr.company_id
     where mgr.user_id = auth.uid() and mgr.role in ('owner','admin','supervisor')
       and emp.user_id = target_user);
$$;

alter table public.company_roles enable row level security;
revoke all on public.company_roles from anon;
grant select, insert, update, delete on public.company_roles to authenticated;
drop policy if exists company_roles_select on public.company_roles;
create policy company_roles_select on public.company_roles for select to authenticated
  using (public.is_member_of_company(company_id, auth.uid()) or public.is_admin());
drop policy if exists company_roles_write on public.company_roles;
create policy company_roles_write on public.company_roles for all to authenticated
  using (public.is_manager_of_company(company_id) or public.is_admin())
  with check (public.is_manager_of_company(company_id) or public.is_admin());

-- set a member's role (and optional custom role label)
create or replace function public.set_company_member_role(
  p_company_id uuid, p_user_id uuid, p_role text, p_custom_role_id uuid default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_platform boolean := public.is_admin();
  v_caller text;
  v_old text;
  v_new text := p_role;
  v_owners int;
begin
  if auth.uid() is null then raise exception 'Not signed in' using errcode = '42501'; end if;
  perform 1 from public.companies where id = p_company_id for update;   -- serialize role changes
  if not found then raise exception 'Company not found'; end if;

  select role into v_caller from public.company_members where company_id = p_company_id and user_id = auth.uid();
  if not v_platform and coalesce(v_caller, '') not in ('owner', 'admin') then
    raise exception 'Not authorized to manage this company' using errcode = '42501';
  end if;

  select role into v_old from public.company_members where company_id = p_company_id and user_id = p_user_id for update;
  if v_old is null then raise exception 'That person is not on this company' using errcode = '42501'; end if;

  if p_custom_role_id is not null then
    select base_role into v_new from public.company_roles where id = p_custom_role_id and company_id = p_company_id;
    if v_new is null then raise exception 'Unknown role for this company' using errcode = '22023'; end if;
  end if;
  if v_new = 'member' then v_new := 'employee'; end if;
  if v_new not in ('owner', 'admin', 'supervisor', 'employee') then
    raise exception 'Invalid role' using errcode = '22023';
  end if;

  if not v_platform then
    if p_user_id = auth.uid() and public.company_role_rank(v_new) > public.company_role_rank(v_old) then
      raise exception 'You cannot raise your own role' using errcode = '42501';
    end if;
    if v_caller = 'admin' and (v_old = 'owner' or v_new = 'owner') then
      raise exception 'Only an owner can grant or change the owner role' using errcode = '42501';
    end if;
  end if;

  if v_old = 'owner' and v_new <> 'owner' then
    select count(*) into v_owners from public.company_members where company_id = p_company_id and role = 'owner';
    if v_owners <= 1 then
      raise exception 'A company must keep at least one owner' using errcode = '42501';
    end if;
  end if;

  update public.company_members set role = v_new, custom_role_id = p_custom_role_id
   where company_id = p_company_id and user_id = p_user_id;
  return jsonb_build_object('success', true, 'role', v_new);
end;
$$;
revoke all on function public.set_company_member_role(uuid, uuid, text, uuid) from public, anon;
grant execute on function public.set_company_member_role(uuid, uuid, text, uuid) to authenticated;

-- belt and braces: no direct API writes to company_members.role/custom_role_id
-- by non-platform users (RPCs are SECURITY DEFINER and unaffected).
create or replace function public.protect_company_member_role()
returns trigger language plpgsql set search_path = public as $$
begin
  if current_user in ('authenticated', 'anon') and not public.is_admin() then
    new.role := old.role; new.custom_role_id := old.custom_role_id;
  end if;
  return new;
end; $$;
drop trigger if exists company_members_protect_role on public.company_members;
create trigger company_members_protect_role before update on public.company_members
  for each row execute function public.protect_company_member_role();

-- supervisors can assign courses (was owner/admin only)
create or replace function public.manager_assign_course(
  p_company_id uuid, p_course_id uuid, p_user_id uuid default null, p_due_date date default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_count int;
begin
  if auth.uid() is null or not public.is_supervisor_of_company(p_company_id) then
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
drop policy if exists course_assignments_supervisor_select on public.course_assignments;
create policy course_assignments_supervisor_select on public.course_assignments for select to authenticated
  using (public.is_supervisor_of_company(company_id));

-- ---------------------------------------------------------------------------
-- 2. trades + company settings
-- ---------------------------------------------------------------------------
create table if not exists public.company_trades (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 60),
  created_at timestamptz not null default now()
);
create unique index if not exists company_trades_name_uq on public.company_trades (company_id, lower(name));
alter table public.company_trades enable row level security;
revoke all on public.company_trades from anon;
grant select, insert, update, delete on public.company_trades to authenticated;
drop policy if exists company_trades_select on public.company_trades;
create policy company_trades_select on public.company_trades for select to authenticated
  using (public.is_member_of_company(company_id, auth.uid()) or public.is_admin());
drop policy if exists company_trades_write on public.company_trades;
create policy company_trades_write on public.company_trades for all to authenticated
  using (public.is_manager_of_company(company_id) or public.is_admin())
  with check (public.is_manager_of_company(company_id) or public.is_admin());

alter table public.companies add column if not exists allow_employee_self_trade boolean not null default false;

create or replace function public.manager_set_company_settings(p_company_id uuid, p_allow_employee_self_trade boolean)
returns jsonb language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null or not (public.is_manager_of_company(p_company_id) or public.is_admin()) then
    raise exception 'Not authorized to manage this company' using errcode = '42501';
  end if;
  update public.companies set allow_employee_self_trade = coalesce(p_allow_employee_self_trade, false) where id = p_company_id;
  return jsonb_build_object('success', true);
end; $$;
revoke all on function public.manager_set_company_settings(uuid, boolean) from public, anon;
grant execute on function public.manager_set_company_settings(uuid, boolean) to authenticated;

-- ---------------------------------------------------------------------------
-- 3. client placements (sites) + per-member placement/contract details
-- ---------------------------------------------------------------------------
create table if not exists public.company_placements (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  client_name text not null check (length(trim(client_name)) between 1 and 160),
  industry text[] not null default '{}',
  location text,
  equipment text[] not null default '{}',
  equipment_notes text,
  research_ok boolean not null default false,
  notes text,
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists company_placements_company_idx on public.company_placements (company_id);

create table if not exists public.company_member_details (
  company_id uuid not null references public.companies(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  trade text check (trade is null or length(trade) <= 60),
  placement_id uuid references public.company_placements(id) on delete set null,
  site_location text,          -- overrides placement location when set
  contract_name text,
  contract_number text,
  contract_start date,
  contract_end date,
  shift text,
  supervisor_name text,
  notes text,
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_at timestamptz not null default now(),
  primary key (company_id, user_id),
  check (contract_end is null or contract_start is null or contract_end >= contract_start)
);
create index if not exists company_member_details_placement_idx on public.company_member_details (placement_id);

-- placement must belong to the same company
create or replace function public.check_member_detail_placement()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.placement_id is not null and not exists (
       select 1 from public.company_placements where id = new.placement_id and company_id = new.company_id) then
    raise exception 'Placement belongs to another company' using errcode = '42501';
  end if;
  if not public.is_member_of_company(new.company_id, new.user_id) then
    raise exception 'That person is not on this company' using errcode = '42501';
  end if;
  return new;
end; $$;
drop trigger if exists company_member_details_check on public.company_member_details;
create trigger company_member_details_check before insert or update on public.company_member_details
  for each row execute function public.check_member_detail_placement();
drop trigger if exists company_member_details_updated_at on public.company_member_details;
create trigger company_member_details_updated_at before update on public.company_member_details
  for each row execute function public.update_updated_at_column();
drop trigger if exists company_placements_updated_at on public.company_placements;
create trigger company_placements_updated_at before update on public.company_placements
  for each row execute function public.update_updated_at_column();

alter table public.company_placements enable row level security;
revoke all on public.company_placements from anon;
grant select, insert, update, delete on public.company_placements to authenticated;
drop policy if exists company_placements_select on public.company_placements;
create policy company_placements_select on public.company_placements for select to authenticated
  using (public.is_supervisor_of_company(company_id) or public.is_admin()
         or exists (select 1 from public.company_member_details d
                     where d.placement_id = company_placements.id and d.user_id = auth.uid()));
drop policy if exists company_placements_write on public.company_placements;
create policy company_placements_write on public.company_placements for all to authenticated
  using (public.is_manager_of_company(company_id) or public.is_admin())
  with check (public.is_manager_of_company(company_id) or public.is_admin());

alter table public.company_member_details enable row level security;
revoke all on public.company_member_details from anon;
grant select, insert, update, delete on public.company_member_details to authenticated;
drop policy if exists company_member_details_select on public.company_member_details;
create policy company_member_details_select on public.company_member_details for select to authenticated
  using (user_id = auth.uid() or public.is_supervisor_of_company(company_id) or public.is_admin());
drop policy if exists company_member_details_write on public.company_member_details;
create policy company_member_details_write on public.company_member_details for all to authenticated
  using (public.is_manager_of_company(company_id) or public.is_admin())
  with check (public.is_manager_of_company(company_id) or public.is_admin());

-- employee sets own trade, only if the company allows it
create or replace function public.set_my_trade(p_trade text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_company uuid;
begin
  select cm.company_id into v_company from public.company_members cm
    join public.companies c on c.id = cm.company_id
   where cm.user_id = auth.uid() and c.allow_employee_self_trade limit 1;
  if v_company is null then
    raise exception 'Your company does not allow employees to set their own trade' using errcode = '42501';
  end if;
  insert into public.company_member_details (company_id, user_id, trade, updated_by)
  values (v_company, auth.uid(), nullif(left(trim(p_trade), 60), ''), auth.uid())
  on conflict (company_id, user_id) do update set trade = excluded.trade, updated_by = excluded.updated_by;
  return jsonb_build_object('success', true);
end; $$;
revoke all on function public.set_my_trade(text) from public, anon;
grant execute on function public.set_my_trade(text) to authenticated;

-- removing someone clears their details row for that company
create or replace function public.company_members_cleanup_details()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  delete from public.company_member_details where company_id = old.company_id and user_id = old.user_id;
  return old;
end; $$;
revoke all on function public.company_members_cleanup_details() from public, anon, authenticated;
drop trigger if exists company_members_cleanup_details on public.company_members;
create trigger company_members_cleanup_details after delete on public.company_members
  for each row execute function public.company_members_cleanup_details();

-- team roster for supervisor+ (or platform admin), with role label + details
create or replace function public.get_company_team(p_company_id uuid)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare r jsonb;
begin
  if auth.uid() is null or not (public.is_supervisor_of_company(p_company_id) or public.is_admin()) then
    raise exception 'Not authorized to view this company' using errcode = '42501';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
      'member_id', cm.id, 'user_id', cm.user_id, 'role', cm.role, 'created_at', cm.created_at,
      'custom_role_id', cm.custom_role_id, 'custom_role', cr.name,
      'email', p.email, 'full_name', p.full_name,
      'details', case when d.user_id is null then null else to_jsonb(d) - 'company_id' - 'user_id' end
    ) order by cm.created_at), '[]'::jsonb) into r
    from public.company_members cm
    left join public.profiles p on p.id = cm.user_id
    left join public.company_roles cr on cr.id = cm.custom_role_id
    left join public.company_member_details d on d.company_id = cm.company_id and d.user_id = cm.user_id
   where cm.company_id = p_company_id;
  return r;
end; $$;
revoke all on function public.get_company_team(uuid) from public, anon;
grant execute on function public.get_company_team(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 4. company training profile (optional; placements carry per-site industry)
-- ---------------------------------------------------------------------------
create table if not exists public.company_training_profile (
  company_id uuid primary key references public.companies(id) on delete cascade,
  industries text[] not null default '{}',
  plant_details text,
  equipment text[] not null default '{}',
  equipment_notes text,
  research_ok boolean not null default false,
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_at timestamptz not null default now()
);
drop trigger if exists company_training_profile_updated_at on public.company_training_profile;
create trigger company_training_profile_updated_at before update on public.company_training_profile
  for each row execute function public.update_updated_at_column();
alter table public.company_training_profile enable row level security;
revoke all on public.company_training_profile from anon;
grant select, insert, update, delete on public.company_training_profile to authenticated;
drop policy if exists company_training_profile_select on public.company_training_profile;
create policy company_training_profile_select on public.company_training_profile for select to authenticated
  using (public.is_supervisor_of_company(company_id) or public.is_admin());
drop policy if exists company_training_profile_write on public.company_training_profile;
create policy company_training_profile_write on public.company_training_profile for all to authenticated
  using (public.is_manager_of_company(company_id) or public.is_admin())
  with check (public.is_manager_of_company(company_id) or public.is_admin());

-- ---------------------------------------------------------------------------
-- 5. custom training requests
-- ---------------------------------------------------------------------------
create table if not exists public.training_requests (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  requested_by uuid references auth.users(id) on delete set null default auth.uid(),
  placement_id uuid references public.company_placements(id) on delete set null,
  topic text not null check (length(trim(topic)) between 1 and 200),
  topics text[] not null default '{}',
  details text check (details is null or length(details) <= 10000),
  worker_count int check (worker_count is null or worker_count between 1 and 100000),
  trades text,
  urgency text not null default 'normal' check (urgency in ('flexible', 'normal', 'soon', 'urgent')),
  preferred_format text not null default 'online' check (preferred_format in ('online', 'on_site', 'blend')),
  industries text[] not null default '{}',
  equipment text[] not null default '{}',
  research_ok boolean not null default false,
  attachments text[] not null default '{}',   -- storage paths in training-request-files
  source text not null default 'form' check (source in ('form', 'assistant')),
  status text not null default 'new' check (status in ('new', 'quoted', 'in_progress', 'delivered', 'declined')),
  admin_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists training_requests_company_idx on public.training_requests (company_id, created_at desc);
create index if not exists training_requests_status_idx on public.training_requests (status, created_at desc);

create or replace function public.protect_training_request_fields()
returns trigger language plpgsql set search_path = public as $$
begin
  if current_user in ('authenticated', 'anon') and not public.is_admin() then
    if tg_op = 'INSERT' then
      new.status := 'new'; new.admin_notes := null; new.requested_by := auth.uid();
    else
      new.status := old.status; new.admin_notes := old.admin_notes;
      new.company_id := old.company_id; new.requested_by := old.requested_by;
    end if;
  end if;
  if new.placement_id is not null and not exists (
       select 1 from public.company_placements where id = new.placement_id and company_id = new.company_id) then
    raise exception 'Placement belongs to another company' using errcode = '42501';
  end if;
  return new;
end; $$;
drop trigger if exists training_requests_protect on public.training_requests;
create trigger training_requests_protect before insert or update on public.training_requests
  for each row execute function public.protect_training_request_fields();
drop trigger if exists training_requests_updated_at on public.training_requests;
create trigger training_requests_updated_at before update on public.training_requests
  for each row execute function public.update_updated_at_column();

alter table public.training_requests enable row level security;
revoke all on public.training_requests from anon;
grant select, insert, update on public.training_requests to authenticated;
drop policy if exists training_requests_select on public.training_requests;
create policy training_requests_select on public.training_requests for select to authenticated
  using (public.is_manager_of_company(company_id) or public.is_admin());
drop policy if exists training_requests_insert on public.training_requests;
create policy training_requests_insert on public.training_requests for insert to authenticated
  with check (public.is_manager_of_company(company_id) or public.is_admin());
drop policy if exists training_requests_admin_update on public.training_requests;
create policy training_requests_admin_update on public.training_requests for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- private bucket, paths "<company_id>/<request-or-upload-id>/<file>"
insert into storage.buckets (id, name, public, file_size_limit)
values ('training-request-files', 'training-request-files', false, 20971520)
on conflict (id) do nothing;

drop policy if exists training_request_files_select on storage.objects;
create policy training_request_files_select on storage.objects for select to authenticated
  using (bucket_id = 'training-request-files'
         and (public.is_manager_of_company(public.fl_try_uuid((storage.foldername(name))[1])) or public.is_admin()));
drop policy if exists training_request_files_insert on storage.objects;
create policy training_request_files_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'training-request-files'
              and (public.is_manager_of_company(public.fl_try_uuid((storage.foldername(name))[1])) or public.is_admin()));
drop policy if exists training_request_files_delete on storage.objects;
create policy training_request_files_delete on storage.objects for delete to authenticated
  using (bucket_id = 'training-request-files'
         and (public.is_manager_of_company(public.fl_try_uuid((storage.foldername(name))[1])) or public.is_admin()));

-- ---------------------------------------------------------------------------
-- 6. bulk: assign by trade/role, invites carrying trade/role
-- ---------------------------------------------------------------------------
create or replace function public.manager_assign_course_to_group(
  p_company_id uuid, p_course_id uuid, p_trade text default null, p_role text default null, p_due_date date default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_count int;
begin
  if auth.uid() is null or not public.is_supervisor_of_company(p_company_id) then
    raise exception 'Not authorized to manage this company' using errcode = '42501';
  end if;
  if p_trade is null and p_role is null then
    return jsonb_build_object('success', false, 'error', 'Pick a trade or a role.');
  end if;
  if not exists (select 1 from public.courses where id = p_course_id) then
    return jsonb_build_object('success', false, 'error', 'Course not found.');
  end if;
  insert into public.course_assignments (company_id, user_id, course_id, due_date, assigned_by)
  select p_company_id, cm.user_id, p_course_id, p_due_date, auth.uid()
    from public.company_members cm
    left join public.company_member_details d on d.company_id = cm.company_id and d.user_id = cm.user_id
    left join public.company_roles cr on cr.id = cm.custom_role_id
   where cm.company_id = p_company_id
     and (p_trade is null or lower(d.trade) = lower(p_trade))
     and (p_role is null or cm.role = p_role or (p_role = 'employee' and cm.role = 'member') or lower(cr.name) = lower(p_role))
  on conflict (company_id, user_id, course_id)
  do update set due_date = excluded.due_date, assigned_by = excluded.assigned_by;
  get diagnostics v_count = row_count;
  return jsonb_build_object('success', true, 'assigned', v_count);
end; $$;
revoke all on function public.manager_assign_course_to_group(uuid, uuid, text, text, date) from public, anon;
grant execute on function public.manager_assign_course_to_group(uuid, uuid, text, text, date) to authenticated;

alter table public.company_invites add column if not exists trade text check (trade is null or length(trade) <= 60);
alter table public.company_invites add column if not exists invite_role text check (invite_role is null or invite_role in ('supervisor', 'employee'));

-- set trade/role on a pending invite of your company (used by bulk invite after manager_create_invite)
create or replace function public.manager_set_invite_extras(p_invite_id uuid, p_trade text, p_role text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_company uuid;
begin
  select company_id into v_company from public.company_invites where id = p_invite_id and status = 'pending';
  if v_company is null or not public.is_manager_of_company(v_company) then
    raise exception 'Not authorized' using errcode = '42501';
  end if;
  if p_role is not null and p_role not in ('supervisor', 'employee') then
    return jsonb_build_object('success', false, 'error', 'Invites can only set supervisor or employee.');
  end if;
  update public.company_invites set trade = nullif(left(trim(p_trade), 60), ''), invite_role = p_role where id = p_invite_id;
  return jsonb_build_object('success', true);
end; $$;
revoke all on function public.manager_set_invite_extras(uuid, text, text) from public, anon;
grant execute on function public.manager_set_invite_extras(uuid, text, text) to authenticated;

-- when an invited user joins, apply the invite's trade/role
create or replace function public.company_members_apply_invite_extras()
returns trigger language plpgsql security definer set search_path = public as $$
declare v_inv record;
begin
  select i.trade, i.invite_role into v_inv
    from public.company_invites i join auth.users u on lower(u.email) = i.email
   where u.id = new.user_id and i.company_id = new.company_id and i.status in ('pending', 'accepted')
     and (i.trade is not null or i.invite_role is not null)
   order by i.created_at desc limit 1;
  if found then
    if v_inv.invite_role is not null and new.role = 'member' then
      update public.company_members set role = v_inv.invite_role where id = new.id;
    end if;
    if v_inv.trade is not null then
      insert into public.company_member_details (company_id, user_id, trade)
      values (new.company_id, new.user_id, v_inv.trade) on conflict (company_id, user_id) do nothing;
    end if;
  end if;
  return new;
end; $$;
revoke all on function public.company_members_apply_invite_extras() from public, anon, authenticated;
drop trigger if exists company_members_apply_invite_extras on public.company_members;
create trigger company_members_apply_invite_extras after insert on public.company_members
  for each row execute function public.company_members_apply_invite_extras();

revoke all on function public.fl_try_uuid(text) from public, anon;
grant execute on function public.fl_try_uuid(text) to authenticated;
