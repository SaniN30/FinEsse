import Link from "next/link";
import { Nav } from "@/components/Nav";
import { BadgeShelf } from "@/components/BadgeShelf";

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
            className="rounded-full bg-purple-500 px-6 py-3 text-sm font-medium text-white shadow-soft hover:bg-purple-600"
          >
            Start lessons
          </Link>
          <Link
            href="/college/roles"
            className="rounded-full border border-surface-border bg-surface px-6 py-3 text-sm font-medium hover:border-purple-400"
          >
            Explore roles
          </Link>
        </div>
        <Link
          href="/college/pocket-money"
          className="text-sm font-medium text-primary-500 hover:text-primary-600"
        >
          Pocket Money Planner →
        </Link>
        <BadgeShelf />
      </main>
    </div>
  );
}
