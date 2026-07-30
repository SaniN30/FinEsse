"use client";

import { motion } from "framer-motion";

export function PocketMoneyPlanner() {
  return (
    <motion.section
      initial={{ opacity: 0, y: 32 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
      className="mx-auto max-w-6xl px-6 pb-28"
    >
      <div className="relative overflow-hidden rounded-[var(--radius-card)] border border-surface-border bg-gradient-to-br from-primary-500 via-secondary-500 to-primary-700 p-10 text-white shadow-soft sm:p-14">
        <div
          aria-hidden
          className="pointer-events-none absolute -right-10 -top-10 h-64 w-64 rounded-full bg-white/10 blur-3xl"
        />
        <span className="mb-4 inline-flex items-center rounded-full bg-white/15 px-3 py-1 text-xs font-semibold uppercase tracking-wide">
          Coming soon
        </span>
        <h2 className="max-w-lg text-3xl font-semibold leading-tight sm:text-4xl">
          The Pocket Money Planner
        </h2>
        <p className="mt-4 max-w-xl text-white/80">
          A hands-on budgeting tool built for the School tier — set a weekly
          allowance, track spending against goals, and watch savings grow.
          Landing in a later phase.
        </p>
      </div>
    </motion.section>
  );
}
