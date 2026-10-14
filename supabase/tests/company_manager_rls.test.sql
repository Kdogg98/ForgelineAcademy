-- =============================================================================
-- RLS / entitlement test plan for migrations
--   20261008150000_company_builder_entitlements_manager_rls.sql
--   20261008150100_protect_profile_privileged_columns.sql
--   20261014120000_company_manager_roster_rpcs.sql
--   20261014180000_company_assignments_invites.sql   (section 8)
--
-- Proves: manager A cannot see company B rows, employees cannot see each
-- other, company premium grants premium (only while the company is active), drafts are admin-only, and users can
-- no longer self-grant is_admin / is_premium / company_id.
--
-- RUN ONLY ON A LOCAL STACK OR A SUPABASE BRANCH, never on production:
--   supabase db reset            # local, applies migrations
--   psql "$LOCAL_DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/company_manager_rls.test.sql
-- Everything runs in one transaction and is ROLLED BACK at the end. Any failed
-- ASSERT aborts with the message of the broken rule.
-- Must be run as a superuser/postgres (to insert fixtures into auth.users).
-- =============================================================================
begin;

-- live auth.users has email_confirmed_at; minimal local stubs may not
do $$ begin
  if not exists (select 1 from information_schema.columns where table_schema = 'auth' and table_name = 'users' and column_name = 'email_confirmed_at') then
    alter table auth.users add column email_confirmed_at timestamptz;
  end if;
end $$;

-- ---------- fixtures (as postgres, bypasses RLS) ----------
-- ids: aa.. = company A, bb.. = company B, ad = master admin, 50 = solo, 5b = subscriber
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@test.local'),
  ('00000000-0000-0000-0000-0000000000a0', 'mgr-a@test.local'),
  ('00000000-0000-0000-0000-0000000000a1', 'emp-a1@test.local'),
  ('00000000-0000-0000-0000-0000000000a2', 'emp-a2@test.local'),
  ('00000000-0000-0000-0000-0000000000b0', 'mgr-b@test.local'),
  ('00000000-0000-0000-0000-0000000000b1', 'emp-b1@test.local'),
  ('00000000-0000-0000-0000-000000000050', 'solo@test.local'),
  ('00000000-0000-0000-0000-00000000005b', 'subscriber@test.local')
on conflict (id) do nothing;

insert into public.companies (id, name, premium) values
  ('0000000a-0000-0000-0000-000000000000', 'RLS Test Co A', true),
  ('0000000b-0000-0000-0000-000000000000', 'RLS Test Co B', false);

insert into public.profiles (id, email, is_admin, is_premium, company_id) values
  ('00000000-0000-0000-0000-0000000000ad', 'admin@test.local', true,  false, null),
  ('00000000-0000-0000-0000-0000000000a0', 'mgr-a@test.local', false, false, '0000000a-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000a1', 'emp-a1@test.local', false, false, '0000000a-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000a2', 'emp-a2@test.local', false, false, '0000000a-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000b0', 'mgr-b@test.local', false, false, '0000000b-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000b1', 'emp-b1@test.local', false, false, '0000000b-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-000000000050', 'solo@test.local', false, false, null),
  ('00000000-0000-0000-0000-00000000005b', 'subscriber@test.local', false, false, null)
on conflict (id) do update set is_admin = excluded.is_admin, is_premium = excluded.is_premium, company_id = excluded.company_id;

insert into public.company_members (company_id, user_id, role) values
  ('0000000a-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000a0', 'owner'),
  ('0000000a-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000a1', 'member'),
  ('0000000a-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000a2', 'member'),
  ('0000000b-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000b0', 'admin'),
  ('0000000b-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000b1', 'member');

insert into public.stripe_customers (user_id, customer_id) values ('00000000-0000-0000-0000-00000000005b', 'cus_rls_test');
insert into public.stripe_subscriptions (customer_id, status) values ('cus_rls_test', 'active');

-- learning records (course/lesson ids are arbitrary for the stub; on a real
-- stack swap in any existing course/lesson ids if FKs are enforced)
create temp table t_ids as
  select (select id from public.courses order by sort_order limit 1) as course_id,
         (select l.id from public.lessons l join public.modules m on m.id = l.module_id
           where m.course_id = (select id from public.courses order by sort_order limit 1) limit 1) as lesson_id;
grant select on t_ids to authenticated, anon;

insert into public.user_progress (user_id, lesson_id, course_id, completed, quiz_score, completed_at)
select u, t.lesson_id, t.course_id, true, 90, now() from t_ids t,
  unnest(array['00000000-0000-0000-0000-0000000000a0','00000000-0000-0000-0000-0000000000a1',
               '00000000-0000-0000-0000-0000000000a2','00000000-0000-0000-0000-0000000000b1']::uuid[]) u;
insert into public.quiz_attempts (user_id, lesson_id, course_id, score, passed)
select u, t.lesson_id, t.course_id, 85, true from t_ids t,
  unnest(array['00000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000000a2',
               '00000000-0000-0000-0000-0000000000b1']::uuid[]) u;
insert into public.certificates (user_id, course_id)
select u, t.course_id from t_ids t,
  unnest(array['00000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000000b1']::uuid[]) u;

-- ---------- 1. Manager A (owner of A) ----------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a0","role":"authenticated"}', true);
set local role authenticated;
do $$
declare b uuid[] := array['00000000-0000-0000-0000-0000000000b0','00000000-0000-0000-0000-0000000000b1']::uuid[];
        a uuid[] := array['00000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000000a2']::uuid[];
begin
  assert (select count(*) from public.user_progress  where user_id = any(b)) = 0, 'mgr A sees company B user_progress';
  assert (select count(*) from public.quiz_attempts  where user_id = any(b)) = 0, 'mgr A sees company B quiz_attempts';
  assert (select count(*) from public.certificates   where user_id = any(b)) = 0, 'mgr A sees company B certificates';
  assert (select count(*) from public.company_member_course_progress where user_id = any(b)) = 0, 'mgr A sees company B rollup';
  assert (select count(*) from public.company_members where company_id = '0000000b-0000-0000-0000-000000000000') = 0, 'mgr A sees company B members';
  assert (select count(*) from public.companies where id = '0000000b-0000-0000-0000-000000000000') = 0, 'mgr A sees company B row';
  -- positive: can see own employees
  assert (select count(distinct user_id) from public.user_progress where user_id = any(a)) = 2, 'mgr A cannot see own employees progress';
  assert (select count(*) from public.quiz_attempts where user_id = any(a)) = 2, 'mgr A cannot see own employees quiz attempts';
  assert (select count(*) from public.certificates where user_id = any(a)) = 1, 'mgr A cannot see own employees certificates';
  assert (select count(*) from public.company_member_course_progress where user_id = any(a)) = 2, 'mgr A rollup missing employees';
  assert public.has_premium('00000000-0000-0000-0000-0000000000a1'), 'mgr A should see employee premium';
  assert not public.has_premium('00000000-0000-0000-0000-0000000000b1'), 'mgr A must not learn about B users';
  assert (select count(*) from public.company_drafts) = 0, 'mgr A can read drafts';
end $$;

-- 1b. Manager A tries to hop into company B by editing their own profile.
update public.profiles set company_id = '0000000b-0000-0000-0000-000000000000', is_admin = true
 where id = '00000000-0000-0000-0000-0000000000a0';
do $$ begin
  assert (select company_id from public.profiles where id = auth.uid()) = '0000000a-0000-0000-0000-000000000000', 'company_id self-edit not blocked';
  assert (select not is_admin from public.profiles where id = auth.uid()), 'is_admin self-grant not blocked';
  assert (select count(*) from public.company_members where company_id = '0000000b-0000-0000-0000-000000000000') = 0, 'profile hop leaked B members';
  assert (select count(*) from public.user_progress where user_id = '00000000-0000-0000-0000-0000000000b1') = 0, 'profile hop leaked B progress';
end $$;
-- 1c. Non-admin cannot build / publish companies.
do $$ begin
  begin
    perform public.save_company_draft(null, 'Sneaky Co', '{}'::jsonb);
    raise exception 'TEST FAIL: manager created a company';
  exception when others then
    if sqlerrm like 'TEST FAIL%' then raise; end if;
  end;
  begin
    perform public.publish_company_profile('0000000a-0000-0000-0000-000000000000');
    raise exception 'TEST FAIL: manager published a company';
  exception when others then
    if sqlerrm like 'TEST FAIL%' then raise; end if;
  end;
end $$;
reset role;

-- ---------- 2. Employee A1 (plain member) ----------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  assert (select count(*) from public.user_progress where user_id <> auth.uid()) = 0, 'employee sees other users progress';
  assert (select count(*) from public.quiz_attempts where user_id <> auth.uid()) = 0, 'employee sees other users quiz attempts';
  assert (select count(*) from public.certificates  where user_id <> auth.uid()) = 0, 'employee sees other users certificates';
  assert (select count(*) from public.company_member_course_progress where user_id <> auth.uid()) = 0, 'employee sees other users rollup';
  assert (select count(*) from public.company_members) = 1, 'employee sees other members rows';
  assert (select count(*) from public.user_progress where user_id = auth.uid()) = 1, 'employee cannot see own progress';
  assert public.has_premium(), 'company A premium not granted to member';
  assert not public.has_premium('00000000-0000-0000-0000-0000000000a2'), 'employee can probe a colleague entitlement';
end $$;
-- self-grant premium is blocked
update public.profiles set is_premium = true where id = auth.uid();
do $$ begin
  assert (select not is_premium from public.profiles where id = auth.uid()), 'is_premium self-grant not blocked';
end $$;
reset role;

-- ---------- 3. Manager B (admin role of B) ----------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b0","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  assert (select count(*) from public.user_progress where user_id in ('00000000-0000-0000-0000-0000000000a0','00000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000000a2')) = 0, 'mgr B sees company A progress';
  assert (select count(*) from public.user_progress where user_id = '00000000-0000-0000-0000-0000000000b1') = 1, 'mgr B cannot see own employee';
  assert not public.has_premium(), 'company B is not premium; manager should not be premium';
end $$;
reset role;

-- ---------- 4. Solo user and subscriber ----------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000050","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  assert not public.has_premium(), 'solo user should not be premium';
  assert (select count(*) from public.user_progress) = 0, 'solo user sees others progress';
end $$;
reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000005b","role":"authenticated"}', true);
set local role authenticated;
do $$ begin assert public.has_premium(), 'active Stripe subscriber should be premium'; end $$;
reset role;

-- ---------- 4b. Inactive company grants nothing (ended trial) ----------
update public.companies set active = false
 where id = (select company_id from public.company_members where user_id = '00000000-0000-0000-0000-0000000000a1');
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
do $$ begin assert not public.has_premium(), 'inactive company must not grant premium'; end $$;
reset role;
update public.companies set active = true
 where id = (select company_id from public.company_members where user_id = '00000000-0000-0000-0000-0000000000a1');

-- ---------- 5. Master admin: builder flow ----------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}', true);
set local role authenticated;
do $$
declare cid uuid;
begin
  cid := public.save_company_draft(null, 'Built Co', '{"domain":"built.example","brand_colors":{"primary":"#112233","secondary":"#445566","accent":"#FF6600"},"locations":["Austin, TX"],"suggested_tracks":[]}'::jsonb);
  assert (select not published and not premium from public.companies where id = cid), 'new company should be unpublished, non-premium';
  perform public.publish_company_profile(cid);
  assert (select published and brand_accent = '#FF6600' and domain = 'built.example' and not premium from public.companies where id = cid), 'publish did not copy draft / changed premium';
  assert (select count(*) from public.user_progress where user_id = '00000000-0000-0000-0000-0000000000b1') = 1, 'master admin support read failed';
end $$;
reset role;

-- ---------- 7. Manager roster RPCs + seat limit (migration 20261014120000) ----------
-- extra fixtures: a3 = admin of A, f1/f2/f3 = accounts with no company
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a3', 'adm-a3@test.local'),
  ('00000000-0000-0000-0000-0000000000f1', 'free-1@test.local'),
  ('00000000-0000-0000-0000-0000000000f2', 'free-2@test.local'),
  ('00000000-0000-0000-0000-0000000000f3', 'free-3@test.local');
insert into public.profiles (id, email) values
  ('00000000-0000-0000-0000-0000000000a3', 'adm-a3@test.local'),
  ('00000000-0000-0000-0000-0000000000f1', 'free-1@test.local'),
  ('00000000-0000-0000-0000-0000000000f2', 'free-2@test.local'),
  ('00000000-0000-0000-0000-0000000000f3', 'free-3@test.local');
insert into public.company_members (company_id, user_id, role) values
  ('0000000a-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000a3', 'admin');
-- A now has 4 members (a0 owner, a1, a2, a3 admin)

-- 7a. master admin sets seat_limit (trigger lets is_admin through)
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000ad","role":"authenticated"}', true);
set local role authenticated;
update public.companies set seat_limit = 5 where id = '0000000a-0000-0000-0000-000000000000';
do $$ begin
  assert (select seat_limit from public.companies where id = '0000000a-0000-0000-0000-000000000000') = 5, 'master admin cannot set seat_limit';
end $$;
reset role;

-- 7b. owner A0: cannot raise own seat_limit via direct API update
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a0","role":"authenticated"}', true);
set local role authenticated;
update public.companies set seat_limit = 999 where id = '0000000a-0000-0000-0000-000000000000';
reset role;
do $$ begin
  assert (select seat_limit from public.companies where id = '0000000a-0000-0000-0000-000000000000') = 5, 'owner changed own seat_limit';
end $$;
-- even if an UPDATE policy for owners existed, the trigger pins seat_limit
create policy tmp_owner_update on public.companies for update to authenticated
  using (public.is_manager_of_company(id)) with check (true);
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a0","role":"authenticated"}', true);
set local role authenticated;
update public.companies set seat_limit = 999, name = 'RLS Test Co A' where id = '0000000a-0000-0000-0000-000000000000';
reset role;
do $$ begin
  assert (select seat_limit from public.companies where id = '0000000a-0000-0000-0000-000000000000') = 5, 'trigger did not pin seat_limit';
end $$;
drop policy tmp_owner_update on public.companies;

-- 7c. admin A3 adds / removes within company A
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
do $$
declare r jsonb;
begin
  -- add to own company: ok (5th of 5 seats)
  r := public.manager_add_company_member('0000000a-0000-0000-0000-000000000000', 'FREE-1@test.local');
  assert (r->>'success')::boolean, 'manager add failed: ' || r::text;
  -- seat limit reached: refused server-side
  r := public.manager_add_company_member('0000000a-0000-0000-0000-000000000000', 'free-2@test.local');
  assert not (r->>'success')::boolean and r->>'error' like '%seats%', 'seat limit not enforced: ' || r::text;
  -- duplicate / other-company user refused
  r := public.manager_add_company_member('0000000a-0000-0000-0000-000000000000', 'emp-b1@test.local');
  assert not (r->>'success')::boolean, 'added a user from another company';
  -- other company: denied
  begin
    perform public.manager_add_company_member('0000000b-0000-0000-0000-000000000000', 'free-3@test.local');
    raise exception 'TEST FAIL: added to other company';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  begin
    perform public.manager_remove_company_member('0000000b-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000b1');
    raise exception 'TEST FAIL: removed from other company';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  -- own company id but other-company target: denied
  begin
    perform public.manager_remove_company_member('0000000a-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000b1');
    raise exception 'TEST FAIL: removed other-company user via own company id';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  -- self removal: denied
  begin
    perform public.manager_remove_company_member('0000000a-0000-0000-0000-000000000000', auth.uid());
    raise exception 'TEST FAIL: manager removed self';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  -- owner removal: denied
  begin
    perform public.manager_remove_company_member('0000000a-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000a0');
    raise exception 'TEST FAIL: manager removed the owner';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  -- remove a member: ok, then seat frees up
  r := public.manager_remove_company_member('0000000a-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000f1');
  assert (r->>'success')::boolean, 'manager remove failed';
  r := public.manager_add_company_member('0000000a-0000-0000-0000-000000000000', 'free-2@test.local');
  assert (r->>'success')::boolean, 'freed seat not reusable';
end $$;
reset role;
do $$ begin
  assert (select count(*) from public.company_members where company_id = '0000000a-0000-0000-0000-000000000000') = 5, 'A member count wrong';
  assert (select company_id from public.profiles where id = '00000000-0000-0000-0000-0000000000f1') is null, 'removed user profile.company_id not cleared';
  assert (select count(*) from public.company_members where company_id = '0000000b-0000-0000-0000-000000000000') = 2, 'B membership changed';
end $$;

-- 7d. plain member and outsider cannot use the RPCs
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  begin
    perform public.manager_remove_company_member('0000000a-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000a2');
    raise exception 'TEST FAIL: member removed a colleague';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  begin
    perform public.manager_add_company_member('0000000a-0000-0000-0000-000000000000', 'free-3@test.local');
    raise exception 'TEST FAIL: member added someone';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
end $$;
reset role;

-- 7e. NULL seat_limit = unlimited
update public.companies set seat_limit = null where id = '0000000a-0000-0000-0000-000000000000';
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a0","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  assert (public.manager_add_company_member('0000000a-0000-0000-0000-000000000000', 'free-3@test.local')->>'success')::boolean, 'unlimited company refused add';
end $$;
reset role;

-- ---------- 8. Course assignments + invites (migration 20261014180000) ----------
-- state: A has 6 members (a0 owner, a1, a2, a3 admin, f2, f3), seat_limit null. B: b0 owner, b1.
insert into public.courses (id, title) values
  ('c0000000-0000-0000-0000-000000000001', 'Assign Test Course 1'),
  ('c0000000-0000-0000-0000-000000000002', 'Assign Test Course 2');
insert into auth.users (id, email, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000e1', 'invitee-1@test.local', now()),
  ('00000000-0000-0000-0000-0000000000e2', 'invitee-2@test.local', null),
  ('00000000-0000-0000-0000-0000000000e3', 'invitee-3@test.local', now());
insert into public.profiles (id, email) values
  ('00000000-0000-0000-0000-0000000000e2', 'invitee-2@test.local');

-- 8a. manager A0 assigns: one employee, then everyone; cannot touch B
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a0","role":"authenticated"}', true);
set local role authenticated;
do $$
declare r jsonb;
begin
  r := public.manager_assign_course('0000000a-0000-0000-0000-000000000000', 'c0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000a1', '2026-10-01');
  assert (r->>'success')::boolean and (r->>'assigned')::int = 1, 'assign one failed: ' || r::text;
  r := public.manager_assign_course('0000000a-0000-0000-0000-000000000000', 'c0000000-0000-0000-0000-000000000002', null, null);
  assert (r->>'assigned')::int = 6, 'assign all should hit 6 members: ' || r::text;
  -- re-assign updates due date (upsert)
  r := public.manager_assign_course('0000000a-0000-0000-0000-000000000000', 'c0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000a1', '2026-12-01');
  assert (select due_date from public.course_assignments where user_id = '00000000-0000-0000-0000-0000000000a1' and course_id = 'c0000000-0000-0000-0000-000000000001') = '2026-12-01', 'due date not updated';
  -- cannot assign to a B employee via own company id
  begin
    perform public.manager_assign_course('0000000a-0000-0000-0000-000000000000', 'c0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000b1', null);
    raise exception 'TEST FAIL: assigned other-company employee';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  -- cannot assign in company B
  begin
    perform public.manager_assign_course('0000000b-0000-0000-0000-000000000000', 'c0000000-0000-0000-0000-000000000001', null, null);
    raise exception 'TEST FAIL: assigned in other company';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  -- direct insert into B rejected by RLS
  begin
    insert into public.course_assignments (company_id, user_id, course_id) values ('0000000b-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000b1', 'c0000000-0000-0000-0000-000000000001');
    raise exception 'TEST FAIL: direct insert into B';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  -- direct insert of a B employee under company A rejected
  begin
    insert into public.course_assignments (company_id, user_id, course_id) values ('0000000a-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000b1', 'c0000000-0000-0000-0000-000000000001');
    raise exception 'TEST FAIL: direct insert of B employee under A';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  assert (select count(*) from public.course_assignments) = 7, 'manager A should see exactly A rows (7)';
end $$;
reset role;

-- B manager assigns one to b1 (fixture for isolation)
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b0","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  perform public.manager_assign_course('0000000b-0000-0000-0000-000000000000', 'c0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000b1', null);
  assert (select count(*) from public.course_assignments) = 1, 'manager B should see only B rows';
  update public.course_assignments set due_date = '2030-01-01' where company_id = '0000000a-0000-0000-0000-000000000000';
  delete from public.course_assignments where company_id = '0000000a-0000-0000-0000-000000000000';
end $$;
reset role;
do $$ begin
  assert (select count(*) from public.course_assignments where company_id = '0000000a-0000-0000-0000-000000000000') = 7, 'manager B changed A assignments';
  assert not exists (select 1 from public.course_assignments where due_date = '2030-01-01'), 'manager B updated A rows';
end $$;

-- 8b. employee a1: sees own rows only, cannot self-assign / edit / delete / invite
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  assert (select count(*) from public.course_assignments) = 2, 'employee should see only own 2 assignments';
  assert (select count(*) from public.course_assignments where user_id <> auth.uid()) = 0, 'employee sees colleagues assignments';
  begin
    insert into public.course_assignments (company_id, user_id, course_id) values ('0000000a-0000-0000-0000-000000000000', auth.uid(), 'c0000000-0000-0000-0000-000000000002');
    raise exception 'TEST FAIL: employee self-assigned';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  begin
    perform public.manager_assign_course('0000000a-0000-0000-0000-000000000000', 'c0000000-0000-0000-0000-000000000001', auth.uid(), null);
    raise exception 'TEST FAIL: employee self-assigned via RPC';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  update public.course_assignments set due_date = null where user_id = auth.uid();
  delete from public.course_assignments where user_id = auth.uid();
  begin
    perform public.manager_create_invite('0000000a-0000-0000-0000-000000000000', 'someone@test.local');
    raise exception 'TEST FAIL: employee created an invite';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  begin
    insert into public.company_invites (company_id, email) values ('0000000a-0000-0000-0000-000000000000', 'someone@test.local');
    raise exception 'TEST FAIL: employee inserted an invite directly';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  begin
    perform public._claim_company_invites_for(auth.uid());
    raise exception 'TEST FAIL: internal claim callable';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
end $$;
reset role;
do $$ begin
  assert (select due_date from public.course_assignments where user_id = '00000000-0000-0000-0000-0000000000a1' and course_id = 'c0000000-0000-0000-0000-000000000001') = '2026-12-01', 'employee edited own due date';
  assert (select count(*) from public.course_assignments where user_id = '00000000-0000-0000-0000-0000000000a1') = 2, 'employee deleted own assignment';
end $$;

-- 8c. seat limit counts pending invites. A: 6 members, limit 8.
update public.companies set seat_limit = 8 where id = '0000000a-0000-0000-0000-000000000000';
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
do $$
declare r jsonb; r2 jsonb;
begin
  r := public.manager_create_invite('0000000a-0000-0000-0000-000000000000', ' Invitee-1@Test.local ');
  assert (r->>'success')::boolean and length(r->>'token') >= 32, 'invite 1 failed: ' || r::text;
  r := public.manager_create_invite('0000000a-0000-0000-0000-000000000000', 'invitee-1@test.local');
  assert not (r->>'success')::boolean, 'duplicate pending invite allowed';
  r2 := public.manager_create_invite('0000000a-0000-0000-0000-000000000000', 'invitee-2@test.local');
  assert (r2->>'success')::boolean, 'invite 2 failed: ' || r2::text;
  assert public.company_seats_used('0000000a-0000-0000-0000-000000000000') = 8, 'seats used should be 6 members + 2 invites';
  -- 9th seat: invite refused, direct add refused
  r := public.manager_create_invite('0000000a-0000-0000-0000-000000000000', 'invitee-3@test.local');
  assert not (r->>'success')::boolean and r->>'error' like '%seats%', 'invite past seat limit allowed: ' || r::text;
  r := public.manager_add_company_member('0000000a-0000-0000-0000-000000000000', 'free-1@test.local');
  assert not (r->>'success')::boolean and r->>'error' like '%seats%', 'add past limit (pending invites) allowed: ' || r::text;
  -- other company: cannot invite or revoke
  begin
    perform public.manager_create_invite('0000000b-0000-0000-0000-000000000000', 'x@test.local');
    raise exception 'TEST FAIL: invited into other company';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
  assert (select count(*) from public.company_invites) = 2, 'manager A should see its 2 invites';
  -- revoke frees a seat
  perform public.manager_revoke_invite((r2->>'invite_id')::uuid);
  assert public.company_seats_used('0000000a-0000-0000-0000-000000000000') = 7, 'revoke did not free a seat';
  r := public.manager_create_invite('0000000a-0000-0000-0000-000000000000', 'invitee-3@test.local');
  assert (r->>'success')::boolean, 'freed seat not reusable for invite: ' || r::text;
end $$;
reset role;

-- B manager: cannot see or revoke A invites
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b0","role":"authenticated"}', true);
set local role authenticated;
do $$
declare v uuid := (select id from public.company_invites limit 1);
begin
  assert v is null, 'manager B sees A invites';
end $$;
reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b0","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  begin
    perform public.manager_revoke_invite((select id from public.company_invites where email = 'invitee-1@test.local' and false));
    raise exception 'TEST FAIL: revoke with null id allowed';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
end $$;
reset role;
-- pass the real A invite id in as postgres-built literal
select set_config('fl.inv1', (select id::text from public.company_invites where email = 'invitee-1@test.local'), true);
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b0","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  begin
    perform public.manager_revoke_invite(current_setting('fl.inv1')::uuid);
    raise exception 'TEST FAIL: manager B revoked A invite';
  exception when others then if sqlerrm like 'TEST FAIL%' then raise; end if; end;
end $$;
reset role;
do $$ begin
  assert (select status from public.company_invites where email = 'invitee-1@test.local') = 'pending', 'A invite changed by B';
end $$;

-- 8d. joining: verified email joins on profile creation (trigger); unverified does not
insert into public.profiles (id, email) values ('00000000-0000-0000-0000-0000000000e1', 'invitee-1@test.local');
do $$ begin
  assert exists (select 1 from public.company_members where user_id = '00000000-0000-0000-0000-0000000000e1' and company_id = '0000000a-0000-0000-0000-000000000000' and role = 'member'), 'verified invitee did not join on profile creation';
  assert (select company_id from public.profiles where id = '00000000-0000-0000-0000-0000000000e1') = '0000000a-0000-0000-0000-000000000000', 'profile.company_id not set';
  assert (select status from public.company_invites where email = 'invitee-1@test.local') = 'accepted', 'invite not marked accepted';
  assert public.company_seats_used('0000000a-0000-0000-0000-000000000000') = 8, 'accepted invite double counted';
end $$;
-- invitee-2 (unverified, invite revoked) and a fresh pending invite for an unverified email
update public.companies set seat_limit = null where id = '0000000a-0000-0000-0000-000000000000';
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a0","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  assert (public.manager_create_invite('0000000a-0000-0000-0000-000000000000', 'invitee-2@test.local')->>'success')::boolean, 're-invite after revoke failed';
end $$;
reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e2","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  assert not (public.claim_my_company_invites()->>'joined')::boolean, 'unverified email joined';
end $$;
reset role;
update auth.users set email_confirmed_at = now() where id = '00000000-0000-0000-0000-0000000000e2';
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e2","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  assert (public.claim_my_company_invites()->>'joined')::boolean, 'verified sign-in did not join';
  assert not (public.claim_my_company_invites()->>'joined')::boolean, 'claim is not idempotent';
end $$;
reset role;
-- expired invites do not count and cannot be claimed
update public.company_invites set expires_at = now() - interval '1 minute' where email = 'invitee-3@test.local';
insert into public.profiles (id, email) values ('00000000-0000-0000-0000-0000000000e3', 'invitee-3@test.local');
do $$ begin
  assert not exists (select 1 from public.company_members where user_id = '00000000-0000-0000-0000-0000000000e3'), 'expired invite was claimed';
end $$;

-- 8e. removing a member deletes their assignments in that company
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a0","role":"authenticated"}', true);
set local role authenticated;
do $$ begin
  perform public.manager_remove_company_member('0000000a-0000-0000-0000-000000000000', '00000000-0000-0000-0000-0000000000f2');
end $$;
reset role;
do $$ begin
  assert not exists (select 1 from public.course_assignments where user_id = '00000000-0000-0000-0000-0000000000f2'), 'assignments not cleaned up on removal';
end $$;

-- 8f. anon gets nothing
select set_config('request.jwt.claims', '', true);
set local role anon;
do $$ begin
  begin
    perform 1 from public.course_assignments;
    assert (select count(*) from public.course_assignments) = 0, 'anon sees assignments';
  exception when insufficient_privilege then null; end;
  begin
    perform 1 from public.company_invites;
    raise exception 'TEST FAIL: anon can read invites';
  exception when insufficient_privilege then null; end;
end $$;
reset role;

-- ---------- 6. anon ----------
select set_config('request.jwt.claims', '', true);
set local role anon;
do $$ begin
  assert (select count(*) from public.user_progress) = 0, 'anon sees progress';
  assert (select count(*) from public.company_drafts) = 0, 'anon sees drafts';
exception when insufficient_privilege then null;  -- no grant at all is also a pass
end $$;
reset role;

select 'ALL COMPANY RLS TESTS PASSED' as result;
rollback;
