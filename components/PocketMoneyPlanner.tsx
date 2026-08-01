"use client";

import { motion } from "framer-motion";
import { useCallback, useEffect, useState } from "react";
import { useAuth } from "@/lib/supabase/auth-context";
import { fetchAccountBalances, fetchSavingsGoalProgress } from "@/lib/pocket-money/queries";
import { SavingsGoalCard } from "@/components/pocket-money/SavingsGoalCard";
import { CreateGoalForm } from "@/components/pocket-money/CreateGoalForm";
import { WalletBalance } from "@/components/pocket-money/WalletBalance";
import { ParentGoalsView } from "@/components/pocket-money/ParentGoalsView";
import { Skeleton } from "@/components/Skeleton";
import type { AccountBalance, SavingsGoalProgress } from "@/lib/supabase/types";

function StudentPlanner({ profileId }: { profileId: string }) {
  const [goals, setGoals] = useState<SavingsGoalProgress[] | null>(null);
  const [accounts, setAccounts] = useState<AccountBalance[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(() => {
    Promise.all([fetchSavingsGoalProgress(profileId), fetchAccountBalances(profileId)])
      .then(([goalsResult, accountsResult]) => {
        setGoals(goalsResult);
        setAccounts(accountsResult);
      })
      .catch((err: unknown) => {
        setError(err instanceof Error ? err.message : "Could not load your savings goals.");
      });
  }, [profileId]);

  useEffect(() => {
    load();
  }, [load]);

  if (error) return <p className="text-sm text-red-600">{error}</p>;
  if (!goals || !accounts) {
    return (
      <div>
        <Skeleton className="mb-8 h-24 w-full" />
        <div className="grid gap-5 sm:grid-cols-2">
          <Skeleton className="h-40 w-full" />
          <Skeleton className="h-40 w-full" />
        </div>
      </div>
    );
  }

  return (
    <div>
      <WalletBalance accounts={accounts} />

      <div className="mb-8 grid gap-5 sm:grid-cols-2">
        {goals.map((goal, index) => (
          <SavingsGoalCard key={goal.account_id} goal={goal} onChanged={load} index={index} />
        ))}
      </div>

      <CreateGoalForm onCreated={load} />
    </div>
  );
}

export function PocketMoneyPlanner() {
  const { profile, loading: isLoading } = useAuth();

  if (isLoading || (profile && profile.role === "student")) {
    return (
      <motion.section
        initial={{ opacity: 0, y: 32 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-80px" }}
        transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
        className="mx-auto max-w-6xl px-6 pb-28"
      >
        <h2 className="mb-6 text-3xl font-semibold leading-tight sm:text-4xl">
          The Pocket Money Planner
        </h2>
        {isLoading ? (
          <Skeleton className="h-24 w-full" />
        ) : profile ? (
          <StudentPlanner profileId={profile.id} />
        ) : null}
      </motion.section>
    );
  }

  if (profile && profile.role === "parent") {
    return (
      <motion.section
        initial={{ opacity: 0, y: 32 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-80px" }}
        transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
        className="mx-auto max-w-6xl px-6 pb-28"
      >
        <h2 className="mb-2 text-3xl font-semibold leading-tight sm:text-4xl">
          Pocket Money Planner
        </h2>
        <p className="mb-6 max-w-xl text-muted-foreground">
          Fund your student&apos;s wallet and run savings projections together. Deposits and
          withdrawals on individual goals stay theirs to manage.
        </p>
        <ParentGoalsView parentId={profile.id} />
      </motion.section>
    );
  }

  return (
    <motion.section
      initial={{ opacity: 0, y: 32 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
      className="mx-auto max-w-6xl px-6 pb-28"
    >
      <div className="relative overflow-hidden rounded-[var(--radius-card)] border-2 border-foreground bg-primary-500 p-10 text-white shadow-[var(--shadow-offset)] sm:p-14">
        <h2 className="max-w-lg font-display text-3xl font-bold leading-tight sm:text-4xl">
          The Pocket Money Planner
        </h2>
        <p className="mt-4 max-w-xl text-primary-50">
          A hands-on budgeting tool built for the School tier — set a savings goal, deposit and
          withdraw on your own terms, and watch progress grow. Sign in to get started.
        </p>
      </div>
    </motion.section>
  );
}
