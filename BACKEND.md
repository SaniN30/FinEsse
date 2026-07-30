# FinEsse Backend (Phase 1 + Phase 2)

Data layer and auth on Supabase (Postgres + Auth + Edge Functions), scoped to
fit entirely within Supabase's free tier. No frontend UI ships in this phase —
this doc exists so later phases and the eventual frontend mockup can build
against a stable contract.

## Local dev setup

Requires Docker (or Podman) on PATH — the Supabase CLI's local stack runs
Postgres, GoTrue, and the Edge Functions runtime in containers.

```sh
npm run supabase:start   # supabase start
npm run supabase:reset   # supabase db reset -- applies all migrations from scratch
npm run test:integration # vitest against the local stack (see env vars below)
npm run supabase:stop
```

`supabase start` prints `anon key` and `service_role key` for the local
instance. Export them before running the integration tests:

```sh
export SUPABASE_URL=http://127.0.0.1:54321
export SUPABASE_ANON_KEY=<from supabase start output>
export SUPABASE_SERVICE_ROLE_KEY=<from supabase start output>
```

Migrations live in `supabase/migrations/`; Edge Functions in
`supabase/functions/`. A live Supabase project can adopt this repo directly
(`supabase link` + `supabase db push` + `supabase functions deploy`) once
provisioned — no code changes needed to go from local to hosted.

## Schema

### `profiles`

One row per person (parent or student), `id` = `auth.users.id`.

| column | notes |
|---|---|
| `role` | `parent` \| `student` |
| `parent_id` | self-FK, null for parents, required for students |
| `tier` | `school` \| `college` \| `job_ready` |
| `date_of_birth` | collected only for COPPA age/consent record-keeping (data minimization — no other demographic fields) |
| `consent_id` | FK to `parental_consents`, required for students; a unique partial index (`idx_profiles_consent_id_unique`) prevents the same consent record from being reused for more than one student login |
| `data_retention_requested_at` | set when a deletion/retention request is recorded, for GDPR-K/COPPA compliance |

A DB trigger (`enforce_student_consent`) makes "student row requires a valid,
matching, affirmatively-given consent record" a hard invariant — it fires on
every insert/update to `profiles` regardless of caller, including
`service_role`, so it can't be bypassed by a future code path that inserts
directly. A second trigger (`lock_profile_identity_fields`) prevents
non-service-role callers from changing `role`/`parent_id`/`consent_id` after
creation.

### Mastery graph: `skills`, `skill_attempts`, `xp_events`

- `skills` is reference data (tier, prerequisite chain, per-skill mastery
  threshold), read-only to clients.
- `skill_attempts` is an append-only log of right/wrong attempts per
  `(profile_id, skill_id)`.
- `skill_mastery` (a view, not a table) computes rolling accuracy over each
  profile's last 10 attempts per skill; a skill "unlocks" the next one in the
  graph when `rolling_accuracy >= skills.mastery_threshold`. There is no
  stored "current level" — mastery state is always derived from the log.
- `xp_events` is an append-only XP ledger (`xp_delta >= 0`, one row per
  scoring event). Total XP for a profile is `sum(xp_delta)`, computed on
  read, never stored.

### Pocket-money ledger: `accounts`, `transactions`, `postings`

Simulated double-entry bookkeeping — virtual/practice money only, no real
banking integration.

- `accounts.type` is `student_wallet` \| `parent_wallet` \| `savings_goal`.
- A `transaction` is a logical event; its `postings` (one row per affected
  account, signed `amount_cents`) must net to zero.
- `check_postings_balance` is a **deferred constraint trigger** on
  `postings` — it validates at `COMMIT`, not per-row, so the several postings
  that make up one transaction can be inserted across statements within the
  same DB transaction before the zero-sum check runs.
- `accounts.target_amount_cents` (Phase 3) is only meaningful for
  `type = 'savings_goal'`; null for wallets.

#### Pocket Money Planner: savings-goal RPCs (Phase 3)

Three `SECURITY DEFINER` RPCs
(`supabase/migrations/00000000000011_savings_goals.sql`), same pattern as
Phase 2's `grade_quiz_attempt` — each identifies the caller from
`auth.uid()`, never a client-supplied `profile_id`, and verifies any goal
account referenced actually belongs to that caller before touching it:

- `create_savings_goal(p_name, p_target_amount_cents)` — opens an `accounts`
  row of `type = 'savings_goal'` for the calling student, returns the new
  account id.
- `deposit_to_savings_goal(p_goal_account_id, p_amount_cents, p_description)`
  — posts a balanced `transaction` moving funds from the student's own
  `student_wallet` into their own `savings_goal` account. Lazily creates the
  wallet (`get_or_create_student_wallet`) if the student doesn't have one
  yet, since no other path provisions one.
- `withdraw_from_savings_goal(p_goal_account_id, p_amount_cents, p_description)`
  — posts a balanced `transaction` moving funds back out, rejecting an
  amount greater than the goal's current balance. This is the student's own
  "my choice" autonomy zone per the plan's Tone & Trust Principles: the
  student, not the parent, authorizes withdrawal, so there is no
  parent-approval gate on either deposits or withdrawals — same
  visibility-not-control posture already used for parent access to a
  child's `quiz_attempts` (Phase 2).

All amounts are integer cents, matching `postings.amount_cents`.

#### Progress calculation

No stored balance column (same "derive on read" principle as `skill_mastery`
and total XP) — two `security_invoker` views compute it from `postings`:

- `account_balances` — `account_id`, `profile_id`, `type`, `name`,
  `target_amount_cents`, `balance_cents` (signed sum of that account's
  postings) for every account.
- `savings_goal_progress` — the same, filtered to `type = 'savings_goal'`,
  plus `percent_complete` (`balance_cents / target_amount_cents * 100`,
  capped at 100, null if there's no target).

Both views are declared `with (security_invoker = true)`. This matters
because migrations run as the `postgres` role, which has `BYPASSRLS` in
Supabase — an ordinary (`security_invoker = false`) view owned by `postgres`
would run with the owner's privileges and silently bypass the
`accounts`/`postings` RLS policies below, leaking every account to every
caller. `security_invoker = true` makes the view evaluate RLS as the calling
user instead, the opposite of `quiz_questions_public`'s deliberate
owner-bypass (which exists specifically to hide one column, not to open up
row visibility).

### School-tier content: `lessons`, `quizzes`, `quiz_questions`, `quiz_attempts`

Phase 2. Lessons and quizzes are shared reference content (like `skills`),
not per-student rows; `quiz_attempts` is the per-student append-only log.

- `lessons` belongs to a `skill` (`skill_id`), has a `content_type`
  (`article` \| `video` \| `interactive`), `content_url` and/or
  `content_body`, an `order_index`, and a `published` flag.
- `quizzes` belongs to a `skill` and/or a `lesson` (at least one required),
  with a `pass_threshold` (default 0.8) and `published` flag.
  `quiz_skill_id(quiz_id)` resolves which skill a quiz should award mastery
  against, whether the quiz hangs off a skill directly or off one of that
  skill's lessons.
- `quiz_questions` holds `question`, `options` (jsonb), `correct_answer`,
  and `order_index`. **`correct_answer` is never exposed to clients** —
  `quiz_questions` has RLS enabled with zero select policies (default deny
  to every non-service-role caller), so the only readable surface is the
  `quiz_questions_public` view (`id`, `quiz_id`, `question`, `options`,
  `order_index`), which is owned by the migration role and therefore reads
  through as that owner, bypassing the base table's RLS for just those
  columns. Only the grading function below reads `correct_answer` directly.
- `quiz_attempts` (`profile_id`, `quiz_id`, `score`, `passed`, `answers`,
  `attempted_at`) is append-only, same pattern as `skill_attempts`/`xp_events`.
- `xp_events.source` gained a `'quiz_attempt'` value alongside Phase 1's
  `skill_attempt` \| `interview_session` \| `bonus`.

#### Auto-grading: `grade_quiz_attempt(p_quiz_id, p_answers)`

A `SECURITY DEFINER` Postgres RPC (`supabase/migrations/00000000000008_grade_quiz_attempt.sql`),
called directly via `supabase-js`'s `.rpc()` — no Edge Function needed since
grading only needs `auth.uid()`, not the Auth Admin API.

- Identifies the student from `auth.uid()`, never a client-supplied
  `profile_id` — a student can only ever grade an attempt as themselves.
- `p_answers` is a jsonb array of `{"question_id": uuid, "answer": text}`.
  The score is always computed here from `quiz_questions.correct_answer`;
  any other fields the client includes (a submitted `score`, `passed`, etc.)
  are ignored — same "never trust client-submitted XP/score" principle as
  Phase 1's derived XP rollups.
- Always inserts one `quiz_attempts` row. If `score >= pass_threshold`, also
  inserts a `skill_attempts` row (`is_correct = true`, resolved skill via
  `quiz_skill_id`) and an `xp_events` row (`source = 'quiz_attempt'`,
  `source_id` = the new attempt id) — mirroring Phase 1's mastery-graph
  pattern where XP/mastery is always a derived write from a scoring event,
  never trusted from the client directly.
- `SECURITY DEFINER` is required specifically so this function can read
  `quiz_questions.correct_answer`, which regular callers cannot. Execute is
  granted to `authenticated` only (revoked from `public`).

### `interview_sessions`

`profile_id`, `firm_style`, `transcript` (jsonb), `rubric_scores` (jsonb).
Structure intentionally loose (jsonb) since the interview rubric/format is
still evolving in later phases.

## Row Level Security

Enabled on every table. Two helper functions gate almost all policies:

- `is_own_or_linked_profile(profile_id)` — true if the row belongs to the
  caller or to one of the caller's linked children (`parent_id = auth.uid()`).
- `is_own_or_linked_account(account_id)` — same idea, resolved through
  `accounts.profile_id`.

`profiles` is indexed on `parent_id` (`idx_profiles_parent_id`) since every
RLS check and parent-dashboard query filters on it.

`skill_attempts` and `xp_events` only have `select`/`insert` policies (no
`update`/`delete`) to keep them genuinely append-only.

`lessons`/`quizzes` are readable by any authenticated user whose own
`profiles.tier` matches the underlying skill's tier, once `published`.
`quiz_questions` has no policies at all (see above — read via
`quiz_questions_public` instead). `quiz_attempts` is append-only and has a
`select` policy only (`is_own_or_linked_profile`) — no `insert`/`update`/
`delete` policy for `authenticated` at all. Rows are written exclusively by
the `SECURITY DEFINER` `grade_quiz_attempt()` function (below), which runs
as the table owner and bypasses `authenticated`-scoped policies; a
self-insert policy was deliberately rejected because it would let a student
bypass grading and fabricate a passing score/answers directly. A linked
parent can read (not write) a child's attempts — visibility, not control,
consistent with the consumer-research finding already reflected in Phase 1's
consent model.

`accounts`/`transactions`/`postings` (Phase 3 tightening): `select` still
uses `is_own_or_linked_profile`/`is_own_or_linked_account`, so a linked
parent can read a child's savings-goal accounts and transactions. `insert`/
`update` on `accounts`, and `insert` on `postings`, were tightened from
"self or linked profile/account" to self-only (`profile_id = auth.uid()` /
resolved through the owning account) — a parent could otherwise open,
rename, or post transactions against a child's savings goal directly,
bypassing the RPCs' student-only checks. `transactions.insert` was already
self-only (`created_by = auth.uid()`). The savings-goal RPCs remain the only
way funds move, and they're `SECURITY DEFINER` so they aren't affected by
this tightening — they run as the function owner and enforce
`profile_id = auth.uid()` themselves before touching any account.
consistent with the consumer-research finding already reflected in Phase 1's
consent model.

## Auth / consent flow (COPPA + GDPR-K)

There is no independent student sign-up. The flow is:

1. **Parent signup** — normal Supabase Auth email/password sign-up, client
   inserts their own `profiles` row (`role = 'parent'`, RLS requires
   `id = auth.uid()`).
2. **Explicit parental consent** — a *separate* step from any
   terms-of-service acceptance, calling the `record-consent` Edge Function
   with the child's display name and an explicit `consent_given: true`. This
   writes a `parental_consents` row (`parent_id = auth.uid()`, from the JWT,
   not client input). Consent is versioned (`consent_version`) so a future
   copy change can be tracked per-record.
3. **Student account creation** — the parent calls `create-student-account`
   with the `consent_id` from step 2, a display name, and a 4–6 digit PIN.
   The function:
   - re-verifies the consent record belongs to the caller and was
     affirmatively given (defense in depth — the DB trigger enforces this
     too, independently);
   - creates a synthetic-email auth user (`student-<uuid>@students.finesse.internal`,
     password = the PIN) via the Auth Admin API — no real student contact
     info is ever collected (data minimization);
   - inserts the `profiles` row (`role = 'student'`, `parent_id`,
     `consent_id`) using `service_role`, which is the only writer for
     student profile rows.
4. **Student login** — the student (or the parent, on the student's behalf)
   signs in with the synthetic email + PIN via the normal
   `supabase.auth.signInWithPassword` client call. No custom session code is
   needed; it's a standard Supabase Auth password sign-in.

### Deletion / retention

`profiles.data_retention_requested_at` is a marker column for recording a
deletion/retention request; actual cascading delete (via `on delete cascade`
FKs from `skill_attempts`, `xp_events`, `accounts`, `interview_sessions`,
etc. down to `profiles`) is a single `delete from profiles where id = ...` by
an operator — the schema already cascades correctly. Building the
operator-facing deletion tool itself is out of scope for this phase.

## Testing

`tests/integration/` (vitest + `@supabase/supabase-js`) against a local
`supabase start` stack:

- `rls-isolation.test.ts` — a parent can read a linked child, cannot read an
  unrelated student; a student can read only their own profile, not another
  student's or their parent's own row.
- `ledger-balance.test.ts` — unbalanced postings are rejected at commit,
  balanced postings succeed.
- `quiz-grading.test.ts` — an all-correct submission passes and awards a
  `skill_attempts` row + XP; a below-threshold submission does neither; a
  client cannot force a pass by adding a fabricated `score`/`passed` field to
  its answers; a student cannot read or insert another student's
  `quiz_attempts`; a linked parent can read but not insert a child's
  `quiz_attempts`; `correct_answer` is unreadable through the base
  `quiz_questions` table but question/options are readable via
  `quiz_questions_public`.
- `consent-gate.test.ts` — `create-student-account` rejects a fabricated
  consent id, rejects another parent's consent record, and — critically — a
  **direct `service_role` insert into `profiles`** bypassing the Edge
  Function entirely is still rejected by the `enforce_student_consent`
  trigger, both for a missing `consent_id` and for a `consent_given = false`
  record. This proves the consent gate is a DB-level invariant, not just an
  application-layer check.
- `savings-goals.test.ts` — deposit increases the goal balance and decreases
  the student wallet (and the transaction nets to zero, verified via
  `account_balances`/`savings_goal_progress`); withdrawal reverses it; an
  over-large withdrawal is rejected; a student cannot deposit into or
  withdraw from another student's goal; a linked parent can read a child's
  savings-goal account/transactions/progress but cannot write to the
  account or call the deposit RPC on the child's behalf.

All tests pass against a provisioned free-tier Supabase project (migrations
applied with `supabase db push`, functions deployed with
`supabase functions deploy`). Test accounts are created via the Admin API
(`auth.admin.createUser`) rather than the public sign-up flow, since the
hosted project's shared-SMTP sign-up path has a signup email rate limit far
too low for a test suite creating many accounts per run; `fileParallelism` is
disabled in `vitest.config.ts` for the same reason. This worktree has no
Docker/Podman, so local `supabase start`/`db reset` still can't be exercised
here, but `supabase db push` to a linked live project needs no Docker.
