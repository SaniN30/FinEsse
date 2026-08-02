"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { cn } from "@/lib/cn";

export type LevelTier = "school" | "college" | "jobready";

const tierHrefs: Record<LevelTier, string> = {
  school: "/school",
  college: "/college",
  jobready: "/job-ready",
};

interface LevelCardProps {
  tier: LevelTier;
  title: string;
  tagline: string;
  topics: string[];
  stat: string;
  index?: number;
}

const tierStyles: Record<
  LevelTier,
  { accent: string; badge: string; panel: string; label: string }
> = {
  school: {
    accent: "bg-tier-school",
    badge: "bg-secondary-400/15 text-secondary-600",
    panel: "bg-[var(--panel-school)]",
    label: "Level 01",
  },
  college: {
    accent: "bg-tier-college",
    badge: "bg-primary-400/15 text-primary-600",
    panel: "bg-[var(--panel-college)]",
    label: "Level 02",
  },
  jobready: {
    accent: "bg-tier-jobready",
    badge: "bg-accent-400/15 text-accent-600",
    panel: "bg-[var(--panel-jobready)]",
    label: "Level 03",
  },
};

export function LevelCard({
  tier,
  title,
  tagline,
  topics,
  stat,
  index = 0,
}: LevelCardProps) {
  const styles = tierStyles[tier];

  return (
    <motion.article
      initial={{ opacity: 0, y: 32 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const, delay: index * 0.12 }}
      whileHover={{ y: -6, scale: 1.015 }}
      whileTap={{ y: -2, scale: 0.99 }}
      className={cn(
        "group relative overflow-hidden rounded-[var(--radius-card)] border-2 border-foreground p-6 shadow-[var(--shadow-offset)]",
        styles.panel,
      )}
    >
      <Link href={tierHrefs[tier]} className="absolute inset-0 z-10" aria-label={`Explore ${title}`} />

      <div className={cn("mb-4 inline-flex items-center rounded-full border-2 border-foreground bg-surface px-3 py-1 text-xs font-semibold", styles.badge)}>
        {styles.label}
      </div>

      <h3 className="mb-2 text-2xl font-semibold">{title}</h3>
      <p className="mb-5 text-sm leading-relaxed text-muted-foreground">{tagline}</p>

      <ul className="mb-6 space-y-2">
        {topics.map((topic) => (
          <li key={topic} className="flex items-center gap-2 text-sm text-muted-foreground">
            <span className={cn("h-1.5 w-1.5 shrink-0 rounded-full", styles.accent)} />
            {topic}
          </li>
        ))}
      </ul>

      <div className="flex items-center justify-between gap-2 text-xs font-medium text-muted-foreground">
        <span className="flex items-center gap-2">
          <span className={cn("h-1.5 w-1.5 shrink-0 rounded-full", styles.accent)} />
          {stat}
        </span>
        <span className="flex items-center gap-1 opacity-0 transition-opacity duration-200 group-hover:opacity-100">
          Explore
          <span aria-hidden className="transition-transform duration-200 group-hover:translate-x-0.5">
            →
          </span>
        </span>
      </div>
    </motion.article>
  );
}
