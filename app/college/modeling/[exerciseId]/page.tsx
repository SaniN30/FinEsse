import { Nav } from "@/components/Nav";
import { BackLink } from "@/components/BackLink";
import { ModelingExerciseForm } from "@/components/modeling/ModelingExerciseForm";

interface CollegeModelingPageProps {
  params: Promise<{ exerciseId: string }>;
}

export default async function CollegeModelingPage({
  params,
}: CollegeModelingPageProps) {
  const { exerciseId } = await params;

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-2xl flex-1 px-6 py-16">
        <BackLink href="/college" label="Back to College" />
        <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-tier-college">
          College · Modeling exercise
        </p>
        <ModelingExerciseForm exerciseId={exerciseId} />
      </main>
    </div>
  );
}
