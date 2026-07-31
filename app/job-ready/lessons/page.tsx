import { Nav } from "@/components/Nav";
import { LessonList } from "@/components/lessons/LessonList";

export default function JobReadyLessonsPage() {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-4xl flex-1 px-6 py-16">
        <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-tier-jobready">
          Job-Ready
        </p>
        <h1 className="mb-8 text-3xl font-semibold tracking-tight">Lessons</h1>
        <LessonList
          tier="job_ready"
          basePath="/job-ready/lessons"
          accentClassName="bg-tier-jobready"
        />
      </main>
    </div>
  );
}
