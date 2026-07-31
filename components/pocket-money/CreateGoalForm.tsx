"use client";

import { useState } from "react";
import { Button } from "@/components/Button";
import { createSavingsGoal } from "@/lib/pocket-money/queries";

export function CreateGoalForm({ onCreated }: { onCreated: () => void }) {
  const [isOpen, setIsOpen] = useState(false);
  const [name, setName] = useState("");
  const [target, setTarget] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const targetCents = Math.round(Number(target) * 100);

    if (!name.trim()) {
      setError("Give your goal a name.");
      return;
    }
    if (!Number.isFinite(targetCents) || targetCents <= 0) {
      setError("Set a target amount greater than $0.");
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      await createSavingsGoal(name.trim(), targetCents);
      setName("");
      setTarget("");
      setIsOpen(false);
      onCreated();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Could not create that goal.");
    } finally {
      setIsSubmitting(false);
    }
  }

  if (!isOpen) {
    return (
      <Button variant="secondary" onClick={() => setIsOpen(true)}>
        + New savings goal
      </Button>
    );
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="max-w-sm space-y-3 rounded-[var(--radius-card)] border border-surface-border bg-surface p-5 shadow-soft"
    >
      <label className="block text-sm">
        <span className="mb-1 block font-medium text-muted-foreground">Goal name</span>
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          className="w-full rounded-lg border border-surface-border bg-background px-3 py-2 text-sm"
          placeholder="New headphones"
        />
      </label>
      <label className="block text-sm">
        <span className="mb-1 block font-medium text-muted-foreground">Target amount (USD)</span>
        <input
          type="number"
          min="0.01"
          step="0.01"
          value={target}
          onChange={(e) => setTarget(e.target.value)}
          className="w-full rounded-lg border border-surface-border bg-background px-3 py-2 text-sm"
          placeholder="100.00"
        />
      </label>

      {error ? <p className="text-sm text-red-600">{error}</p> : null}

      <div className="flex gap-2">
        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting ? "Creating…" : "Create goal"}
        </Button>
        <Button type="button" variant="ghost" onClick={() => setIsOpen(false)}>
          Cancel
        </Button>
      </div>
    </form>
  );
}
