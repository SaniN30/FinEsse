"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { Button } from "@/components/Button";

function useIsDesktop() {
  const [isDesktop, setIsDesktop] = useState(false);

  useEffect(() => {
    const query = window.matchMedia("(min-width: 1024px)");
    setIsDesktop(query.matches);
    const handleChange = (event: MediaQueryListEvent) => setIsDesktop(event.matches);
    query.addEventListener("change", handleChange);
    return () => query.removeEventListener("change", handleChange);
  }, []);

  return isDesktop;
}

const container = {
  hidden: {},
  show: {
    transition: { staggerChildren: 0.1, delayChildren: 0.1 },
  },
};

const item = {
  hidden: { opacity: 0, y: 20 },
  show: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.6, ease: [0.25, 1, 0.5, 1] as const },
  },
};

const tierDots: Array<{ label: string; className: string }> = [
  { label: "School", className: "bg-tier-school" },
  { label: "College", className: "bg-tier-college" },
  { label: "Job-Ready", className: "bg-tier-jobready" },
];

export function Hero() {
  const isDesktop = useIsDesktop();

  return (
    <section className="relative overflow-hidden px-6 pb-28 pt-16 sm:pt-20">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-x-0 -top-32 h-[28rem] bg-[radial-gradient(circle_at_50%_0%,var(--color-primary-100),transparent_65%)]"
      />

      <div className="relative mx-auto grid max-w-6xl items-center gap-16 lg:grid-cols-[1.05fr_0.95fr]">
        <motion.div
          variants={container}
          initial="hidden"
          animate="show"
          className="flex flex-col items-start text-left"
        >
          <motion.span
            variants={item}
            className="mb-6 inline-flex items-center gap-2 rounded-full border-2 border-foreground bg-surface px-4 py-1.5 text-xs font-semibold shadow-[var(--shadow-offset)]"
          >
            <span className="h-1.5 w-1.5 rounded-full bg-accent-500" />
            Financial literacy, staged for real life
          </motion.span>

          <motion.h1
            variants={item}
            className="text-4xl font-bold leading-[1.08] tracking-tight sm:text-6xl"
          >
            Money skills that
            <br />
            grow <span className="text-primary-500">with you</span>
          </motion.h1>

          <motion.p
            variants={item}
            className="mt-6 max-w-lg text-lg leading-relaxed text-muted-foreground"
          >
            FinEsse teaches personal finance in three stages — School,
            College, and Job-Ready — so every lesson meets you exactly where
            your money life actually is.
          </motion.p>

          <motion.div variants={item} className="mt-10 flex flex-wrap items-center gap-4">
            <Button size="lg">Start learning</Button>
            <Button size="lg" variant="secondary">
              See how it works
            </Button>
          </motion.div>

          <motion.div
            variants={item}
            className="mt-10 flex items-center gap-3 text-sm text-muted-foreground"
          >
            <div className="flex -space-x-1.5">
              {tierDots.map((tier) => (
                <span
                  key={tier.label}
                  title={tier.label}
                  className={`h-6 w-6 rounded-full border-2 border-background ${tier.className}`}
                />
              ))}
            </div>
            <span>One growth path, from first pocket money to first paycheck</span>
          </motion.div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, ease: [0.25, 1, 0.5, 1] as const, delay: 0.2 }}
          className="relative mx-auto flex w-full max-w-md flex-col gap-4 lg:mx-0 lg:h-[22rem] lg:block"
        >
          <motion.div
            initial={{ y: 0 }}
            animate={{ y: isDesktop ? [0, -10, 0] : 0 }}
            transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
            style={{ rotate: isDesktop ? -6 : 0 }}
            className="w-full rounded-[var(--radius-card)] border-2 border-foreground bg-surface p-5 shadow-[var(--shadow-offset)] lg:absolute lg:left-0 lg:top-6 lg:w-64"
          >
            <p className="text-xs font-semibold text-muted-foreground">Today&apos;s lesson</p>
            <p className="mt-1 font-display text-lg font-semibold">Needs vs. wants</p>
            <div className="mt-4 h-2 w-full rounded-full bg-neutral-100 dark:bg-neutral-800">
              <div className="h-2 w-2/3 rounded-full bg-accent-500" />
            </div>
            <p className="mt-2 text-xs text-muted-foreground">2 of 3 quizzes complete</p>
          </motion.div>

          <motion.div
            initial={{ y: 0 }}
            animate={{ y: isDesktop ? [0, 10, 0] : 0 }}
            transition={{ duration: 7, repeat: Infinity, ease: "easeInOut", delay: 0.5 }}
            style={{ rotate: isDesktop ? 5 : 0 }}
            className="w-full rounded-[var(--radius-card)] border-2 border-foreground bg-primary-500 p-5 text-white shadow-[var(--shadow-offset)] lg:absolute lg:bottom-6 lg:right-0 lg:w-56"
          >
            <p className="text-xs font-semibold text-primary-100">Level up</p>
            <p className="mt-1 font-display text-2xl font-bold">+120 XP</p>
            <p className="mt-2 text-xs text-primary-100">
              Job-Ready mock interview scored
            </p>
          </motion.div>

          <motion.div
            initial={{ y: 0 }}
            animate={{ y: isDesktop ? [0, -6, 0] : 0 }}
            transition={{ duration: 5.5, repeat: Infinity, ease: "easeInOut", delay: 1 }}
            style={{ rotate: isDesktop ? -2 : 0 }}
            className="w-full rounded-[var(--radius-card)] border-2 border-foreground bg-tier-jobready p-4 text-white shadow-[var(--shadow-offset)] lg:absolute lg:left-14 lg:top-52 lg:w-48"
          >
            <p className="text-xs font-semibold">Pocket money</p>
            <p className="mt-1 font-display text-xl font-bold">₹340 saved</p>
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
