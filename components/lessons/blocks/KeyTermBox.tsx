import type { LessonTier } from "@/lib/lessons/content-blocks";
import { getTierBlockPalette } from "@/lib/lessons/tier-block-styles";

interface KeyTermBoxProps {
  tier: LessonTier;
  term: string;
  definition: string;
}

export function KeyTermBox({ tier, term, definition }: KeyTermBoxProps) {
  const palette = getTierBlockPalette(tier);

  return (
    <div
      className="rounded-[var(--radius-card)] border-l-4 bg-surface p-4 shadow-soft"
      style={{ borderColor: palette.accentVar }}
    >
      <p className={`${palette.eyebrow} mb-1`} style={{ color: palette.accentVar }}>
        Key term
      </p>
      <p className={`${palette.heading} text-base text-foreground`}>{term}</p>
      <p className="mt-1 text-sm leading-relaxed text-muted-foreground">{definition}</p>
    </div>
  );
}
