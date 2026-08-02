import Link from "next/link";
import { Nav } from "@/components/Nav";
import { SkillDashboard } from "@/components/school/SkillDashboard";
import { BadgeShelf } from "@/components/BadgeShelf";

export default function SchoolPage() {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-5xl flex-1 px-6 py-16">
        <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-tier-school">
          School
        </p>
        <h1 className="mb-2 text-4xl font-semibold tracking-tight">Your skills</h1>
        <Link
          href="/school/pocket-money"
          className="mb-8 inline-block text-sm font-medium text-primary-500 hover:text-primary-600"
        >
          Pocket Money Planner →
        </Link>
        <div className="mt-8">
          <SkillDashboard />
        </div>
        <div className="mt-10">
          <BadgeShelf />
        </div>
      </main>
    </div>
  );
}
