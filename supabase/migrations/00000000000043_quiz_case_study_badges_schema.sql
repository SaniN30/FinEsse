-- Job-Ready content depth follow-up, schema pass. Three additive changes,
-- all documented here rather than split across migrations since they touch
-- the same grading path:
--
-- 1. `difficulty` ('easy'|'medium'|'hard') on `quiz_questions` and (see the
--    later interview-questions migration) `interview_questions`, so every
--    question in the app carries a difficulty label. Existing rows default
--    to 'medium' (a reasonable prior for the School/College content this
--    migration doesn't hand-tag); the Job-Ready quiz-expansion and
--    case-study migrations that follow this one explicitly set real
--    easy/medium/hard values on the new rows they add.
--
-- 2. Case-study support on `quiz_questions`/`quizzes`: `question_type`
--    ('multiple_choice' default | 'free_response'), `keywords` (jsonb array
--    of acceptable answer terms, free_response only, never exposed to
--    students -- same hidden-from-`quiz_questions_public` treatment as
--    `correct_answer`), and `quizzes.scenario_body`/`context_tag`/`quiz_type`
--    ('standard' default | 'case_study') so a case-study quiz can show a
--    scenario once and tag where it's drawn from. `options`/`correct_answer`
--    become nullable (still required for `multiple_choice`, enforced by
--    `quiz_questions_type_shape`) since a free_response question has
--    neither.
--
-- 3. Milestone badges: `badges` (reference content, same posture as
--    `skills`/`roles`) + `profile_badges` (append-only per-profile award
--    log, "visibility not control" RLS like `quiz_attempts`) +
--    `award_badge()` (security definer, idempotent via `on conflict do
--    nothing`, silently no-ops on an unknown slug so seeding order never
--    matters). `grade_quiz_attempt` is extended to award the Job-Ready
--    lesson/quiz/tier badges; the interview-coach Edge Function awards the
--    fourth (first mock interview) separately since scoring happens there,
--    not in Postgres.
--
-- Scope note: this pass is written for Job-Ready (this branch's remit), but
-- the schema itself is tier-agnostic and School/College can adopt the same
-- badge slugs pattern (e.g. `school_first_lesson_completed`) without a
-- schema change -- only new `badges` rows + award-site wiring.

alter table quiz_questions
  add column difficulty text not null default 'medium' check (difficulty in ('easy', 'medium', 'hard')),
  add column question_type text not null default 'multiple_choice' check (question_type in ('multiple_choice', 'free_response')),
  add column keywords jsonb;

alter table quiz_questions alter column options drop not null;
alter table quiz_questions alter column correct_answer drop not null;

alter table quiz_questions add constraint quiz_questions_type_shape check (
  (question_type = 'multiple_choice' and options is not null and correct_answer is not null)
  or
  (question_type = 'free_response' and keywords is not null and jsonb_array_length(keywords) > 0)
);

alter table quizzes
  add column scenario_body text,
  add column context_tag text,
  add column quiz_type text not null default 'standard' check (quiz_type in ('standard', 'case_study'));

-- Recreated (not just altered) so the public view picks up the new
-- non-sensitive columns; `correct_answer` and `keywords` stay excluded, same
-- hidden-from-students treatment.
drop view quiz_questions_public;
create view quiz_questions_public as
  select id, quiz_id, question, options, order_index, difficulty, question_type
  from quiz_questions;

alter view quiz_questions_public owner to postgres;
grant select on quiz_questions_public to authenticated;

create table badges (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text not null,
  icon text not null,
  created_at timestamptz not null default now()
);

create table profile_badges (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles (id) on delete cascade,
  badge_id uuid not null references badges (id) on delete cascade,
  earned_at timestamptz not null default now(),
  unique (profile_id, badge_id)
);

create index idx_profile_badges_profile on profile_badges (profile_id);

alter table badges enable row level security;

create policy badges_select on badges
  for select
  using (auth.role() = 'authenticated');

alter table profile_badges enable row level security;

create policy profile_badges_select on profile_badges
  for select
  using (is_own_or_linked_profile(profile_id));

-- No insert/update/delete policy for `authenticated`: badges are only ever
-- written by award_badge(), a security-definer function that runs as the
-- table owner and is not subject to `authenticated`-scoped policies.
create or replace function award_badge(p_profile_id uuid, p_slug text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_badge_id uuid;
begin
  select id into v_badge_id from badges where slug = p_slug;

  if v_badge_id is null then
    return;
  end if;

  insert into profile_badges (profile_id, badge_id)
  values (p_profile_id, v_badge_id)
  on conflict (profile_id, badge_id) do nothing;
end;
$$;

revoke execute on function award_badge(uuid, text) from public;
grant execute on function award_badge(uuid, text) to service_role;

insert into badges (slug, title, description, icon) values
  ('jobready_first_lesson_completed', 'First Step', 'Completed your first Job-Ready lesson.', '🎯'),
  ('jobready_first_quiz_passed', 'Quiz Passed', 'Passed your first Job-Ready quiz.', '✅'),
  ('jobready_tier_completed', 'Job-Ready Graduate', 'Completed every topic in the Job-Ready track.', '🎓'),
  ('jobready_first_mock_interview_completed', 'First Rehearsal', 'Completed your first AI mock interview.', '🎤');

-- Extends 00000000000033's version: (a) free_response questions are graded
-- by keyword match (at least half of a question's `keywords` array must
-- appear, case-insensitively, as substrings of the submitted answer -- a
-- simple, auditable rubric/keyword match rather than an LLM call, since
-- quiz grading elsewhere in this schema is always a deterministic SQL
-- function, never a model call); (b) a passing Job-Ready attempt now awards
-- the lesson/quiz/tier-completion badges. "Lesson completed" is awarded
-- alongside "quiz passed" because this schema has no separate lesson-read
-- tracking -- a lesson's only gradable completion signal is passing its
-- quiz, so the two badges fire together by design, not by omission.
create or replace function grade_quiz_attempt(p_quiz_id uuid, p_answers jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile_id uuid := auth.uid();
  v_pass_threshold numeric;
  v_skill_id uuid;
  v_tier text;
  v_total integer;
  v_correct integer;
  v_score numeric;
  v_passed boolean;
  v_attempt_id uuid;
begin
  if v_profile_id is null then
    raise exception 'not authenticated';
  end if;

  select pass_threshold into v_pass_threshold
  from quizzes
  where id = p_quiz_id and published;

  if not found then
    raise exception 'quiz % not found or not published', p_quiz_id;
  end if;

  select count(*) into v_total
  from quiz_questions
  where quiz_id = p_quiz_id;

  if v_total = 0 then
    raise exception 'quiz % has no questions', p_quiz_id;
  end if;

  perform pg_advisory_xact_lock(hashtextextended(v_profile_id::text || ':' || p_quiz_id::text, 0));

  select count(*) into v_correct
  from quiz_questions qq
  where qq.quiz_id = p_quiz_id
    and (
      (
        qq.question_type = 'multiple_choice'
        and qq.correct_answer = (
          select a->>'answer'
          from jsonb_array_elements(p_answers) a
          where (a->>'question_id')::uuid = qq.id
          limit 1
        )
      )
      or
      (
        qq.question_type = 'free_response'
        and (
          select count(*)
          from jsonb_array_elements_text(qq.keywords) kw
          where position(lower(kw) in lower(coalesce(
            (
              select a->>'answer'
              from jsonb_array_elements(p_answers) a
              where (a->>'question_id')::uuid = qq.id
              limit 1
            ),
            ''
          ))) > 0
        ) >= greatest(1, ceil(jsonb_array_length(qq.keywords) * 0.5))
      )
    );

  v_score := v_correct::numeric / v_total;
  v_passed := v_score >= v_pass_threshold;

  insert into quiz_attempts (profile_id, quiz_id, score, passed, answers)
  values (v_profile_id, p_quiz_id, v_score, v_passed, p_answers)
  returning id into v_attempt_id;

  if v_passed then
    v_skill_id := quiz_skill_id(p_quiz_id);

    if v_skill_id is not null then
      insert into skill_attempts (profile_id, skill_id, is_correct)
      values (v_profile_id, v_skill_id, true);

      select tier into v_tier from skills where id = v_skill_id;
    end if;

    insert into xp_events (profile_id, source, source_id, xp_delta)
    select v_profile_id, 'quiz_attempt', v_attempt_id, 10
    where not exists (
      select 1 from quiz_attempts
      where profile_id = v_profile_id
        and quiz_id = p_quiz_id
        and passed
        and id <> v_attempt_id
    );

    if v_tier = 'job_ready' then
      perform award_badge(v_profile_id, 'jobready_first_lesson_completed');
      perform award_badge(v_profile_id, 'jobready_first_quiz_passed');

      -- Tier completion only requires the standard (one-per-skill) lesson
      -- quizzes, not the case-study quizzes attached to the case-study
      -- practice skill -- those are supplemental practice, not part of the
      -- topic chain a "completed the tier" badge should gate on.
      if not exists (
        select 1
        from quizzes q
        join skills s on s.id = coalesce(q.skill_id, (select l.skill_id from lessons l where l.id = q.lesson_id))
        where q.published
          and q.quiz_type = 'standard'
          and s.tier = 'job_ready'
          and not exists (
            select 1 from quiz_attempts qa
            where qa.quiz_id = q.id and qa.profile_id = v_profile_id and qa.passed
          )
      ) then
        perform award_badge(v_profile_id, 'jobready_tier_completed');
      end if;
    end if;
  end if;

  return jsonb_build_object(
    'attempt_id', v_attempt_id,
    'score', v_score,
    'passed', v_passed,
    'correct', v_correct,
    'total', v_total
  );
end;
$$;
