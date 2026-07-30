# FinEsse Backend (Phase 1)

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
| `consent_id` | FK to `parental_consents`, required for students |
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
- `consent-gate.test.ts` — `create-student-account` rejects a fabricated
  consent id, rejects another parent's consent record, and — critically — a
  **direct `service_role` insert into `profiles`** bypassing the Edge
  Function entirely is still rejected by the `enforce_student_consent`
  trigger, both for a missing `consent_id` and for a `consent_given = false`
  record. This proves the consent gate is a DB-level invariant, not just an
  application-layer check.

This environment does not have Docker/Podman available, so these tests are
written and type-check but have not been executed here — see the
`fm/finesse-phase1-schema-auth` status log for that caveat. Run them with
`npm run test:integration` once Docker is available.
