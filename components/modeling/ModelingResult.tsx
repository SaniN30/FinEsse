"use client";

import { motion } from "framer-motion";
import { Button } from "@/components/Button";
import { humanizeMetricKey } from "@/lib/modeling";
import type { ModelingGradeResult } from "@/lib/supabase/types";
import { cn } from "@/lib/cn";

interface ModelingResultProps {
  result: ModelingGradeResult;
  onRetry?: () => void;
}

export function ModelingResult({ result, onRetry }: ModelingResultProps) {
  const metricEntries = Object.entries(result.breakdown);

  return (
    <motion.div
      initial={{ opacity: 0, y: 24 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
      className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft"
    >
      <div className="mb-6 text-center">
        <p
          className={
            result.passed
              ? "mb-2 text-sm font-semibold text-accent-600"
              : "mb-2 text-sm font-semibold text-neutral-500"
          }
        >
          {result.passed ? "Passed" : "Not quite yet"}
        </p>
        <h3 className="text-2xl font-semibold">{Math.round(result.score * 100)}%</h3>
        {result.passed && result.alreadyCompleted ? (
          <p className="mt-2 text-xs text-neutral-500">
            You&apos;d already passed this exercise, so no additional XP was awarded.
          </p>
        ) : null}
      </div>

      <ul className="space-y-3">
        {metricEntries.map(([key, metric]) => (
          <li
            key={key}
            className={cn(
              "flex items-center justify-between rounded-xl border px-4 py-3 text-sm",
              metric.correct
                ? "border-accent-400/40 bg-accent-400/10"
                : "border-surface-border bg-neutral-100/50",
            )}
          >
            <span className="font-medium">{humanizeMetricKey(key)}</span>
            <span
              className={cn(
                "font-semibold",
                metric.correct ? "text-accent-600" : "text-neutral-500",
              )}
            >
              {metric.correct ? "Correct" : "Off target"}
            </span>
          </li>
        ))}
      </ul>

      {onRetry ? (
        <Button variant="secondary" className="mt-6 w-full" onClick={onRetry}>
          Try again
        </Button>
      ) : null}
    </motion.div>
  );
}
