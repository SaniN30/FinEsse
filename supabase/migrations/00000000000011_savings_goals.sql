-- Phase 3: Pocket Money Planner -- savings goals on top of the existing
-- accounts/transactions/postings ledger (see BACKEND.md). Backend/data only.
--
-- Per the consumer-research finding already reflected in Phase 1/2's
-- parent-visibility model ("parents get visibility, not control/veto, over
-- the student's own savings-goal money"), deposits and withdrawals are
-- authorized by the student alone -- there is no parent-approval gate here.

alter table accounts
  add column target_amount_cents bigint check (target_amount_cents > 0);

comment on column accounts.target_amount_cents is
  'Only meaningful for accounts.type = ''savings_goal''; null for wallets.';

-- Current balance is always derived by summing that account's postings --
-- no redundant stored balance column that could drift from the ledger.
--
-- security_invoker = true is required: migrations run as the `postgres`
-- role, which has BYPASSRLS in Supabase. Without it, these views would run
-- with the owner's (postgres') privileges and silently bypass the
-- accounts/postings RLS policies, leaking every account to every caller --
-- the opposite of quiz_questions_public's deliberate owner-bypass pattern.
create view account_balances
with (security_invoker = true)
as
select
  a.id as account_id,
  a.profile_id,
  a.type,
  a.name,
  a.target_amount_cents,
  coalesce(sum(p.amount_cents), 0) as balance_cents
from accounts a
left join postings p on p.account_id = a.id
group by a.id, a.profile_id, a.type, a.name, a.target_amount_cents;

-- Progress view for savings goals: balance + percent-to-goal, derived on
-- read from the ledger, same "never store what can be computed" principle
-- as skill_mastery (Phase 1) and total XP (Phase 1).
create view savings_goal_progress
with (security_invoker = true)
as
select
  account_id,
  profile_id,
  name,
  target_amount_cents,
  balance_cents,
  case
    when target_amount_cents is null or target_amount_cents = 0 then null
    else round(
      least(balance_cents::numeric, target_amount_cents::numeric)
        / target_amount_cents::numeric * 100,
      2
    )
  end as percent_complete
from account_balances
where type = 'savings_goal';

-- Resolves (creating if necessary) the calling student's student_wallet
-- account. There is no other path that provisions a wallet today, so both
-- deposit and withdraw need to be able to lazily create one.
create or replace function get_or_create_student_wallet(p_profile_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
begin
  perform pg_advisory_xact_lock(hashtextextended('student_wallet:' || p_profile_id::text, 0));

  select id into v_account_id
  from accounts
  where profile_id = p_profile_id and type = 'student_wallet'
  limit 1;

  if v_account_id is null then
    insert into accounts (profile_id, type, name)
    values (p_profile_id, 'student_wallet', 'Pocket Money')
    returning id into v_account_id;
  end if;

  return v_account_id;
end;
$$;

revoke execute on function get_or_create_student_wallet(uuid) from public;

-- create_savings_goal(name, target_amount_cents) -> the new account id.
-- Opens an accounts row of type='savings_goal' for the calling student.
create or replace function create_savings_goal(p_name text, p_target_amount_cents bigint)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile_id uuid := auth.uid();
  v_account_id uuid;
begin
  if v_profile_id is null then
    raise exception 'not authenticated';
  end if;

  if p_target_amount_cents is null or p_target_amount_cents <= 0 then
    raise exception 'target_amount_cents must be positive';
  end if;

  insert into accounts (profile_id, type, name, target_amount_cents)
  values (v_profile_id, 'savings_goal', p_name, p_target_amount_cents)
  returning id into v_account_id;

  return v_account_id;
end;
$$;

revoke execute on function create_savings_goal(text, bigint) from public;
grant execute on function create_savings_goal(text, bigint) to authenticated;

-- deposit_to_savings_goal(goal_account_id, amount_cents, description) ->
-- posts a balanced transaction moving funds from the student's own
-- student_wallet into their own savings_goal account. Identifies the
-- student from auth.uid(), never a client-supplied profile_id, and verifies
-- the goal account actually belongs to that student -- a student cannot
-- deposit into another student's goal.
create or replace function deposit_to_savings_goal(
  p_goal_account_id uuid,
  p_amount_cents bigint,
  p_description text default 'Deposit to savings goal'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile_id uuid := auth.uid();
  v_wallet_account_id uuid;
  v_transaction_id uuid;
begin
  if v_profile_id is null then
    raise exception 'not authenticated';
  end if;

  if p_amount_cents is null or p_amount_cents <= 0 then
    raise exception 'amount_cents must be positive';
  end if;

  if not exists (
    select 1 from accounts
    where id = p_goal_account_id
      and profile_id = v_profile_id
      and type = 'savings_goal'
  ) then
    raise exception 'savings goal % not found for caller', p_goal_account_id;
  end if;

  v_wallet_account_id := get_or_create_student_wallet(v_profile_id);

  insert into transactions (description, created_by)
  values (p_description, v_profile_id)
  returning id into v_transaction_id;

  insert into postings (transaction_id, account_id, amount_cents)
  values
    (v_transaction_id, v_wallet_account_id, -p_amount_cents),
    (v_transaction_id, p_goal_account_id, p_amount_cents);

  return v_transaction_id;
end;
$$;

revoke execute on function deposit_to_savings_goal(uuid, bigint, text) from public;
grant execute on function deposit_to_savings_goal(uuid, bigint, text) to authenticated;

-- withdraw_from_savings_goal(goal_account_id, amount_cents, description) ->
-- posts a balanced transaction moving funds back from the goal into the
-- student's wallet. This is the student's own autonomy zone ("my choice")
-- per the plan's Tone & Trust Principles -- authorized by the student
-- alone, not gated behind parent approval.
create or replace function withdraw_from_savings_goal(
  p_goal_account_id uuid,
  p_amount_cents bigint,
  p_description text default 'Withdrawal from savings goal'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile_id uuid := auth.uid();
  v_wallet_account_id uuid;
  v_transaction_id uuid;
  v_balance_cents bigint;
begin
  if v_profile_id is null then
    raise exception 'not authenticated';
  end if;

  if p_amount_cents is null or p_amount_cents <= 0 then
    raise exception 'amount_cents must be positive';
  end if;

  if not exists (
    select 1 from accounts
    where id = p_goal_account_id
      and profile_id = v_profile_id
      and type = 'savings_goal'
  ) then
    raise exception 'savings goal % not found for caller', p_goal_account_id;
  end if;

  perform pg_advisory_xact_lock(hashtextextended('savings_goal:' || p_goal_account_id::text, 0));

  select coalesce(sum(amount_cents), 0) into v_balance_cents
  from postings
  where account_id = p_goal_account_id;

  if v_balance_cents < p_amount_cents then
    raise exception 'insufficient savings goal balance: have %, requested %',
      v_balance_cents, p_amount_cents;
  end if;

  v_wallet_account_id := get_or_create_student_wallet(v_profile_id);

  insert into transactions (description, created_by)
  values (p_description, v_profile_id)
  returning id into v_transaction_id;

  insert into postings (transaction_id, account_id, amount_cents)
  values
    (v_transaction_id, p_goal_account_id, -p_amount_cents),
    (v_transaction_id, v_wallet_account_id, p_amount_cents);

  return v_transaction_id;
end;
$$;

revoke execute on function withdraw_from_savings_goal(uuid, bigint, text) from public;
grant execute on function withdraw_from_savings_goal(uuid, bigint, text) to authenticated;

-- account_balances / savings_goal_progress: security_invoker views, so
-- they run with the querying user's own privileges -- a caller only ever
-- sees rows for accounts they can already see via
-- is_own_or_linked_profile/is_own_or_linked_account through the base
-- accounts/postings RLS policies.
grant select on account_balances to authenticated;
grant select on savings_goal_progress to authenticated;
