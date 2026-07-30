"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { Nav } from "@/components/Nav";
import type { LevelTier } from "@/components/LevelCard";

const tierColor: Record<LevelTier, string> = {
  school: "text-tier-school",
  college: "text-tier-college",
  jobready: "text-tier-jobready",
};

interface TierPlaceholderProps {
  tier: LevelTier;
  title: string;
  description: string;
}

export function TierPlaceholder({ tier, title, description }: TierPlaceholderProps) {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto flex max-w-3xl flex-1 flex-col items-center justify-center px-6 py-24 text-center">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
        >
          <p className={`mb-3 text-sm font-semibold uppercase tracking-wide ${tierColor[tier]}`}>
            Coming in a later phase
          </p>
          <h1 className="text-4xl font-semibold tracking-tight sm:text-5xl">{title}</h1>
          <p className="mt-4 text-lg text-neutral-500">{description}</p>
          <Link
            href="/"
            className="mt-8 inline-flex text-sm font-medium text-primary-500 hover:text-primary-600"
          >
            ← Back to home
          </Link>
        </motion.div>
      </main>
    </div>
  );
}
