-- Row Level Security: a parent can read/write their linked children's rows
-- (via parent_id); a student can only read/write their own rows.

create or replace function is_own_or_linked_profile(target_profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from profiles p
    where p.id = target_profile_id
      and (p.id = auth.uid() or p.parent_id = auth.uid())
  );
$$;

create or replace function is_own_or_linked_account(target_account_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from accounts a
    where a.id = target_account_id
      and is_own_or_linked_profile(a.profile_id)
  );
$$;

-- profiles ------------------------------------------------------------

alter table profiles enable row level security;

create policy profiles_select on profiles
  for select
  using (id = auth.uid() or parent_id = auth.uid());

-- A parent's own row is created via the normal signup path (id = auth.uid()).
-- Student rows are created exclusively by the trusted server-side path
-- (service_role, which bypasses RLS) once consent has been recorded.
create policy profiles_insert_self on profiles
  for insert
  with check (id = auth.uid() and parent_id is null);

create policy profiles_update on profiles
  for update
  using (id = auth.uid() or parent_id = auth.uid());

-- parental_consents -----------------------------------------------------

alter table parental_consents enable row level security;

create policy parental_consents_select on parental_consents
  for select
  using (parent_id = auth.uid());

create policy parental_consents_insert on parental_consents
  for insert
  with check (parent_id = auth.uid());

-- skills (public reference data, no user-writable policies) -------------

alter table skills enable row level security;

create policy skills_select on skills
  for select
  using (auth.role() in ('authenticated', 'service_role'));

-- skill_attempts (append-only) -------------------------------------------

alter table skill_attempts enable row level security;

create policy skill_attempts_select on skill_attempts
  for select
  using (is_own_or_linked_profile(profile_id));

create policy skill_attempts_insert on skill_attempts
  for insert
  with check (is_own_or_linked_profile(profile_id));

-- xp_events (append-only) ------------------------------------------------

alter table xp_events enable row level security;

create policy xp_events_select on xp_events
  for select
  using (is_own_or_linked_profile(profile_id));

create policy xp_events_insert on xp_events
  for insert
  with check (is_own_or_linked_profile(profile_id));

-- accounts ----------------------------------------------------------------

alter table accounts enable row level security;

create policy accounts_select on accounts
  for select
  using (is_own_or_linked_profile(profile_id));

create policy accounts_insert on accounts
  for insert
  with check (is_own_or_linked_profile(profile_id));

create policy accounts_update on accounts
  for update
  using (is_own_or_linked_profile(profile_id));

-- transactions --------------------------------------------------------------

alter table transactions enable row level security;

create policy transactions_select on transactions
  for select
  using (
    exists (
      select 1 from postings po
      where po.transaction_id = transactions.id
        and is_own_or_linked_account(po.account_id)
    )
  );

create policy transactions_insert on transactions
  for insert
  with check (created_by = auth.uid());

-- postings ------------------------------------------------------------------

alter table postings enable row level security;

create policy postings_select on postings
  for select
  using (is_own_or_linked_account(account_id));

create policy postings_insert on postings
  for insert
  with check (is_own_or_linked_account(account_id));

-- interview_sessions ----------------------------------------------------

alter table interview_sessions enable row level security;

create policy interview_sessions_select on interview_sessions
  for select
  using (is_own_or_linked_profile(profile_id));

create policy interview_sessions_insert on interview_sessions
  for insert
  with check (is_own_or_linked_profile(profile_id));

create policy interview_sessions_update on interview_sessions
  for update
  using (is_own_or_linked_profile(profile_id));
