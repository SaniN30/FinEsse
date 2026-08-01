"use client";

import { motion } from "framer-motion";
import { cn } from "@/lib/cn";

interface ProgressBarProps {
  value: number;
  label?: string;
  colorClassName?: string;
  className?: string;
}

export function ProgressBar({
  value,
  label,
  colorClassName = "bg-purple-500",
  className,
}: ProgressBarProps) {
  const clamped = Math.min(100, Math.max(0, value));

  return (
    <div className={cn("w-full", className)}>
      {label ? (
        <div className="mb-1.5 flex items-center justify-between text-xs font-medium text-muted-foreground">
          <span>{label}</span>
          <span>{clamped}%</span>
        </div>
      ) : null}
      <div className="h-2 w-full overflow-hidden rounded-full bg-neutral-200/70">
        <motion.div
          initial={{ width: 0 }}
          whileInView={{ width: `${clamped}%` }}
          viewport={{ once: true }}
          transition={{ duration: 0.9, ease: [0.25, 1, 0.5, 1] as const }}
          className={cn("h-full rounded-full", colorClassName)}
        />
      </div>
    </div>
  );
}
