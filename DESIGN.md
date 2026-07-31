# FinEsse Design System (Phase 0)

Scaffolded on Next.js 14+ (App Router) + TypeScript + Tailwind CSS v4 + Framer Motion.

## Typography

Font pairing chosen to read as a modern fintech/edtech product, not a generic SaaS
default (no Geist, no system fallback as the visible face):

- **Display / headings — [Space Grotesk](https://fonts.google.com/specimen/Space+Grotesk)**
  (weights 500/600/700). Geometric, slightly technical, confident — used for `h1–h4`
  and anything branded (`.font-display`).
- **Body / UI — [Inter](https://fonts.google.com/specimen/Inter)** (weights 400/500/600).
  Highly legible at small sizes, standard for data-dense product UI.

Both are loaded via `next/font/google` in `app/layout.tsx` as CSS variables
(`--font-space-grotesk`, `--font-inter`) and wired into Tailwind through
`--font-display` / `--font-sans` in `app/globals.css`.

## Color Palette

Custom scales defined as CSS variables in `app/globals.css` and exposed to Tailwind
via `@theme inline`, deliberately avoiding Tailwind's stock indigo/gray defaults.

| Role | Token | Hex | Use |
|---|---|---|---|
| Primary (brand) | `primary-500` | `#6E46EA` | CTAs, links, brand accents (Amethyst) |
| Primary dark | `primary-700` | `#4824AB` | Gradients, dark surfaces |
| Secondary | `secondary-500` | `#3D6BEF` | Secondary accents, School tier |
| Accent | `accent-500` | `#1FC491` | Growth/money cues, Job-Ready tier, progress bars |
| Neutral (warm ink, not gray) | `neutral-50`…`neutral-950` | `#F7F6F3` → `#0C0B08` | Backgrounds, text, borders |

Tier accent mapping (`--color-tier-school` / `--color-tier-college` /
`--color-tier-jobready`, used by `LevelCard` and every `bg-tier-*`/`text-tier-*`/
`border-tier-*` consumer — the single approved set, per the Lavish design pass):
- School → `#C98B7D` (`#D9A7A0` in dark mode)
- College → `#6E46EA` (`#A98CF5` in dark mode)
- Job-Ready → `accent-500` `#1FC491` (constant across themes)

Each tier root (`app/school`, `app/college`, `app/job-ready`) also wraps its
pages in a `.theme-tier-*` class (`app/globals.css`) carrying the Lavish
three-tier visual language: pixel-art School (chunky radius, pixelated
image-rendering), transitional College (softer radius, gradient underline),
minimal Job-Ready (ink-colored heading, default radius, no extra chrome).

### Dark mode

Dark variant is driven by `prefers-color-scheme` and an optional `data-theme`
attribute override on `:root`. Background/foreground/surface tokens
(`--background`, `--foreground`, `--surface`, `--surface-border`) flip; the
primary/secondary/accent scales stay constant so brand color reads consistently
in both themes.

## Spacing & Radius

- Base spacing follows Tailwind's default 4px scale — no custom overrides needed
  for Phase 0. Section padding standardizes on `px-6` (mobile) with a `max-w-6xl`
  or `max-w-3xl` content container.
- Card corner radius: `--radius-card: 1.25rem` (`rounded-[var(--radius-card)]`),
  used consistently across `LevelCard` and the Pocket Money Planner panel.
- Soft elevation: `--shadow-soft` — a subtle two-layer shadow for cards and buttons,
  avoiding harsh default Tailwind shadows.

## Motion Conventions

Framer Motion is the animation library. Conventions for later phases:

- **Entrance easing**: `[0.25, 1, 0.5, 1]` (ease-out-quart) for all appear/reveal
  animations — snappy start, soft landing.
- **Hero entrance**: staggered children (`staggerChildren: 0.12`) fading up
  (`y: 24 → 0`) — see `components/Hero.tsx`.
- **Scroll reveals**: `whileInView` with `viewport={{ once: true, margin: "-80px" }}`
  for cards/sections below the fold — see `LevelCard`, `LevelSection`,
  `PocketMoneyPlanner`.
- **Hover/press micro-interactions**: buttons lift (`y: -2, scale: 1.015`) on hover
  and settle (`scale: 0.97`) on press with a spring transition
  (`stiffness: 400, damping: 24`); cards lift `y: -6` on hover with a glow reveal.
- **Progress bars**: animate width from 0 on scroll-into-view, 0.9s duration.

## Components (Phase 0 primitives)

Located in `components/`, typed, and used on the landing page:

- **`Button`** (`Button.tsx`) — `primary` / `secondary` / `ghost` variants,
  `md` / `lg` sizes, built-in hover/press motion.
- **`LevelCard`** (`LevelCard.tsx`) — tier-aware card (school/college/jobready)
  with badge, topic list, and embedded `ProgressBar`.
- **`ProgressBar`** (`ProgressBar.tsx`) — animated fill, optional label.

## Routes

- `/` — landing page (hero, 3-tier level preview, Pocket Money Planner placeholder)
- `/school`, `/college`, `/job-ready` — tier placeholder pages, ready for Phase 1+
  content

## Not in this phase

Supabase/backend wiring is intentionally out of scope for Phase 0 — this is
frontend scaffolding and the design system only.
