"use client";

import { motion } from "framer-motion";

const EASE_OUT_QUART = [0.25, 1, 0.5, 1] as const;

/**
 * Topic heading for a lesson page. Renders a real h1 so it picks up each
 * tier's `.theme-tier-* h1` treatment (pixel-shadow / gradient-underline /
 * ink color, see DESIGN.md) for free, plus an entrance animation shared
 * across tiers.
 */
export function LessonHeading({ title }: { title: string }) {
  return (
    <motion.h1
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, ease: EASE_OUT_QUART }}
      className="mb-6 text-3xl font-bold sm:text-4xl"
    >
      {title}
    </motion.h1>
  );
}
