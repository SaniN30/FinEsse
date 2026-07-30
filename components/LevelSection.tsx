"use client";

import { motion } from "framer-motion";
import { LevelCard, type LevelTier } from "@/components/LevelCard";

const levels: Array<{
  tier: LevelTier;
  title: string;
  tagline: string;
  topics: string[];
  progress: number;
}> = [
  {
    tier: "school",
    title: "School",
    tagline: "Build the basics: pocket money, saving habits, and the first real budget.",
    topics: ["Saving vs. spending", "Pocket money planning", "Needs vs. wants"],
    progress: 65,
  },
  {
    tier: "college",
    title: "College",
    tagline: "Navigate student budgets, part-time income, and your first credit decisions.",
    topics: ["Budgeting on variable income", "Student credit basics", "Avoiding debt traps"],
    progress: 40,
  },
  {
    tier: "jobready",
    title: "Job-Ready",
    tagline: "Move from paycheck to portfolio: taxes, investing, and long-term planning.",
    topics: ["Reading a payslip", "Investing fundamentals", "Retirement & taxes"],
    progress: 20,
  },
];

export function LevelSection() {
  return (
    <section className="mx-auto max-w-6xl px-6 pb-24">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-80px" }}
        transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
        className="mb-12 max-w-xl"
      >
        <h2 className="text-3xl font-semibold tracking-tight sm:text-4xl">
          Three levels, one growth path
        </h2>
        <p className="mt-3 text-neutral-500">
          Each stage of FinEsse is built around where you actually are with
          money — not a one-size-fits-all course.
        </p>
      </motion.div>

      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {levels.map((level, index) => (
          <LevelCard key={level.tier} index={index} {...level} />
        ))}
      </div>
    </section>
  );
}
