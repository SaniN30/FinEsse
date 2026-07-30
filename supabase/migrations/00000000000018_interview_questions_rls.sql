-- RLS for `interview_questions` -- same "shared reference content" pattern
-- as `roles_select` (migration 014): readable by any authenticated user
-- once published, writable only by service_role.
alter table interview_questions enable row level security;

create policy interview_questions_select on interview_questions
  for select
  using (published and auth.role() = 'authenticated');
