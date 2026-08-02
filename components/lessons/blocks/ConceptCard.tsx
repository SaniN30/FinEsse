import type { LessonTier } from "@/lib/lessons/content-blocks";
import { getTierBlockPalette } from "@/lib/lessons/tier-block-styles";

interface ConceptCardProps {
  tier: LessonTier;
  title: string;
  body: string;
}

export function ConceptCard({ tier, title, body }: ConceptCardProps) {
  const palette = getTierBlockPalette(tier);

  return (
    <div
      className={`${palette.cardBase} p-5`}
      style={{ backgroundColor: `color-mix(in srgb, ${palette.panelVar} 55%, var(--surface))` }}
    >
      <p className={`${palette.eyebrow} mb-1.5`} style={{ color: palette.accentVar }}>
        Core concept
      </p>
      <h3 className={`${palette.heading} mb-2 text-lg text-foreground`}>{title}</h3>
      <p className="text-sm leading-relaxed text-foreground">{body}</p>
    </div>
  );
}
