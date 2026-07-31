"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { useEffect, useState } from "react";
import { useAuth } from "@/lib/supabase/auth-context";
import { fetchSkillsWithMastery, fetchTotalXp, type SkillWithMastery } from "@/lib/school/queries";
import { ProgressBar } from "@/components/ProgressBar";
import { Skeleton } from "@/components/Skeleton";

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message;
  return "Something went wrong loading your skills.";
}

/** The one skill the plan wants surfaced as "the current quest": the first
 * unlocked skill the student hasn't yet reached mastery on. Falls back to
 * the first locked skill (nothing to do yet) if every unlocked skill is
 * already mastered. */
function pickCurrentQuest(skills: SkillWithMastery[]): SkillWithMastery | null {
  const inProgress = skills.find(
    (skill) => skill.isUnlocked && (skill.rollingAccuracy ?? 0) < skill.mastery_threshold,
  );
  return inProgress ?? skills.find((skill) => skill.isUnlocked) ?? skills[0] ?? null;
}

function SkillDashboardSkeleton() {
  return (
    <div>
      <Skeleton className="mb-6 h-40 w-full" />
      <div className="space-y-2">
        <Skeleton className="h-12 w-full" />
        <Skeleton className="h-12 w-full" />
        <Skeleton className="h-12 w-full" />
      </div>
    </div>
  );
}

export function SkillDashboard() {
  const { profile, loading: isAuthLoading } = useAuth();
  const [skills, setSkills] = useState<SkillWithMastery[] | null>(null);
  const [totalXp, setTotalXp] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!profile) return;

    let isMounted = true;
    Promise.all([fetchSkillsWithMastery(profile.id, "school"), fetchTotalXp(profile.id)])
      .then(([skillsResult, xpResult]) => {
        if (!isMounted) return;
        setSkills(skillsResult);
        setTotalXp(xpResult);
      })
      .catch((err: unknown) => {
        if (isMounted) setError(getErrorMessage(err));
      });

    return () => {
      isMounted = false;
    };
  }, [profile]);

  if (isAuthLoading) {
    return <SkillDashboardSkeleton />;
  }

  if (!profile) {
    return (
      <p className="text-sm text-neutral-500">
        Sign in to see your School skills and progress.
      </p>
    );
  }

  if (error) {
    return <p className="text-sm text-red-600">{error}</p>;
  }

  if (!skills) {
    return <SkillDashboardSkeleton />;
  }

  if (skills.length === 0) {
    return <p className="text-sm text-neutral-500">No skills published for School yet.</p>;
  }

  const currentQuest = pickCurrentQuest(skills);
  const restOfPath = skills.filter((skill) => skill.id !== currentQuest?.id);

  return (
    <div>
      {/* The current quest: one skill node, large, clearly "next" — the plan
          is explicit that this should not be a full skill tree upfront. */}
      {currentQuest ? (
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: [0.25, 1, 0.5, 1] as const }}
        >
          <p className="mb-3 text-xs font-semibold uppercase tracking-wide text-tier-school">
            Current quest
          </p>
          {currentQuest.isUnlocked ? (
            <Link href={`/school/skills/${currentQuest.id}`} className="block">
              <div className="rounded-[var(--radius-card)] border-2 border-tier-school/40 bg-surface p-8 shadow-soft transition-shadow hover:shadow-lg">
                <h2 className="mb-2 text-2xl font-semibold">{currentQuest.title}</h2>
                <ProgressBar
                  value={Math.round((currentQuest.rollingAccuracy ?? 0) * 100)}
                  colorClassName="bg-tier-school"
                  label={`${currentQuest.attemptsConsidered} recent attempt${
                    currentQuest.attemptsConsidered === 1 ? "" : "s"
                  }`}
                  className="mt-4"
                />
              </div>
            </Link>
          ) : (
            <div className="rounded-[var(--radius-card)] border-2 border-surface-border bg-surface p-8 opacity-70 shadow-soft">
              <h2 className="mb-2 text-2xl font-semibold">{currentQuest.title}</h2>
              <p className="text-sm text-neutral-500">Locked — finish the prerequisite skill first</p>
            </div>
          )}
        </motion.div>
      ) : null}

      {/* Collapsed path preview: done/locked nodes shown small, below the
          fold, lazy-revealed on scroll so first paint stays on the quest. */}
      {restOfPath.length > 0 ? (
        <div className="mt-10">
          <p className="mb-3 text-xs font-medium uppercase tracking-wide text-neutral-500">
            Skill path
          </p>
          <ul className="space-y-1.5">
            {restOfPath.map((skill, index) => {
              const isMastered = (skill.rollingAccuracy ?? 0) >= skill.mastery_threshold;
              const label = !skill.isUnlocked ? "Locked" : isMastered ? "Mastered" : "Unlocked";
              const row = (
                <motion.div
                  initial={{ opacity: 0, y: 12 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true, margin: "-40px" }}
                  transition={{ duration: 0.35, ease: [0.25, 1, 0.5, 1] as const, delay: index * 0.03 }}
                  className={`flex items-center justify-between rounded-lg border border-surface-border px-4 py-2.5 text-sm ${
                    skill.isUnlocked ? "bg-surface" : "bg-surface/50 opacity-60"
                  }`}
                >
                  <span className="font-medium">{skill.title}</span>
                  <span className="text-xs uppercase tracking-wide text-neutral-500">{label}</span>
                </motion.div>
              );
              return skill.isUnlocked ? (
                <li key={skill.id}>
                  <Link href={`/school/skills/${skill.id}`} className="block">
                    {row}
                  </Link>
                </li>
              ) : (
                <li key={skill.id}>{row}</li>
              );
            })}
          </ul>
        </div>
      ) : null}

      {/* Level/XP: quiet corner readout, not a headline number. */}
      {totalXp !== null ? (
        <p className="mt-10 text-right text-xs font-medium text-neutral-400">
          Total XP <span className="text-neutral-600">{totalXp}</span>
        </p>
      ) : null}
    </div>
  );
}
