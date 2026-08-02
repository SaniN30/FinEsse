import type { DiagramNode, LessonTier } from "@/lib/lessons/content-blocks";
import { getTierBlockPalette } from "@/lib/lessons/tier-block-styles";

interface FlowDiagramProps {
  tier: LessonTier;
  caption?: string;
  nodes: DiagramNode[];
}

/**
 * Generic left-to-right flow/schematic primitive: renders an ordered chain of
 * labeled nodes connected by arrows. Reusable for any structural/relational
 * concept (a process flow, a statement's sections, a decision chain) without
 * needing a bespoke diagram per lesson.
 */
export function FlowDiagram({ tier, caption, nodes }: FlowDiagramProps) {
  const palette = getTierBlockPalette(tier);

  return (
    <div className={`${palette.cardBase} bg-surface p-5`}>
      {caption ? (
        <p className={`${palette.eyebrow} mb-3`} style={{ color: palette.accentVar }}>
          {caption}
        </p>
      ) : null}
      <div className="flex flex-wrap items-stretch gap-2 sm:flex-nowrap sm:gap-0">
        {nodes.map((node, index) => (
          <div key={index} className="flex flex-1 items-center">
            <div
              className="flex min-w-[9rem] flex-1 flex-col items-center justify-center gap-0.5 rounded-xl border-2 px-3 py-3 text-center"
              style={{ borderColor: palette.accentVar }}
            >
              <span className="text-sm font-semibold text-foreground">{node.label}</span>
              {node.sublabel ? (
                <span className="text-xs text-muted-foreground">{node.sublabel}</span>
              ) : null}
            </div>
            {index < nodes.length - 1 ? (
              <svg
                viewBox="0 0 24 24"
                aria-hidden="true"
                className="mx-1 hidden h-5 w-5 flex-none sm:block"
                style={{ color: palette.accentVar }}
              >
                <path
                  d="M4 12h14m0 0-5-5m5 5-5 5"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            ) : null}
          </div>
        ))}
      </div>
    </div>
  );
}
