"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { useEffect, useState } from "react";
import { useAuth } from "@/lib/supabase/auth-context";
import { fetchSkillsWithMastery, fetchTotalXp, type SkillWithMastery } from "@/lib/school/queries";
import { ProgressBar } from "@/components/ProgressBar";

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message;
  return "Something went wrong loading your skills.";
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
    return <p className="text-sm text-neutral-500">Loading your account…</p>;
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
    return <p className="text-sm text-neutral-500">Loading skills…</p>;
  }

  return (
    <div>
      {totalXp !== null ? (
        <p className="mb-8 text-sm font-medium text-neutral-500">
          Total XP: <span className="text-foreground font-semibold">{totalXp}</span>
        </p>
      ) : null}

      <div className="grid gap-5 sm:grid-cols-2">
        {skills.map((skill, index) => {
          const progress = Math.round((skill.rollingAccuracy ?? 0) * 100);
          const card = (
            <motion.article
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-60px" }}
              transition={{ duration: 0.5, ease: [0.25, 1, 0.5, 1] as const, delay: index * 0.08 }}
              className={`rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft transition-shadow duration-300 ${
                skill.isUnlocked ? "hover:shadow-lg" : "opacity-60"
              }`}
            >
              <h3 className="mb-1 text-xl font-semibold">{skill.title}</h3>
              <p className="mb-4 text-xs font-medium uppercase tracking-wide text-neutral-500">
                {skill.isUnlocked ? "Unlocked" : "Locked — finish the prerequisite skill first"}
              </p>
              <ProgressBar
                value={progress}
                colorClassName="bg-tier-school"
                label={`${skill.attemptsConsidered} recent attempt${skill.attemptsConsidered === 1 ? "" : "s"}`}
              />
            </motion.article>
          );

          return skill.isUnlocked ? (
            <Link key={skill.id} href={`/school/skills/${skill.id}`} className="block">
              {card}
            </Link>
          ) : (
            <div key={skill.id}>{card}</div>
          );
        })}
      </div>
    </div>
  );
}
