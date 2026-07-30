-- Phase 4: College-tier content schema.
--
-- Two genuinely new concepts on top of the existing Phase 2 lesson/quiz
-- pattern (reused as-is for College lessons/quizzes -- see seed migration):
--
-- 1. `roles` -- shared reference content (like `skills`/`lessons`), not
--    per-student rows. Finance role cards for the plan's "Role Explorer"
--    feature.
-- 2. `modeling_exercises` / `modeling_submissions` -- a guided financial-
--    modeling exercise belongs to a skill and carries a structured rubric;
--    submissions are an append-only per-student log, mirroring the
--    quiz_attempts pattern (score always computed server-side, see the
--    grading RPC in a later migration -- never trusted from the client).

create table roles (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text not null,
  typical_pay_range text not null,
  required_skill_ids uuid[] not null default '{}',
  published boolean not null default true,
  created_at timestamptz not null default now()
);

create table modeling_exercises (
  id uuid primary key default gen_random_uuid(),
  skill_id uuid not null references skills (id) on delete cascade,
  title text not null,
  instructions text not null,
  -- Rubric: jsonb keyed by cell/metric name, e.g.
  -- {"revenue_growth_pct": {"expected": 12.5, "tolerance": 0.5}, ...}.
  -- Read only by the grading RPC below -- never exposed with the expected
  -- values readable directly by students (see RLS migration).
  rubric jsonb not null,
  pass_threshold numeric not null default 0.8 check (pass_threshold between 0 and 1),
  published boolean not null default true,
  created_at timestamptz not null default now()
);

create index idx_modeling_exercises_skill on modeling_exercises (skill_id);

create table modeling_submissions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles (id) on delete cascade,
  exercise_id uuid not null references modeling_exercises (id) on delete cascade,
  submitted_values jsonb not null,
  score numeric not null check (score between 0 and 1),
  passed boolean not null,
  submitted_at timestamptz not null default now()
);

create index idx_modeling_submissions_profile on modeling_submissions (profile_id);
create index idx_modeling_submissions_exercise on modeling_submissions (exercise_id);

-- 'modeling_submission' joins the existing xp_events sources so a passing
-- modeling exercise can award XP through the same append-only ledger as
-- skill attempts and quiz attempts.
alter table xp_events drop constraint xp_events_source_check;
alter table xp_events add constraint xp_events_source_check
  check (source in ('skill_attempt', 'interview_session', 'bonus', 'quiz_attempt', 'modeling_submission'));
