-- Phase 2: School-tier lesson/quiz content schema.
--
-- Lessons and quizzes are shared reference content (not per-student rows),
-- analogous to `skills`. `quiz_attempts` is the per-student append-only log
-- that auto-grading writes to -- mirroring the `skill_attempts`/`xp_events`
-- pattern from Phase 1 (score is always computed server-side, never trusted
-- from the client; see the grading function in a later migration).

create table lessons (
  id uuid primary key default gen_random_uuid(),
  skill_id uuid not null references skills (id) on delete cascade,
  content_type text not null check (content_type in ('article', 'video', 'interactive')),
  content_url text,
  content_body text,
  order_index integer not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  constraint lessons_has_content check (content_url is not null or content_body is not null)
);

create index idx_lessons_skill on lessons (skill_id);

create table quizzes (
  id uuid primary key default gen_random_uuid(),
  skill_id uuid references skills (id) on delete cascade,
  lesson_id uuid references lessons (id) on delete cascade,
  title text not null,
  pass_threshold numeric not null default 0.8 check (pass_threshold between 0 and 1),
  published boolean not null default true,
  created_at timestamptz not null default now(),
  constraint quizzes_belongs_to_skill_or_lesson check (
    skill_id is not null or lesson_id is not null
  )
);

create index idx_quizzes_skill on quizzes (skill_id);
create index idx_quizzes_lesson on quizzes (lesson_id);

-- Resolves a quiz to the skill it should award mastery/XP against, whether
-- the quiz is attached directly to a skill or to one of that skill's lessons.
create or replace function quiz_skill_id(p_quiz_id uuid)
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(q.skill_id, l.skill_id)
  from quizzes q
  left join lessons l on l.id = q.lesson_id
  where q.id = p_quiz_id;
$$;

create table quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references quizzes (id) on delete cascade,
  question text not null,
  options jsonb not null,
  correct_answer text not null,
  order_index integer not null default 0,
  created_at timestamptz not null default now()
);

create index idx_quiz_questions_quiz on quiz_questions (quiz_id);

-- Correct answers must never be readable by students directly (RLS on
-- quiz_questions denies select entirely to regular clients -- see the RLS
-- migration). This view is owned by the migration role and deliberately has
-- no `security_invoker`, so it reads through as the view owner and can
-- expose the question/options columns without also exposing
-- `correct_answer`, which only the grading function ever reads.
create view quiz_questions_public as
  select id, quiz_id, question, options, order_index
  from quiz_questions;

create table quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles (id) on delete cascade,
  quiz_id uuid not null references quizzes (id) on delete cascade,
  score numeric not null check (score between 0 and 1),
  passed boolean not null,
  answers jsonb not null,
  attempted_at timestamptz not null default now()
);

create index idx_quiz_attempts_profile on quiz_attempts (profile_id);
create index idx_quiz_attempts_quiz on quiz_attempts (quiz_id);

-- 'quiz_attempt' joins the existing xp_events sources so a passing quiz can
-- award XP through the same append-only ledger as skill attempts.
alter table xp_events drop constraint xp_events_source_check;
alter table xp_events add constraint xp_events_source_check
  check (source in ('skill_attempt', 'interview_session', 'bonus', 'quiz_attempt'));
