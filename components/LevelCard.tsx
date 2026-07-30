"use client";

import { motion } from "framer-motion";
import { cn } from "@/lib/cn";
import { ProgressBar } from "@/components/ProgressBar";

export type LevelTier = "school" | "college" | "jobready";

interface LevelCardProps {
  tier: LevelTier;
  title: string;
  tagline: string;
  topics: string[];
  progress: number;
  index?: number;
}

const tierStyles: Record<
  LevelTier,
  { accent: string; badge: string; glow: string; label: string }
> = {
  school: {
    accent: "bg-tier-school",
    badge: "bg-secondary-400/15 text-secondary-600",
    glow: "from-secondary-400/25",
    label: "Level 01",
  },
  college: {
    accent: "bg-tier-college",
    badge: "bg-primary-400/15 text-primary-600",
    glow: "from-primary-400/25",
    label: "Level 02",
  },
  jobready: {
    accent: "bg-tier-jobready",
    badge: "bg-accent-400/15 text-accent-600",
    glow: "from-accent-400/25",
    label: "Level 03",
  },
};

export function LevelCard({
  tier,
  title,
  tagline,
  topics,
  progress,
  index = 0,
}: LevelCardProps) {
  const styles = tierStyles[tier];

  return (
    <motion.article
      initial={{ opacity: 0, y: 32 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const, delay: index * 0.12 }}
      whileHover={{ y: -6 }}
      className={cn(
        "group relative overflow-hidden rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft transition-shadow duration-300 hover:shadow-lg",
      )}
    >
      <div
        className={cn(
          "pointer-events-none absolute -right-16 -top-16 h-40 w-40 rounded-full bg-gradient-to-br opacity-0 blur-2xl transition-opacity duration-500 group-hover:opacity-100",
          styles.glow,
        )}
      />

      <div className={cn("mb-4 inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold", styles.badge)}>
        {styles.label}
      </div>

      <h3 className="mb-2 text-2xl font-semibold">{title}</h3>
      <p className="mb-5 text-sm leading-relaxed text-neutral-500">{tagline}</p>

      <ul className="mb-6 space-y-2">
        {topics.map((topic) => (
          <li key={topic} className="flex items-center gap-2 text-sm text-neutral-600">
            <span className={cn("h-1.5 w-1.5 shrink-0 rounded-full", styles.accent)} />
            {topic}
          </li>
        ))}
      </ul>

      <ProgressBar value={progress} colorClassName={styles.accent} label="Curriculum ready" />
    </motion.article>
  );
}
