import Link from "next/link";
import { Nav } from "@/components/Nav";

export default function CollegePage() {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto flex w-full max-w-4xl flex-1 flex-col gap-6 px-6 py-16">
        <p className="text-sm font-semibold uppercase tracking-wide text-tier-college">
          College
        </p>
        <h1 className="text-4xl font-semibold tracking-tight sm:text-5xl">
          Build the finance skills that get you hired
        </h1>
        <p className="text-lg text-muted-foreground">
          Lessons and quizzes on markets, valuation, and modeling — plus a
          Role Explorer that matches what you&apos;ve mastered to real
          finance jobs.
        </p>
        <div className="flex flex-wrap gap-4 pt-2">
          <Link
            href="/college/lessons"
            className="rounded-full bg-primary-500 px-6 py-3 text-sm font-medium text-white shadow-soft hover:bg-primary-600"
          >
            Start lessons
          </Link>
          <Link
            href="/college/roles"
            className="rounded-full border border-surface-border bg-surface px-6 py-3 text-sm font-medium hover:border-primary-400"
          >
            Explore roles
          </Link>
        </div>
      </main>
    </div>
  );
}
