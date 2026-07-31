"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/supabase/auth-context";

/**
 * Per finesse-page-plan.html, /dashboard is the parent's landing screen and
 * the entry point for the aggregate rollup ("keep the card list ready to
 * grow a summary strip above it"). The aggregate rollup (per-child tier, XP,
 * mastery, pocket money, Interview Coach) already lives at /parent/dashboard
 * (see AGENTS.md's "Parent dashboard aggregate rollup" section) but was
 * unreachable from any nav link or post-login redirect — /login and Nav both
 * pointed here at a plain child-picker with none of that data. Redirecting
 * here (rather than duplicating the aggregate view under a second route)
 * makes /dashboard the single landing screen the plan describes without
 * rebuilding the rollup that Phase 8 already shipped.
 */
export default function DashboardPage() {
  const router = useRouter();
  const { session, loading } = useAuth();

  useEffect(() => {
    if (loading) return;
    router.replace(session ? "/parent/dashboard" : "/login");
  }, [loading, session, router]);

  return null;
}
