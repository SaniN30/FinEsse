-- RLS for Phase 2 content tables.
--
-- lessons/quizzes/quiz_questions_public: readable by any authenticated user
-- once published (content, not per-student data -- gating is editorial, not
-- a privacy boundary). quiz_questions itself gets NO select policy at all,
-- so `correct_answer` is unreadable through the base table; only the
-- security-definer grading function (and quiz_questions_public, which omits
-- the column) can see it.
--
-- quiz_attempts: append-only per Phase 1's pattern. A student may read/write
-- only their own attempts; a linked parent may read (not write) a child's
-- attempts -- visibility, not control, per the consumer-research finding
-- already reflected in Phase 1's consent model.

alter table lessons enable row level security;

create policy lessons_select on lessons
  for select
  using (
    published
    and exists (
      select 1
      from skills s
      join profiles p on p.tier = s.tier
      where s.id = lessons.skill_id
        and p.id = auth.uid()
    )
  );

alter table quizzes enable row level security;

create policy quizzes_select on quizzes
  for select
  using (
    published
    and exists (
      select 1
      from skills s
      join profiles p on p.tier = s.tier
      where s.id = coalesce(
        quizzes.skill_id,
        (select l.skill_id from lessons l where l.id = quizzes.lesson_id)
      )
      and p.id = auth.uid()
    )
  );

-- quiz_questions: RLS enabled, deliberately zero policies -> default deny
-- for select/insert/update/delete to every non-service-role caller. Content
-- authoring happens via service_role (migrations/seed for now); students
-- only ever read questions through `quiz_questions_public`.
alter table quiz_questions enable row level security;

alter view quiz_questions_public owner to postgres;
grant select on quiz_questions_public to authenticated;

alter table quiz_attempts enable row level security;

create policy quiz_attempts_select on quiz_attempts
  for select
  using (is_own_or_linked_profile(profile_id));

-- No insert/update/delete policy for `authenticated`: attempts are written
-- exclusively by the security-definer grade_quiz_attempt() function, which
-- runs as the table owner and is not subject to policies scoped to
-- `authenticated`. Adding a self-insert policy here would let a student
-- bypass grading and fabricate a passing score/answers directly.
