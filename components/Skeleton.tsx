import { cn } from "@/lib/cn";

/**
 * Shared skeleton-pulse primitive for the "skeleton, never spinner-block"
 * optimization rule (finesse-page-plan.html, Optimization plan #01): every
 * live-data section should render its shape immediately, then swap in real
 * numbers, instead of blocking the page on a "Loading…" string.
 */
export function Skeleton({ className }: { className?: string }) {
  return (
    <div
      aria-hidden
      className={cn("animate-pulse rounded-md bg-neutral-200/70", className)}
    />
  );
}
