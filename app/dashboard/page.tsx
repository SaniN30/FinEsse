"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Nav } from "@/components/Nav";
import { Button } from "@/components/Button";
import { useAuth } from "@/lib/supabase/auth-context";
import { fetchLinkedChildren } from "@/lib/supabase/auth-actions";
import type { Profile } from "@/lib/supabase/types";

export default function DashboardPage() {
  const router = useRouter();
  const { session, profile, loading } = useAuth();
  const [children, setChildren] = useState<Profile[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [loadingChildren, setLoadingChildren] = useState(true);

  useEffect(() => {
    if (!loading && !session) {
      router.replace("/login");
    }
  }, [loading, session, router]);

  useEffect(() => {
    if (!session) return;
    fetchLinkedChildren(session.user.id).then((result) => {
      if (result.data) {
        setChildren(result.data);
        setSelectedId((current) => current ?? result.data?.[0]?.id ?? null);
      }
      setLoadingChildren(false);
    });
  }, [session]);

  if (loading || !session) {
    return null;
  }

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-4xl flex-1 px-6 py-16">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
        >
          <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-primary-500">
            Parent dashboard
          </p>
          <h1 className="text-3xl font-semibold tracking-tight">
            Welcome back{profile?.display_name ? `, ${profile.display_name}` : ""}
          </h1>

          {loadingChildren ? (
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
            <>
              <div className="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-3">
                {children.map((child) => (
                  <motion.button
                    key={child.id}
                    type="button"
                    onClick={() => setSelectedId(child.id)}
                    whileHover={{ y: -4 }}
                    whileTap={{ scale: 0.97 }}
                    className={`flex flex-col items-center gap-3 rounded-[var(--radius-card)] border p-6 text-center shadow-soft transition-colors ${
                      selectedId === child.id
                        ? "border-primary-400 bg-primary-50"
                        : "border-surface-border bg-surface"
                    }`}
                  >
                    <span className="flex h-14 w-14 items-center justify-center rounded-full bg-primary-100 text-xl font-semibold text-primary-600">
                      {(child.display_name ?? "?").charAt(0).toUpperCase()}
                    </span>
                    <span className="text-sm font-medium text-foreground">
                      {child.display_name}
                    </span>
                    <span className="text-xs uppercase tracking-wide text-neutral-500">
                      {child.tier ?? "school"}
                    </span>
                  </motion.button>
                ))}
                <button
                  type="button"
                  onClick={() => router.push("/consent")}
                  className="flex flex-col items-center justify-center gap-2 rounded-[var(--radius-card)] border border-dashed border-surface-border p-6 text-center text-sm font-medium text-neutral-500 transition-colors hover:border-primary-400 hover:text-primary-500"
                >
                  + Add another child
                </button>
              </div>

              {selectedId ? (
                <p className="mt-6 text-sm text-neutral-500">
                  Viewing{" "}
                  <span className="font-medium text-foreground">
                    {children.find((c) => c.id === selectedId)?.display_name}
                  </span>
                  — lesson and progress views land in a later phase.
                </p>
              ) : null}
            </>
          )}
        </motion.div>
      </main>
    </div>
  );
}
