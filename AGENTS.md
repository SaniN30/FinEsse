<!-- BEGIN:nextjs-agent-rules -->
# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->

# FinEsse

Next.js 14+ (App Router) + TypeScript + Tailwind CSS v4 + Framer Motion.

- Design system (fonts, palette, spacing, motion conventions): see `DESIGN.md` at
  repo root — read it before adding any new UI so later phases stay visually
  consistent.
- Reusable primitives live in `components/` (`Button`, `LevelCard`, `ProgressBar`,
  `Nav`, `Hero`, `LevelSection`, `PocketMoneyPlanner`, `TierPlaceholder`, `BackLink`) and
  `components/auth/` (`AuthCard`, `FormField`, `SelectField`, `PinInput`) — prefer extending
  these over ad-hoc styling.
- Routes: `/` (landing), `/school`, `/college`, `/job-ready` (tier landing pages;
  `/job-ready` links to both its lesson track and the Phase 9 AI Interview Coach),
  `/settings` (Account, Appearance, Notifications, Help, Legal —
  `components/settings/`, theme state via `lib/settings/theme.ts`), plus the
  Phase 6 auth flow below.
- `tsconfig.json`'s `include` intentionally excludes `vitest.config.ts`/
  `vitest.config.component.ts` (see `tsconfig.vitest.json`) so a dev-tooling
  version drift in vitest/vite plugins can't break `npm run build` — don't
  fold those files back into the main tsconfig's `include`.
- Tailwind v4 theme tokens are defined as CSS variables in `app/globals.css` under
  `@theme inline` (no `tailwind.config` color overrides needed).
- Secondary/muted body text must use `text-muted-foreground` (backed by
  `--muted-foreground`, flips `neutral-500`→`neutral-400` in dark mode), not the raw
  `text-neutral-500`/`text-neutral-600` scale steps — those are fixed values that drop
  below WCAG contrast on dark surfaces. Prominent body copy (lesson content, key data
  values) should use `text-foreground` instead of a raw `neutral-700`, which is nearly
  invisible on dark surfaces since it doesn't flip either.
- Backend (Phase 1-5): Supabase schema, RLS, auth/consent flow, the ledger/mastery-graph
  model, the School-tier lesson/quiz content schema + auto-grading RPC, the College-tier
  content (roles reference table, modeling exercises + rubric-graded submissions), and the
  Phase 5 AI Interview Coach (question bank, submission RPC, Gemini-based rubric-scoring
  Edge Function) are documented in `BACKEND.md` — read it before touching `supabase/` or
  writing any frontend code that talks to the backend. Phase 5 has no audio/speech-to-text
  pipeline (transcript is plain text input).
- Frontend data layer: `lib/supabase/client.ts` is the one browser Supabase client
  singleton (`getSupabaseClient()`); `lib/supabase/auth-context.tsx` (`AuthProvider`/
  `useAuth`, mounted once in `app/layout.tsx`) is the one session/profile listener. Any
  new auth or data-fetching code should build on these rather than creating another
  client instance. Needs `NEXT_PUBLIC_SUPABASE_URL`/`NEXT_PUBLIC_SUPABASE_ANON_KEY` (see
  `.env.local`, gitignored).

## Auth / consent frontend (Phase 6)

- Routes: `/signup`, `/login` (parent), `/consent`, `/create-student`,
  `/student-login`, `/dashboard` — implements Flow A from
  `data/finesse-uiux-planning/report.md` §3. There is deliberately no
  independent student sign-up route; a student account can only be created by
  an authenticated parent via `/consent` → `/create-student`.
- The live Supabase project has email confirmation enabled (`mailer_autoconfirm:
  false`), so `signUp()` often returns no session — `/signup` shows a "confirm
  your email" state in that case, and `/login` + `ensureParentProfile()`
  (`lib/supabase/auth-actions.ts`) create the `profiles` row on first
  post-confirmation login instead.
- The backend has no lookup from a student's display name to their synthetic
  login email (`profiles` RLS blocks anonymous reads by design), so
  `/student-login` can only list students this browser has already created —
  see the caching note in `lib/supabase/student-registry.ts`. This is a known
  frontend-only workaround, not a backend contract.
- Component tests for this flow live in `tests/component/` (vitest + jsdom +
  React Testing Library, run via `npm run test:component`) — separate from the
  `tests/integration/` suite (vitest against the live/local Supabase project,
  run via `npm run test:integration`), which already covers the backend
  consent gate end-to-end.

### Parent signup fields expansion (post-Phase 9)

- `00000000000042_profile_signup_fields.sql` added `education_level` (check
  constrained to `school`/`college`/`working_professional` — distinct from the
  existing `tier` enum, since a parent isn't a student), `institution_name`,
  and `phone_number` to `profiles`, plus a unique index on `phone_number`
  (partial, `where phone_number is not null`). `date_of_birth` already existed
  (added in migration 1 for student COPPA record-keeping) and is reused here
  for the parent's own row rather than duplicated under a new column name.
  These fields are collected on `/signup` only, not `/create-student` —
  `create-student-account`'s data-minimization design (synthetic email, no
  real contact info for students) meant extending phone/email collection to
  the student flow would work against a documented design decision, and
  `/signup` is the only flow that already collects an email/phone-shaped
  identity. No RLS changes were needed: the existing `profiles_select`/
  `profiles_update` policies already scope every column row-wise.
- Duplicate-phone rejection is two-layered: `is_phone_number_taken(text)` (a
  `security definer` RPC, same migration) lets the signup form reject a taken
  phone number before creating an auth user — plain client-side `select`
  against `profiles` can't do this, since RLS hides other users' rows
  entirely including existence. The unique index is still the real
  authority for the race case; `lib/supabase/auth-actions.ts#insertParentProfile`
  maps a `23505` (unique_violation) from the insert itself to the same
  friendly message. Duplicate-email rejection relies entirely on Supabase
  Auth's own `auth.users.email` uniqueness — `signUpParent()` additionally
  checks for `data.user.identities.length === 0` on a successful-looking
  `signUp()` response, which is how a duplicate, already-confirmed email
  presents when the project has email-enumeration protection on (no error,
  but no new identity either).
- This project's shared-SMTP mailer rate limit (see the "Lessons empty" /
  root-cause section below) makes repeatedly calling the real `signUp()`
  end-to-end impractical for verification — both this migration's live
  verification and `tests/integration/helpers.ts`'s `signUpParent()` helper
  work around it by creating the parent via the Admin API
  (`admin.auth.admin.createUser`) instead and driving the rest of the flow
  (profile insert, RLS, RPC, unique-constraint dedup) through a real
  anon-authenticated client from there.

## School lesson→quiz→XP loop and Pocket Money Planner (Phase 7)

- Mastery/XP/balances are always fetched live from the `skill_mastery`/`xp_events`/
  `account_balances`/`savings_goal_progress` views per `BACKEND.md`'s "derive on read"
  principle — never cache a computed level/balance client-side. School lesson→quiz→XP UI
  lives under `app/school/` + `components/school/`; the Pocket Money Planner lives in
  `components/PocketMoneyPlanner.tsx` + `components/pocket-money/`.
- Its component tests live alongside Phase 6's in `tests/components/` (plural — a second
  spec directory covered by the same `vitest.config.component.ts` and
  `npm run test:component`), with its own `tests/components/setup.ts` adding an
  `IntersectionObserver` mock for framer-motion's `whileInView`.
- A student's `student_wallet` is only ever funded by a parent calling `fund_student_wallet`
  (`supabase/migrations/00000000000024_pocket_money_funding.sql`), which posts from the
  parent's own lazily-created `parent_wallet` account — gated by checking the caller is the
  target student's `parent_id`, not `is_own_or_linked_profile` (that helper also matches the
  student themself, which would be wrong here). `deposit_to_savings_goal` now rejects a
  deposit that would exceed the wallet balance, mirroring `withdraw_from_savings_goal`'s
  goal-balance check. The parent-facing "add allowance" form lives in
  `components/pocket-money/FundWalletForm.tsx`, used from `ParentGoalsView.tsx`.

## College-tier frontend (Phase 8)

- College-tier screens live under `app/college/{lessons,quiz,roles,modeling}` and reuse
  tier-agnostic components (`components/lessons`, `components/quiz`) built against the
  School-tier schema (`lessons`/`quizzes`/`quiz_questions_public`/`grade_quiz_attempt`) —
  the same components should be reused for School-tier screens rather than duplicated.
  The Modeling exercise form (`components/modeling`) derives its numeric input fields
  from the `{"key": <number>, ...}` convention every modeling exercise's `instructions`
  text spells out (see `lib/modeling.ts`), since the rubric's keys are never exposed to
  the client. `grade_modeling_submission`'s per-metric `metrics` breakdown (boolean per
  key, no expected values) was added in
  `supabase/migrations/00000000000022_grade_modeling_submission_metric_breakdown.sql`,
  additive to Phase 4.

## Parent dashboard aggregate rollup (Phase 8)

- `/parent/dashboard` shows, per linked child, tier, total XP, mastery %, pocket
  money wallet/savings-goal progress, and Interview Coach scores — all read from
  the single `parent_dashboard_children` view (one row per child, RLS-scoped via
  `is_own_or_linked_profile`, `security_invoker = true`), defined in
  `supabase/migrations/00000000000021_parent_dashboard_aggregate.sql`. Query
  helper: `lib/parent-dashboard/queries.ts`; card UI: `components/parent-dashboard/
  ChildRollupCard.tsx`. That migration also fixes `skill_mastery` (Phase 1) to
  `security_invoker = true`, which it had been missing — read the migration's
  comment before touching either view.

## AI Interview Coach frontend (Phase 9)

- Question picker (`/job-ready/interview`, `components/interview-coach/QuestionPicker.tsx`)
  shows `interview_questions.category` values as plain-text tabs with recent attempts below —
  note the real seeded categories are `behavioral` \| `technical` (see `BACKEND.md`), not the
  `guesstimate`/`framework`/`behavioral` labels an earlier planning doc used; the UI derives
  tabs from whatever categories exist in the data rather than hardcoding a fixed label set.
- Transcript entry + single-reveal scoring live at `/job-ready/interview/[questionId]`
  (`components/interview-coach/{TranscriptEntry,ScoreReveal,InterviewSession}.tsx`), calling
  `submit_interview_session` then `score-interview-session` via
  `lib/interview-coach/queries.ts#submitAndScoreInterviewSession` — one synchronous round
  trip, so `ScoreReveal` renders the headline + all sub-scores (STAR structure, clarity,
  filler-word count) together, never staggered.
- The parent read-only view for this feature is the existing Interview Coach section inside
  `components/parent-dashboard/ChildRollupCard.tsx` (Phase 8) — no separate parent screen was
  added for Phase 9.

## Content depth pass + Job-Ready lesson track (post-Phase 9)

- The original Phase 2/3 seed migrations (`00000000000009`, `00000000000016`) were
  explicitly schema-validation fixtures — one-paragraph lessons, 2-question quizzes.
  `00000000000027_expand_school_content.sql` and `00000000000028_expand_college_content.sql`
  expand those in place (same skill/lesson/quiz ids, longer `content_body` with a worked
  example, 4-6 quiz questions with a recall/application mix) rather than replacing rows, so
  historical `quiz_attempts`/`skill_attempts` referencing those ids stay valid.
- `00000000000028` also replaces the College modeling exercise's rubric/instructions with a
  multi-step build (revenue → COGS → gross profit → net income) matching its lesson's
  3-statement description — still graded by the existing `grade_modeling_submission` RPC,
  which already iterates an arbitrary jsonb-keyed rubric, so no RPC change was needed.
- Job-Ready now has a real lesson track (`00000000000029_seed_jobready_content.sql`:
  interview fundamentals, resume/behavioral basics, case-method basics) at
  `app/job-ready/lessons` + `[skillId]` + `app/job-ready/quiz/[quizId]`, reusing the same
  tier-agnostic `components/lessons`/`components/quiz` components College uses — pass
  `tier="job_ready"` (the schema's tier value; the route segment is `job-ready`).
- `00000000000030_seed_advanced_content.sql` adds 9 new (not expanded-in-place) skills —
  School: compound interest, budgeting; College: statement analysis/ratios, credit risk,
  portfolio construction; Job-Ready: technical interview prep, market-sizing case
  interviews, ethics & compliance — each chained off that tier's most-advanced prior skill,
  at the same lesson/quiz depth as migrations 27-29. It also adds two new case-style
  `modeling_exercises` (DSCR credit assessment on College's `credit-risk-basics`, a
  branch market-sizing case on Job-Ready's `market-sizing-case-interviews`), reusing
  `grade_modeling_submission` unchanged. `components/lessons/LessonDetail.tsx` gained an
  optional `modelingBasePath` prop that fetches/links `modeling_exercises_public` rows for
  the current skill (College and Job-Ready lesson pages now pass it; School doesn't have
  the concept). Job-Ready previously had no modeling route at all — added
  `app/job-ready/modeling/[exerciseId]/page.tsx`, mirroring College's. 30 was free as of
  this migration (see the migration numbering note below).
- `00000000000031_seed_capstone_content.sql` adds one more skill at the top of each tier's
  chain, closing gaps 27-30 left: School `banking-and-inflation-basics` (real return vs.
  nominal interest); College `capital-structure-and-wacc` (debt/equity mix, CAPM cost of
  equity, WACC — plus a multi-step WACC `modeling_exercises` row); Job-Ready
  `advanced-behavioral-interviews` (leadership/conflict/failure question categories, STARL
  for failure stories). Same lesson/quiz depth pattern as 27-30; no schema/RPC changes.
- Migration numbering: this repo has had numbering collisions across parallel branches
  (e.g. `00000000000022` and `00000000000023` each exist twice) — before adding a new seed
  migration, check the highest number in use on `main` *and* any known in-flight branches,
  not just `main` alone, and pick a clearly-past-the-end number to avoid a second collision.
  31 was free as of this migration.

## School-tier content depth pass 2 (post-capstone)

- School had only 7 skills after migrations 09/27/30/31 versus College/Job-Ready's
  deeper chains. `00000000000040_seed_school_content_depth_pass2.sql` adds 8 more
  (008-015: digital payments & online safety, simple investing basics, taxes basics,
  entrepreneurship basics, credit & debt basics, insurance basics, comparison shopping
  & consumer skills, financial goal setting), chaining off `banking-and-inflation-basics`
  (007), bringing School to 15 total skills. Same lesson/quiz depth pattern as
  migrations 27-31 (one article lesson with a worked example + recap, one 5-6 question
  quiz per skill); School still has no `modeling_exercises` concept, so none were added.
  40 was picked per the existing migration-numbering-collision note below (highest
  in use on `main` at write time was 33).
- This worktree has no linked Supabase CLI session and only the anon key in
  `.env.local` (no DB password/service role/access token), so this migration could not
  be pushed to the live project from here — same constraint noted above for
  migrations 27-31.

## Frontend redesign (optimalearn.com reference)

- `DESIGN.md` was reworked to reference https://www.optimalearn.com (cream ground,
  navy ink, a single bright blue brand color, rounded Baloo 2 display type, and a
  hard ink-colored `--shadow-offset` on outlined chrome like `Nav` and the
  `secondary` `Button` variant). This landed only at the shared token/component
  layer (`app/globals.css`, `Button`, `Nav`) — every route inherits it, but a
  per-page pass (dashboards, settings sections, Interview Coach, per-tier lesson
  chrome individually restyled) was explicitly deferred to follow-up work.
- The home page (`app/page.tsx`) got that per-page pass next: `Hero.tsx` is now a
  split two-column layout with floating offset-shadow cards (was a centered
  generic-gradient hero), `LevelCard.tsx` uses flat pastel tier panels with the
  ink-offset border/shadow chrome instead of soft-shadow generic cards, and the
  signed-out `PocketMoneyPlanner` CTA dropped its gradient-plus-blur treatment for
  the same flat offset-shadow language — verified live against optimalearn.com
  reference screenshots via chrome-devtools-axi. Dashboards (parent/student),
  settings, and Interview Coach still need this same per-page pass and live
  verification — a mechanical design-detector pass over those components found no
  violations of the shared tokens, but nobody has looked at them rendered. Signing
  in to check them live was blocked mid-session by Supabase's built-in auth
  mailer's rate limit ("email rate limit exceeded" on `signUp()`, a shared
  per-project cap unrelated to code) — retry once that resets, or configure custom
  SMTP on the Supabase project, before attempting live verification again.
- This repo's dev environment has no live Supabase access (`.env.local` holds
  placeholder credentials, no `supabase` CLI, no linked project ref, no CI/CD
  migration deploy step) — verifying whether migrations `00000000000027`-`00000000000031`
  (School/College content depth + Job-Ready lesson track + advanced-tier and
  capstone skills) are actually applied to the live project requires real project credentials
  from whoever operates it; that gap, not missing code, is the likely cause of a
  "no coursework" report against the live site.
  **Correction (2026-08-01):** `.env.local` in fact holds a real, working anon key
  for `https://lanfhdsfqfzekodynqai.supabase.co` (confirmed live via unauthenticated
  REST calls) — it is not a placeholder. There is still no `supabase` CLI link/access
  token/service-role key here, so pushing migrations from a plain dev checkout isn't
  possible, but reading the schema/RLS shape via the anon key is.

## "Lessons empty" / "calculator not visible" — root causes and fix (2026-08-01, resolved)

This was not one bug but five compounding ones, found and fixed in order while live-verifying
against the deployed app with real Supabase project credentials. Each was independently
sufficient to make the app look broken to an end user, which is why "check the migrations"
alone wouldn't have fully explained the report:

1. **Vercel Deployment Protection** was blocking every `*.vercel.app` URL for the project
   (prod alias, git-branch alias, individual commit deployments) behind a `vercel.com/login`
   wall — no anonymous visitor could reach the Next.js app at all. Resolved separately by the
   captain (Vercel project setting) partway through this session; confirmed cleared by the
   production alias returning 200 instead of a login redirect.
2. **`main` had a real migration-timestamp collision**: `00000000000031_seed_capstone_content.sql`
   and `00000000000031_student_login_lockout.sql` both shipped at prefix `00000000000031`
   (PR #24's "fix" for a different 22/23 collision missed this one). `supabase db push`
   errored on it directly. Fixed by renumbering `student_login_lockout` to
   `00000000000041` (next free slot past 40).
3. **`00000000000031_seed_capstone_content.sql` was recorded as applied in the live
   project's migration history table without its data actually being present** — `supabase
   migration list` showed it applied, but the capstone skills weren't in `skills` (checked via
   service-role REST, which bypasses RLS). Likely a prior `migration repair --status applied`
   used to unblock 32/33 past the same collision, without the SQL ever actually running.
   Fixed via `migration repair --status reverted 00000000000031` then a real `db push`, which
   re-ran it and inserted the missing rows for real this time.
4. **Two migrations had genuine SQL bugs never caught locally**: `00000000000034_seed_
   jobready_workplace_readiness.sql` had two `quiz_questions.options` jsonb array literals
   with unescaped embedded double quotes (invalid JSON — `supabase db push` caught it at
   apply time with SQLSTATE 22P02); `00000000000031/41_student_login_lockout.sql`'s plain
   `alter table add column` failed because `profiles.login_email`/`failed_login_attempts`/
   `locked_until` already existed live (added by someone manually, outside migration
   history) while its backfill UPDATE (needed for all 148 existing students' `login_email`,
   which was null for every one of them) had never run. Fixed by escaping the JSON and
   making the alter/index statements `if not exists`, respectively; both are now applied and
   verified (0 students with null `login_email` after re-running).
5. **The `student-login` Supabase Edge Function had never been deployed to the live
   project at all** (`supabase functions list` showed only `record-consent`,
   `create-student-account`, `score-interview-session`) — every student PIN-login attempt
   failed browser-side with a CORS preflight 404 before even reaching application logic, so
   no student, old or new, could ever log in. Separately, **the live `create-student-account`
   function predated `login_email` being added to its `profiles` insert**, so newly created
   students got a null `login_email` and couldn't log in either even after (5) was fixed.
   Fixed by `supabase functions deploy student-login --no-verify-jwt` and redeploying
   `create-student-account` from current source.
6. **Frontend bug, unrelated to any of the above**: `app/student-login/page.tsx` dead-ended
   on a static "Lessons and quizzes are coming in a later phase" message after a successful
   login — leftover Phase-6 copy that was never updated when Phase 7's real lesson/quiz/XP UI
   landed at `/school`/`/college`/`/job-ready`. A student had no in-app way to reach their
   lessons post-login except manually clicking the tier link in the top nav. Fixed by
   redirecting to the student's own tier path once their profile loads.

All six were verified live end-to-end: created a real parent + student account through the
actual deployed signup/consent/create-student/student-login flow (via the Auth Admin API for
the parent, to skip email-confirmation friction — not a bypass of any app logic, just of the
mailer), confirmed the student lands on a populated 15-skill School list, opened a real lesson,
and confirmed the Pocket Money Planner renders and its "New savings goal" form is interactive.
Test accounts were deleted afterward. Live data as of this session: 45 skills (15 School / 8
College / 22 Job-Ready), 45 lessons, 45 quizzes, 115 interview questions, all migrations
through `00000000000041` applied.

Of the three sibling branches the original task brief named: `fm/finesse-school-content-
depth-followup` (migration `00000000000040`) and `fm/finesse-jobready-content-depth-
followup` (migrations `00000000000034`/`00000000000035`, uncommitted in that branch's
worktree) were real and existed only as local branches in this machine's shared git dir,
never pushed to `origin` — brought forward and pushed as part of this fix. No
`fm/finesse-college-content-depth-followup` branch exists anywhere (local or `origin`) —
there was nothing to bring forward for College.

`components/lessons/LessonList.tsx` still doesn't distinguish "zero rows because RLS/tier
filtered them out" from "genuinely no content" (an empty result renders an empty grid with no
messaging) — not a live bug right now since content is populated, but worth tightening if this
class of report recurs.

## Maintaining this file

Keep this file short and durable — project structure, conventions, and
non-obvious constraints that apply to nearly every session. Point to
authoritative files (like `DESIGN.md`) instead of duplicating their content.
Update it when the project's structure or conventions materially change, not
for routine feature work.
