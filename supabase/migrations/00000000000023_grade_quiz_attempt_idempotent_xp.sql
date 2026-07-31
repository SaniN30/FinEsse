-- Security audit Finding 2: XP-farming idempotency. grade_quiz_attempt
-- previously awarded 10 xp_events on every passing attempt, so repeatedly
-- retaking (or re-submitting) an already-passed quiz farmed unlimited xp.
-- This still records every attempt in quiz_attempts (so history/analytics
-- are unaffected) but only inserts an xp_events row the first time a given
-- profile passes a given quiz.
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
  v_already_passed boolean;
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

  select exists(
    select 1 from quiz_attempts
    where profile_id = v_profile_id and quiz_id = p_quiz_id and passed
  ) into v_already_passed;

  select count(*) into v_correct
  from quiz_questions qq
  where qq.quiz_id = p_quiz_id
    and qq.correct_answer = (
      select a->>'answer'
      from jsonb_array_elements(p_answers) a
      where (a->>'question_id')::uuid = qq.id
      limit 1
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
    end if;

    if not v_already_passed then
      insert into xp_events (profile_id, source, source_id, xp_delta)
      values (v_profile_id, 'quiz_attempt', v_attempt_id, 10);
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
