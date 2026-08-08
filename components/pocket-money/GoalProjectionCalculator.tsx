"use client";

import { useMemo, useState } from "react";
import { projectSavingsGoal } from "@/lib/pocket-money/projection";
import { currencyOrDefault } from "@/lib/currency/config";
import { displayAmountToUsdCents, formatUsdCents } from "@/lib/currency/format";

interface GoalProjectionCalculatorProps {
  goalName: string;
  balanceCents: number;
  targetAmountCents: number | null;
  currency: string | null;
}

/**
 * A pure "what if" tool: it never touches the ledger, only previews how
 * many weeks a hypothetical recurring contribution would take to reach the
 * goal. Actual deposits still go through GoalTransferForm. The contribution
 * input is entered in the profile's display currency and converted to USD
 * cents (the ledger's canonical unit) before being handed to
 * projectSavingsGoal, same as GoalTransferForm/FundWalletForm/CreateGoalForm.
 */
export function GoalProjectionCalculator({
  goalName,
  balanceCents,
  targetAmountCents,
  currency,
}: GoalProjectionCalculatorProps) {
  const resolvedCurrency = currencyOrDefault(currency);
  const [contribution, setContribution] = useState("5.00");
  const [frequencyWeeks, setFrequencyWeeks] = useState("1");

  const result = useMemo(() => {
    if (!targetAmountCents) return null;
    const contributionCents = displayAmountToUsdCents(Number(contribution), resolvedCurrency);
    const weeks = Number(frequencyWeeks);
    if (!Number.isFinite(contributionCents) || !Number.isFinite(weeks)) return null;

    return projectSavingsGoal({
      balanceCents,
      targetAmountCents,
      contributionCents,
      frequencyWeeks: weeks,
    });
  }, [balanceCents, targetAmountCents, contribution, frequencyWeeks, resolvedCurrency]);

  if (!targetAmountCents) return null;

  return (
    <div className="mt-5 rounded-[var(--radius-card)] border border-dashed border-surface-border bg-background/60 p-4">
      <p className="mb-3 text-sm font-medium text-muted-foreground">
        Projection calculator: if I save toward &ldquo;{goalName}&rdquo;&hellip;
      </p>

      <div className="grid grid-cols-2 gap-3">
        <label className="block text-sm">
          <span className="mb-1 block text-xs font-medium text-muted-foreground">
            Amount ({resolvedCurrency})
          </span>
          <input
            type="number"
            min="0"
            step="0.01"
            value={contribution}
            onChange={(e) => setContribution(e.target.value)}
            className="w-full rounded-lg border border-surface-border bg-surface px-3 py-2 text-sm"
          />
        </label>
        <label className="block text-sm">
          <span className="mb-1 block text-xs font-medium text-muted-foreground">Every N weeks</span>
          <input
            type="number"
            min="1"
            step="1"
            value={frequencyWeeks}
            onChange={(e) => setFrequencyWeeks(e.target.value)}
            className="w-full rounded-lg border border-surface-border bg-surface px-3 py-2 text-sm"
          />
        </label>
      </div>

      <div className="mt-3 text-sm">
        {result === null ? (
          <p className="text-muted-foreground">Enter an amount to see a projection.</p>
        ) : result.weeksToGoal === 0 ? (
          <p className="font-medium text-accent-600">You&apos;ve already reached this goal.</p>
        ) : result.weeksToGoal === null ? (
          <p className="text-muted-foreground">
            Enter a contribution greater than {formatUsdCents(0, currency)} to project a date.
          </p>
        ) : (
          <p>
            You&apos;ll hit{" "}
            <span className="font-semibold tabular-nums">
              {formatUsdCents(targetAmountCents, currency)}
            </span>{" "}
            in about{" "}
            <span className="font-semibold tabular-nums">{result.weeksToGoal}</span> week
            {result.weeksToGoal === 1 ? "" : "s"} (around{" "}
            {result.projectedDate?.toLocaleDateString(undefined, {
              month: "short",
              day: "numeric",
              year: "numeric",
            })}
            ).
          </p>
        )}
      </div>

      {result && result.timeline.length > 1 ? (
        <div className="mt-3 flex items-end gap-1 overflow-x-auto pb-1" aria-hidden>
          {result.timeline.map((point) => {
            const heightPercent = targetAmountCents
              ? Math.min(100, Math.round((point.balanceCents / targetAmountCents) * 100))
              : 0;
            return (
              <div
                key={point.week}
                title={`Week ${point.week}: ${formatUsdCents(point.balanceCents, currency)}`}
                className="w-3 shrink-0 rounded-t bg-accent-400/70"
                style={{ height: `${Math.max(4, heightPercent)}px`, maxHeight: "80px" }}
              />
            );
          })}
        </div>
      ) : null}
    </div>
  );
}
