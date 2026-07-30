"use client";

import { useEffect, useState } from "react";
import { fetchLinkedChildren, fetchSavingsGoalProgress } from "@/lib/pocket-money/queries";
import { SavingsGoalCard } from "@/components/pocket-money/SavingsGoalCard";
import type { SavingsGoalProgress } from "@/lib/supabase/types";

interface ChildGoals {
  childId: string;
  goals: SavingsGoalProgress[];
}

export function ParentGoalsView({ parentId }: { parentId: string }) {
  const [childGoals, setChildGoals] = useState<ChildGoals[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function load() {
      const children = await fetchLinkedChildren(parentId);
      const results = await Promise.all(
        children.map(async (child) => ({
          childId: child.id,
          goals: await fetchSavingsGoalProgress(child.id),
        })),
      );
      if (isMounted) setChildGoals(results);
    }

    load().catch((err: unknown) => {
      if (isMounted) setError(err instanceof Error ? err.message : "Could not load goals.");
    });

    return () => {
      isMounted = false;
    };
  }, [parentId]);

  if (error) return <p className="text-sm text-red-600">{error}</p>;
  if (!childGoals) return <p className="text-sm text-neutral-500">Loading…</p>;
  if (childGoals.length === 0) {
    return <p className="text-sm text-neutral-500">No linked students yet.</p>;
  }

  return (
    <div className="space-y-10">
      {childGoals.map(({ childId, goals }) => (
        <section key={childId}>
          <h2 className="mb-4 text-lg font-semibold">Student {childId.slice(0, 8)}</h2>
          {goals.length === 0 ? (
            <p className="text-sm text-neutral-500">No savings goals yet.</p>
          ) : (
            <div className="grid gap-5 sm:grid-cols-2">
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
