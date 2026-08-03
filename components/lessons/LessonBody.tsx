"use client";

import { useState } from "react";
import { AnimatePresence, motion } from "framer-motion";

const EASE_OUT_QUART = [0.25, 1, 0.5, 1] as const;

function splitParagraphs(text: string): string[] {
  const blocks = text
    .split(/\n\s*\n/)
    .map((block) => block.trim())
    .filter(Boolean);
  return blocks.length > 0 ? blocks : [text];
}

/**
 * Renders a lesson's plain-text content_body as progressively-revealed
 * paragraphs (whileInView, staggered) instead of one static text block, plus
 * a collapsible "Why this matters" callout built from the final paragraph so
 * every lesson gets at least one piece of genuine interactivity.
 */
export function LessonBody({ text }: { text: string }) {
  const paragraphs = splitParagraphs(text);
  const takeaway = paragraphs.length > 1 ? paragraphs[paragraphs.length - 1] : null;
  const bodyParagraphs = takeaway ? paragraphs.slice(0, -1) : paragraphs;
  const [showTakeaway, setShowTakeaway] = useState(false);

  return (
    <div className="space-y-4">
      {bodyParagraphs.map((paragraph, index) => (
        <motion.p
          key={index}
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-40px" }}
          transition={{ duration: 0.5, ease: EASE_OUT_QUART, delay: index * 0.08 }}
          className="text-sm leading-relaxed text-foreground"
        >
          {paragraph}
        </motion.p>
      ))}

      {takeaway ? (
        <div className="rounded-[var(--radius-card)] border border-[var(--tier-accent)]/40 bg-[var(--tier-accent)]/10">
          <button
            type="button"
            onClick={() => setShowTakeaway((open) => !open)}
            className="flex w-full items-center justify-between gap-3 px-4 py-3 text-left text-sm font-semibold text-foreground"
            aria-expanded={showTakeaway}
          >
            Why this matters
            <motion.span
              animate={{ rotate: showTakeaway ? 180 : 0 }}
              transition={{ duration: 0.2, ease: EASE_OUT_QUART }}
              aria-hidden
            >
              ▾
            </motion.span>
          </button>
          <AnimatePresence initial={false}>
            {showTakeaway ? (
              <motion.div
                key="takeaway"
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: "auto", opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                transition={{ duration: 0.3, ease: EASE_OUT_QUART }}
                className="overflow-hidden"
              >
                <p className="px-4 pb-4 text-sm leading-relaxed text-muted-foreground">
                  {takeaway}
                </p>
              </motion.div>
            ) : null}
          </AnimatePresence>
        </div>
      ) : null}
    </div>
  );
}
