import type { LessonTier } from "@/lib/lessons/content-blocks";
import { getTierBlockPalette } from "@/lib/lessons/tier-block-styles";

interface PitfallCalloutProps {
  tier: LessonTier;
  title?: string;
  body: string;
}

export function PitfallCallout({ tier, title, body }: PitfallCalloutProps) {
  const palette = getTierBlockPalette(tier);

  return (
    <div className="rounded-[var(--radius-card)] border border-red-300/60 bg-red-500/[0.06] p-4 dark:border-red-500/30">
      <p className={`${palette.eyebrow} mb-1 text-red-600 dark:text-red-400`}>
        Common mistake{title ? ` — ${title}` : ""}
      </p>
      <p className="text-sm leading-relaxed text-foreground">{body}</p>
    </div>
  );
}
