-- Re-applies the two no-mistakes review fixes made to migrations 007/008
-- after they were already run against the live project via `supabase db
-- push` (which tracks applied migrations by version and won't re-run an
-- edited historical file). Both statements are idempotent so this is safe
-- to run again on any environment that migrates from scratch.

-- Fix 1: a student could previously `insert into quiz_attempts` directly
-- with a self-chosen score/passed, bypassing grade_quiz_attempt() entirely.
-- Attempts must be written exclusively by that security-definer function.
drop policy if exists quiz_attempts_insert on quiz_attempts;

-- Fix 2: the correlated subquery matching answers to questions could raise
-- "more than one row returned by a subquery used as an expression" if a
-- client submitted duplicate question_id entries; `limit 1` makes malformed
-- client input degrade to a wrong answer instead of crashing the RPC.
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

    insert into xp_events (profile_id, source, source_id, xp_delta)
    values (v_profile_id, 'quiz_attempt', v_attempt_id, 10);
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

revoke execute on function grade_quiz_attempt(uuid, jsonb) from public;
grant execute on function grade_quiz_attempt(uuid, jsonb) to authenticated;
