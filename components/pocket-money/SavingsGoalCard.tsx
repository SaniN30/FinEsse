"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { ProgressBar } from "@/components/ProgressBar";
import { GoalTransferForm } from "@/components/pocket-money/GoalTransferForm";
import { GoalProjectionCalculator } from "@/components/pocket-money/GoalProjectionCalculator";
import type { SavingsGoalProgress } from "@/lib/supabase/types";

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

interface SavingsGoalCardProps {
  goal: SavingsGoalProgress;
  readOnly?: boolean;
  onChanged?: () => void;
  index?: number;
}

export function SavingsGoalCard({ goal, readOnly = false, onChanged, index = 0 }: SavingsGoalCardProps) {
  const [isTransferOpen, setIsTransferOpen] = useState(false);

  return (
    <motion.article
      initial={{ opacity: 0, y: 24 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-60px" }}
      transition={{ duration: 0.5, ease: [0.25, 1, 0.5, 1] as const, delay: index * 0.08 }}
      className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft"
    >
      <h3 className="mb-1 text-xl font-semibold">{goal.name}</h3>
      <p className="mb-4 text-sm text-neutral-500">
        {formatCents(goal.balance_cents)}
        {goal.target_amount_cents ? ` of ${formatCents(goal.target_amount_cents)}` : ""}
      </p>
      <ProgressBar
        value={goal.percent_complete ?? 0}
        colorClassName="bg-accent-500"
        label="Progress"
      />

      {!readOnly && (
        <div className="mt-5">
          {isTransferOpen ? (
            <GoalTransferForm
              goalAccountId={goal.account_id}
              balanceCents={goal.balance_cents}
              onComplete={() => {
                setIsTransferOpen(false);
                onChanged?.();
              }}
            />
          ) : (
            <button
              type="button"
              onClick={() => setIsTransferOpen(true)}
              className="text-sm font-medium text-primary-500 hover:text-primary-600"
            >
              Add or withdraw money →
            </button>
          )}
        </div>
      )}

      <GoalProjectionCalculator
        goalName={goal.name}
        balanceCents={goal.balance_cents}
        targetAmountCents={goal.target_amount_cents}
      />
    </motion.article>
  );
}
