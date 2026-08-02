-- Milestone badge system completion pass. The existing badges/award_badge
-- machinery (00000000000046) already covers first-lesson, first-quiz,
-- first-modeling-exercise, and tier-completed, tier-agnostically, plus a
-- first-mock-interview badge added later live (see badges_criteria_type_check
-- history). Two milestone types from the badge system brief are still
-- missing: perfect quiz score and consecutive-day activity streaks. Both are
-- additive to the same badges/profile_badges/award_badge posture -- new
-- criteria_type values, no schema redesign.
--
-- Note: an earlier, never-applied local migration file
-- (00000000000043_quiz_case_study_badges_schema.sql) attempted a parallel
-- badges system with different column names (slug-keyed, `icon` column, no
-- `criteria_type`). It never actually ran against the live project -- the
-- live 00000000000043 slot was independently claimed by the sticky-notes
-- migration -- so it was deleted rather than reconciled; 00000000000046's
-- schema is the only one that was ever live.

alter table badges drop constraint badges_criteria_type_check;
alter table badges add constraint badges_criteria_type_check check (
  criteria_type in (
    'first_lesson_completed',
    'first_quiz_passed',
    'first_modeling_exercise_passed',
    'tier_completed',
    'first_mock_interview',
    'perfect_quiz_score',
    'streak_3_day',
    'streak_7_day'
  )
);

insert into badges (slug, title, description, criteria_type) values
  ('perfect-quiz-score', 'Perfect Score', 'Scored 100% on a quiz.', 'perfect_quiz_score'),
  ('streak-3-day', 'On a Roll', 'Learned three days in a row.', 'streak_3_day'),
  ('streak-7-day', 'Week Streak', 'Learned seven days in a row.', 'streak_7_day');

-- Consecutive-day activity streak, computed from the union of every
-- activity log this app already has a completed_at/created_at timestamp
-- for (lesson_completions, quiz_attempts, modeling_submissions) rather than
-- a new tracking table -- one row per profile per active calendar day is
-- exactly what those tables already give us via `distinct ... ::date`.
-- Walks backward day-by-day from today so a broken streak (a gap) stops the
-- count instead of overcounting historical activity.
create or replace function check_and_award_streak(p_profile_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_active_days date[];
  v_streak integer := 0;
  v_cursor date := current_date;
begin
  select array_agg(distinct d) into v_active_days
  from (
    select completed_at::date as d from lesson_completions where profile_id = p_profile_id
    union
    select attempted_at::date as d from quiz_attempts where profile_id = p_profile_id and passed
    union
    select submitted_at::date as d from modeling_submissions where profile_id = p_profile_id and passed
  ) activity;

  if v_active_days is null or not (v_cursor = any(v_active_days)) then
    return;
  end if;

  while v_cursor = any(v_active_days) loop
    v_streak := v_streak + 1;
    v_cursor := v_cursor - 1;
  end loop;

  if v_streak >= 3 then
    perform award_badge(p_profile_id, 'streak_3_day');
  end if;

  if v_streak >= 7 then
    perform award_badge(p_profile_id, 'streak_7_day');
  end if;
end;
$$;

revoke execute on function check_and_award_streak(uuid) from public;

-- grade_quiz_attempt: award perfect_quiz_score on a 100% pass and check the
-- activity streak on every passing attempt (unchanged otherwise from
-- 00000000000046's version).
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
  v_total integer;
  v_correct integer;
  v_score numeric;
  v_passed boolean;
  v_attempt_id uuid;
  v_first_ever_pass boolean;
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

  with answer_map as (
    select
      (a ->> 'question_id')::uuid as question_id,
      a ->> 'answer' as answer
    from jsonb_array_elements(p_answers) a
  ),
  graded as (
    select
      qq.id,
      case
        when qq.question_type = 'free_response' then (
          select count(*)
          from jsonb_array_elements_text(coalesce(qq.grading_keywords, '[]'::jsonb)) kw
          where position(lower(kw) in lower(coalesce(am.answer, ''))) > 0
        ) >= qq.min_keyword_matches
        else qq.correct_answer = am.answer
      end as is_correct
    from quiz_questions qq
    left join answer_map am on am.question_id = qq.id
    where qq.quiz_id = p_quiz_id
  )
  select count(*) filter (where is_correct) into v_correct from graded;

  v_score := v_correct::numeric / v_total;
  v_passed := v_score >= v_pass_threshold;

  select not exists (
    select 1 from quiz_attempts where profile_id = v_profile_id and passed
  ) into v_first_ever_pass;

  insert into quiz_attempts (profile_id, quiz_id, score, passed, answers)
  values (v_profile_id, p_quiz_id, v_score, v_passed, p_answers)
  returning id into v_attempt_id;

  if v_passed then
    v_skill_id := quiz_skill_id(p_quiz_id);

    if v_skill_id is not null then
      insert into skill_attempts (profile_id, skill_id, is_correct)
      values (v_profile_id, v_skill_id, true);
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

    if v_first_ever_pass then
      perform award_badge(v_profile_id, 'first_quiz_passed');
    end if;

    if v_score = 1 then
      perform award_badge(v_profile_id, 'perfect_quiz_score');
    end if;

    perform check_and_award_tier_completed(v_profile_id);
    perform check_and_award_streak(v_profile_id);
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

-- mark_lesson_complete: check the activity streak on every lesson view
-- (unchanged otherwise from 00000000000046's version).
create or replace function mark_lesson_complete(p_lesson_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile_id uuid := auth.uid();
  v_is_first boolean;
begin
  if v_profile_id is null then
    raise exception 'not authenticated';
  end if;

  if not exists (
    select 1
    from lessons l
    join skills s on s.id = l.skill_id
    join profiles p on p.tier = s.tier
    where l.id = p_lesson_id
      and l.published
      and p.id = v_profile_id
  ) then
    raise exception 'lesson % not found or not visible to this profile', p_lesson_id;
  end if;

  select not exists (select 1 from lesson_completions where profile_id = v_profile_id)
    into v_is_first;

  insert into lesson_completions (profile_id, lesson_id)
  values (v_profile_id, p_lesson_id)
  on conflict (profile_id, lesson_id) do nothing;

  if v_is_first then
    perform award_badge(v_profile_id, 'first_lesson_completed');
  end if;

  perform check_and_award_streak(v_profile_id);

  return jsonb_build_object('lesson_id', p_lesson_id);
end;
$$;

-- grade_modeling_submission: check the activity streak on every passing
-- submission too, so College/Job-Ready modeling exercises count toward a
-- streak the same way lessons and quizzes do (unchanged otherwise from
-- 00000000000046's version).
create or replace function grade_modeling_submission(p_exercise_id uuid, p_submitted_values jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile_id uuid := auth.uid();
  v_pass_threshold numeric;
  v_skill_id uuid;
  v_rubric jsonb;
  v_total integer;
  v_correct integer := 0;
  v_key text;
  v_metric jsonb;
  v_expected numeric;
  v_tolerance numeric;
  v_submitted numeric;
  v_score numeric;
  v_passed boolean;
  v_submission_id uuid;
  v_metric_correct boolean;
  v_breakdown jsonb := '{}'::jsonb;
  v_already_passed boolean;
  v_first_ever_pass boolean;
begin
  if v_profile_id is null then
    raise exception 'not authenticated';
  end if;

  select rubric, pass_threshold, skill_id into v_rubric, v_pass_threshold, v_skill_id
  from modeling_exercises
  where id = p_exercise_id and published;

  if not found then
    raise exception 'modeling exercise % not found or not published', p_exercise_id;
  end if;

  v_total := (select count(*) from jsonb_object_keys(v_rubric));

  if v_total = 0 then
    raise exception 'modeling exercise % has an empty rubric', p_exercise_id;
  end if;

  select exists(
    select 1 from modeling_submissions
    where profile_id = v_profile_id and exercise_id = p_exercise_id and passed
  ) into v_already_passed;

  select not exists (
    select 1 from modeling_submissions where profile_id = v_profile_id and passed
  ) into v_first_ever_pass;

  for v_key in select jsonb_object_keys(v_rubric) loop
    v_metric := v_rubric -> v_key;
    v_expected := (v_metric ->> 'expected')::numeric;
    v_tolerance := coalesce((v_metric ->> 'tolerance')::numeric, 0);

    begin
      v_submitted := (p_submitted_values ->> v_key)::numeric;
    exception when others then
      v_submitted := null;
    end;

    v_metric_correct := v_submitted is not null and abs(v_submitted - v_expected) <= v_tolerance;
    if v_metric_correct then
      v_correct := v_correct + 1;
    end if;

    v_breakdown := v_breakdown || jsonb_build_object(v_key, v_metric_correct);
  end loop;

  v_score := v_correct::numeric / v_total;
  v_passed := v_score >= v_pass_threshold;

  insert into modeling_submissions (profile_id, exercise_id, submitted_values, score, passed)
  values (v_profile_id, p_exercise_id, p_submitted_values, v_score, v_passed)
  returning id into v_submission_id;

  if v_passed and not v_already_passed then
    if v_skill_id is not null then
      insert into skill_attempts (profile_id, skill_id, is_correct)
      values (v_profile_id, v_skill_id, true);
    end if;

    insert into xp_events (profile_id, source, source_id, xp_delta)
    values (v_profile_id, 'modeling_submission', v_submission_id, 15);

    if v_first_ever_pass then
      perform award_badge(v_profile_id, 'first_modeling_exercise_passed');
    end if;

    perform check_and_award_tier_completed(v_profile_id);
  end if;

  if v_passed then
    perform check_and_award_streak(v_profile_id);
  end if;

  return jsonb_build_object(
    'submission_id', v_submission_id,
    'score', v_score,
    'passed', v_passed,
    'correct', v_correct,
    'total', v_total,
    'metrics', v_breakdown,
    'already_completed', v_already_passed
  );
end;
$$;
