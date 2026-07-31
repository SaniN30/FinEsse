import { Nav } from "@/components/Nav";
import { BackLink } from "@/components/BackLink";
import { LessonDetail } from "@/components/lessons/LessonDetail";

interface CollegeLessonDetailPageProps {
  params: Promise<{ skillId: string }>;
}

export default async function CollegeLessonDetailPage({
  params,
}: CollegeLessonDetailPageProps) {
  const { skillId } = await params;

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-3xl flex-1 px-6 py-16">
        <BackLink href="/college" label="Back to College" />
        <LessonDetail skillId={skillId} quizBasePath="/college/quiz" modelingBasePath="/college/modeling" />
      </main>
    </div>
  );
}
