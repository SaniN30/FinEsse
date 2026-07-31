import { Nav } from "@/components/Nav";
import { QuestionPicker } from "@/components/interview-coach/QuestionPicker";

export default function InterviewCoachPage() {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-3xl flex-1 px-6 py-16">
        <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-tier-jobready">
          Job-Ready
        </p>
        <h1 className="mb-8 text-4xl font-semibold tracking-tight">AI Interview Coach</h1>
        <QuestionPicker />
      </main>
    </div>
  );
}
