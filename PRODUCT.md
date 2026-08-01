# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users
[Inferred from AGENTS.md/BACKEND.md — not confirmed via live interview; this is an
unattended autonomous task with no synchronous human to interview.] Two roles:
- **Students** (School / College / Job-Ready tier) working through lessons, quizzes,
  modeling exercises, an AI interview coach, and a pocket-money/savings tool.
- **Parents**, who create/link student accounts, fund a student's wallet, and view a
  read-mostly rollup dashboard of their child's progress across tiers.

## Product Purpose
FinEsse is a financial-literacy edtech product teaching money/finance skills across
three escalating tiers (School → College → Job-Ready), each with lessons, auto-graded
quizzes, and tier-appropriate practice (School: pocket-money planner; College: role
explorer + financial modeling exercises; Job-Ready: AI-scored mock interviews). XP and
mastery are derived live from an event ledger, never cached client-side.

## Positioning
[Inferred] A single product that grows up with the student — the same lesson/quiz
UI and mastery model spans School through Job-Ready, rather than three disconnected
apps, with a real transactional pocket-money system (not a toy) as the youngest tier's
hook.

## Operating Context
Next.js 14 App Router, TypeScript, Tailwind v4, Framer Motion, Supabase (Postgres +
RLS + Edge Functions). See `AGENTS.md`/`BACKEND.md` for full architecture. This pass
targets shared visual language (tokens, Nav, Button, cards, layout) reused by every
route, not any single page.
