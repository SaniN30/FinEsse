"use client";

import { motion } from "framer-motion";
import { ProgressBar } from "@/components/ProgressBar";
import { Button } from "@/components/Button";
import { rubricOverallScore } from "@/lib/interview-coach/rubric";
import type { InterviewRubricScores } from "@/lib/supabase/types";

interface ScoreRevealProps {
  rubricScores: InterviewRubricScores;
  improvementGuide?: string;
  onPracticeAgain?: () => void;
}

/** Renders the headline score and every sub-score together, once -- no staggered/streamed reveal (score-interview-session is one synchronous call). */
export function ScoreReveal({ rubricScores, improvementGuide, onPracticeAgain }: ScoreRevealProps) {
  const overall = rubricOverallScore(rubricScores);

  return (
    <motion.div
      initial={{ opacity: 0, y: 24 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
      className="space-y-6"
    >
      <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 text-center shadow-soft">
        <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-primary-500">
          Your practice score
        </p>
        <h2 className="text-4xl font-semibold tabular-nums">
          {overall !== null ? `${overall}/10` : "Scored"}
        </h2>
        {rubricScores.overall_feedback ? (
          <p className="mt-4 text-sm text-muted-foreground">{rubricScores.overall_feedback}</p>
        ) : null}
      </div>

      <div className="space-y-4">
        {rubricScores.star_structure ? (
          <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-5 shadow-soft">
            <div className="mb-2 flex items-center justify-between text-sm font-medium">
              <span>STAR structure</span>
              <span className="tabular-nums">{rubricScores.star_structure.score}/10</span>
            </div>
            <ProgressBar
              value={rubricScores.star_structure.score * 10}
              colorClassName="bg-primary-500"
            />
            <p className="mt-3 text-sm text-muted-foreground">{rubricScores.star_structure.feedback}</p>
          </div>
        ) : null}

        {rubricScores.clarity ? (
          <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-5 shadow-soft">
            <div className="mb-2 flex items-center justify-between text-sm font-medium">
              <span>Clarity</span>
              <span className="tabular-nums">{rubricScores.clarity.score}/10</span>
            </div>
            <ProgressBar value={rubricScores.clarity.score * 10} colorClassName="bg-secondary-500" />
            <p className="mt-3 text-sm text-muted-foreground">{rubricScores.clarity.feedback}</p>
          </div>
        ) : null}

        {typeof rubricScores.filler_word_count === "number" ? (
          <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-5 shadow-soft">
            <div className="flex items-center justify-between text-sm font-medium">
              <span>Filler words</span>
              <span className="tabular-nums">{rubricScores.filler_word_count}</span>
            </div>
          </div>
        ) : null}
      </div>

      {improvementGuide ? (
        <div className="rounded-[var(--radius-card)] border border-primary-300 bg-primary-500/5 p-5 shadow-soft">
          <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-primary-500">
            How to strengthen this answer
          </p>
          <p className="text-sm leading-relaxed text-foreground">{improvementGuide}</p>
        </div>
      ) : null}

      {onPracticeAgain ? (
        <Button variant="secondary" onClick={onPracticeAgain}>
          Practice another question
        </Button>
      ) : null}
    </motion.div>
  );
}
