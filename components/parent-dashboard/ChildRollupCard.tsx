"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { ProgressBar } from "@/components/ProgressBar";
import { cn } from "@/lib/cn";
import { updateChildTier } from "@/lib/parent-dashboard/queries";
import type { ParentDashboardChild, Tier } from "@/lib/supabase/types";

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

const tierLabel: Record<Tier, string> = {
  school: "School",
  college: "College",
  job_ready: "Job-Ready",
};

const tierAccent: Record<Tier, string> = {
  school: "bg-secondary-400",
  college: "bg-primary-400",
  job_ready: "bg-accent-500",
};

const tierBadge: Record<Tier, string> = {
  school: "bg-secondary-400/15 text-secondary-600",
  college: "bg-primary-400/15 text-primary-600",
  job_ready: "bg-accent-400/15 text-accent-600",
};

function rubricOverallScore(rubricScores: Record<string, unknown>): number | null {
  const values = Object.values(rubricScores).filter(
    (value): value is { score: number } =>
      typeof value === "object" &&
      value !== null &&
      "score" in value &&
      typeof (value as { score: unknown }).score === "number",
  );
  if (values.length === 0) return null;
  const total = values.reduce((sum, entry) => sum + entry.score, 0);
  return Math.round((total / values.length) * 10) / 10;
}

interface ChildRollupCardProps {
  child: ParentDashboardChild;
  index?: number;
  onTierChange?: (profileId: string, tier: Tier) => void;
}

export function ChildRollupCard({ child, index = 0, onTierChange }: ChildRollupCardProps) {
  const tier = child.tier ?? "school";
  const [isSavingTier, setIsSavingTier] = useState(false);
  const [tierError, setTierError] = useState<string | null>(null);

  async function handleTierChange(nextTier: Tier) {
    if (nextTier === tier) return;
    setIsSavingTier(true);
    setTierError(null);
    try {
      await updateChildTier(child.profile_id, nextTier);
      onTierChange?.(child.profile_id, nextTier);
    } catch (err: unknown) {
      setTierError(err instanceof Error ? err.message : "Couldn't change tier.");
    } finally {
      setIsSavingTier(false);
    }
  }

  return (
    <motion.article
      initial={{ opacity: 0, y: 32 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const, delay: index * 0.1 }}
      className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft"
    >
      <div className="mb-5 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <span className="flex h-11 w-11 items-center justify-center rounded-full bg-primary-100 text-lg font-semibold text-primary-600">
            {(child.display_name ?? "?").charAt(0).toUpperCase()}
          </span>
          <div>
            <h3 className="text-lg font-semibold">{child.display_name ?? "Student"}</h3>
            <label className="sr-only" htmlFor={`tier-${child.profile_id}`}>
              Tier for {child.display_name ?? "this student"}
            </label>
            <select
              id={`tier-${child.profile_id}`}
              value={tier}
              disabled={isSavingTier}
              onChange={(event) => handleTierChange(event.target.value as Tier)}
              className={cn(
                "inline-flex items-center rounded-full border-none px-2.5 py-0.5 text-xs font-semibold",
                tierBadge[tier],
              )}
            >
              <option value="school">{tierLabel.school}</option>
              <option value="college">{tierLabel.college}</option>
              <option value="job_ready">{tierLabel.job_ready}</option>
            </select>
            {tierError ? <p className="mt-1 text-xs text-red-600">{tierError}</p> : null}
          </div>
        </div>
        <div className="text-right">
          <p className="text-2xl font-semibold tabular-nums">{child.total_xp}</p>
          <p className="text-xs uppercase tracking-wide text-muted-foreground">Total XP</p>
        </div>
      </div>

      <ProgressBar
        value={child.avg_mastery_pct ?? 0}
        colorClassName={tierAccent[tier]}
        label="Overall mastery"
        className="mb-5"
      />

      <div className="mb-5 grid grid-cols-2 gap-3">
        <div className="rounded-[calc(var(--radius-card)-0.5rem)] border border-surface-border bg-background/40 p-3">
          <p className="text-xs uppercase tracking-wide text-muted-foreground">Wallet</p>
          <p className="text-lg font-semibold tabular-nums">
            {formatCents(child.wallet_balance_cents)}
          </p>
        </div>
        <div className="rounded-[calc(var(--radius-card)-0.5rem)] border border-surface-border bg-background/40 p-3">
          <p className="text-xs uppercase tracking-wide text-muted-foreground">Savings goals</p>
          <p className="text-lg font-semibold tabular-nums">{child.savings_goals.length}</p>
        </div>
      </div>

      {child.savings_goals.length > 0 ? (
        <div className="mb-5 space-y-3">
          {child.savings_goals.map((goal) => (
            <div key={goal.account_id}>
              <ProgressBar
                value={goal.percent_complete ?? 0}
                colorClassName="bg-accent-500"
                label={`${goal.name} — ${formatCents(goal.balance_cents)}${
                  goal.target_amount_cents ? ` of ${formatCents(goal.target_amount_cents)}` : ""
                }`}
              />
            </div>
          ))}
        </div>
      ) : null}

      <div>
        <p className="mb-2 text-xs uppercase tracking-wide text-muted-foreground">
          Interview Coach
        </p>
        {child.interview_sessions.length === 0 ? (
          <p className="text-sm text-muted-foreground">No sessions taken yet.</p>
        ) : (
          <ul className="space-y-2">
            {child.interview_sessions.slice(0, 3).map((session) => {
              const overall = rubricOverallScore(session.rubric_scores);
              return (
                <li
                  key={session.session_id}
                  className="flex items-center justify-between text-sm text-muted-foreground"
                >
                  <span className="capitalize">{session.firm_style.replace(/_/g, " ")}</span>
                  <span className="font-medium text-foreground">
                    {overall !== null ? `${overall}/10` : "Scored"}
                  </span>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </motion.article>
  );
}
