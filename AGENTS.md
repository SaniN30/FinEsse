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
  `components/auth/` (`AuthCard`, `FormField`, `PinInput`) — prefer extending these
  over ad-hoc styling.
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
- Migration numbering: this repo has had numbering collisions across parallel branches
  (e.g. `00000000000022` and `00000000000023` each exist twice) — before adding a new seed
  migration, check the highest number in use on `main` *and* any known in-flight branches,
  not just `main` alone, and pick a clearly-past-the-end number to avoid a second collision.

## Maintaining this file

Keep this file short and durable — project structure, conventions, and
non-obvious constraints that apply to nearly every session. Point to
authoritative files (like `DESIGN.md`) instead of duplicating their content.
Update it when the project's structure or conventions materially change, not
for routine feature work.
