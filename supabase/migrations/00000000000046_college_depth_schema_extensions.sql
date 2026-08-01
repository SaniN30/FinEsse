-- College content-depth followup: schema extensions.
--
-- Three genuinely new concepts, all additive (no existing column dropped or
-- retyped, so historical quiz_attempts/interview data stays valid):
--
-- 1. Difficulty labels on quiz_questions and interview_questions -- a plain
--    enum column, defaulted so existing rows don't need an immediate
--    backfill at schema-creation time (backfilled for real in migration 049).
-- 2. Typed free-response questions on quiz_questions, graded by keyword
--    match rather than exact string equality -- needed for the case-study
--    quizzes (migration 048), which mix multiple-choice with short typed
--    answers. `grading_keywords`/`min_keyword_matches` are the free-response
--    equivalent of `correct_answer`: never exposed to clients (same
--    hide-the-answer-key posture quiz_questions already has for
--    `correct_answer`), only read inside the SECURITY DEFINER grading
--    function. `scenario_context` is different in kind -- it's shown to the
--    student alongside the question (which real-world scenario/role/industry
--    a case-study question is modeled on), not an answer key, so it IS
--    exposed via quiz_questions_public.
-- 3. Milestone badges (`badges`/`profile_badges`) -- awarded once per
--    profile on first lesson completed, first quiz passed, first modeling
--    exercise passed, and full tier completion. `lesson_completions` is a
--    new append-only log (lessons had no completion/attempt concept at all
--    before this) backing the "first lesson completed" badge; the other
--    three badges are awarded from inside the existing grading RPCs.

-- ===================== Difficulty labels =====================

alter table quiz_questions
  add column difficulty text not null default 'medium'
    check (difficulty in ('easy', 'medium', 'hard'));

alter table interview_questions
  add column difficulty text not null default 'medium'
    check (difficulty in ('easy', 'medium', 'hard'));

-- ===================== Typed free-response questions =====================

alter table quiz_questions
  add column question_type text not null default 'multiple_choice'
    check (question_type in ('multiple_choice', 'free_response')),
  add column grading_keywords jsonb,
  add column min_keyword_matches integer not null default 1
    check (min_keyword_matches > 0),
  add column scenario_context text,
  add constraint quiz_questions_free_response_has_keywords check (
    question_type = 'multiple_choice'
    or (grading_keywords is not null and jsonb_array_length(grading_keywords) > 0)
  );

-- Recreated with the new student-facing columns. `grading_keywords` and
-- `min_keyword_matches` are the free-response answer key -- deliberately
-- left out here, same reasoning as omitting `correct_answer`.
create or replace view quiz_questions_public as
  select
    id,
    quiz_id,
    question,
    options,
    order_index,
    difficulty,
    question_type,
    scenario_context
  from quiz_questions;

-- ===================== Milestone badges =====================

create table badges (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text not null,
  criteria_type text not null unique
    check (criteria_type in (
      'first_lesson_completed',
      'first_quiz_passed',
      'first_modeling_exercise_passed',
      'tier_completed'
    )),
  created_at timestamptz not null default now()
);

insert into badges (slug, title, description, criteria_type) values
  ('first-lesson-completed', 'First Steps', 'Opened your first lesson.', 'first_lesson_completed'),
  ('first-quiz-passed', 'Quiz Whiz', 'Passed your first quiz.', 'first_quiz_passed'),
  ('first-modeling-exercise-passed', 'Model Builder', 'Passed your first modeling exercise.', 'first_modeling_exercise_passed'),
  ('tier-completed', 'Tier Champion', 'Mastered every skill in your tier.', 'tier_completed');

create table profile_badges (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles (id) on delete cascade,
  badge_id uuid not null references badges (id) on delete cascade,
  awarded_at timestamptz not null default now(),
  unique (profile_id, badge_id)
);

create index idx_profile_badges_profile on profile_badges (profile_id);

alter table badges enable row level security;

create policy badges_select on badges
  for select
  using (auth.role() = 'authenticated');

alter table profile_badges enable row level security;

-- Append-only, same "visibility not control" posture as quiz_attempts /
-- modeling_submissions: a linked parent can see a child's earned badges, but
-- rows are only ever written by the SECURITY DEFINER grading/completion
-- functions below -- no self-insert policy, so a student can't fabricate one.
create policy profile_badges_select on profile_badges
  for select
  using (is_own_or_linked_profile(profile_id));

-- Shared by every award site below (grade_quiz_attempt, grade_modeling_submission,
-- mark_lesson_complete) so the "insert once, ignore duplicates" logic lives
-- in exactly one place.
create or replace function award_badge(p_profile_id uuid, p_criteria_type text)
returns void
language sql
security definer
set search_path = public
as $$
  insert into profile_badges (profile_id, badge_id)
  select p_profile_id, id from badges where criteria_type = p_criteria_type
  on conflict (profile_id, badge_id) do nothing;
$$;

-- Both helpers take an arbitrary p_profile_id and must never be callable
-- directly by a student (who could otherwise forge any badge for any
-- profile) -- only from inside the other SECURITY DEFINER functions in this
-- file, which always resolve v_profile_id from auth.uid() themselves.
-- Postgres grants EXECUTE to PUBLIC by default on new functions, so this
-- revoke is required, not redundant; the internal calls below still work
-- because the function owner always retains implicit privilege on its own
-- objects regardless of this revoke.
revoke execute on function award_badge(uuid, text) from public;

-- Checks whether every skill in the profile's own tier has been mastered
-- (skill_mastery.rolling_accuracy >= skills.mastery_threshold) and, if so,
-- awards 'tier_completed'. Called from grade_quiz_attempt after a passing
-- attempt -- mastery only ever improves on a pass, so that's the only point
-- completion status can newly become true.
create or replace function check_and_award_tier_completed(p_profile_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tier text;
  v_total_skills integer;
  v_mastered_skills integer;
begin
  select tier into v_tier from profiles where id = p_profile_id;

  select count(*) into v_total_skills from skills where tier = v_tier;

  select count(*) into v_mastered_skills
  from skill_mastery sm
  join skills s on s.id = sm.skill_id
  where sm.profile_id = p_profile_id
    and s.tier = v_tier
    and sm.rolling_accuracy >= s.mastery_threshold;

  if v_total_skills > 0 and v_mastered_skills >= v_total_skills then
    perform award_badge(p_profile_id, 'tier_completed');
  end if;
end;
$$;

revoke execute on function check_and_award_tier_completed(uuid) from public;

-- ===================== Lesson completion (new concept) =====================

-- Lessons previously had no completion/attempt log at all -- only quizzes
-- and modeling exercises did. This is intentionally minimal: "completed"
-- here means "opened", the same operational simplicity the rest of this
-- app's content-progress tracking already uses (no partial-scroll or
-- time-on-page tracking). One row per (profile, lesson); the unique
-- constraint makes mark_lesson_complete idempotent against repeat views.
create table lesson_completions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles (id) on delete cascade,
  lesson_id uuid not null references lessons (id) on delete cascade,
  completed_at timestamptz not null default now(),
  unique (profile_id, lesson_id)
);

create index idx_lesson_completions_profile on lesson_completions (profile_id);

alter table lesson_completions enable row level security;

create policy lesson_completions_select on lesson_completions
  for select
  using (is_own_or_linked_profile(profile_id));

-- SECURITY DEFINER so it can award the badge; identifies the student from
-- auth.uid() (never a client-supplied profile_id), and re-checks the same
-- tier-match gate lessons_select relies on so a student can't mark a lesson
-- outside their own tier as complete.
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

  return jsonb_build_object('lesson_id', p_lesson_id);
end;
$$;

revoke execute on function mark_lesson_complete(uuid) from public;
grant execute on function mark_lesson_complete(uuid) to authenticated;

-- ===================== grade_quiz_attempt: free-response grading + badges =====================

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

    perform check_and_award_tier_completed(v_profile_id);
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

-- ===================== grade_modeling_submission: badge =====================

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
