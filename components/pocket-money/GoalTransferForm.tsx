"use client";

import { useState } from "react";
import { Button } from "@/components/Button";
import { depositToSavingsGoal, withdrawFromSavingsGoal } from "@/lib/pocket-money/queries";

type TransferMode = "deposit" | "withdraw";

interface GoalTransferFormProps {
  goalAccountId: string;
  balanceCents: number;
  onComplete: () => void;
}

/**
 * Deposit and withdraw are both the student's own call, with no
 * parent-approval step in the data model -- the two actions are styled
 * identically (same button size/weight/prominence) so neither reads as
 * needing more permission than the other.
 */
export function GoalTransferForm({ goalAccountId, balanceCents, onComplete }: GoalTransferFormProps) {
  const [mode, setMode] = useState<TransferMode>("deposit");
  const [amount, setAmount] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const amountCents = Math.round(Number(amount) * 100);

    if (!Number.isFinite(amountCents) || amountCents <= 0) {
      setError("Enter an amount greater than $0.");
      return;
    }

    if (mode === "withdraw" && amountCents > balanceCents) {
      setError("You can't withdraw more than what's in this goal.");
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      if (mode === "deposit") {
        await depositToSavingsGoal(goalAccountId, amountCents);
      } else {
        await withdrawFromSavingsGoal(goalAccountId, amountCents);
      }
      setAmount("");
      onComplete();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "That transfer didn't go through.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="mt-4 space-y-3">
      <div className="flex gap-2" role="tablist">
        <button
          type="button"
          role="tab"
          aria-selected={mode === "deposit"}
          onClick={() => setMode("deposit")}
          className={`flex-1 rounded-full px-4 py-2 text-sm font-medium transition-colors ${
            mode === "deposit"
              ? "bg-accent-500 text-white"
              : "border border-surface-border text-foreground hover:border-accent-400"
          }`}
        >
          Add money
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={mode === "withdraw"}
          onClick={() => setMode("withdraw")}
          className={`flex-1 rounded-full px-4 py-2 text-sm font-medium transition-colors ${
            mode === "withdraw"
              ? "bg-secondary-500 text-white"
              : "border border-surface-border text-foreground hover:border-secondary-400"
          }`}
        >
          Withdraw
        </button>
      </div>

      <label className="block text-sm">
        <span className="mb-1 block font-medium text-neutral-600">Amount (USD)</span>
        <input
          type="number"
          min="0.01"
          step="0.01"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          className="w-full rounded-lg border border-surface-border bg-background px-3 py-2 text-sm"
          placeholder="0.00"
        />
      </label>

      {error ? <p className="text-sm text-red-600">{error}</p> : null}

      <Button type="submit" disabled={isSubmitting} className="w-full">
        {isSubmitting ? "Processing…" : mode === "deposit" ? "Add money" : "Withdraw"}
      </Button>
    </form>
  );
}
