import Link from "next/link";
import { Nav } from "@/components/Nav";

export default function JobReadyPage() {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto flex max-w-3xl flex-1 flex-col items-center justify-center px-6 py-24 text-center">
        <p className="mb-3 text-sm font-semibold uppercase tracking-wide text-tier-jobready">
          Job-Ready
        </p>
        <h1 className="text-4xl font-semibold tracking-tight sm:text-5xl">Job-Ready</h1>
        <p className="mt-4 text-lg text-muted-foreground">
          Lessons on interview fundamentals, resumes, and case-method thinking, plus the AI
          Interview Coach for live practice.
        </p>
        <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
          <Link
            href="/job-ready/lessons"
            className="rounded-full bg-purple-500 px-6 py-3 text-sm font-medium text-white shadow-soft hover:bg-purple-600"
          >
            Start lessons
          </Link>
          <Link
            href="/job-ready/interview"
            className="text-sm font-medium text-primary-500 hover:text-primary-600"
          >
            Practice an interview question →
          </Link>
        </div>
      </main>
    </div>
  );
}
