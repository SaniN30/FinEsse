create table interview_sessions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles (id) on delete cascade,
  firm_style text not null,
  transcript jsonb not null default '[]'::jsonb,
  rubric_scores jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_interview_sessions_profile on interview_sessions (profile_id);
