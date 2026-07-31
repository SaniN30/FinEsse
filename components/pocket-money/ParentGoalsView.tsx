"use client";

import { useCallback, useEffect, useState } from "react";
import {
  fetchAccountBalances,
  fetchLinkedChildren,
  fetchSavingsGoalProgress,
} from "@/lib/pocket-money/queries";
import { SavingsGoalCard } from "@/components/pocket-money/SavingsGoalCard";
import { FundWalletForm } from "@/components/pocket-money/FundWalletForm";
import type { AccountBalance, SavingsGoalProgress } from "@/lib/supabase/types";

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

interface ChildGoals {
  childId: string;
  displayName: string | null;
  walletBalanceCents: number;
  goals: SavingsGoalProgress[];
}

export function ParentGoalsView({ parentId }: { parentId: string }) {
  const [childGoals, setChildGoals] = useState<ChildGoals[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(() => {
    async function run() {
      const children = await fetchLinkedChildren(parentId);
      const results = await Promise.all(
        children.map(async (child) => {
          const [goals, accounts] = await Promise.all([
            fetchSavingsGoalProgress(child.id),
            fetchAccountBalances(child.id),
          ]);
          const wallet = accounts.find((account: AccountBalance) => account.type === "student_wallet");
          return {
            childId: child.id,
            displayName: child.display_name,
            walletBalanceCents: wallet?.balance_cents ?? 0,
            goals,
          };
        }),
      );
      setChildGoals(results);
    }

    return run();
  }, [parentId]);

  useEffect(() => {
    let isMounted = true;

    load().catch((err: unknown) => {
      if (isMounted) setError(err instanceof Error ? err.message : "Could not load goals.");
    });

    return () => {
      isMounted = false;
    };
  }, [load]);

  if (error) return <p className="text-sm text-red-600">{error}</p>;
  if (!childGoals) return <p className="text-sm text-neutral-500">Loading…</p>;
  if (childGoals.length === 0) {
    return <p className="text-sm text-neutral-500">No linked students yet.</p>;
  }

  return (
    <div className="space-y-10">
      {childGoals.map(({ childId, displayName, walletBalanceCents, goals }) => (
        <section key={childId}>
          <h2 className="mb-1 text-lg font-semibold">{displayName ?? `Student ${childId.slice(0, 8)}`}</h2>
          <p className="mb-4 text-sm text-neutral-500">
            Wallet balance: {formatCents(walletBalanceCents)}
          </p>

          <FundWalletForm studentProfileId={childId} onComplete={load} />

          {goals.length === 0 ? (
            <p className="mt-6 text-sm text-neutral-500">No savings goals yet.</p>
          ) : (
            <div className="mt-6 grid gap-5 sm:grid-cols-2">
              {goals.map((goal, index) => (
                <SavingsGoalCard key={goal.account_id} goal={goal} readOnly index={index} />
              ))}
            </div>
          )}
        </section>
      ))}
    </div>
  );
}
