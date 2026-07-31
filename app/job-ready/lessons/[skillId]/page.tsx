import { Nav } from "@/components/Nav";
import { LessonDetail } from "@/components/lessons/LessonDetail";

interface JobReadyLessonDetailPageProps {
  params: Promise<{ skillId: string }>;
}

export default async function JobReadyLessonDetailPage({
  params,
}: JobReadyLessonDetailPageProps) {
  const { skillId } = await params;

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-3xl flex-1 px-6 py-16">
        <LessonDetail skillId={skillId} quizBasePath="/job-ready/quiz" modelingBasePath="/job-ready/modeling" />
      </main>
    </div>
  );
}
