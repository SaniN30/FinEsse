"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Nav } from "@/components/Nav";
import { Button } from "@/components/Button";
import { ChildRollupCard } from "@/components/parent-dashboard/ChildRollupCard";
import { useAuth } from "@/lib/supabase/auth-context";
import { fetchParentDashboardChildren } from "@/lib/parent-dashboard/queries";
import type { ParentDashboardChild } from "@/lib/supabase/types";

export default function ParentDashboardPage() {
  const router = useRouter();
  const { session, loading } = useAuth();
  const [children, setChildren] = useState<ParentDashboardChild[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!loading && !session) {
      router.replace("/login");
    }
  }, [loading, session, router]);

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

  if (loading || !session) {
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
          <p className="mt-2 max-w-2xl text-sm text-neutral-500">
            Tier, XP, mastery, pocket money, and Interview Coach progress for every
            linked child, in one view.
          </p>

          {error ? (
            <p className="mt-8 text-sm text-red-600">{error}</p>
          ) : children === null ? (
            <p className="mt-8 text-sm text-neutral-500">Loading your children…</p>
          ) : children.length === 0 ? (
            <div className="mt-8 rounded-[var(--radius-card)] border border-surface-border bg-surface p-8 text-center shadow-soft">
              <p className="mb-4 text-sm text-neutral-500">
                You haven&apos;t created a child account yet.
              </p>
              <Button size="lg" onClick={() => router.push("/consent")}>
                Add a child
              </Button>
            </div>
          ) : (
            <div className="mt-8 grid gap-6 sm:grid-cols-2 xl:grid-cols-3">
              {children.map((child, index) => (
                <ChildRollupCard key={child.profile_id} child={child} index={index} />
              ))}
            </div>
          )}
        </motion.div>
      </main>
    </div>
  );
}
