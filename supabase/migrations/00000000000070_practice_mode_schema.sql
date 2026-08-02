-- Practice mode: free-browse question bank spanning quiz_questions and
-- interview_questions, independent of the guided lesson flow.
--
-- Deliberately built only on schema that is actually live today. Three
-- other, already-merged-to-main migrations in this repo's history
-- (00000000000043_quiz_case_study_badges_schema.sql, 00000000000045_seed_
-- jobready_case_studies.sql, 00000000000046_interview_questions_difficulty_
-- and_guides.sql) were never applied to the live database -- see AGENTS.md's
-- "Job-Ready quality/depth pass" and "College-tier content depth pass 2"
-- sections for how a live migration-numbering collision (version 043 was
-- claimed live by an unrelated, unmerged sticky-notes migration) left them
-- stuck, and a separate task lane is reconciling that. This migration does
-- not depend on `quizzes.quiz_type`/`scenario_body`/`context_tag` or
-- `interview_questions.improvement_guide` (none of which exist live yet) --
-- only on `quiz_questions.difficulty`/`question_type`/`grading_keywords`/
-- `min_keyword_matches`/`scenario_context` and `interview_questions.
-- difficulty`, all added by the already-live College depth-pass-2 migration
-- (00000000000046_college_depth_schema_extensions.sql).
--
-- `practice_attempts` is a new, standalone table -- practice grading never
-- writes to `quiz_attempts`, `skill_attempts`, `xp_events`, or
-- `profile_badges`, so free practice cannot affect lesson completion,
-- mastery, XP, or badge state.

create table practice_attempts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles (id) on delete cascade,
  question_id uuid not null,
  tier text not null check (tier in ('school', 'college', 'job_ready')),
  question_type text not null check (question_type in ('multiple_choice', 'free_response')),
  is_correct boolean not null,
  submitted_answer text,
  attempted_at timestamptz not null default now()
);

create index idx_practice_attempts_profile on practice_attempts (profile_id);
create index idx_practice_attempts_question on practice_attempts (question_id);

alter table practice_attempts enable row level security;

create policy practice_attempts_select on practice_attempts
  for select
  using (is_own_or_linked_profile(profile_id));

-- No insert policy for `authenticated`: rows are only ever written by
-- grade_practice_attempt(), a security-definer function that runs as the
-- table owner, same "visibility not control" posture as quiz_attempts.

-- Cross-source practice question bank. Runs as the view owner (postgres),
-- same pattern as quiz_questions_public/modeling_exercises_public, so it can
-- read across every tier regardless of the caller's own profile tier --
-- filtering to "content appropriate to their tier" is a client-side default,
-- not an RLS restriction, consistent with how quiz_questions_public already
-- behaves. Never exposes correct_answer/grading_keywords.
create view practice_questions as
select
  qq.id,
  'quiz'::text as source,
  s.tier,
  s.slug as topic_slug,
  s.title as topic_title,
  qq.difficulty,
  qq.question_type,
  qq.question,
  qq.options,
  qq.scenario_context,
  (qq.scenario_context is not null) as is_case_study,
  qq.quiz_id as ref_id
from quiz_questions_public qq
join quizzes qz on qz.id = qq.quiz_id
join skills s on s.id = coalesce(qz.skill_id, (select l.skill_id from lessons l where l.id = qz.lesson_id))
where qz.published
union all
select
  iq.id,
  'interview'::text as source,
  'job_ready'::text as tier,
  iq.category as topic_slug,
  iq.firm_style as topic_title,
  iq.difficulty,
  'free_response'::text as question_type,
  iq.question_text as question,
  null::jsonb as options,
  null::text as scenario_context,
  false as is_case_study,
  null::uuid as ref_id
from interview_questions iq
where iq.published;

alter view practice_questions owner to postgres;
grant select on practice_questions to authenticated;

-- Grades one question in isolation (no quiz-level pass/fail, no XP, no
-- badges) using the same deterministic keyword-match / exact-match logic as
-- grade_quiz_attempt, then logs the attempt to practice_attempts only.
create or replace function grade_practice_attempt(p_question_id uuid, p_answer text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile_id uuid := auth.uid();
  v_tier text;
  v_question_type text;
  v_correct_answer text;
  v_grading_keywords jsonb;
  v_min_matches integer;
  v_is_correct boolean;
  v_attempt_id uuid;
begin
  if v_profile_id is null then
    raise exception 'not authenticated';
  end if;

  select
    qq.question_type,
    qq.correct_answer,
    qq.grading_keywords,
    qq.min_keyword_matches,
    s.tier
  into v_question_type, v_correct_answer, v_grading_keywords, v_min_matches, v_tier
  from quiz_questions qq
  join quizzes qz on qz.id = qq.quiz_id
  join skills s on s.id = coalesce(qz.skill_id, (select l.skill_id from lessons l where l.id = qz.lesson_id))
  where qq.id = p_question_id and qz.published;

  if not found then
    raise exception 'practice question % not found or not published', p_question_id;
  end if;

  if v_question_type = 'free_response' then
    v_is_correct := (
      select count(*)
      from jsonb_array_elements_text(coalesce(v_grading_keywords, '[]'::jsonb)) kw
      where position(lower(kw) in lower(coalesce(p_answer, ''))) > 0
    ) >= coalesce(v_min_matches, 1);
  else
    v_is_correct := (v_correct_answer = p_answer);
  end if;

  insert into practice_attempts (profile_id, question_id, tier, question_type, is_correct, submitted_answer)
  values (v_profile_id, p_question_id, v_tier, v_question_type, v_is_correct, p_answer)
  returning id into v_attempt_id;

  return jsonb_build_object(
    'attempt_id', v_attempt_id,
    'question_id', p_question_id,
    'is_correct', v_is_correct
  );
end;
$$;

revoke execute on function grade_practice_attempt(uuid, text) from public;
grant execute on function grade_practice_attempt(uuid, text) to authenticated;
