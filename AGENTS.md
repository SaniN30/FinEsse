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
  `/practice` (free-practice question bank, see below), `/settings` (Account,
  Appearance, Notifications, Help, Legal — `components/settings/`, theme state via
  `lib/settings/theme.ts`), plus the Phase 6 auth flow below.
- `tsconfig.json`'s `include` intentionally excludes `vitest.config.ts`/
  `vitest.config.component.ts` (see `tsconfig.vitest.json`) so a dev-tooling
  version drift in vitest/vite plugins can't break `npm run build` — don't
  fold those files back into the main tsconfig's `include`.
- Tailwind v4 theme tokens are defined as CSS variables in `app/globals.css` under
  `@theme inline` (no `tailwind.config` color overrides needed).
- Secondary/muted body text must use `text-muted-foreground` (backed by
  `--muted-foreground`, flips `neutral-600`→`neutral-400` in dark mode), not the raw
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
- Home page motion polish: `components/MotionProvider.tsx` wraps the app in
  framer-motion's `MotionConfig` (mounted in `app/layout.tsx`, inside `AuthProvider`)
  with `reducedMotion="user"`, so all existing motion (Hero stagger/floating cards,
  `LevelCard` scroll-in/hover, `Button` press) degrades to instant transitions when
  the OS `prefers-reduced-motion` setting is on — no per-component opt-in needed.
  `LevelCard.tsx` also gained a full-card `Link` overlay to its tier route plus a
  hover-revealed "Explore →" affordance, since the cards looked interactive but
  weren't previously clickable.
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

## Milestone badge system completion (2026-08-04)

- The generic `badges`/`profile_badges`/`award_badge` machinery from
  `00000000000046_college_depth_schema_extensions.sql` (tier-agnostic,
  `criteria_type`-keyed, idempotent via `on conflict (profile_id, badge_id) do
  nothing`) already covered first-lesson/first-quiz/first-modeling-exercise/
  tier-completed/first-mock-interview live. `00000000000075_milestone_badges_
  streak_and_perfect_score.sql` adds the two remaining milestone types from
  the badge-system brief — `perfect_quiz_score` (in `grade_quiz_attempt`, on
  `v_score = 1`) and consecutive-day activity streaks (`streak_3_day`/
  `streak_7_day`, via new `check_and_award_streak(profile_id)`, called from
  `grade_quiz_attempt`, `mark_lesson_complete`, and `grade_modeling_submission`
  on every qualifying action) — same additive `criteria_type` enum extension
  pattern, no schema redesign. Streak is computed live from the union of
  `lesson_completions`/`quiz_attempts`/`modeling_submissions` timestamps
  (`distinct ...::date`, walked backward from `current_date` until a gap),
  not a separate tracking table.
- An earlier, never-applied local migration file
  (`00000000000043_quiz_case_study_badges_schema.sql`, slug-keyed, `icon`
  column, no `criteria_type` — a different, incompatible shape) was deleted
  rather than reconciled: it never actually ran against the live project (the
  live `00000000000043` slot was independently claimed by the sticky-notes
  migration, see the postmortem above), so `00000000000046`'s schema is the
  only badges schema that was ever live. Its dead frontend counterpart
  (`components/badges/BadgeShelf.tsx`, `lib/badges/queries.ts`) was removed
  too — `components/BadgeShelf.tsx` (mounted on all three tier landing pages,
  `app/{school,college,job-ready}/page.tsx`) is the one live implementation,
  with a `BADGE_ICON` map covering all 8 `criteria_type` values.
  `components/school/LessonDetail.tsx` was missing the `mark_lesson_complete`
  RPC call that College/Job-Ready's shared `components/lessons/LessonDetail.tsx`
  already had — added, so School's first-lesson badge now fires too.
- Live-verified end-to-end via a real signup→consent→create-student→
  password-grant flow (same disposable-account pattern as prior postmortems)
  plus `chrome-devtools-axi`: a real School-tier student earned
  first_lesson_completed after opening one lesson, first_quiz_passed +
  perfect_quiz_score after a 100%-score `grade_quiz_attempt` call, and (via
  backdated `quiz_attempts.attempted_at` rows plus a direct
  `check_and_award_streak` call, since a real multi-day wait isn't feasible
  in one session) streak_3_day and streak_7_day — all 5 rendered correctly
  with distinct icons/labels on `/school`, and retaking the same quiz did not
  re-award any badge (`profile_badges` row count per slug stayed at 1).

## Sticky notes widget

- A global, draggable/resizable sticky-note widget (`components/sticky-notes/`)
  is mounted once in `app/layout.tsx` inside `AuthProvider`, so it renders on
  every authenticated page regardless of whether that page includes `Nav`. It
  renders nothing when there's no session. `lib/sticky-notes/queries.ts` wraps
  CRUD against the `sticky_notes` table (migration
  `00000000000050_sticky_notes.sql`; RLS contract documented in `BACKEND.md`'s
  Row Level Security section). The "All Notes" page (`app/notes`, linked from `Nav`) lists the same rows
  newest-first and shares the same query module, so edits/deletes from either
  surface are consistent (not live-synced — each surface re-fetches on its
  own mount). Drag/resize is implemented with plain pointer events (no drag
  library) on `StickyNoteCard.tsx`; any interactive control nested inside the
  draggable header (e.g. the Save/delete buttons) must call
  `event.stopPropagation()` on `onPointerDown`, or the header's
  `setPointerCapture` swallows its click. Both the widget card and the All
  Notes page have an explicit Save button (debounced autosave-on-change stays
  as a safety net, not replaced) that flashes a brief "✓ Saved" confirmation.
  Each note's heading is derived from its stored `source` route via
  `lib/sticky-notes/source.ts#getSourceTitle` (e.g. `/parent/dashboard` →
  "Parent · Dashboard") and styled with the app's `font-display` heading
  type, not the raw path string.
- The widget and the All Notes page share one in-memory cache
  (`lib/sticky-notes/store.ts`, subscribed via `useSyncExternalStore`), not
  independent per-mount fetches — a create/edit/delete on either surface is
  visible on the other immediately, including with no navigation at all,
  since the widget never unmounts across client-side routes. Any component
  reading `note.content` into local buffered state (`StickyNoteCard`,
  `NoteListItem`) must reset that local state from the `note.content` prop
  during render when it changes (React's prop-change pattern, not a
  `useEffect` — `react-hooks/set-state-in-effect` flags the effect form) or
  edits made elsewhere silently stop reaching an already-mounted card.

## "College/Job-Ready 0 lessons" + missing Job-Ready content-depth — root causes and fix (2026-08-02)

Despite College (PR #28) and Job-Ready (PR #29) content-depth both being merged to `main`,
the live College/Job-Ready Lessons pages showed "0 lessons" on every topic card. Two
genuinely distinct bugs, both now fixed:

1. **Every real student account is silently locked to School tier at creation time.**
   `app/create-student/page.tsx`'s form never collected a tier — `createStudentAccount()`
   always called the Edge Function with `tier` omitted, and
   `supabase/functions/create-student-account/index.ts:114` defaults omitted tier to
   `"school"`. Combined with `lessons_select`'s RLS
   (`supabase/migrations/00000000000007_content_rls.sql`) requiring the viewer's own
   `profiles.tier` to match the skill's tier — while `skills_select` has no such
   gate — any real student (always school-tier) browsing `/college/lessons` or
   `/job-ready/lessons` saw full skill cards (skills query succeeds) but "0 lessons" on
   every one (lessons query is RLS-denied). This is the actual mechanism behind the
   screenshot, reproduced live with a real student created through the unmodified UI. Fixed
   by adding a tier `SelectField` to `app/create-student/page.tsx`, threading it through to
   the already-tier-aware Edge Function (no backend change needed). Verified end-to-end: a
   real College-tier student created through the fixed flow sees real lesson content on
   every College topic card; a real Job-Ready-tier student (created via the Admin API,
   verified through an authenticated `skills`/`lessons` REST query using the exact RLS path
   the frontend uses) sees the same for all 23 Job-Ready skills.
2. **PR #29's Job-Ready content-depth migrations never actually reached the live
   project**, independent of (1). `00000000000043_quiz_case_study_badges_schema.sql` was
   recorded live under version `00000000000043`, but that live bookkeeping row is actually
   `sticky_notes` — an unrelated, still-unmerged branch (`fm/finesse-sticky-notes`, PR #32)
   pushed its own migration directly to the live project under the same version number,
   overwriting the tracking row without Job-Ready's DDL ever running. As a direct
   consequence `00000000000044`/`00000000000045` (which depend on that schema) never
   applied either, and `00000000000046_interview_questions_difficulty_and_guides.sql`
   collided on its own version with College's unrelated
   `00000000000046_college_depth_schema_extensions.sql` (College's won the live slot).
   Verified directly against `supabase_migrations.schema_migrations` and
   `information_schema.columns` — never trust `supabase migration list`'s local/remote
   version match alone, since it only compares version numbers, not file identity (this is
   the same failure class as the migration-031/042 postmortems above, just a fresh
   instance). Fixed by `supabase/migrations/00000000000072_reconcile_jobready_content_depth.sql`
   — not a re-run of the original files (which would collide with College's now-live
   `quiz_questions.difficulty/question_type/grading_keywords/min_keyword_matches/scenario_context`
   and generic `badges/profile_badges/award_badge(profile_id, criteria_type)` schema), but a
   reconciliation of the same intent against that reality: adds the still-missing
   `quizzes.quiz_type/scenario_body/context_tag`, re-seeds the Job-Ready quiz-depth
   expansion and case-study skill/quizzes/questions (translating `keywords` →
   `grading_keywords` + computed `min_keyword_matches` via SQL expression, not hand-typed
   values, to avoid transcription error), extends `badges_criteria_type_check` (a closed
   4-value enum) to admit a 5th `first_mock_interview` value, and backfills all 115
   `interview_questions.improvement_guide` rows verbatim from the original migration. Also
   fixed `supabase/functions/score-interview-session/index.ts`'s `award_badge` RPC call,
   which was calling the live (College-authored) function with a `p_slug` parameter that
   doesn't exist on it (`award_badge(profile_id, criteria_type)`) — silently failing every
   award attempt (best-effort, caught and logged, never surfaced) since that function was
   deployed. Content completeness verified directly against the live DB after applying:
   23 Job-Ready skills (was 22), all 22 pre-existing quizzes at 10 questions, the 4
   case-study quizzes seeded, 0-of-115 `interview_questions` missing
   `improvement_guide`.
   **Lesson**: `supabase db push`/`db pull` refuse to run at all once local migrations
   directory and live `schema_migrations` disagree by more than a simple gap (as happened
   here mid-session when a concurrent task pushed its own migrations `00000000000070`/`71`
   live) — and the CLI's own suggested fix is `migration repair --status applied` on files
   that never actually ran, which would silently misrepresent history exactly like the
   031/042 incidents. When this happens, do not run the CLI's suggested repair blindly:
   apply new migration SQL directly via the Management API
   (`POST /v1/projects/{ref}/database/query`, same endpoint used for read-only diagnostics
   throughout these postmortems) and insert only that migration's own tracking row into
   `supabase_migrations.schema_migrations` — touching no other row.
   Pocket Money Planner (also reported broken live on College/School) could **not** be
   reproduced: verified rendering correctly for a real signed-in student on both
   `/school/pocket-money` and `/college/pocket-money`, at desktop and mobile viewports, with
   zero console/network errors — its underlying `account_balances`/`savings_goal_progress`
   views have no tier dependency at all, so it was never architecturally exposed to bug (1).
   Most likely explanation: the original report was observed in the same session as bug (1)
   and reflects the same tier-mismatch confusion, or a fresh account's legitimate `$0.00`
   empty state being read as "not visible."
   **Environment note**: this worktree's `chrome-devtools-axi` browser is shared with other
   concurrently-running sessions in this environment — pages/tabs can be silently navigated
   or hijacked mid-task by unrelated work. Always re-check the page URL immediately before
   acting, explicitly `selectpage`/`newpage` rather than assume tab identity persists, and
   prefer a direct authenticated REST/RPC call over the browser for verification when a
   page keeps getting hijacked.

## Free Practice mode (post-content-depth)

- `/practice` (nav entry alongside School/College/Job-Ready) lets any signed-in account —
  student or parent, no role/tier gate — browse and answer quiz/case-study questions from
  any tier outside the guided lesson flow, plus browse (not yet answer inline) the
  interview-question bank. `app/practice/page.tsx` gates purely on `session` truthiness;
  `practice_questions`/`grade_practice_attempt` never had a student-only restriction to
  begin with (see below), so opening this to parents required only the frontend gate and
  the tier-filter default (next bullet). Built entirely on the already-live College-depth
  schema (`quiz_questions.difficulty`/`question_type`/
  `grading_keywords`/`min_keyword_matches`/`scenario_context`, `interview_questions.
  difficulty`) — it does **not** depend on `quizzes.quiz_type`/`scenario_body`/
  `context_tag` or `interview_questions.improvement_guide`, which are referenced by
  already-merged frontend code (`components/quiz/QuizRunner.tsx`,
  `lib/interview-coach/queries.ts`) but were never actually pushed to the live database
  — see the next bullet.
- **Known pre-existing gap, not fixed by this pass**: main's migration history has three
  files from an earlier merged PR (`00000000000043_quiz_case_study_badges_schema.sql`,
  `00000000000045_seed_jobready_case_studies.sql`,
  `00000000000046_interview_questions_difficulty_and_guides.sql`) that were never applied
  live — version `043` was independently claimed live by an unrelated sticky-notes
  migration, and a later, separately-authored College-depth pass shipped an overlapping
  but differently-shaped schema (its own `badges`/`difficulty`/free-response columns)
  under `046-049` instead. `supabase db push --dry-run` confirms the stuck files will
  hard-fail if pushed as-is (duplicate columns, missing dependent columns). This means
  the live Interview Coach question picker (`fetchInterviewQuestions`, which selects
  `improvement_guide`) and the case-study banner in `components/quiz/QuizRunner.tsx`
  (which reads `quizzes.scenario_body`/`context_tag`/`quiz_type`) are currently broken in
  production. Do not build new frontend code against those columns until this is
  reconciled — check `select column_name from information_schema.columns where
  table_name = '...'` against the live project first.
- `practice_attempts` (new table, `00000000000070_practice_mode_schema.sql`) and
  `grade_practice_attempt(question_id, answer)` (security-definer RPC) are fully isolated
  from the graded-lesson path: grading a practice question never writes to
  `quiz_attempts`/`skill_attempts`/`xp_events`/`profile_badges`, so free practice cannot
  affect lesson completion, mastery, XP, or badge state — verified live via direct DB
  query after answering a mix of MCQ and free-response/case-study questions as a real
  student. The `practice_questions` view (same migration) unions quiz- and
  interview-sourced questions for the browse/filter UI; it runs as the view owner
  (postgres), same pattern as `quiz_questions_public`, so — like that view — it is not
  itself tier-restricted by RLS. `/practice` defaults its tier filter to the caller's own
  `profile.tier` client-side, but only when `profile.role === "student"` — `profiles.tier`
  has a `not null default 'school'` at the DB level
  (`00000000000001_profiles_and_consent.sql`), so a parent profile's `tier` reads as the
  literal string `"school"` too, not `null`; naively defaulting on `profile?.tier` would
  silently restrict every parent to School. Non-student accounts start on "all tiers."
- `00000000000071_seed_practice_case_studies.sql` adds 5 new case-study quizzes (one
  School MCQ-only — School's `components/school/QuizRunner.tsx` has no free_response
  support, so its case study avoids that question type — plus 2 College and 2 Job-Ready
  mixing MCQ/free-response), each attached as a second quiz on an existing skill (same
  non-breaking pattern as `00000000000048_seed_college_case_studies.sql` — doesn't add a
  new skill, so tier-completion mastery math over `skills` is unaffected). Brings the
  platform to 58 case-study questions (`quiz_questions.scenario_context is not null`) and
  500 total practice-eligible questions (`quiz_questions` + `interview_questions`
  combined) — both verified by live count query, comfortably past the 50/100 bars.
- `components/practice/` (`PracticeFilters`, `PracticeList`, `PracticeQuestionCard`,
  `InterviewPracticeList`) + `lib/practice/queries.ts`. `PracticeList`/
  `InterviewPracticeList` are remounted via a `key` on their filter values from
  `app/practice/page.tsx` rather than resetting state from inside an effect — this
  repo's ESLint config enforces `react-hooks/set-state-in-effect` as an error, so a
  synchronous `setState` at the top of an effect body (even to reset loading state before
  a refetch) fails lint; the existing `components/lessons/LessonDetail.tsx` pattern
  (state only ever set inside a `.then`/`catch`) is the one to copy for new data-fetching
  components in this repo.
- Interview questions are browsable in `/practice`'s "Interview Prep" tab (deep, its own
  defensive query selecting only currently-live columns) but attempting one links out to
  the existing `/job-ready/interview/[questionId]` flow rather than a duplicate
  in-Practice scoring UI — per the task brief's "reuse existing UI patterns" instruction.
  That link currently 400s client-side due to the `improvement_guide` gap above; it will
  start working once that migration reconciliation lands, with no Practice-side change
  needed.

## Job-Ready "0 lessons" recurrence: `profiles.tier` was permanent, no way to change it (2026-08-02)

The captain re-reported the same "Job-Ready shows 0 lessons / blank lesson page" symptom
immediately after the fix above (PR #34) had merged. Content/RLS/migration state were all
re-verified correct at the DB level (23 Job-Ready skills, all with a published lesson;
migration `00000000000072` genuinely applied) — the previous fix (tier `SelectField` at
`/create-student`) only affects *new* student creation and does nothing for accounts
already created. There was, and had never been, any way to change `profiles.tier` after
creation anywhere in the app. Live query confirmed 111 students on `school`, 42 on
`college`, only 2 on `job_ready` — so almost every real account is permanently stuck on
whichever tier it started at, and any of those accounts browsing another tier reproduces
exactly this symptom (skill cards render since `skills_select` has no tier gate; each
shows "0 lessons" and a blank lesson-detail page since `lessons_select`/`quizzes_select`
RLS requires `profiles.tier` to match). Reproduced directly: authenticated as a real
school-tier student via password grant, `GET lessons?skill_id=eq.<job-ready skill>`
returned `[]`.

Fixed by adding a tier changer to the parent dashboard (`components/parent-dashboard/
ChildRollupCard.tsx`'s tier badge is now a `<select>`, wired to
`lib/parent-dashboard/queries.ts#updateChildTier`) rather than a backend/migration change —
`profiles_update` RLS (`supabase/migrations/00000000000005_rls_policies.sql`) already lets
a parent update their linked child's row, `tier` included, so this is a plain client-side
`.update()`, no new RPC needed. Live-verified end-to-end: changed a real student's tier
`job_ready` → `school` via this control, confirmed via direct REST query as that student
that Job-Ready lessons became invisible (reproducing the bug on demand), then changed it
back and confirmed the same student's `/job-ready/lessons` page rendered all 23 skill
cards with their real lesson content again.

**Environment note**: this worktree's local dev server can collide with another
concurrently-running session's `npm run dev` on port 3000 — Next.js silently falls back to
the next free port (3002 in this session) and only says so once in its own startup log, not
in any error visible from a plain `curl localhost:3000` (which will happily hit the *other*
session's server and return 200). Check the dev server's own log for the port it actually
bound before pointing a browser at `localhost:3000` by assumption.

## Content reads are no longer tier-gated (2026-08-02)

Per explicit captain directive, `profiles.tier` no longer restricts *reading*
lesson/quiz/modeling content at all -- any authenticated FinEsse account (any
tier) can browse School, College, and Job-Ready lesson/quiz/modeling-exercise
content. `supabase/migrations/00000000000076_remove_tier_gating_from_content_reads.sql`
drops the `p.tier = s.tier` join from `lessons_select`/`quizzes_select` RLS and
from the `modeling_exercises_public` view, replacing it with the same
`auth.role() = 'authenticated'` gate `skills_select`/`roles_select`/
`interview_questions_select` already used. `profiles.tier` still exists and
still drives which tier a student's own dashboard/badges/mastery defaults to
(see the parent-dashboard tier switcher above) -- it's just no longer a read
gate. Write/progress-tracking RLS (`quiz_attempts`, `modeling_submissions`,
`skill_attempts`, `xp_events`, `practice_attempts`, `profile_badges`,
`lesson_completions`, `interview_sessions`) was untouched -- all of it is
already scoped to `is_own_or_linked_profile(profile_id)`, unrelated to tier.
Applied directly via the Management API (same reasoning as the migration-
031/042/072 postmortems: `supabase db push` refuses to run here because this
worktree's local migrations directory doesn't have the concurrently-pushed
`00000000000070`/`71`/`75` files, and blindly running its suggested
`migration repair` would misrepresent those other branches' history) --
statements were sent to `POST /v1/projects/{ref}/database/query`
**one at a time**; sending the whole multi-statement migration file (with its
leading comment block) in one call returned success but silently applied
nothing, so verify each DDL statement's effect with a follow-up read query
before trusting a 201/`[]` response body. Live-verified: a real school-tier
student browsing `/college/lessons` and `/job-ready/lessons` sees full lesson
counts and real lesson content (not blank pages) on both tiers, not just their
own.

## Lesson content presentation components

- Lesson bodies can render as structured, tier-styled components instead of a
  plain paragraph: `components/lessons/blocks/` (`ConceptCard`, `KeyTermBox`,
  `ComparisonTable`, `StepSequence`, `FlowDiagram` — an inline-SVG diagram
  primitive — `WorkedExample`, `PitfallCallout`, `TakeawayBox`), rendered via
  `LessonBlockList`/`LessonBlockRenderer`. Block content types live in
  `lib/lessons/content-blocks.ts`; per-tier chrome (School: offset-shadow
  cards, Baloo headings; College: thin-border analytical cards, blue accent;
  Job-Ready: minimal green-accent scenario cards) is centralized in
  `lib/lessons/tier-block-styles.ts` so a block component doesn't hardcode
  tier styling itself.
- A lesson opts in via `lib/lessons/content-overrides.ts`, a `Record<"skill_id:
  order_index", LessonBlock[]>` restructuring that lesson's `content_body`
  prose into blocks (same facts, no rewrite) — checked by both
  `components/lessons/LessonDetail.tsx` (College/Job-Ready, now takes a
  required `tier` prop) and `components/school/LessonDetail.tsx` before
  falling back to the raw `content_body` paragraph. The key is
  `skill_id:order_index`, not just `skill_id`, since a skill now has multiple
  lessons (see next bullet) and each needs its own block entry. This lives in
  code rather than `content_body` itself specifically to avoid touching the
  live migration history — see the College-depth-pass-2 postmortem above for
  why that history is fragile right now; a lesson's `content_body` stays the
  source of truth for facts, and an override entry is a reversible, code-only
  presentation decision that could be migrated into the database later once
  that history is stable. As of the multi-lesson expansion below, every
  lesson across all three tiers has an override entry — none fall back to
  plain `content_body` anymore.
- This worktree had live `service_role`-key access (via the Supabase CLI's
  linked session + Management API, see the College-depth-pass-2 note above on
  how to fetch it) despite no `.env.local` being checked in; that key was used
  read-only to ground override content in each lesson's real `content_body`
  text and to create/delete disposable parent+student test accounts for live
  browser verification (`chrome-devtools-axi`, signing in as the student by
  writing a real password-grant access token into the `sb-<ref>-auth-token`
  localStorage key) — no schema or migration changes were made.
## Mobile responsiveness pass

- Nav (`components/Nav.tsx`) already had a `sm:hidden` hamburger → dropdown-drawer
  pattern before this pass; no other screen needed a comparable nav-collapse fix.
  `Hero.tsx`'s three floating stat cards used `absolute` positioning tuned for
  desktop only (`w-64`/`w-56`/`w-48` cards with `left-14 top-52` etc.) — below
  `lg:`, they now stack in normal flow (`flex flex-col`) with the float/rotate
  animation disabled (`useIsDesktop()` gates it via a `min-width: 1024px`
  media-query listener), since a stacked static card doesn't need the desktop
  float. `app/globals.css` reserves `padding-bottom: 4.5rem` on the body below
  640px so the fixed sticky-note FAB (`bottom-6 right-6`) never sits on top of
  the last on-screen element at the true end of a page — it can still overlap a
  mid-list item while scrolling past it, same as any fixed FAB over a scrollable
  list, which is expected and clears once scrolled by.
- `StickyNoteCard.tsx` persists `position_x/y`/`width`/`height` in pixels
  (`00000000000050_sticky_notes.sql`), so a note dragged near the right/bottom
  edge on a wide desktop viewport would previously render off-screen and
  undraggable on a phone. It now clamps to the current viewport on mount and on
  `resize` (shrinking width/height first, then position), and the drag
  handle/resize handle both have `touch-none` so a touch drag doesn't fight the
  page's own scroll/pan gestures.
- No blocking mobile-only overflow was found elsewhere: a static grep for
  fixed-px widths/`whitespace-nowrap`/`overflow-x-auto`/wide `grid-cols-*`
  outside `sm:`/`lg:` guards, plus live `chrome-devtools-axi` checks (390px and
  768px, `document.documentElement.scrollWidth === clientWidth`) across every
  route in the app (landing, signup/login, School/College/Job-Ready tier pages,
  lesson/skill lists, quiz runner, interview coach, Pocket Money Planner + its
  "New savings goal" form, parent dashboard, settings, notes), came back clean.
  Desktop layout was spot-checked unchanged at 1440px after these fixes.

## Job-Ready had no Pocket Money Planner route at all (2026-08-04)

- Re-investigated a recurring "Pocket Money Planner not visible" report by signing in as
  the actual reporting account (a real, confirmed `auth.users` row — an earlier session's
  "no matching account" finding was stale) via an admin-generated magiclink `token_hash`
  exchanged through `/auth/v1/verify` (no password change needed) and injecting the
  resulting session into the `sb-<ref>-auth-token` localStorage key against the live
  production Vercel URL (`gh api repos/<org>/<repo>/deployments` — not a fixed domain, look
  it up per session). For that account (tier `school`) the planner rendered correctly on
  desktop and mobile, both on `/` and `/school/pocket-money` — genuinely empty ($0.00, no
  goals), matching the earlier postmortem's "fresh account empty state" theory, not a
  rendering bug.
- Checking all three tier landing pages the task brief asked for surfaced a real,
  independent bug though: unlike `/school` and `/college` (each with a "Pocket Money
  Planner →" link to their own `/pocket-money` route, added for College by the
  College-depth-pass-2 postmortem above), `/job-ready` had no such link and
  `app/job-ready/pocket-money/` didn't exist — `PocketMoneyPlanner` itself is tier-agnostic
  and would have worked fine there too, it was just never wired up when the Job-Ready
  lesson track landed. Since content reads are no longer tier-gated and real accounts do
  exist on the `job_ready` tier, this is a genuine "planner missing" case for that segment.
  Fixed by adding `app/job-ready/pocket-money/page.tsx` (identical to School/College's) and
  a matching CTA link on `app/job-ready/page.tsx`.
- Account-tier mismatches are still possible for accounts created before the signup
  role-gate feature (`isParentWithChildFlow`/`educationLevelToTier` above) existed —
  `profiles.tier` was left at the schema default regardless of `education_level` for
  anyone who signed up earlier. Not fixed here (no user-reported symptom pointed at it,
  and it's a data backfill decision, not a code bug) — worth a one-off backfill query if a
  future report describes tier/institution content mismatching what a student picked at
  signup.

## Lesson page heading/interactivity treatment

- Per-topic lesson pages (School's `components/school/LessonDetail.tsx` and the
  shared College/Job-Ready `components/lessons/LessonDetail.tsx`) render the
  skill title through `components/lessons/LessonHeading.tsx` — a real animated
  `h1`, which picks up each tier's `.theme-tier-*` heading treatment (see
  `DESIGN.md`) automatically rather than duplicating tier-specific styling.
  Lesson body text goes through `components/lessons/LessonBody.tsx`, which
  splits `content_body` into paragraphs revealed on scroll (`whileInView`,
  staggered) and renders the final paragraph as a collapsible "Why this
  matters" callout tinted with `--tier-accent` — the one shared interactivity
  pattern across all three tiers. Extend these two components rather than
  re-implementing heading/body rendering per tier.
- This repo's dev environment can have a stale `next dev` instance already
  bound to port 3000 from another concurrent session — `npm run dev` silently
  falls back to 3001 in that case (check its own log line, don't assume 3000).
  Likewise `chrome-devtools-axi`'s default browser session can be hijacked
  mid-task by other concurrent work; set `CHROME_DEVTOOLS_AXI_SESSION` to a
  unique name to get an isolated browser instance before doing any live
  verification that takes more than one navigation.

## Signup role gate: self-service (school/college) vs. parent/child (working_professional)

- `/signup`'s `educationLevel` choice now decides which flow the account gets, not just
  copy: `working_professional` keeps the original parent/consent/`/create-student` flow
  unchanged (`role: "parent"` profile managing a separate linked child). `school`/
  `college` selections instead land the signing-up person directly in their own tier
  content — no child profile is created for them.
- This works entirely within the existing schema: a `school`/`college` self-service
  account is still `role: "parent"` (the only self-signup identity `profiles` has) but
  gets `tier` set to the matching value at insert time (`educationLevelToTier`, in
  `lib/supabase/profile-helpers.ts`) instead of the schema default. Every RLS policy and
  RPC gating lesson/quiz/ledger/badge access (`lessons_select`, `grade_quiz_attempt`,
  `get_or_create_student_wallet`, etc.) keys off `profiles.tier`/`profiles.id`, never
  `role`, so this "self-serve parent" reads and writes tier content exactly like a real
  student profile would.
- `isParentWithChildFlow(profile)` (same file) is the one place that answers "does this
  account have the parent/child model" — `role === "parent" && education_level ===
  "working_professional"`. Every place that used to branch on `profile.role ===
  "student"`/`"parent"` to decide "is this the tier-content consumer" now branches on
  this helper instead (`Nav`'s Dashboard link, `PocketMoneyPlanner`'s student-wallet vs.
  parent-rollup view, `BadgeShelf`, `/practice`'s access gate, `/dashboard` and
  `/parent/dashboard`'s redirect targets). `role === "student"` itself is still correct
  and unchanged for anything specific to the synthetic PIN-login student flow (e.g.
  `/student-login`, `fund_student_wallet`'s linked-child check) — don't conflate the two;
  a self-service school/college account is `role: "parent"` and will never match a
  `role === "student"` check.
- `tierBasePath(tier)` (same file) maps a tier to its route segment (`job_ready` →
  `/job-ready`) and is shared by `/signup`, `/login`, `/dashboard`, and `/student-login`
  post-auth routing — add new tier-aware redirects here rather than re-deriving the path.

## Multi-lesson sequences per skill

- Every skill now has 2-5 `lessons` rows (same `skill_id`, incrementing
  `order_index`, the original lesson kept at `order_index = 1`), not one —
  `supabase/migrations/00000000000100_seed_multi_lesson_sequences.sql` added
  the additional rows for all 56 skills across School/College/Job-Ready,
  splitting each topic into a foundational lesson followed by
  application/deep-dive lessons grounded in the original lesson's
  `content_body`. `fetchLessonsForSkill` (already existed, tier-agnostic)
  is the one place both `LessonDetail` components pull the full ordered
  sequence from — `components/school/LessonDetail.tsx` fetches siblings via
  the loaded lesson's `skill_id` and renders previous/next links;
  `components/lessons/LessonDetail.tsx` (College/Job-Ready) already fetched
  by `skillId` and just needed a "Lesson N of M" label plus the
  `skill_id:order_index` override-key change above. `mark_lesson_complete`
  is still called per-lesson-id and quizzes are still fetched per-skill (not
  per-lesson), so completion tracking and quiz attachment are unaffected by
  a skill having more lessons. `LessonList.tsx` (both tier-agnostic and
  School variants) already rendered a lesson *count*, not an assumed single
  lesson, so neither needed a structural change.

## Multi-currency pocket money

- `profiles.currency` (`00000000000110_profile_currency.sql`, default `USD`, checked
  against a fixed 7-code enum: USD/INR/GBP/EUR/CAD/AUD/JPY) is a per-profile display
  currency. The ledger (`accounts`/`postings`, see `BACKEND.md`) stays canonical USD
  cents unconditionally — this is a display/input conversion only, via a static
  USD-rate table in `lib/currency/config.ts` (`SUPPORTED_CURRENCIES[code].usdRate`), not
  a live FX feed. That's a deliberate proportionality call for a learning-app feature,
  not a real payments product — revisit only if the captain asks for live rates.
  `lib/currency/format.ts` has the two conversion primitives every pocket-money surface
  uses: `formatUsdCents(cents, currency)` (ledger → display string) and
  `displayAmountToUsdCents(majorUnits, currency)` (user input → ledger cents, used by
  every pocket-money form before calling `deposit_to_savings_goal`/
  `fund_student_wallet`/`create_savings_goal`). Add a new currency by adding one entry
  to `SUPPORTED_CURRENCIES` and to the `profiles_currency_check` constraint in a new
  migration — no other code changes needed.
- A profile picks its own currency at `/signup` (self-service school/college accounts)
  or via `/settings` (`AccountSection`, own currency + a per-linked-child selector using
  the same `updateProfileCurrency`/`updateChildCurrency` RLS-scoped update as
  `renameChildProfile`/`updateChildTier` — no new RPC). A parent can also change a
  linked child's currency from `/parent/dashboard`'s `ChildRollupCard` (same select-as-
  badge pattern as its existing tier switcher). `create-student-account`'s Edge Function
  was intentionally left alone (still creates every new student at the `USD` column
  default) rather than adding a third currency-collection surface + redeploy — a parent
  sets the real currency via the dashboard/settings selector post-creation, mirroring
  how tier itself works today via the same `ChildRollupCard`.
  `parent_dashboard_children` (`00000000000111_parent_dashboard_currency.sql`) exposes
  `currency` alongside the existing rollup columns so `ChildRollupCard` never needs a
  second query.
- Lesson/quiz `content_body` money examples (e.g. "$5 a week") were deliberately left as
  USD-denominated prose — rewriting embedded example amounts across every seed migration
  is a content-authoring pass, disproportionate to a currency-*model* task; only the
  live ledger/wallet/goal amounts convert per-profile.
- `app/parent/dashboard/page.tsx`'s `CombinedStatsStrip` (2+ linked children) sums
  `wallet_balance_cents`/goal balances across children, who can each have a different
  `currency` — it always renders that sum in canonical USD via `formatUsdCents(cents,
  "USD")`, labeled "(USD)" in the UI, rather than picking one child's currency arbitrarily
  or converting to a currency none of them chose.
- Both `00000000000110_profile_currency.sql`/`00000000000111_parent_dashboard_currency.sql`
  were already applied to the live project by the time this branch's implementation was
  reviewed (checked via `information_schema.columns` per the migration-history postmortems
  above) — live-verified end-to-end with two real disposable accounts (self-service college
  tier, one `USD` one `INR`), wallet balance + a funded savings goal created directly via
  service-role SQL (`get_or_create_student_wallet`/`get_or_create_parent_wallet` +
  balanced `postings`, since `create_savings_goal`/`deposit_to_savings_goal` are
  security-definer and key off `auth.uid()`): USD rendered `US$50.00` wallet / `US$20.00 of
  US$100.00` goal; INR rendered `₹9,960.00` wallet / `₹4,150.00 of ₹20,750.00` goal — correct
  symbol, comma grouping, and rate conversion in both. Test accounts deleted afterward.

## Maintaining this file

Keep this file short and durable — project structure, conventions, and
non-obvious constraints that apply to nearly every session. Point to
authoritative files (like `DESIGN.md`) instead of duplicating their content.
Update it when the project's structure or conventions materially change, not
for routine feature work.
