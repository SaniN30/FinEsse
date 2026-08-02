import type { Tier } from "@/lib/supabase/types";

export type LessonTier = Tier;

export interface ConceptBlock {
  type: "concept";
  title: string;
  body: string;
}

export interface KeyTermBlock {
  type: "keyterm";
  term: string;
  definition: string;
}

export interface ExampleBlock {
  type: "example";
  title?: string;
  body: string;
}

export interface MistakeBlock {
  type: "mistake";
  title?: string;
  body: string;
}

export interface TakeawayBlock {
  type: "takeaway";
  body: string;
}

export interface TableBlock {
  type: "table";
  caption?: string;
  headers: string[];
  rows: string[][];
}

export interface StepsBlock {
  type: "steps";
  title?: string;
  steps: string[];
}

export interface DiagramNode {
  label: string;
  sublabel?: string;
}

export interface DiagramBlock {
  type: "diagram";
  caption?: string;
  nodes: DiagramNode[];
}

export type LessonBlock =
  | ConceptBlock
  | KeyTermBlock
  | ExampleBlock
  | MistakeBlock
  | TakeawayBlock
  | TableBlock
  | StepsBlock
  | DiagramBlock;
