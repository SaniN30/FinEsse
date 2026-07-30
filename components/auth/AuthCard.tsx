"use client";

import { motion } from "framer-motion";
import { Nav } from "@/components/Nav";

interface AuthCardProps {
  eyebrow: string;
  title: string;
  description?: string;
  children: React.ReactNode;
}

export function AuthCard({ eyebrow, title, description, children }: AuthCardProps) {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto flex w-full max-w-md flex-1 flex-col justify-center px-6 py-16">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
          className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-8 shadow-soft"
        >
          <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-primary-500">
            {eyebrow}
          </p>
          <h1 className="text-3xl font-semibold tracking-tight">{title}</h1>
          {description ? (
            <p className="mt-2 text-sm leading-relaxed text-neutral-500">{description}</p>
          ) : null}
          <div className="mt-6">{children}</div>
        </motion.div>
      </main>
    </div>
  );
}
