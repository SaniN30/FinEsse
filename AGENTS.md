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
  `Nav`, `Hero`, `LevelSection`, `PocketMoneyPlanner`, `TierPlaceholder`) and
  `components/auth/` (`AuthCard`, `FormField`, `PinInput`) — prefer extending these
  over ad-hoc styling.
- Routes: `/` (landing), `/school`, `/college`, `/job-ready` (tier placeholders,
  content lands in later phases), plus the Phase 6 auth flow below.
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

## Maintaining this file

Keep this file short and durable — project structure, conventions, and
non-obvious constraints that apply to nearly every session. Point to
authoritative files (like `DESIGN.md`) instead of duplicating their content.
Update it when the project's structure or conventions materially change, not
for routine feature work.
