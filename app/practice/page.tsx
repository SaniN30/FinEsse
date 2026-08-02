"use client";

import { useState } from "react";
import { Nav } from "@/components/Nav";
import { useAuth } from "@/lib/supabase/auth-context";
import { PracticeFilters } from "@/components/practice/PracticeFilters";
import { PracticeList } from "@/components/practice/PracticeList";
import { InterviewPracticeList } from "@/components/practice/InterviewPracticeList";
import type { PracticeFilters as PracticeFiltersValue } from "@/lib/practice/queries";
import { cn } from "@/lib/cn";

type PracticeTab = "questions" | "interview";

export default function PracticePage() {
  const { session, profile, loading } = useAuth();
  const [tab, setTab] = useState<PracticeTab>("questions");
  const [filters, setFilters] = useState<PracticeFiltersValue>({});

  // Defaults the tier filter to the student's own tier until they pick one
  // explicitly, without syncing profile.tier into state via an effect.
  const effectiveFilters: PracticeFiltersValue = {
    ...filters,
    tier: filters.tier ?? profile?.tier ?? undefined,
  };
  const filtersKey = `${effectiveFilters.tier ?? ""}-${effectiveFilters.difficulty ?? ""}-${effectiveFilters.questionType ?? ""}-${effectiveFilters.caseStudyOnly ? "1" : "0"}`;

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-4xl flex-1 px-6 py-16">
        <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-primary-500">Practice</p>
        <h1 className="mb-4 text-3xl font-semibold tracking-tight">Free Practice</h1>
        <p className="mb-8 text-muted-foreground">
          Answer quiz, free-response, and case-study questions from across School, College, and
          Job-Ready in one place. Practice attempts are tracked separately here and never affect
          your lesson progress, XP, or badges.
        </p>

        {loading ? (
          <p className="text-sm text-muted-foreground">Loading…</p>
        ) : !session ? (
          <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-8 text-center shadow-soft">
            <p className="mb-4 text-sm text-muted-foreground">Sign in as a student to start practicing.</p>
            <a href="/login" className="text-sm font-medium text-primary-500 hover:text-primary-600">
              Sign in →
            </a>
          </div>
        ) : profile?.role !== "student" ? (
          <p className="text-sm text-muted-foreground">
            Practice is available on a student account -- sign in as a student to use it.
          </p>
        ) : (
          <>
            <div className="mb-6 flex gap-2">
              <button
                type="button"
                onClick={() => setTab("questions")}
                className={cn(
                  "rounded-full border px-4 py-2 text-sm font-medium transition-colors",
                  tab === "questions"
                    ? "border-purple-500 bg-purple-500 text-white"
                    : "border-surface-border bg-surface text-muted-foreground",
                )}
              >
                Quiz &amp; Case Studies
              </button>
              <button
                type="button"
                onClick={() => setTab("interview")}
                className={cn(
                  "rounded-full border px-4 py-2 text-sm font-medium transition-colors",
                  tab === "interview"
                    ? "border-purple-500 bg-purple-500 text-white"
                    : "border-surface-border bg-surface text-muted-foreground",
                )}
              >
                Interview Prep
              </button>
            </div>

            {tab === "questions" ? (
              <>
                <div className="mb-6">
                  <PracticeFilters value={effectiveFilters} onChange={setFilters} />
                </div>
                <PracticeList key={filtersKey} filters={effectiveFilters} />
              </>
            ) : (
              <>
                <div className="mb-6">
                  <select
                    aria-label="Filter interview questions by difficulty"
                    className="rounded-full border border-surface-border bg-surface px-4 py-2 text-sm text-foreground focus:border-purple-400 focus:outline-none"
                    value={filters.difficulty ?? ""}
                    onChange={(event) =>
                      setFilters((current) => ({
                        ...current,
                        difficulty: (event.target.value || undefined) as PracticeFiltersValue["difficulty"],
                      }))
                    }
                  >
                    <option value="">All difficulties</option>
                    <option value="easy">Easy</option>
                    <option value="medium">Medium</option>
                    <option value="hard">Hard</option>
                  </select>
                </div>
                <InterviewPracticeList key={filters.difficulty ?? "all"} difficulty={filters.difficulty} />
              </>
            )}
          </>
        )}
      </main>
    </div>
  );
}
