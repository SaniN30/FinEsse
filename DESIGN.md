# FinEsse Design System (Optimalearn-referenced redesign)

Scaffolded on Next.js 14+ (App Router) + TypeScript + Tailwind CSS v4 + Framer Motion.

Redesign direction (captain-pinned reference: https://www.optimalearn.com): a warm
cream ground with navy ink, a single bright blue brand color carrying every primary
action, and rounded/pill chrome with a hard ink-colored offset shadow on outlined
surfaces (nav bar, secondary buttons) — a friendly, slightly playful "study buddy"
register appropriate for a student-facing product, in Operate mode (task/dashboard
UI), so the treatment stays restrained: one accent color, no gradients-as-default,
legibility and hierarchy first.

## Typography

- **Display / headings — [Baloo 2](https://fonts.google.com/specimen/Baloo+2)**
  (weights 500/600/700/800). Rounded, chunky, friendly — matches optimalearn's
  display type — used for `h1–h4` and anything branded (`.font-display`).
- **Body / UI — [Inter](https://fonts.google.com/specimen/Inter)** (weights 400/500/600).
  Highly legible at small sizes, standard for data-dense product UI.

Both are loaded via `next/font/google` in `app/layout.tsx` as CSS variables
(`--font-baloo-2`, `--font-inter`) and wired into Tailwind through
`--font-display` / `--font-sans` in `app/globals.css`.

## Color Palette

Custom scales defined as CSS variables in `app/globals.css` and exposed to Tailwind
via `@theme inline`.

| Role | Token | Hex | Use |
|---|---|---|---|
| Primary (brand) | `primary-500` | `#1A56FF` | CTAs, links, brand accents (Optimalearn Blue) |
| Primary dark | `primary-700` | `#1034A8` | Gradients, dark surfaces |
| Secondary | `secondary-500` | `#3D84EF` | Chat/coach surfaces |
| Accent | `accent-500` | `#1FC491` | Growth/money cues, Job-Ready tier, progress bars |
| Neutral (cream ground, navy ink) | `neutral-50`…`neutral-950` | `#FAF6EC` → `#0A0D18` | Backgrounds, text, borders |

Tier accent mapping (`--color-tier-school` / `--color-tier-college` /
`--color-tier-jobready`, used by `LevelCard` and every `bg-tier-*`/`text-tier-*`/
`border-tier-*` consumer):
- School → `#E0855F` (`#F0A37E` in dark mode)
- College → `#1A56FF` (`#6F96FF` in dark mode) — now the same hue family as the
  primary brand blue, since College's prior tier color (Amethyst) no longer exists
  as a token.
- Job-Ready → `accent-500` `#1FC491` (constant across themes)

Each tier root (`app/school`, `app/college`, `app/job-ready`) also wraps its
pages in a `.theme-tier-*` class (`app/globals.css`) carrying the three-tier
visual language: pixel-art School (chunky radius, pixelated image-rendering),
transitional College (softer radius, gradient underline), minimal Job-Ready
(ink-colored heading, default radius, no extra chrome) — unchanged by this pass.

### Dark mode

Dark variant is driven by `prefers-color-scheme` and an optional `data-theme`
attribute override on `:root`. Background/foreground/surface tokens
(`--background`, `--foreground`, `--surface`, `--surface-border`) flip; the
primary/secondary/accent scales stay constant so brand color reads consistently
in both themes. `--shadow-offset` is redefined per theme since it's keyed off
`var(--foreground)`.

## Spacing & Radius

- Base spacing follows Tailwind's default 4px scale. Section padding standardizes
  on `px-6` (mobile) with a `max-w-6xl` or `max-w-3xl` content container.
- Card corner radius: `--radius-card: 1.5rem` (`rounded-[var(--radius-card)]`) —
  bumped up from 1.25rem for a rounder, friendlier register.
- Soft elevation: `--shadow-soft` — a subtle two-layer shadow for filled surfaces
  (primary buttons, plain cards).
- **Hard offset shadow — `--shadow-offset` (`3px 3px 0 var(--foreground)`)**: the
  optimalearn signature, a solid ink-colored offset (never blurred). Used on the
  floating pill `Nav` bar and the `secondary` `Button` variant, both of which also
  carry a `border-2 border-foreground`. Do not blur this shadow or use it on more
  than a couple of chrome elements per screen — it reads as emphasis, not default
  elevation.

## Motion Conventions

Unchanged from prior phases — Framer Motion, `[0.25, 1, 0.5, 1]` ease-out-quart,
`whileInView` scroll reveals, spring hover/press on buttons and cards.

## Components

Located in `components/`:

- **`Button`** (`Button.tsx`) — `primary` (filled blue, `shadow-soft`) /
  `secondary` (white, `border-2 border-foreground`, `shadow-[var(--shadow-offset)]`,
  the neubrutalist-outline optimalearn secondary-CTA look) / `ghost` variants,
  `md` / `lg` sizes, built-in hover/press motion.
- **`Nav`** (`Nav.tsx`) — floating rounded-full pill bar (`border-2 border-foreground`
  + `shadow-[var(--shadow-offset)]`) instead of a full-bleed bottom-border bar,
  matching optimalearn's white pill navbar floating on the cream page.
- **`LevelCard`** (`LevelCard.tsx`) — tier-aware card (school/college/jobready)
  with badge, topic list, and a short status stat string.
- **`ProgressBar`** (`ProgressBar.tsx`) — animated fill, optional label.

Extending this palette/shadow language to remaining screens (dashboards, settings,
Interview Coach, per-tier lesson chrome) is follow-up work — see `AGENTS.md`'s
"Frontend redesign (optimalearn reference)" note for scope split.

## Not in this phase

A full per-page redesign (every dashboard/settings/lesson screen individually
restyled) was explicitly split into follow-up work by the captain; this pass
covers the shared token layer + `Button` + `Nav`, which every route inherits.
