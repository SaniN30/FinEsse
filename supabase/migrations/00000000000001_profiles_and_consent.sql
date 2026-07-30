-- Profiles + COPPA/GDPR-K parental consent records.
--
-- Design: a parent signs up via Supabase Auth normally and gets a `profiles`
-- row with role='parent'. A student never gets their own email/password
-- account with independent sign-up; a parent creates the child's linked
-- login only after recording an explicit, separate consent (parental_consents),
-- and only a trusted server-side path (service_role) is expected to insert
-- student profiles. The trigger below makes that a hard DB-level invariant,
-- not just an application convention, so it holds even against a direct
-- SQL insert.

create extension if not exists "pgcrypto";

create table parental_consents (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid not null,
  child_display_name text not null,
  consent_given boolean not null default false,
  consent_version text not null,
  consented_at timestamptz,
  created_at timestamptz not null default now()
);

create table profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role text not null check (role in ('parent', 'student')),
  parent_id uuid references profiles (id) on delete cascade,
  tier text not null default 'school' check (tier in ('school', 'college', 'job_ready')),
  display_name text not null,
  -- Date of birth is collected only for COPPA age/consent record-keeping
  -- (data minimization: no other demographic fields are collected here).
  date_of_birth date,
  consent_id uuid references parental_consents (id),
  data_retention_requested_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_student_has_parent check (
    role = 'parent' or parent_id is not null
  )
);

alter table parental_consents
  add constraint parental_consents_parent_id_fkey
  foreign key (parent_id) references profiles (id) on delete cascade;

create index idx_profiles_parent_id on profiles (parent_id);
create index idx_parental_consents_parent_id on parental_consents (parent_id);

create or replace function enforce_student_consent()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_consent parental_consents%rowtype;
begin
  if new.role = 'student' then
    if new.parent_id is null then
      raise exception 'student profile requires parent_id';
    end if;

    if new.consent_id is null then
      raise exception 'student profile requires a recorded parental consent';
    end if;

    select * into v_consent from parental_consents where id = new.consent_id;

    if not found then
      raise exception 'consent record % not found', new.consent_id;
    end if;

    if v_consent.parent_id <> new.parent_id then
      raise exception 'consent record does not belong to this parent';
    end if;

    if v_consent.consent_given is not true then
      raise exception 'parental consent has not been explicitly given';
    end if;
  end if;

  return new;
end;
$$;

create trigger trg_enforce_student_consent
  before insert or update on profiles
  for each row execute function enforce_student_consent();

-- Identity fields (role, parent_id, consent_id) are only mutable by the
-- trusted server-side path (service_role); regular users may update their
-- own display fields but not re-parent or re-consent themselves.
create or replace function lock_profile_identity_fields()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() = 'service_role' then
    return new;
  end if;

  if new.role is distinct from old.role
    or new.parent_id is distinct from old.parent_id
    or new.consent_id is distinct from old.consent_id then
    raise exception 'role, parent_id, and consent_id can only be changed by the server';
  end if;

  return new;
end;
$$;

create trigger trg_lock_profile_identity_fields
  before update on profiles
  for each row execute function lock_profile_identity_fields();
