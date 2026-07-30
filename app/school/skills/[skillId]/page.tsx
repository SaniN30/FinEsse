import { Nav } from "@/components/Nav";
import { LessonList } from "@/components/school/LessonList";

export default async function SkillLessonsPage({
  params,
}: {
  params: Promise<{ skillId: string }>;
}) {
  const { skillId } = await params;

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-3xl flex-1 px-6 py-16">
        <h1 className="mb-8 text-3xl font-semibold tracking-tight">Lessons</h1>
        <LessonList skillId={skillId} />
      </main>
    </div>
  );
}
