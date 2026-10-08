-- =============================================================================
-- ForgeLine Academy: AI company builder, company-premium entitlement,
-- and company-manager tracking (RLS).
--
-- Project: vacmkldqirwhihaniguk
-- Safe to re-run: every statement is IF NOT EXISTS / CREATE OR REPLACE /
-- DROP ... IF EXISTS + CREATE.
--
-- Existing model this builds on (verified against the live schema 2026-10-08):
--   * profiles.is_admin            -> master (platform) admin
--   * profiles.is_premium          -> personal premium (set by stripe-webhook / comps)
--   * stripe_subscriptions.status  -> 'active' | 'trialing' = paying subscriber
--   * companies.premium            -> company-wide premium (ONLINE seats only)
--   * company_members(company_id, user_id, role in owner|admin|member)
--       -> authoritative user<->company link. owner/admin = "company manager".
--       NOTE: profiles.company_id is a convenience copy that end users can
--       currently write on their own row, so it is NOT trusted for security.
--   * user_progress, quiz_attempts, certificates -> per-user learning records
--     (there is no separate enrollments table: an "enrollment" is any
--      (user, course) pair with at least one user_progress row).
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. companies: branding + published profile columns
--    The live row only ever holds PUBLISHED content. Work-in-progress AI drafts
--    live in public.company_drafts (admin-only, see section 2).
-- -----------------------------------------------------------------------------
alter table public.companies
  add column if not exists domain          text,
  add column if not exists industry        text,
  add column if not exists brand_primary   text,
  add column if not exists brand_secondary text,
  add column if not exists brand_accent    text,
  add column if not exists profile         jsonb       not null default '{}'::jsonb,
  add column if not exists published       boolean     not null default false,
  add column if not exists published_at    timestamptz,
  add column if not exists updated_at      timestamptz not null default now();

comment on column public.companies.profile is
  'Published company profile: {summary, locations[], equipment[], processes[], suggested_tracks[{course_id, title, reason}]}';
comment on column public.companies.published is
  'When false, the branded /company dashboard is only shown to master admins.';

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'companies_brand_colors_hex') then
    alter table public.companies
      add constraint companies_brand_colors_hex check (
        (brand_primary   is null or brand_primary   ~ '^#[0-9A-Fa-f]{6}$') and
        (brand_secondary is null or brand_secondary ~ '^#[0-9A-Fa-f]{6}$') and
        (brand_accent    is null or brand_accent    ~ '^#[0-9A-Fa-f]{6}$')
      );
  end if;
end $$;

-- Reuse the existing public.update_updated_at_column() trigger function.
drop trigger if exists companies_set_updated_at on public.companies;
create trigger companies_set_updated_at
  before update on public.companies
  for each row execute function public.update_updated_at_column();


-- -----------------------------------------------------------------------------
-- 2. company_drafts: admin-only working copy produced by the AI builder
-- -----------------------------------------------------------------------------
create table if not exists public.company_drafts (
  company_id uuid primary key references public.companies(id) on delete cascade,
  draft      jsonb       not null default '{}'::jsonb,
  updated_by uuid        references auth.users(id) on delete set null,
  updated_at timestamptz not null default now()
);

alter table public.company_drafts enable row level security;
revoke all on public.company_drafts from anon;
grant select, insert, update, delete on public.company_drafts to authenticated;

drop policy if exists company_drafts_admin_all on public.company_drafts;
create policy company_drafts_admin_all on public.company_drafts
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());


-- -----------------------------------------------------------------------------
-- 3. Helper functions
-- -----------------------------------------------------------------------------

-- 3a. Is the caller an owner/admin of a company that target_user belongs to?
--     SECURITY DEFINER so it can read company_members without recursing into
--     company_members RLS. Only answers for auth.uid(); no cross-company data.
create or replace function public.is_company_manager_of(target_user uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select auth.uid() is not null
     and target_user is not null
     and exists (
       select 1
       from public.company_members mgr
       join public.company_members emp on emp.company_id = mgr.company_id
       where mgr.user_id = auth.uid()
         and mgr.role in ('owner', 'admin')
         and emp.user_id = target_user
     );
$$;

comment on function public.is_company_manager_of(uuid) is
  'True when auth.uid() is owner/admin (manager) of a company that target_user is a member of.';

-- 3b. Central server-side entitlement: personal premium OR active/trialing Stripe
--     subscription OR membership (company_members) in a company with premium = true
--     AND active = true (an inactive company, e.g. ended trial, grants nothing).
--     Mirrors src/lib/entitlements.ts. Callers may only ask about themselves
--     unless they are a master admin or that user's company manager.
create or replace function public.has_premium(uid uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    uid is not null
    and (
      uid = auth.uid()
      or coalesce(auth.jwt()->>'role', '') = 'service_role'   -- edge functions
      or public.is_admin()
      or public.is_company_manager_of(uid)
    )
    and (
      exists (select 1 from public.profiles p where p.id = uid and p.is_premium = true)
      or exists (
        select 1
        from public.stripe_customers c
        join public.stripe_subscriptions s on s.customer_id = c.customer_id
        where c.user_id = uid
          and c.deleted_at is null
          and s.deleted_at is null
          and s.status in ('active', 'trialing')   -- same set as stripe-webhook
      )
      or exists (
        select 1
        from public.company_members m
        join public.companies co on co.id = m.company_id
        where m.user_id = uid
          and co.premium = true
          and co.active = true            -- inactive company (ended trial) grants nothing
      )
    ),
    false
  );
$$;

comment on function public.has_premium(uuid) is
  'Premium entitlement: profiles.is_premium OR stripe_subscriptions.status in (active, trialing) OR member of a company with premium = true and active = true.';

-- 3c. Admin RPC: create/update an AI draft. Creates the companies row (unpublished,
--     premium unchanged/default false) when p_company_id is null.
create or replace function public.save_company_draft(p_company_id uuid, p_name text, p_draft jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid := p_company_id;
begin
  if not public.is_admin() then
    raise exception 'Only platform admins can build companies';
  end if;
  if coalesce(btrim(p_name), '') = '' then
    raise exception 'Company name is required';
  end if;

  if v_id is null then
    insert into public.companies (name, created_by, published)
    values (btrim(p_name), auth.uid(), false)
    returning id into v_id;
  elsif not exists (select 1 from public.companies where id = v_id) then
    raise exception 'Company not found';
  end if;

  insert into public.company_drafts (company_id, draft, updated_by, updated_at)
  values (v_id, coalesce(p_draft, '{}'::jsonb) || jsonb_build_object('name', btrim(p_name)), auth.uid(), now())
  on conflict (company_id) do update
    set draft = excluded.draft,
        updated_by = excluded.updated_by,
        updated_at = now();

  return v_id;
end;
$$;

-- 3d. Admin RPC: copy the saved draft onto the live companies row and publish.
--     Never touches companies.premium / companies.active.
create or replace function public.publish_company_profile(p_company_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  d jsonb;
  hex constant text := '^#[0-9A-Fa-f]{6}$';
begin
  if not public.is_admin() then
    raise exception 'Only platform admins can publish companies';
  end if;

  select draft into d from public.company_drafts where company_id = p_company_id;
  if d is null then
    raise exception 'No saved draft for this company';
  end if;

  update public.companies c set
    name            = coalesce(nullif(btrim(d->>'name'), ''), c.name),
    domain          = nullif(btrim(d->>'domain'), ''),
    industry        = nullif(btrim(d->>'industry'), ''),
    logo_url        = coalesce(nullif(btrim(d->>'logo_url'), ''), c.logo_url),
    brand_primary   = case when d->'brand_colors'->>'primary'   ~ hex then d->'brand_colors'->>'primary'   end,
    brand_secondary = case when d->'brand_colors'->>'secondary' ~ hex then d->'brand_colors'->>'secondary' end,
    brand_accent    = case when d->'brand_colors'->>'accent'    ~ hex then d->'brand_colors'->>'accent'    end,
    profile = jsonb_build_object(
      'summary',          coalesce(d->'summary', '""'::jsonb),
      'locations',        coalesce(d->'locations', '[]'::jsonb),
      'equipment',        coalesce(d->'equipment', '[]'::jsonb),
      'processes',        coalesce(d->'processes', '[]'::jsonb),
      'suggested_tracks', coalesce(d->'suggested_tracks', '[]'::jsonb)
    ),
    published    = true,
    published_at = now()
  where c.id = p_company_id;

  if not found then
    raise exception 'Company not found';
  end if;
end;
$$;

-- 3e. Admin RPC: hide the branded dashboard again (keeps data + premium).
create or replace function public.unpublish_company_profile(p_company_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Only platform admins can unpublish companies';
  end if;
  update public.companies set published = false where id = p_company_id;
end;
$$;

-- Function grants: signed-in users only (never anon).
revoke all on function public.is_company_manager_of(uuid)            from public, anon;
revoke all on function public.has_premium(uuid)                      from public, anon;
revoke all on function public.save_company_draft(uuid, text, jsonb)  from public, anon;
revoke all on function public.publish_company_profile(uuid)          from public, anon;
revoke all on function public.unpublish_company_profile(uuid)        from public, anon;
grant execute on function public.is_company_manager_of(uuid)            to authenticated;
grant execute on function public.has_premium(uuid)                      to authenticated, service_role;
grant execute on function public.save_company_draft(uuid, text, jsonb)  to authenticated;
grant execute on function public.publish_company_profile(uuid)          to authenticated;
grant execute on function public.unpublish_company_profile(uuid)        to authenticated;


-- -----------------------------------------------------------------------------
-- 4. Manager read access (RLS). SELECT only, additive to the existing
--    "own rows" policies. A manager sees rows of users in THEIR company only;
--    plain members gain nothing; master admins can read for support.
-- -----------------------------------------------------------------------------
drop policy if exists company_managers_read_member_progress on public.user_progress;
create policy company_managers_read_member_progress on public.user_progress
  for select to authenticated
  using (public.is_company_manager_of(user_id) or public.is_admin());

drop policy if exists company_managers_read_member_quiz_attempts on public.quiz_attempts;
create policy company_managers_read_member_quiz_attempts on public.quiz_attempts
  for select to authenticated
  using (public.is_company_manager_of(user_id) or public.is_admin());

drop policy if exists company_managers_read_member_certificates on public.certificates;
create policy company_managers_read_member_certificates on public.certificates
  for select to authenticated
  using (public.is_company_manager_of(user_id) or public.is_admin());

-- Tighten company_members reads. The old policy trusted profiles.company_id,
-- which users can set on their own row, so anyone could list another company's
-- member ids/roles. Now: your own membership row, or every row of a company
-- you manage (is_company_admin already includes master admins).
drop policy if exists members_can_read_company_members on public.company_members;
create policy members_can_read_company_members on public.company_members
  for select to authenticated
  using (user_id = auth.uid() or public.is_company_admin(company_id));


-- -----------------------------------------------------------------------------
-- 5. Per-employee, per-course rollup ("enrollments"). SECURITY INVOKER, so
--    the user_progress RLS above decides which rows each caller sees:
--    self + (if manager) own-company employees + (if master admin) everyone.
-- -----------------------------------------------------------------------------
create or replace view public.company_member_course_progress
with (security_invoker = true) as
select
  up.user_id,
  up.course_id,
  count(*)                                         as lessons_started,
  count(*) filter (where up.completed)             as lessons_completed,
  round(avg(up.quiz_score) filter (where up.quiz_score is not null))::int as avg_quiz_score,
  min(up.created_at)                               as enrolled_at,
  max(greatest(up.created_at, coalesce(up.completed_at, up.created_at))) as last_activity
from public.user_progress up
group by up.user_id, up.course_id;

comment on view public.company_member_course_progress is
  'Per user per course progress rollup. security_invoker: respects user_progress RLS.';

revoke all on public.company_member_course_progress from anon;
grant select on public.company_member_course_progress to authenticated;
