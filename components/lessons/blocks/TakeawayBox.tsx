import type { LessonTier } from "@/lib/lessons/content-blocks";
import { getTierBlockPalette } from "@/lib/lessons/tier-block-styles";

interface TakeawayBoxProps {
  tier: LessonTier;
  body: string;
}

export function TakeawayBox({ tier, body }: TakeawayBoxProps) {
  const palette = getTierBlockPalette(tier);

  return (
    <div
      className="rounded-[var(--radius-card)] p-4"
      style={{ backgroundColor: `color-mix(in srgb, ${palette.accentVar} 14%, var(--surface))` }}
    >
      <p className={`${palette.eyebrow} mb-1`} style={{ color: palette.accentVar }}>
        Key takeaway
      </p>
      <p className="text-sm font-medium leading-relaxed text-foreground">{body}</p>
    </div>
  );
}
