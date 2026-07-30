-- Phase 3 RLS: parents get visibility, not control, over a child's ledger.
--
-- The Phase 1 accounts/transactions/postings policies (migration 005) used
-- is_own_or_linked_profile/is_own_or_linked_account for both select AND
-- write, which let a parent directly write into a linked child's accounts
-- (e.g. open or rename a savings goal on the child's behalf, or post
-- transactions against it) -- undermining the "student's own autonomy
-- zone" invariant the savings-goal RPCs enforce. Writes are tightened to
-- self-only; the security-definer RPCs in the previous migration remain
-- the only way anyone (including the student) creates/moves savings-goal
-- funds, and they already check profile_id = auth.uid() internally.
-- Read access for parents is unchanged.

drop policy accounts_insert on accounts;
create policy accounts_insert on accounts
  for insert
  with check (profile_id = auth.uid());

drop policy accounts_update on accounts;
create policy accounts_update on accounts
  for update
  using (profile_id = auth.uid());

-- transactions_insert was already created_by = auth.uid() (self-only); no
-- change needed there.

drop policy postings_insert on postings;
create policy postings_insert on postings
  for insert
  with check (
    is_own_or_linked_account(account_id)
    and exists (
      select 1 from accounts a
      where a.id = postings.account_id and a.profile_id = auth.uid()
    )
  );
