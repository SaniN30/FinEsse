"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Nav } from "@/components/Nav";
import { Button } from "@/components/Button";
import { Skeleton } from "@/components/Skeleton";
import { ChildRollupCard } from "@/components/parent-dashboard/ChildRollupCard";
import { useAuth } from "@/lib/supabase/auth-context";
import { isParentWithChildFlow, tierBasePath } from "@/lib/supabase/profile-helpers";
import { fetchParentDashboardChildren } from "@/lib/parent-dashboard/queries";
import type { ParentDashboardChild } from "@/lib/supabase/types";

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

/**
 * Plan calls for a "combined stats strip — total saved across children,
 * total XP this week — only if 2+ children linked". `parent_dashboard_children`
 * has no week-scoped XP figure (xp_events isn't bucketed by week anywhere in
 * the schema/views — see BACKEND.md), so only the total-saved figure, which
 * is derivable from wallet_balance_cents + savings goal balances, is shown
 * here; the weekly-XP stat is deliberately skipped rather than invented.
 */
function CombinedStatsStrip({ childProfiles }: { childProfiles: ParentDashboardChild[] }) {
  if (childProfiles.length < 2) return null;

  const totalSavedCents = childProfiles.reduce((sum, child) => {
    const goalBalances = child.savings_goals.reduce((goalSum, goal) => goalSum + goal.balance_cents, 0);
    return sum + child.wallet_balance_cents + goalBalances;
  }, 0);

  return (
    <div className="mt-8 inline-flex items-center gap-3 rounded-full border border-surface-border bg-surface px-5 py-3 shadow-soft">
      <span className="text-sm font-medium text-muted-foreground">Total saved across children</span>
      <span className="text-lg font-semibold tabular-nums">{formatCents(totalSavedCents)}</span>
    </div>
  );
}

function ChildRollupSkeleton() {
  return (
    <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft">
      <div className="mb-5 flex items-center gap-3">
        <Skeleton className="h-11 w-11 rounded-full" />
        <div className="flex-1 space-y-2">
          <Skeleton className="h-4 w-24" />
          <Skeleton className="h-3 w-16" />
        </div>
      </div>
      <Skeleton className="mb-5 h-2 w-full rounded-full" />
      <div className="grid grid-cols-2 gap-3">
        <Skeleton className="h-14 w-full" />
        <Skeleton className="h-14 w-full" />
      </div>
    </div>
  );
}

export default function ParentDashboardPage() {
  const router = useRouter();
  const { session, profile, loading } = useAuth();
  const [children, setChildren] = useState<ParentDashboardChild[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (loading) return;
    if (!session) {
      router.replace("/login");
      return;
    }
    // A school/college self-service account has no child flow -- this page
    // isn't a valid destination for it even by direct URL.
    if (profile && !isParentWithChildFlow(profile)) {
      router.replace(tierBasePath(profile.tier ?? null));
    }
  }, [loading, session, profile, router]);

  useEffect(() => {
    if (!session) return;
    let isMounted = true;

    fetchParentDashboardChildren()
      .then((data) => {
        if (isMounted) setChildren(data);
      })
      .catch((err: unknown) => {
        if (isMounted) {
          setError(err instanceof Error ? err.message : "Could not load your dashboard.");
        }
      });

    return () => {
      isMounted = false;
    };
  }, [session]);

  function handleTierChange(profileId: string, tier: ParentDashboardChild["tier"]) {
    setChildren((prev) =>
      prev
        ? prev.map((child) => (child.profile_id === profileId ? { ...child, tier } : child))
        : prev,
    );
  }

  if (loading || !session || (profile && !isParentWithChildFlow(profile))) {
    return null;
  }

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-6xl flex-1 px-6 py-16">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
        >
          <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-primary-500">
            Parent dashboard
          </p>
          <h1 className="text-3xl font-semibold tracking-tight">
            Everything, at a glance
          </h1>
          <p className="mt-2 max-w-2xl text-sm text-muted-foreground">
            Tier, XP, mastery, pocket money, and Interview Coach progress for every
            linked child, in one view.
          </p>

          {error ? (
            <p className="mt-8 text-sm text-red-600">{error}</p>
          ) : children === null ? (
            <div className="mt-8 grid gap-6 sm:grid-cols-2 xl:grid-cols-3">
              <ChildRollupSkeleton />
              <ChildRollupSkeleton />
            </div>
          ) : children.length === 0 ? (
            <div className="mt-8 rounded-[var(--radius-card)] border border-surface-border bg-surface p-8 text-center shadow-soft">
              <p className="mb-4 text-sm text-muted-foreground">
                You haven&apos;t created a child account yet.
              </p>
              <Button size="lg" onClick={() => router.push("/consent")}>
                Add a child
              </Button>
            </div>
          ) : (
            <>
              <CombinedStatsStrip childProfiles={children} />
              <div className="mt-8 grid gap-6 sm:grid-cols-2 xl:grid-cols-3">
                {children.map((child, index) => (
                  <ChildRollupCard
                    key={child.profile_id}
                    child={child}
                    index={index}
                    onTierChange={handleTierChange}
                  />
                ))}
              </div>
            </>
          )}
        </motion.div>
      </main>
    </div>
  );
}
