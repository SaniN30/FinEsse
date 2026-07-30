-- Auto-grading RPC for modeling exercises -- same pattern as
-- grade_quiz_attempt (migration 008/010): the client submits only its
-- values; the score is always computed here from `modeling_exercises.rubric`,
-- never trusted from the caller. Rubric-based comparison only in this
-- phase, no free-form AI grading.
--
-- SECURITY DEFINER is required because `modeling_exercises` has no select
-- policy exposing `rubric` to regular clients (see the RLS migration) --
-- this function is the one place allowed to read it. It identifies the
-- student from `auth.uid()`, never a client-supplied profile_id, so a
-- student can only ever grade a submission as themselves.
--
-- p_submitted_values shape: a jsonb object keyed the same way as the
-- rubric, e.g. {"revenue_growth_pct": 12.3, ...}. Each rubric entry is
-- {"expected": <number>, "tolerance": <number>}; a metric is "correct" if
-- |submitted - expected| <= tolerance.
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

  for v_key in select jsonb_object_keys(v_rubric) loop
    v_metric := v_rubric -> v_key;
    v_expected := (v_metric ->> 'expected')::numeric;
    v_tolerance := coalesce((v_metric ->> 'tolerance')::numeric, 0);

    -- A malformed/non-numeric client value should degrade to "wrong answer
    -- for this metric", not crash the whole grading call (same principle
    -- as the duplicate-question_id fix for grade_quiz_attempt).
    begin
      v_submitted := (p_submitted_values ->> v_key)::numeric;
    exception when others then
      v_submitted := null;
    end;

    if v_submitted is not null and abs(v_submitted - v_expected) <= v_tolerance then
      v_correct := v_correct + 1;
    end if;
  end loop;

  v_score := v_correct::numeric / v_total;
  v_passed := v_score >= v_pass_threshold;

  insert into modeling_submissions (profile_id, exercise_id, submitted_values, score, passed)
  values (v_profile_id, p_exercise_id, p_submitted_values, v_score, v_passed)
  returning id into v_submission_id;

  if v_passed then
    if v_skill_id is not null then
      insert into skill_attempts (profile_id, skill_id, is_correct)
      values (v_profile_id, v_skill_id, true);
    end if;

    insert into xp_events (profile_id, source, source_id, xp_delta)
    values (v_profile_id, 'modeling_submission', v_submission_id, 15);
  end if;

  return jsonb_build_object(
    'submission_id', v_submission_id,
    'score', v_score,
    'passed', v_passed,
    'correct', v_correct,
    'total', v_total
  );
end;
$$;

revoke execute on function grade_modeling_submission(uuid, jsonb) from public;
grant execute on function grade_modeling_submission(uuid, jsonb) to authenticated;
