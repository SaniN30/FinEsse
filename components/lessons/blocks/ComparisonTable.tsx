import type { LessonTier } from "@/lib/lessons/content-blocks";
import { getTierBlockPalette } from "@/lib/lessons/tier-block-styles";

interface ComparisonTableProps {
  tier: LessonTier;
  caption?: string;
  headers: string[];
  rows: string[][];
}

export function ComparisonTable({ tier, caption, headers, rows }: ComparisonTableProps) {
  const palette = getTierBlockPalette(tier);

  return (
    <div className={`${palette.cardBase} overflow-hidden bg-surface`}>
      {caption ? (
        <p
          className={`${palette.eyebrow} border-b border-surface-border px-5 py-3`}
          style={{ color: palette.accentVar }}
        >
          {caption}
        </p>
      ) : null}
      <div className="overflow-x-auto">
        <table className="w-full min-w-[420px] border-collapse text-left text-sm">
          <thead>
            <tr>
              {headers.map((header) => (
                <th
                  key={header}
                  className="border-b border-surface-border px-5 py-2.5 font-semibold text-foreground"
                >
                  {header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row, rowIndex) => (
              <tr key={rowIndex} className="odd:bg-transparent even:bg-neutral-500/[0.04]">
                {row.map((cell, cellIndex) => (
                  <td
                    key={cellIndex}
                    className="border-b border-surface-border px-5 py-2.5 align-top text-foreground last:border-b-0"
                  >
                    {cell}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
