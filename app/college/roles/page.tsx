import { Nav } from "@/components/Nav";
import { BackLink } from "@/components/BackLink";
import { RoleExplorerGrid } from "@/components/roles/RoleExplorerGrid";

export default function CollegeRolesPage() {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-5xl flex-1 px-6 py-16">
        <BackLink href="/college" label="Back to College" />
        <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-tier-college">
          College
        </p>
        <h1 className="mb-2 text-3xl font-semibold tracking-tight">Role Explorer</h1>
        <p className="mb-8 text-neutral-500">
          Real finance roles, matched against the skills you&apos;ve mastered.
        </p>
        <RoleExplorerGrid />
      </main>
    </div>
  );
}
