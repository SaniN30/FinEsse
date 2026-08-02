import type { LessonTier } from "@/lib/lessons/content-blocks";
import { getTierBlockPalette } from "@/lib/lessons/tier-block-styles";

interface StepSequenceProps {
  tier: LessonTier;
  title?: string;
  steps: string[];
}

export function StepSequence({ tier, title, steps }: StepSequenceProps) {
  const palette = getTierBlockPalette(tier);

  return (
    <div className={`${palette.cardBase} bg-surface p-5`}>
      {title ? (
        <p className={`${palette.eyebrow} mb-3`} style={{ color: palette.accentVar }}>
          {title}
        </p>
      ) : null}
      <ol className="space-y-3">
        {steps.map((step, index) => (
          <li key={index} className="flex gap-3">
            <span
              className={`flex h-6 w-6 flex-none items-center justify-center rounded-full text-xs font-bold text-white ${palette.heading}`}
              style={{ backgroundColor: palette.accentVar }}
            >
              {index + 1}
            </span>
            <span className="text-sm leading-relaxed text-foreground">{step}</span>
          </li>
        ))}
      </ol>
    </div>
  );
}
