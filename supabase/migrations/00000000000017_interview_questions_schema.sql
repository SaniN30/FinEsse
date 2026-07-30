-- Phase 5: AI Interview Coach -- question bank.
--
-- `interview_questions` is shared reference content, same posture as
-- `skills`/`lessons`/`roles`: authored by service_role, read-only for
-- students once published. Not tier-gated (interview prep applies across
-- School/College) so there is no join to `profiles.tier` here, unlike
-- lessons/quizzes/modeling_exercises.
create table interview_questions (
  id uuid primary key default gen_random_uuid(),
  firm_style text not null,
  question_text text not null,
  category text not null check (category in ('behavioral', 'technical')),
  published boolean not null default true,
  created_at timestamptz not null default now()
);

create index idx_interview_questions_firm_style on interview_questions (firm_style);
