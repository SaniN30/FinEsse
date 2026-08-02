import type { LessonTier } from "@/lib/lessons/content-blocks";

interface TierBlockPalette {
  /** Wrapper chrome shared by every block type in this tier. */
  cardBase: string;
  /** Heading font/weight treatment. */
  heading: string;
  /** Tier accent color as a Tailwind arbitrary-value token, e.g. "var(--color-tier-school)". */
  accentVar: string;
  panelVar: string;
  eyebrow: string;
}

const PALETTES: Record<LessonTier, TierBlockPalette> = {
  school: {
    cardBase:
      "rounded-[var(--radius-card)] border-2 border-foreground shadow-[var(--shadow-offset)]",
    heading: "font-display font-bold",
    accentVar: "var(--color-tier-school)",
    panelVar: "var(--panel-school)",
    eyebrow: "font-display text-xs font-bold uppercase tracking-wide",
  },
  college: {
    cardBase: "rounded-xl border border-surface-border shadow-soft",
    heading: "font-semibold",
    accentVar: "var(--color-tier-college)",
    panelVar: "var(--panel-college)",
    eyebrow: "text-[11px] font-semibold uppercase tracking-[0.14em]",
  },
  job_ready: {
    cardBase: "rounded-[var(--radius-card)] border border-surface-border",
    heading: "font-semibold",
    accentVar: "var(--color-tier-jobready)",
    panelVar: "var(--panel-jobready)",
    eyebrow: "text-[11px] font-semibold uppercase tracking-[0.12em]",
  },
};

export function getTierBlockPalette(tier: LessonTier): TierBlockPalette {
  return PALETTES[tier];
}
