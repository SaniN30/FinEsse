"use client";

import { useState } from "react";
import { Button } from "@/components/Button";
import { fundStudentWallet } from "@/lib/pocket-money/queries";

interface FundWalletFormProps {
  studentProfileId: string;
  onComplete: () => void;
}

/**
 * The only place a parent can put real (virtual) money into a student's
 * wallet -- see fund_student_wallet in
 * supabase/migrations/00000000000024_pocket_money_funding.sql.
 */
export function FundWalletForm({ studentProfileId, onComplete }: FundWalletFormProps) {
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

    setIsSubmitting(true);
    setError(null);

    try {
      await fundStudentWallet(studentProfileId, amountCents);
      setAmount("");
      onComplete();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "That transfer didn't go through.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="mt-3 space-y-2">
      <div className="flex items-end gap-2">
        <label className="block flex-1 text-sm">
          <span className="mb-1 block font-medium text-neutral-600">Add allowance (USD)</span>
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

        <Button type="submit" disabled={isSubmitting} size="md">
          {isSubmitting ? "Sending…" : "Add money"}
        </Button>
      </div>

      {error ? <p className="text-sm text-red-600">{error}</p> : null}
    </form>
  );
}
