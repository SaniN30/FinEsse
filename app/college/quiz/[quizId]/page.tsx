import { Nav } from "@/components/Nav";
import { QuizRunner } from "@/components/quiz/QuizRunner";

interface CollegeQuizPageProps {
  params: Promise<{ quizId: string }>;
}

export default async function CollegeQuizPage({ params }: CollegeQuizPageProps) {
  const { quizId } = await params;

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-2xl flex-1 px-6 py-16">
        <QuizRunner quizId={quizId} />
      </main>
    </div>
  );
}
