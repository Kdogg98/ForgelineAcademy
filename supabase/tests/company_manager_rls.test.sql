-- =============================================================================
-- RLS / entitlement test plan for migrations
--   20261008150000_company_builder_entitlements_manager_rls.sql
--   20261008150100_protect_profile_privileged_columns.sql
--
-- Proves: manager A cannot see company B rows, employees cannot see each
-- other, company premium grants premium, drafts are admin-only, and users can
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
