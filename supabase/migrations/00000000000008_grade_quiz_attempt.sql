-- Auto-grading RPC.
--
-- The client submits only its chosen answers; the score is always computed
-- here from `quiz_questions.correct_answer`, never trusted from the caller
-- (same principle as Phase 1's derived-XP rollups). SECURITY DEFINER is
-- required because `quiz_questions` has no select policy for regular
-- clients (see the RLS migration) -- this function is the one place that's
-- allowed to read `correct_answer`. It still identifies the student from
-- `auth.uid()` rather than a client-supplied profile_id, so a student can
-- only ever grade an attempt as themselves.
--
-- p_answers shape: a jsonb array of {"question_id": uuid, "answer": text}.
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
