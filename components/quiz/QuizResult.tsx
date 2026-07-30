"use client";

import { motion } from "framer-motion";
import { ProgressBar } from "@/components/ProgressBar";
import { Button } from "@/components/Button";
import type { QuizGradeResult } from "@/lib/supabase/types";

interface QuizResultProps {
  result: QuizGradeResult;
  onRetry?: () => void;
}

export function QuizResult({ result, onRetry }: QuizResultProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 24 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
      className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 text-center shadow-soft"
    >
      <p
        className={
          result.passed
            ? "mb-2 text-sm font-semibold text-accent-600"
            : "mb-2 text-sm font-semibold text-neutral-500"
        }
      >
        {result.passed ? "Passed" : "Not quite yet"}
      </p>
      <h3 className="mb-4 text-2xl font-semibold">{Math.round(result.score * 100)}%</h3>
      <ProgressBar
        value={Math.round(result.score * 100)}
        colorClassName={result.passed ? "bg-accent-500" : "bg-secondary-500"}
      />
      {onRetry ? (
        <Button variant="secondary" className="mt-6" onClick={onRetry}>
          Try again
        </Button>
      ) : null}
    </motion.div>
  );
}
