import { Nav } from "@/components/Nav";
import { ModelingExerciseForm } from "@/components/modeling/ModelingExerciseForm";

interface JobReadyModelingPageProps {
  params: Promise<{ exerciseId: string }>;
}

export default async function JobReadyModelingPage({
  params,
}: JobReadyModelingPageProps) {
  const { exerciseId } = await params;

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-2xl flex-1 px-6 py-16">
        <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-tier-jobready">
          Job-Ready · Case exercise
        </p>
        <ModelingExerciseForm exerciseId={exerciseId} />
      </main>
    </div>
  );
}
