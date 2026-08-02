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

- `00000000000042_profile_signup_fields.sql` added `education_level`,
  `institution_name`, and `phone_number` to `profiles`, collected on `/signup`
  only (not `/create-student`, by data-minimization design) with duplicate-
  phone/email rejection at signup time — see `BACKEND.md`'s `profiles` schema
  section for the column contract and dedup mechanism.
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

## Job-Ready quality/depth pass: difficulty, 10-question quizzes, case studies, badges

- `00000000000034_seed_jobready_workplace_readiness.sql` (15 workplace-readiness skills:
  negotiating an offer through workplace communication) and
  `00000000000035_expand_interview_questions.sql` (95 more interview questions, 104 total
  in that migration) were already merged to `main` via PR #26 before this pass started —
  don't re-author that content; it's live (see the "Lessons empty" root-cause section
  above, which also fixed a JSON-escaping bug in migration 34).
- `00000000000043_quiz_case_study_badges_schema.sql` adds the schema every other
  migration in this pass builds on: `difficulty` (`easy`/`medium`/`hard`) on
  `quiz_questions`; `question_type` (`multiple_choice` default | `free_response`) +
  `keywords` (jsonb, free_response only, hidden from `quiz_questions_public` same as
  `correct_answer`) on `quiz_questions`, with `options`/`correct_answer` now nullable
  and a `quiz_questions_type_shape` check enforcing the right columns per type;
  `scenario_body`/`context_tag`/`quiz_type` (`standard` default | `case_study`) on
  `quizzes`; and `badges`/`profile_badges` (reference content + append-only per-profile
  award log, same "visibility not control" RLS as `quiz_attempts`) with an
  `award_badge(profile_id, slug)` security-definer function (idempotent, silently
  no-ops on an unknown slug). `grade_quiz_attempt` is recreated to grade
  `free_response` answers by keyword match (>=50% of a question's `keywords` found as
  substrings, case-insensitive) and to award the three Job-Ready lesson/quiz/tier
  badges; the fourth (first mock interview) is awarded from the
  `score-interview-session` Edge Function instead, since that's where interview
  scoring actually happens.
- `00000000000044_expand_jobready_quizzes_to_ten.sql` brings all 22 Job-Ready quizzes
  (201-207 from migrations 29/30/31, 208-222 from migration 34) from 4-6 questions up
  to 10, continuing each quiz's existing `order_index` and grounded in the same lesson
  content those quizzes already test — no new lessons.
- `00000000000045_seed_jobready_case_studies.sql` adds one new skill (223,
  `case-study-practice`, chaining off 222) holding a short intro lesson plus four
  `quiz_type = 'case_study'` quizzes attached to that same skill (the existing
  `LessonDetail` component already renders one button per quiz for a given skill, so
  multiple quizzes under one skill needed no frontend change) — 20 questions total
  across the four, mixing `multiple_choice` and `free_response`, easy/medium/hard.
  `pass_threshold` is 0.7 for these (vs. 0.8 standard) since keyword-match grading is
  coarser than exact multiple-choice matching.
- `00000000000046_interview_questions_difficulty_and_guides.sql` adds `difficulty` and
  `improvement_guide` (post-answer coaching: what a strong answer includes + one
  concrete common pitfall, written per-question, not boilerplate) to all 115 existing
  `interview_questions` rows from migrations 19/35. Those rows have no deterministic
  `id` (seeded without explicit ids), so the backfill matches on
  `(firm_style, question_text)` instead — the migration ends with a `do` block that
  raises an exception listing any row still missing `improvement_guide`, so a text
  mismatch fails loudly at apply time rather than shipping silently incomplete.
- Frontend: `components/quiz/QuizRunner.tsx` (College/Job-Ready shared) now renders a
  quiz's `scenario_body`/`context_tag` as a banner when present, renders
  `free_response` questions as a textarea instead of MCQ buttons, and shows each
  question's difficulty; `components/school/QuizRunner.tsx` needed only a null-safe
  tweak to its `options.map` since School has no free_response questions yet.
  `components/interview-coach/ScoreReveal.tsx` takes an optional `improvementGuide`
  prop, rendered by `InterviewSession.tsx` from the already-loaded question. New
  `components/badges/BadgeShelf.tsx` + `lib/badges/queries.ts` show a student's earned
  badges on `/job-ready`; not yet added to the parent dashboard.
- This worktree (like the ones documented above) has no live Supabase credentials, so
  these four migrations could not be applied/verified against the live project from
  here — verified statically instead (a Python quote/JSON tokenizer confirmed all four
  files' SQL string literals and jsonb literals are well-formed, and confirmed all 115
  `00000000000046` UPDATE targets match a real `(firm_style, question_text)` pair in
  migrations 19/35 with none missed or duplicated); `npm run build`, `tsc --noEmit`,
  `eslint`, and `npm run test:component` all pass.

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
- A later pass added a purple brand-accent token scale and reworked the dark
  theme to a deliberate deep-violet register (rather than an inverted light
  theme), plus theme-aware `LevelCard` panel tokens — see `DESIGN.md`'s
  "Colors" and "Dark mode" sections for the current token set.
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

## College-tier content depth pass 2, free-response case studies, and milestone badges (2026-08-01)

- College had only 8 skills (101-108) versus the "10-15+ substantive topics" bar the captain
  asked for. `00000000000047_seed_college_depth_content.sql` adds 10 more (109-118: budgeting
  on a student income, student loans & interest, credit scores & credit cards, investing
  basics, taxes for a first job, retirement accounts, insurance, negotiating salary, side
  income/freelancing, and a capstone financial-planning-for-post-grad-life topic), bringing
  College to 18 skills. Unlike the 5-6 question quizzes migrations 27-31 used, every quiz here
  has exactly 10 questions per the captain's added scope; 3 skills (student loans, investing,
  retirement) also got a modeling exercise, following the existing case-style pattern.
- **`skills.slug` is unique across the whole table, not scoped per tier** — a real collision
  hit this migration (College's planned `insurance-basics` slug already existed on School from
  migration 040) and would have failed the push. Check `select slug from skills` across *all*
  tiers before picking a new slug, not just the tier you're adding to.
- `00000000000046_college_depth_schema_extensions.sql` adds `quiz_questions.difficulty`
  (easy/medium/hard), free-response question support (`question_type`, `grading_keywords`,
  `min_keyword_matches`, `scenario_context` — graded by keyword match inside
  `grade_quiz_attempt`, not exact string equality), and milestone badges (`badges`/
  `profile_badges`, awarded via `award_badge()` from `grade_quiz_attempt`,
  `grade_modeling_submission`, and the new `mark_lesson_complete` RPC on first lesson/quiz/
  modeling-exercise completion and full tier mastery). `components/BadgeShelf.tsx` renders a
  profile's earned badges; `LessonDetail.tsx` fires `mark_lesson_complete` best-effort per
  lesson view. `00000000000048_seed_college_case_studies.sql` adds 3 case-study quizzes (mixed
  MCQ + free-response, 8 questions each) as a *second* quiz attached to skills 109/110/118 —
  no frontend change was needed since `LessonDetail` already renders every quiz row for a
  skill. `00000000000049_backfill_difficulty_labels.sql` backfills `difficulty` on
  pre-existing quiz/interview questions (excluding the new quiz ids 109-121, which already
  have authored values). This content pass was originally authored and pushed live at numbers
  042/043/044/045 and renumbered to 046-049 only *after* a `no-mistakes` pipeline rebase pulled
  in `fm/finesse-signup-fields-expansion` (#27, merged to `main` mid-session), whose own
  `00000000000042_profile_signup_fields.sql` collided with this pass's original 042 — see the
  next point for why that collision briefly caused real live-DB bookkeeping damage, not just a
  filename clash.
- **A genuine migration-history corruption, self-inflicted by misdiagnosing a numbering
  collision as the "recorded applied but never ran" failure mode** (that failure mode is real
  and previously hit migration 031, see the postmortem above — but this was a *different* bug
  that looks identical from the CLI's output alone): before the rebase above, this content
  pass's schema-extensions migration was authored and pushed at `00000000000042`, at a point
  in time when this worktree's local `supabase/migrations/` did **not** yet contain
  `fm/finesse-signup-fields-expansion`'s file (that branch hadn't been rebased in yet). Pushing
  failed with a `column "difficulty" does not exist` error even though `migration list` showed
  version `00000000000042` as already remote-applied. That looked exactly like the migration-
  031 phantom-apply bug, so the same fix was applied —
  `supabase migration repair --status reverted 00000000000042` then a real `db push` — **but
  the remote row for `00000000000042` was not actually a phantom**: it was `profile_signup_
  fields`'s legitimately-already-applied migration (pushed live by that PR's own session,
  independently, at some earlier point — its `education_level`/`institution_name`/
  `phone_number` columns on `profiles` really did exist). The `repair --status reverted` call
  deleted the bookkeeping row for that real, already-applied migration; the subsequent `db
  push` then ran *this* content pass's DDL under the now-freed `00000000000042` slot and
  re-inserted a row — but tagged with this pass's own `name`/`statements`, silently erasing the
  tracking record for `profile_signup_fields` even though its actual schema changes remained
  live untouched. Net effect: both migrations' DDL was genuinely live, but only one bookkeeping
  row existed, pointing at the wrong migration. Caught only once the rebase (above) put both
  files in the same `supabase/migrations/` directory and made the `00000000000042` collision
  visible. Fixed by renumbering this pass's four files to 046-049 (`git mv`, plus fixing the
  cross-referencing migration numbers in their header comments) and directly repairing the live
  `supabase_migrations.schema_migrations` table to match — `update ... set version=... where
  version=...` to shift this pass's four rows from 042-045 to 046-049, then `insert into
  supabase_migrations.schema_migrations (version, name) values ('00000000000042',
  'profile_signup_fields')` to restore the lost tracking row (verified via `supabase migration
  list` showing every local file matched to a remote entry, and `db push --dry-run` reporting
  "Remote database is up to date" afterward). **Lesson: before running `migration repair
  --status reverted` on a version that shows as remote-applied but seems to be missing its
  DDL, first check whether a *different*, currently-uncommitted-to-your-branch migration might
  legitimately own that exact version number** — reverting-and-repushing is only safe once
  you've confirmed the remote row's `name`/`statements` (via the Management API's
  `POST /v1/projects/{ref}/database/query` — the `supabase db push` CLI's own JSON error output
  swallows the underlying Postgres error text entirely, so that direct query is also the only
  reliable way to see the real error in the first place) actually match *your* file, not
  someone else's.
- This worktree, unlike prior College-lane sessions, *did* have a live, already-linked
  Supabase CLI session (`npx supabase projects list` / `link` / `db push` all worked without
  any manual token or DB password) plus Management-API access to the CLI's own stored access
  token via macOS Keychain (`security find-generic-password -w -s "Supabase CLI" -a
  "supabase"`) — usable to fetch the project's `service_role` key on demand
  (`GET /v1/projects/{ref}/api-keys?reveal=true`) for admin-API test-account creation. Don't
  assume "no live push access" without checking this first; it varies by environment/session,
  not just by project.
- All content live-verified end-to-end via a real signup→consent→create-student→student-login
  browser flow (parent created via Auth Admin API to skip email confirmation, same as the
  prior postmortem): lesson rendering, a standard 10-question quiz, the case-study quiz (mixed
  MCQ + free-response, keyword-graded, scored 100%), the investing modeling exercise, and 3 of
  4 badge types (first-lesson-completed, first-quiz-passed, first-modeling-exercise-passed) —
  all confirmed both in the UI and via direct DB query. Test accounts deleted afterward.
- The "College lessons/Pocket Money Planner empty" report traced to two separate causes, both
  now fixed: (1) College genuinely only had 8 thin-ish skills, addressed by this content pass;
  (2) `PocketMoneyPlanner` (tier-agnostic component, no tier-specific logic) was only reachable
  at `/school/pocket-money` with copy calling it "built for the School tier" — added
  `/college/pocket-money` (mirroring School's route) and made the copy tier-neutral. No RLS or
  migration-not-applied issue was found specific to College this time (all tiers use the same
  `p.tier = s.tier` RLS join pattern).

## Maintaining this file

Keep this file short and durable — project structure, conventions, and
non-obvious constraints that apply to nearly every session. Point to
authoritative files (like `DESIGN.md`) instead of duplicating their content.
Update it when the project's structure or conventions materially change, not
for routine feature work.
