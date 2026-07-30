-- Mastery graph (Khan Academy style skill-by-skill unlock) + append-only XP log.
-- XP totals are always derived by summing xp_events, never stored as a column.

create table skills (
  id uuid primary key default gen_random_uuid(),
  tier text not null check (tier in ('school', 'college', 'job_ready')),
  slug text not null unique,
  title text not null,
  prerequisite_skill_id uuid references skills (id),
  mastery_threshold numeric not null default 0.8 check (mastery_threshold between 0 and 1),
  created_at timestamptz not null default now()
);

create table skill_attempts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles (id) on delete cascade,
  skill_id uuid not null references skills (id) on delete cascade,
  is_correct boolean not null,
  attempted_at timestamptz not null default now()
);

create index idx_skill_attempts_profile on skill_attempts (profile_id);
create index idx_skill_attempts_profile_skill on skill_attempts (profile_id, skill_id);

create table xp_events (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles (id) on delete cascade,
  source text not null check (source in ('skill_attempt', 'interview_session', 'bonus')),
  source_id uuid,
  xp_delta integer not null check (xp_delta >= 0),
  created_at timestamptz not null default now()
);

create index idx_xp_events_profile on xp_events (profile_id);

-- Rolling accuracy over each profile's last 10 attempts per skill, used to
-- decide whether the next skill in the graph unlocks. Kept as a view (not
-- stored state) so mastery is always derived from the append-only log.
create view skill_mastery as
with recent as (
  select
    profile_id,
    skill_id,
    is_correct,
    row_number() over (
      partition by profile_id, skill_id order by attempted_at desc
    ) as rn
  from skill_attempts
)
select
  profile_id,
  skill_id,
  count(*) as attempts_considered,
  avg(case when is_correct then 1 else 0 end)::numeric as rolling_accuracy
from recent
where rn <= 10
group by profile_id, skill_id;
