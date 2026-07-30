-- Phase 5: submission RPC for the AI Interview Coach.
--
-- `interview_sessions` (migration 004) predates the question bank, so it
-- needs a `question_id` FK to know which question a transcript answers.
-- `transcript` was declared `jsonb` speculatively before this phase's shape
-- was known; the brief for this phase is explicit that the input is a
-- plain-text transcript (audio/STT wiring is a later phase), so it's
-- retyped to `text` here -- the table has no production data yet (no
-- frontend has ever written to it).
alter table interview_sessions add column question_id uuid references interview_questions (id);
alter table interview_sessions alter column transcript drop default;
alter table interview_sessions alter column transcript type text using transcript #>> '{}';
alter table interview_sessions alter column transcript set default '';

create index idx_interview_sessions_question on interview_sessions (question_id);

-- The migration-005 policies let a linked parent insert/update a child's
-- interview_sessions, which is broader than this phase wants: a student may
-- create/read only their own sessions, and a parent gets read-only
-- visibility, same "visibility, not control" posture as quiz_attempts /
-- modeling_submissions. Replace them: no insert/update policy for
-- `authenticated` at all -- rows are written exclusively by
-- submit_interview_session() below (insert) and the score_interview_session
-- Edge Function, which uses the service_role key and so bypasses RLS
-- entirely (update, once rubric scores come back).
drop policy interview_sessions_insert on interview_sessions;
drop policy interview_sessions_update on interview_sessions;

-- Submission RPC: a student submits a transcript for a published question.
-- SECURITY DEFINER because there is deliberately no self-insert policy (see
-- above) -- this is the one place allowed to write a session row, and it
-- always identifies the student from auth.uid(), never a client-supplied
-- profile_id, so a student can only ever submit a session as themselves.
-- rubric_scores stays at its column default ('{}'::jsonb) until the scoring
-- Edge Function fills it in -- never computed or accepted from the client.
create or replace function submit_interview_session(p_question_id uuid, p_transcript text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile_id uuid := auth.uid();
  v_firm_style text;
  v_session_id uuid;
begin
  if v_profile_id is null then
    raise exception 'not authenticated';
  end if;

  if p_transcript is null or length(trim(p_transcript)) = 0 then
    raise exception 'transcript must not be empty';
  end if;

  select firm_style into v_firm_style
  from interview_questions
  where id = p_question_id and published;

  if not found then
    raise exception 'interview question % not found or not published', p_question_id;
  end if;

  insert into interview_sessions (profile_id, question_id, firm_style, transcript)
  values (v_profile_id, p_question_id, v_firm_style, p_transcript)
  returning id into v_session_id;

  return v_session_id;
end;
$$;

revoke execute on function submit_interview_session(uuid, text) from public;
grant execute on function submit_interview_session(uuid, text) to authenticated;
