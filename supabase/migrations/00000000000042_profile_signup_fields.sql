-- Extends the parent signup flow (the only flow that collects real contact
-- info -- students get a synthetic internal email by design, see
-- create-student-account) with date of birth, education level, institution
-- name, and phone number. `date_of_birth` already existed on `profiles`
-- (added in 00000000000001 for student COPPA record-keeping); it's reused
-- here for the parent's own profile rather than duplicated under a new name.
--
-- Email is already required and globally unique via Supabase Auth
-- (auth.users.email), so no additional column or dedup is needed for it.
--
-- No RLS changes: the existing profiles_select/profiles_update policies
-- (id = auth.uid() or parent_id = auth.uid()) already cover these new
-- columns row-wise, so a parent still can't see another family's data.

alter table profiles
  add column if not exists education_level text
    check (education_level in ('school', 'college', 'working_professional')),
  add column if not exists institution_name text,
  add column if not exists phone_number text;

create unique index if not exists idx_profiles_phone_number_unique
  on profiles (phone_number)
  where phone_number is not null;

-- Lets the signup form check phone-number availability before creating an
-- auth user (avoiding an orphaned auth account on a duplicate phone),
-- without exposing which profile owns it -- RLS on `profiles` otherwise
-- hides every other user's row entirely, including existence.
create or replace function is_phone_number_taken(candidate text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from profiles where phone_number = candidate
  );
$$;

grant execute on function is_phone_number_taken(text) to anon, authenticated;
