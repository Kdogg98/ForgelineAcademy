-- =============================================================================
-- RLS tests for 20261015120000_company_accounts_v3.sql
-- Local stack / branch only. One transaction, rolled back. Run as postgres.
-- Proves: cross-company isolation for company_roles, company_trades,
-- company_placements, company_member_details, company_training_profile,
-- training_requests and the training-request-files bucket; role escalation
-- blocked; last-owner protection; employees cannot edit others' placement /
-- contract or requests; supervisors read-only on details; platform admin access.
-- =============================================================================
begin;
do $$ begin
  if not exists (select 1 from information_schema.columns where table_schema='auth' and table_name='users' and column_name='email_confirmed_at') then
    alter table auth.users add column email_confirmed_at timestamptz;
  end if;
end $$;

-- ids: c0 owner A, c1 admin A, c2 supervisor A, c3 employee A (legacy 'member'), c4 employee A
--      d0 owner B, d1 employee B, cf platform admin
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000c0','v3-owner-a@test.local'),
  ('00000000-0000-0000-0000-0000000000c1','v3-admin-a@test.local'),
  ('00000000-0000-0000-0000-0000000000c2','v3-sup-a@test.local'),
  ('00000000-0000-0000-0000-0000000000c3','v3-emp-a@test.local'),
  ('00000000-0000-0000-0000-0000000000c4','v3-emp2-a@test.local'),
  ('00000000-0000-0000-0000-0000000000d0','v3-owner-b@test.local'),
  ('00000000-0000-0000-0000-0000000000d1','v3-emp-b@test.local'),
  ('00000000-0000-0000-0000-0000000000cf','v3-platform@test.local');
insert into public.companies (id, name) values
  ('000000ca-0000-0000-0000-000000000000','V3 Co A'), ('000000cb-0000-0000-0000-000000000000','V3 Co B');
insert into public.profiles (id, email, is_admin, company_id) values
  ('00000000-0000-0000-0000-0000000000c0','v3-owner-a@test.local',false,'000000ca-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000c1','v3-admin-a@test.local',false,'000000ca-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000c2','v3-sup-a@test.local',false,'000000ca-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000c3','v3-emp-a@test.local',false,'000000ca-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000c4','v3-emp2-a@test.local',false,'000000ca-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000d0','v3-owner-b@test.local',false,'000000cb-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000d1','v3-emp-b@test.local',false,'000000cb-0000-0000-0000-000000000000'),
  ('00000000-0000-0000-0000-0000000000cf','v3-platform@test.local',true,null)
on conflict (id) do update set is_admin = excluded.is_admin, company_id = excluded.company_id;
insert into public.company_members (company_id, user_id, role) values
  ('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c0','owner'),
  ('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c1','admin'),
  ('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c2','supervisor'),
  ('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c3','member'),
  ('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c4','employee'),
  ('000000cb-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000d0','owner'),
  ('000000cb-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000d1','member');
insert into public.courses (id, title) values ('0000c0c0-0000-0000-0000-000000000001','V3 course') on conflict do nothing;

-- legacy check: owner/admin still managers, supervisor is not
do $$ begin
  perform set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}',true);
  assert not public.is_manager_of_company('000000ca-0000-0000-0000-000000000000'), 'supervisor counted as manager';
  assert public.is_supervisor_of_company('000000ca-0000-0000-0000-000000000000'), 'supervisor not recognized';
end $$;

-- ---------- 1. owner A sets up roles, trades, placements, details, profile, request ----------
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-0000000000c0","role":"authenticated"}',true);
set local role authenticated;
insert into public.company_roles (id, company_id, name, base_role) values
  ('0000aa01-0000-0000-0000-000000000000','000000ca-0000-0000-0000-000000000000','Lead Hand','supervisor');
insert into public.company_trades (company_id, name) values ('000000ca-0000-0000-0000-000000000000','Instrument Fitter');
insert into public.company_placements (id, company_id, client_name, industry, location, equipment, research_ok) values
  ('0000aa02-0000-0000-0000-000000000000','000000ca-0000-0000-0000-000000000000','Client Foods','{Food & Beverage}','Plant 3, Dayton OH','{Conveyors,VFDs}',true);
insert into public.company_member_details (company_id, user_id, trade, placement_id, contract_start, contract_end) values
  ('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c3','Electrician','0000aa02-0000-0000-0000-000000000000','2026-09-01', current_date + 10),
  ('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c4','Millwright',null,null,null);
insert into public.company_training_profile (company_id, industries, research_ok) values ('000000ca-0000-0000-0000-000000000000','{Manufacturing}',true);
insert into public.training_requests (id, company_id, topic, placement_id, status, admin_notes) values
  ('0000aa03-0000-0000-0000-000000000000','000000ca-0000-0000-0000-000000000000','VFD troubleshooting','0000aa02-0000-0000-0000-000000000000','delivered','sneaky');
insert into storage.objects (bucket_id, name) values ('training-request-files','000000ca-0000-0000-0000-000000000000/r1/spec.pdf');
do $$ begin
  assert (select status from public.training_requests where id='0000aa03-0000-0000-0000-000000000000') = 'new', 'company set its own request status';
  assert (select admin_notes from public.training_requests where id='0000aa03-0000-0000-0000-000000000000') is null, 'company set admin notes';
  -- cannot target another company
  begin
    insert into public.company_placements (company_id, client_name) values ('000000cb-0000-0000-0000-000000000000','x');
    raise exception 'TEST FAIL: owner A wrote placement for B';
  exception when insufficient_privilege then null; end;
  begin
    insert into storage.objects (bucket_id, name) values ('training-request-files','000000cb-0000-0000-0000-000000000000/x/y.pdf');
    raise exception 'TEST FAIL: owner A uploaded into B folder';
  exception when insufficient_privilege then null; end;
  begin
    insert into storage.objects (bucket_id, name) values ('training-request-files','not-a-uuid/x.pdf');
    raise exception 'TEST FAIL: upload outside a company folder';
  exception when insufficient_privilege then null; end;
  -- role changes
  perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c4',null,'0000aa01-0000-0000-0000-000000000000');
  assert (select role from public.company_members where user_id='00000000-0000-0000-0000-0000000000c4') = 'supervisor', 'custom role did not map to base level';
  perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c4','employee');
  begin
    perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c0','admin');
    raise exception 'TEST FAIL: last owner demoted';
  exception when insufficient_privilege then null; end;
  begin
    perform public.set_company_member_role('000000cb-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000d1','admin');
    raise exception 'TEST FAIL: owner A changed role in B';
  exception when insufficient_privilege then null; end;
  begin
    perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000d1','admin');
    raise exception 'TEST FAIL: changed role of non-member';
  exception when insufficient_privilege then null; end;
  begin  -- B's custom role id cannot be used in A
    perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c4',null,gen_random_uuid());
    raise exception 'TEST FAIL: foreign custom role accepted';
  exception when invalid_parameter_value then null; end;
  -- direct update of role column is pinned
  update public.company_members set role = 'owner' where user_id = '00000000-0000-0000-0000-0000000000c3';
  assert (select role from public.company_members where user_id='00000000-0000-0000-0000-0000000000c3') = 'member', 'direct role update not blocked';
  -- bulk assign by trade
  assert (public.manager_assign_course_to_group('000000ca-0000-0000-0000-000000000000','0000c0c0-0000-0000-0000-000000000001','electrician',null,null)->>'assigned')::int = 1, 'group assign by trade';
  assert (public.manager_assign_course_to_group('000000ca-0000-0000-0000-000000000000','0000c0c0-0000-0000-0000-000000000001',null,'employee',null)->>'assigned')::int = 2, 'group assign by role (member+employee)';
  assert jsonb_array_length(public.get_company_team('000000ca-0000-0000-0000-000000000000')) = 5, 'owner team roster';
end $$;
reset role;

-- B fixtures as owner B
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-0000000000d0","role":"authenticated"}',true);
set local role authenticated;
insert into public.company_placements (company_id, client_name) values ('000000cb-0000-0000-0000-000000000000','B Client');
insert into public.company_member_details (company_id, user_id, trade) values ('000000cb-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000d1','Welder');
insert into public.training_requests (company_id, topic) values ('000000cb-0000-0000-0000-000000000000','B topic');
insert into public.company_roles (company_id, name) values ('000000cb-0000-0000-0000-000000000000','B role');
insert into public.company_trades (company_id, name) values ('000000cb-0000-0000-0000-000000000000','B trade');
insert into public.company_training_profile (company_id) values ('000000cb-0000-0000-0000-000000000000');
do $$ begin
  assert (select count(*) from public.company_placements where company_id='000000ca-0000-0000-0000-000000000000') = 0, 'B sees A placements';
  assert (select count(*) from public.company_member_details where company_id='000000ca-0000-0000-0000-000000000000') = 0, 'B sees A details';
  assert (select count(*) from public.training_requests where company_id='000000ca-0000-0000-0000-000000000000') = 0, 'B sees A requests';
  assert (select count(*) from public.company_roles where company_id='000000ca-0000-0000-0000-000000000000') = 0, 'B sees A roles';
  assert (select count(*) from public.company_trades where company_id='000000ca-0000-0000-0000-000000000000') = 0, 'B sees A trades';
  assert (select count(*) from public.company_training_profile where company_id='000000ca-0000-0000-0000-000000000000') = 0, 'B sees A profile';
  assert (select count(*) from storage.objects where bucket_id='training-request-files') = 0, 'B sees A files';
  begin
    perform public.get_company_team('000000ca-0000-0000-0000-000000000000');
    raise exception 'TEST FAIL: B read A team';
  exception when insufficient_privilege then null; end;
  begin  -- B detail cannot point at A placement
    update public.company_member_details set placement_id = '0000aa02-0000-0000-0000-000000000000' where user_id='00000000-0000-0000-0000-0000000000d1';
    raise exception 'TEST FAIL: cross-company placement';
  exception when insufficient_privilege then null; end;
  begin
    perform public.manager_assign_course_to_group('000000ca-0000-0000-0000-000000000000','0000c0c0-0000-0000-0000-000000000001','Electrician',null,null);
    raise exception 'TEST FAIL: B group-assigned in A';
  exception when insufficient_privilege then null; end;
end $$;
update public.company_placements set client_name = 'pwned' where company_id = '000000ca-0000-0000-0000-000000000000';
delete from storage.objects where bucket_id = 'training-request-files';
reset role;
do $$ begin
  assert (select client_name from public.company_placements where id='0000aa02-0000-0000-0000-000000000000') = 'Client Foods', 'B edited A placement';
  assert (select count(*) from storage.objects where name like '000000ca%') = 1, 'B deleted A file';
end $$;

-- ---------- 2. admin A: cannot grant owner, cannot demote owner, cannot raise self ----------
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}',true);
set local role authenticated;
do $$ begin
  begin
    perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c1','owner');
    raise exception 'TEST FAIL: admin raised self to owner';
  exception when insufficient_privilege then null; end;
  begin
    perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c3','owner');
    raise exception 'TEST FAIL: admin granted owner';
  exception when insufficient_privilege then null; end;
  begin
    perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c0','employee');
    raise exception 'TEST FAIL: admin demoted owner';
  exception when insufficient_privilege then null; end;
  perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c3','supervisor');
  perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c3','employee');
  assert (select count(*) from public.training_requests) = 1, 'admin A sees own company requests';
end $$;
reset role;

-- ---------- 3. supervisor A: reads team/details/placements, cannot edit or manage roles/requests ----------
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}',true);
set local role authenticated;
do $$ begin
  assert (select count(*) from public.company_member_details) = 2, 'supervisor cannot read team details';
  assert (select count(*) from public.company_placements) = 1, 'supervisor cannot read placements';
  assert jsonb_array_length(public.get_company_team('000000ca-0000-0000-0000-000000000000')) = 5, 'supervisor team roster';
  assert (select count(*) from public.training_requests) = 0, 'supervisor sees requests';
  assert (public.manager_assign_course('000000ca-0000-0000-0000-000000000000','0000c0c0-0000-0000-0000-000000000001','00000000-0000-0000-0000-0000000000c4',null)->>'success')::boolean, 'supervisor cannot assign';
  begin
    perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c2','admin');
    raise exception 'TEST FAIL: supervisor raised own role';
  exception when insufficient_privilege then null; end;
  begin
    insert into public.training_requests (company_id, topic) values ('000000ca-0000-0000-0000-000000000000','x');
    raise exception 'TEST FAIL: supervisor created request';
  exception when insufficient_privilege then null; end;
end $$;
update public.company_member_details set contract_end = '2030-01-01';
reset role;
do $$ begin
  assert (select count(*) from public.company_member_details where contract_end = '2030-01-01') = 0, 'supervisor edited contract';
end $$;

-- ---------- 4. employee A (legacy member c3): own details only, no edits ----------
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-0000000000c3","role":"authenticated"}',true);
set local role authenticated;
do $$ begin
  assert (select count(*) from public.company_member_details) = 1, 'employee sees others details';
  assert (select count(*) from public.company_member_details where user_id = auth.uid()) = 1, 'employee cannot see own details';
  assert (select count(*) from public.company_placements) = 1, 'employee cannot see own placement';
  assert (select count(*) from public.training_requests) = 0, 'employee sees requests';
  assert (select count(*) from public.company_training_profile) = 0, 'employee sees training profile';
  assert (select count(*) from storage.objects) = 0, 'employee sees request files';
  begin
    perform public.get_company_team('000000ca-0000-0000-0000-000000000000');
    raise exception 'TEST FAIL: employee read team';
  exception when insufficient_privilege then null; end;
  begin
    perform public.set_company_member_role('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c3','owner');
    raise exception 'TEST FAIL: employee escalated';
  exception when insufficient_privilege then null; end;
  begin
    perform public.set_my_trade('Welder');
    raise exception 'TEST FAIL: self trade while disabled';
  exception when insufficient_privilege then null; end;
  begin
    insert into public.training_requests (company_id, topic) values ('000000ca-0000-0000-0000-000000000000','x');
    raise exception 'TEST FAIL: employee created request';
  exception when insufficient_privilege then null; end;
  begin
    insert into storage.objects (bucket_id, name) values ('training-request-files','000000ca-0000-0000-0000-000000000000/x/y.pdf');
    raise exception 'TEST FAIL: employee uploaded';
  exception when insufficient_privilege then null; end;
end $$;
update public.company_member_details set contract_end = '2030-01-01', trade = 'Boss';
update public.training_requests set status = 'declined';
reset role;
do $$ begin
  assert (select count(*) from public.company_member_details where contract_end = '2030-01-01' or trade = 'Boss') = 0, 'employee edited details';
  assert (select status from public.training_requests where id='0000aa03-0000-0000-0000-000000000000') = 'new', 'employee changed request status';
end $$;

-- owner enables self-trade; employee can now set own trade only
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-0000000000c0","role":"authenticated"}',true);
set local role authenticated;
select public.manager_set_company_settings('000000ca-0000-0000-0000-000000000000', true);
update public.training_requests set status = 'quoted' where id = '0000aa03-0000-0000-0000-000000000000';
reset role;
do $$ begin
  assert (select status from public.training_requests where id='0000aa03-0000-0000-0000-000000000000') = 'new', 'owner changed request status';
end $$;
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-0000000000c3","role":"authenticated"}',true);
set local role authenticated;
select public.set_my_trade('Welder');
reset role;
do $$ begin
  assert (select trade from public.company_member_details where user_id='00000000-0000-0000-0000-0000000000c3') = 'Welder', 'self trade not saved';
  assert (select trade from public.company_member_details where user_id='00000000-0000-0000-0000-0000000000c4') = 'Millwright', 'self trade touched another row';
end $$;

-- ---------- 5. platform admin: everything, any company ----------
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-0000000000cf","role":"authenticated"}',true);
set local role authenticated;
do $$ begin
  assert (select count(*) from public.training_requests) = 2, 'platform admin request queue';
  assert (select count(*) from public.company_placements) = 2, 'platform admin placements';
  assert (select count(*) from public.company_training_profile) = 2, 'platform admin profiles';
  assert (select count(*) from storage.objects where bucket_id='training-request-files') = 1, 'platform admin files';
  assert jsonb_array_length(public.get_company_team('000000cb-0000-0000-0000-000000000000')) = 2, 'platform admin team';
  perform public.set_company_member_role('000000cb-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000d1','admin');
  begin
    perform public.set_company_member_role('000000cb-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000d0','employee');
    raise exception 'TEST FAIL: platform admin removed last owner';
  exception when insufficient_privilege then null; end;
end $$;
update public.training_requests set status = 'quoted', admin_notes = 'Quote sent' where id = '0000aa03-0000-0000-0000-000000000000';
reset role;
do $$ begin
  assert (select status from public.training_requests where id='0000aa03-0000-0000-0000-000000000000') = 'quoted', 'platform admin status change failed';
end $$;

-- ---------- 6. bulk invite extras applied on join; removal clears details ----------
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-0000000000c0","role":"authenticated"}',true);
set local role authenticated;
do $$ declare r jsonb; begin
  r := public.manager_create_invite('000000ca-0000-0000-0000-000000000000','v3-new@test.local');
  assert (r->>'success')::boolean, 'invite failed';
  assert (public.manager_set_invite_extras((r->>'invite_id')::uuid,'CNC Machinist','supervisor')->>'success')::boolean, 'extras failed';
  assert not (public.manager_set_invite_extras((r->>'invite_id')::uuid,'x','owner')->>'success')::boolean, 'invite granted owner';
  perform public.manager_remove_company_member('000000ca-0000-0000-0000-000000000000','00000000-0000-0000-0000-0000000000c4');
end $$;
reset role;
insert into auth.users (id, email, email_confirmed_at) values ('00000000-0000-0000-0000-0000000000c9','v3-new@test.local', now());
insert into public.profiles (id, email) values ('00000000-0000-0000-0000-0000000000c9','v3-new@test.local') on conflict (id) do nothing;
do $$ begin
  if not exists (select 1 from public.company_members where user_id='00000000-0000-0000-0000-0000000000c9') then
    perform public._claim_company_invites_for('00000000-0000-0000-0000-0000000000c9');
  end if;
  assert (select role from public.company_members where user_id='00000000-0000-0000-0000-0000000000c9') = 'supervisor', 'invite role not applied';
  assert (select trade from public.company_member_details where user_id='00000000-0000-0000-0000-0000000000c9') = 'CNC Machinist', 'invite trade not applied';
  assert not exists (select 1 from public.company_member_details where user_id='00000000-0000-0000-0000-0000000000c4'), 'details not cleared on removal';
end $$;

-- anon
select set_config('request.jwt.claims','',true);
set local role anon;
do $$ begin
  begin perform 1 from public.training_requests; raise exception 'TEST FAIL: anon reads requests'; exception when insufficient_privilege then null; end;
  begin perform 1 from public.company_member_details; raise exception 'TEST FAIL: anon reads details'; exception when insufficient_privilege then null; end;
  begin perform 1 from public.company_placements; raise exception 'TEST FAIL: anon reads placements'; exception when insufficient_privilege then null; end;
end $$;
reset role;

select 'ALL COMPANY ACCOUNTS V3 TESTS PASSED' as result;
rollback;
