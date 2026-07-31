-- Full-feature audit fix: grade_modeling_submission previously inserted a new
-- XP/skill_attempt row on every passing submission, so a student re-submitting
-- an exercise they already passed (e.g. to review material) accumulated
-- duplicate XP/mastery credit. Every submission is still logged in
-- modeling_submissions (append-only history, unchanged), but XP/mastery is
-- now only awarded on a student's first pass per exercise. The response gains
-- `already_completed` so the frontend can show an "already completed" state
-- instead of implying a resubmission earns more credit.
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

revoke execute on function grade_modeling_submission(uuid, jsonb) from public;
grant execute on function grade_modeling_submission(uuid, jsonb) to authenticated;
