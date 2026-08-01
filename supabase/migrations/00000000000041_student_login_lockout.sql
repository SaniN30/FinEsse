-- Security audit Finding 1b: PIN lockout/backoff. GoTrue doesn't expose a
-- failed-login hook, so failed attempts are tracked here on `profiles` and
-- enforced by the new student-login Edge Function, which is the only
-- supported path for student sign-in going forward (see auth-actions.ts).
--
-- login_email is denormalized from the synthetic auth email assigned at
-- account creation (create-student-account) so the lockout check can find a
-- student's profile without an Auth Admin API call before every login.

alter table profiles
  add column if not exists login_email text,
  add column if not exists failed_login_attempts int not null default 0,
  add column if not exists locked_until timestamptz;

create unique index if not exists idx_profiles_login_email_unique
  on profiles (login_email)
  where login_email is not null;

-- Backfill existing student accounts' login_email from auth.users so the
-- lockout path works for accounts created before this migration too.
update profiles p
set login_email = u.email
from auth.users u
where p.id = u.id
  and p.role = 'student'
  and p.login_email is null;
