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
`quiz_questions_public` instead). `quiz_attempts` is append-only: a student
can read/insert only their own rows (`is_own_or_linked_profile` for select,
a stricter `profile_id = auth.uid()` for insert so a parent cannot write on
a child's behalf); a linked parent can read (not write) a child's attempts —
visibility, not control, consistent with the consumer-research finding
already reflected in Phase 1's consent model.

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

All 20 tests pass against a provisioned free-tier Supabase project (migrations
applied with `supabase db push`, functions deployed with
`supabase functions deploy`). Test accounts are created via the Admin API
(`auth.admin.createUser`) rather than the public sign-up flow, since the
hosted project's shared-SMTP sign-up path has a signup email rate limit far
too low for a test suite creating many accounts per run; `fileParallelism` is
disabled in `vitest.config.ts` for the same reason. This worktree has no
Docker/Podman, so local `supabase start`/`db reset` still can't be exercised
here, but `supabase db push` to a linked live project needs no Docker.
