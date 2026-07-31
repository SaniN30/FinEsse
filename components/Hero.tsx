"use client";

import { motion } from "framer-motion";
import { Button } from "@/components/Button";
import { Logo } from "@/components/Logo";

const container = {
  hidden: {},
  show: {
    transition: { staggerChildren: 0.12, delayChildren: 0.1 },
  },
};

const item = {
  hidden: { opacity: 0, y: 24 },
  show: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.7, ease: [0.25, 1, 0.5, 1] as const },
  },
};

export function Hero() {
  return (
    <section className="relative overflow-hidden px-6 pb-24 pt-20 sm:pt-28">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-x-0 -top-40 h-[32rem] bg-[radial-gradient(circle_at_50%_0%,var(--color-primary-200),transparent_60%)] opacity-60"
      />

      <motion.div
        variants={container}
        initial="hidden"
        animate="show"
        className="relative mx-auto flex max-w-3xl flex-col items-center text-center"
      >
        <motion.div variants={item} className="mb-6">
          <Logo size="lg" />
        </motion.div>

        <motion.span
          variants={item}
          className="mb-6 inline-flex items-center gap-2 rounded-full border border-surface-border bg-surface px-4 py-1.5 text-xs font-medium text-neutral-500"
        >
          <span className="h-1.5 w-1.5 rounded-full bg-accent-500" />
          Financial literacy, staged for real life
        </motion.span>

        <motion.h1
          variants={item}
          className="text-4xl font-semibold leading-[1.1] tracking-tight sm:text-6xl"
        >
          Money skills that
          <br />
          <span className="bg-gradient-to-r from-primary-500 via-secondary-500 to-accent-500 bg-clip-text text-transparent">
            grow with you
          </span>
        </motion.h1>

        <motion.p
          variants={item}
          className="mt-6 max-w-xl text-lg leading-relaxed text-neutral-500"
        >
          FinEsse teaches personal finance in three stages — School, College,
          and Job-Ready — so every lesson meets you exactly where your money
          life actually is.
        </motion.p>

        <motion.div variants={item} className="mt-10 flex flex-wrap items-center justify-center gap-4">
          <Button size="lg">Start learning</Button>
          <Button size="lg" variant="secondary">
            See how it works
          </Button>
        </motion.div>
      </motion.div>
    </section>
  );
}
