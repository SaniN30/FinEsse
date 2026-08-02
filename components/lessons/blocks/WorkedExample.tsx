import type { LessonTier } from "@/lib/lessons/content-blocks";
import { getTierBlockPalette } from "@/lib/lessons/tier-block-styles";

interface WorkedExampleProps {
  tier: LessonTier;
  title?: string;
  body: string;
}

export function WorkedExample({ tier, title, body }: WorkedExampleProps) {
  const palette = getTierBlockPalette(tier);
  const label = tier === "job_ready" ? "Scenario" : "Worked example";

  return (
    <div className={`${palette.cardBase} bg-surface p-5`}>
      <p className={`${palette.eyebrow} mb-1.5`} style={{ color: palette.accentVar }}>
        {label}
        {title ? ` — ${title}` : ""}
      </p>
      <p className="text-sm leading-relaxed text-foreground">{body}</p>
    </div>
  );
}
