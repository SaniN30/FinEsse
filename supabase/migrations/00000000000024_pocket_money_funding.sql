-- Fixes the Pocket Money Planner's two structural gaps documented in the
-- product gap audit:
--
-- 1. deposit_to_savings_goal (migration 011) never checked the student's
--    wallet balance before moving money out of it, so a deposit always
--    succeeded and could drive the wallet arbitrarily negative. This adds
--    the same balance guard withdraw_from_savings_goal already has.
-- 2. Nothing anywhere ever funded a student_wallet -- accounts.type
--    anticipates a 'parent_wallet' (migration 003) but no RPC ever
--    created, credited, or transferred from one. fund_student_wallet below
--    is that missing mechanism: a parent-gated RPC that posts a balanced
--    transaction crediting the linked student's wallet from a
--    lazily-created parent_wallet account, following the same
--    security definer + explicit ownership-check pattern as every other
--    RPC in this file (see is_own_or_linked_profile, migration 005) rather
--    than relying on RLS (security definer functions run as the owner,
--    which has BYPASSRLS in Supabase).

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
  v_wallet_balance_cents bigint;
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

  perform pg_advisory_xact_lock(hashtextextended('student_wallet:' || v_profile_id::text, 0));

  select coalesce(sum(amount_cents), 0) into v_wallet_balance_cents
  from postings
  where account_id = v_wallet_account_id;

  if v_wallet_balance_cents < p_amount_cents then
    raise exception 'insufficient wallet balance: have %, requested %',
      v_wallet_balance_cents, p_amount_cents;
  end if;

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

-- Resolves (creating if necessary) a parent's own parent_wallet account.
-- Mirrors get_or_create_student_wallet's lazy-create pattern.
create or replace function get_or_create_parent_wallet(p_profile_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
begin
  perform pg_advisory_xact_lock(hashtextextended('parent_wallet:' || p_profile_id::text, 0));

  select id into v_account_id
  from accounts
  where profile_id = p_profile_id and type = 'parent_wallet'
  limit 1;

  if v_account_id is null then
    insert into accounts (profile_id, type, name)
    values (p_profile_id, 'parent_wallet', 'Family Pocket Money')
    returning id into v_account_id;
  end if;

  return v_account_id;
end;
$$;

revoke execute on function get_or_create_parent_wallet(uuid) from public;

-- fund_student_wallet(student_profile_id, amount_cents, description) ->
-- posts a balanced transaction crediting a linked student's wallet from
-- the calling parent's own parent_wallet. This is the "add allowance"
-- action: it is the only path anywhere that puts real (virtual) money into
-- the system in the first place. Gated the same way parent-scoped access
-- is gated elsewhere (is_own_or_linked_profile, migration 005) -- the
-- caller must be authenticated and must be the parent_id of the target
-- profile (a parent cannot fund their own wallet as if it were a student's,
-- and a student cannot call this at all since they have no linked
-- children).
create or replace function fund_student_wallet(
  p_student_profile_id uuid,
  p_amount_cents bigint,
  p_description text default 'Allowance from parent'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_parent_id uuid := auth.uid();
  v_parent_wallet_account_id uuid;
  v_student_wallet_account_id uuid;
  v_transaction_id uuid;
begin
  if v_parent_id is null then
    raise exception 'not authenticated';
  end if;

  if p_amount_cents is null or p_amount_cents <= 0 then
    raise exception 'amount_cents must be positive';
  end if;

  if not exists (
    select 1 from profiles
    where id = p_student_profile_id
      and parent_id = v_parent_id
      and role = 'student'
  ) then
    raise exception 'student profile % is not linked to caller', p_student_profile_id;
  end if;

  v_parent_wallet_account_id := get_or_create_parent_wallet(v_parent_id);
  v_student_wallet_account_id := get_or_create_student_wallet(p_student_profile_id);

  insert into transactions (description, created_by)
  values (p_description, v_parent_id)
  returning id into v_transaction_id;

  -- The parent_wallet side is allowed to go negative -- it is a virtual
  -- ledger of how much a parent has given, not a funded external account;
  -- there is no real money to run out of.
  insert into postings (transaction_id, account_id, amount_cents)
  values
    (v_transaction_id, v_parent_wallet_account_id, -p_amount_cents),
    (v_transaction_id, v_student_wallet_account_id, p_amount_cents);

  return v_transaction_id;
end;
$$;

revoke execute on function fund_student_wallet(uuid, bigint, text) from public;
grant execute on function fund_student_wallet(uuid, bigint, text) to authenticated;
