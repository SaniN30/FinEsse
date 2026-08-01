-- Sticky note widget (note-taking only -- no reminder/alarm scheduling, that
-- part of the original idea is explicitly out of scope). Notes are a purely
-- personal scratchpad: unlike skill_attempts/xp_events, a parent has no
-- reason to read a student's notes (or vice versa), so this intentionally
-- uses a plain profile_id = auth.uid() check rather than
-- is_own_or_linked_profile (migration 005) -- self-only, not "own or linked".
--
-- position_x/position_y/width/height are the widget's on-screen geometry in
-- pixels, persisted so a dragged/resized note reopens where it was left.
-- source is a lightweight label of where the note was created (route path,
-- or a lesson/page title when one is available) -- captured once at create
-- time, never re-derived.

create table sticky_notes (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id) on delete cascade,
  content text not null default '',
  source text not null,
  position_x double precision not null default 24,
  position_y double precision not null default 24,
  width double precision not null default 240,
  height double precision not null default 220,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_sticky_notes_profile_id on sticky_notes (profile_id);

alter table sticky_notes enable row level security;

create policy sticky_notes_select on sticky_notes
  for select
  using (profile_id = auth.uid());

create policy sticky_notes_insert on sticky_notes
  for insert
  with check (profile_id = auth.uid());

create policy sticky_notes_update on sticky_notes
  for update
  using (profile_id = auth.uid())
  with check (profile_id = auth.uid());

create policy sticky_notes_delete on sticky_notes
  for delete
  using (profile_id = auth.uid());
