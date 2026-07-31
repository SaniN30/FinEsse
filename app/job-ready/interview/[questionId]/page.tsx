import { Nav } from "@/components/Nav";
import { InterviewSession } from "@/components/interview-coach/InterviewSession";

interface InterviewSessionPageProps {
  params: Promise<{ questionId: string }>;
}

export default async function InterviewSessionPage({ params }: InterviewSessionPageProps) {
  const { questionId } = await params;

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-2xl flex-1 px-6 py-16">
        <InterviewSession questionId={questionId} />
      </main>
    </div>
  );
}
