-- Per captain directive: School/College/Job-Ready lesson/quiz/modeling content
-- should never be tier-gated for reads -- any authenticated FinEsse account can
-- browse any tier's content, full stop. The only read gate is "is this a
-- signed-in account", same as skills_select/roles_select/interview_questions_select
-- already are. profiles.tier remains meaningful for badge/mastery/UI-default
-- purposes (see the parent-dashboard tier switcher), it just no longer
-- restricts *reading* content.
--
-- This is a read-access change only. Write/progress-tracking RLS (quiz_attempts,
-- modeling_submissions, skill_attempts, xp_events, practice_attempts, badges,
-- lesson_completions, interview_sessions) is untouched -- all already scoped to
-- is_own_or_linked_profile(profile_id), which has nothing to do with tier.

drop policy lessons_select on lessons;

create policy lessons_select on lessons
  for select
  using (published and auth.role() = 'authenticated');

drop policy quizzes_select on quizzes;

create policy quizzes_select on quizzes
  for select
  using (published and auth.role() = 'authenticated');

-- modeling_exercises has no RLS select policy of its own (rubric must stay
-- hidden -- students read via modeling_exercises_public instead, same as
-- quiz_questions_public), so the tier check lived inside the view itself.
drop view modeling_exercises_public;

create view modeling_exercises_public as
  select e.id, e.skill_id, e.title, e.instructions, e.pass_threshold, e.published, e.created_at
  from modeling_exercises e
  where e.published and auth.role() = 'authenticated';

alter view modeling_exercises_public owner to postgres;
grant select on modeling_exercises_public to authenticated;
