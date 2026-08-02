import type { LessonBlock, LessonTier } from "@/lib/lessons/content-blocks";
import { ConceptCard } from "@/components/lessons/blocks/ConceptCard";
import { KeyTermBox } from "@/components/lessons/blocks/KeyTermBox";
import { WorkedExample } from "@/components/lessons/blocks/WorkedExample";
import { PitfallCallout } from "@/components/lessons/blocks/PitfallCallout";
import { TakeawayBox } from "@/components/lessons/blocks/TakeawayBox";
import { ComparisonTable } from "@/components/lessons/blocks/ComparisonTable";
import { StepSequence } from "@/components/lessons/blocks/StepSequence";
import { FlowDiagram } from "@/components/lessons/blocks/FlowDiagram";

interface LessonBlockRendererProps {
  tier: LessonTier;
  block: LessonBlock;
}

export function LessonBlockRenderer({ tier, block }: LessonBlockRendererProps) {
  switch (block.type) {
    case "concept":
      return <ConceptCard tier={tier} title={block.title} body={block.body} />;
    case "keyterm":
      return <KeyTermBox tier={tier} term={block.term} definition={block.definition} />;
    case "example":
      return <WorkedExample tier={tier} title={block.title} body={block.body} />;
    case "mistake":
      return <PitfallCallout tier={tier} title={block.title} body={block.body} />;
    case "takeaway":
      return <TakeawayBox tier={tier} body={block.body} />;
    case "table":
      return (
        <ComparisonTable tier={tier} caption={block.caption} headers={block.headers} rows={block.rows} />
      );
    case "steps":
      return <StepSequence tier={tier} title={block.title} steps={block.steps} />;
    case "diagram":
      return <FlowDiagram tier={tier} caption={block.caption} nodes={block.nodes} />;
    default:
      return null;
  }
}

interface LessonBlockListProps {
  tier: LessonTier;
  blocks: LessonBlock[];
}

export function LessonBlockList({ tier, blocks }: LessonBlockListProps) {
  return (
    <div className="space-y-4">
      {blocks.map((block, index) => (
        <LessonBlockRenderer key={index} tier={tier} block={block} />
      ))}
    </div>
  );
}
