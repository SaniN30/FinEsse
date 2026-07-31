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
        <p className="mt-4 text-lg text-neutral-500">
          Case-method lessons land in a later phase — practice with the AI Interview Coach now.
        </p>
        <Link
          href="/job-ready/interview"
          className="mt-8 inline-flex text-sm font-medium text-primary-500 hover:text-primary-600"
        >
          Practice an interview question →
        </Link>
      </main>
    </div>
  );
}
