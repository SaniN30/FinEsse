-- RLS for Phase 4 College-tier content tables.
--
-- roles: shared reference content, publicly readable (published rows only)
-- to any authenticated user, writable only by service_role (no
-- authenticated-scoped insert/update/delete policy at all -- same
-- "content authored by service_role" posture as skills/lessons/quizzes).
--
-- modeling_exercises: readable by any authenticated user whose own
-- profiles.tier matches the underlying skill's tier, once published -- same
-- pattern as lessons/quizzes. The `rubric` column (expected values) must
-- never be readable by students directly, so it's exposed only through
-- modeling_exercises_public, which omits it -- same pattern as
-- quiz_questions_public omitting correct_answer.
--
-- modeling_submissions: append-only, same pattern as quiz_attempts. A
-- student may read/insert only their own submissions; a linked parent may
-- read (not write) a child's submissions -- visibility, not control.
-- Submissions are written exclusively by the security-definer
-- grade_modeling_submission() function (next migration), which runs as the
-- table owner and bypasses authenticated-scoped policies -- there is
-- deliberately no self-insert policy, so a student cannot fabricate a
-- passing score/submitted_values directly.

alter table roles enable row level security;

create policy roles_select on roles
  for select
  using (published and auth.role() = 'authenticated');

alter table modeling_exercises enable row level security;

-- No select policy for authenticated on the base table -- rubric must stay
-- hidden. Students read via modeling_exercises_public instead.
--
-- Unlike quiz_questions_public (which relies on the separate
-- quizzes_select RLS policy to gate visibility, since quiz_questions has no
-- tier concept of its own), modeling_exercises has no separate gating
-- table, so the published/tier check is embedded directly in this view --
-- otherwise, since the view is owned by postgres (BYPASSRLS) and grants
-- select unconditionally to authenticated, any student in any tier could
-- read every exercise regardless of `published` or tier match.
create view modeling_exercises_public as
  select e.id, e.skill_id, e.title, e.instructions, e.pass_threshold, e.published, e.created_at
  from modeling_exercises e
  join skills s on s.id = e.skill_id
  join profiles p on p.tier = s.tier
  where e.published and p.id = auth.uid();

alter view modeling_exercises_public owner to postgres;
grant select on modeling_exercises_public to authenticated;

alter table modeling_submissions enable row level security;

create policy modeling_submissions_select on modeling_submissions
  for select
  using (is_own_or_linked_profile(profile_id));

-- No insert/update/delete policy for `authenticated`: submissions are
-- written exclusively by grade_modeling_submission(), which runs as the
-- table owner. Adding a self-insert policy would let a student bypass
-- grading and fabricate a passing score/submitted_values directly.
