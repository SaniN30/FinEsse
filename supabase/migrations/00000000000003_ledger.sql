-- Simulated double-entry ledger for the pocket-money planner.
-- Virtual/practice money only -- no real banking integration.

create table accounts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles (id) on delete cascade,
  type text not null check (type in ('student_wallet', 'parent_wallet', 'savings_goal')),
  name text not null,
  created_at timestamptz not null default now()
);

create index idx_accounts_profile on accounts (profile_id);

create table transactions (
  id uuid primary key default gen_random_uuid(),
  description text not null,
  created_by uuid not null references profiles (id),
  created_at timestamptz not null default now()
);

create index idx_transactions_created_by on transactions (created_by);

create table postings (
  id uuid primary key default gen_random_uuid(),
  transaction_id uuid not null references transactions (id) on delete cascade,
  account_id uuid not null references accounts (id) on delete cascade,
  amount_cents bigint not null check (amount_cents <> 0),
  created_at timestamptz not null default now()
);

create index idx_postings_transaction on postings (transaction_id);
create index idx_postings_account on postings (account_id);

-- Postings for a transaction must net to zero. This is a deferred constraint
-- trigger (checked at COMMIT, not per-row) so that the several postings that
-- make up one transaction can be inserted across multiple statements within
-- the same transaction before the balance is validated.
create or replace function check_postings_balance()
returns trigger
language plpgsql
as $$
declare
  v_transaction_id uuid;
  v_sum bigint;
begin
  v_transaction_id := coalesce(new.transaction_id, old.transaction_id);

  select coalesce(sum(amount_cents), 0)
    into v_sum
    from postings
    where transaction_id = v_transaction_id;

  if v_sum <> 0 then
    raise exception 'postings for transaction % do not net to zero (sum=%)',
      v_transaction_id, v_sum;
  end if;

  return null;
end;
$$;

create constraint trigger trg_postings_balance
  after insert or update or delete on postings
  deferrable initially deferred
  for each row execute function check_postings_balance();
