import { Nav } from "@/components/Nav";
import { LessonDetail } from "@/components/school/LessonDetail";

export default async function LessonPage({
  params,
}: {
  params: Promise<{ lessonId: string }>;
}) {
  const { lessonId } = await params;

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-3xl flex-1 px-6 py-16">
        <LessonDetail lessonId={lessonId} />
      </main>
    </div>
  );
}
