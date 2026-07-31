"use client";

import { useEffect, useMemo, useState } from "react";
import { useAuth } from "@/lib/supabase/auth-context";
import {
  fetchQuiz,
  fetchQuizQuestions,
  fetchSkillsWithMastery,
  submitQuizAttempt,
  type QuizAnswer,
} from "@/lib/school/queries";
import type { GradeQuizAttemptResult, Quiz, QuizQuestionPublic } from "@/lib/supabase/types";
import { ProgressBar } from "@/components/ProgressBar";
import { Button } from "@/components/Button";
import { BackLink } from "@/components/BackLink";
import { Skeleton } from "@/components/Skeleton";

function getErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Something went wrong.";
}

export function QuizRunner({ quizId }: { quizId: string }) {
  const { profile } = useAuth();
  const [quiz, setQuiz] = useState<Quiz | null>(null);
  const [questions, setQuestions] = useState<QuizQuestionPublic[] | null>(null);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [result, setResult] = useState<GradeQuizAttemptResult | null>(null);
  const [skillUnlockedNow, setSkillUnlockedNow] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    let isMounted = true;
    Promise.all([fetchQuiz(quizId), fetchQuizQuestions(quizId)])
      .then(([quizResult, questionsResult]) => {
        if (!isMounted) return;
        setQuiz(quizResult);
        setQuestions(questionsResult);
      })
      .catch((err: unknown) => {
        if (isMounted) setError(getErrorMessage(err));
      });

    return () => {
      isMounted = false;
    };
  }, [quizId]);

  const allAnswered = useMemo(
    () => (questions ?? []).every((question) => answers[question.id]),
    [questions, answers],
  );

  async function handleSubmit() {
    if (!questions || !profile) return;

    setIsSubmitting(true);
    setError(null);

    try {
      const payload: QuizAnswer[] = questions.map((question) => ({
        question_id: question.id,
        answer: answers[question.id],
      }));

      const gradeResult = await submitQuizAttempt(quizId, payload);
      setResult(gradeResult);

      if (gradeResult.passed && quiz?.skill_id) {
        const skills = await fetchSkillsWithMastery(profile.id, "school");
        const unlockedDependent = skills.some(
          (skill) => skill.prerequisite_skill_id === quiz.skill_id && skill.isUnlocked,
        );
        setSkillUnlockedNow(unlockedDependent);
      }
    } catch (err: unknown) {
      setError(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  }

  if (error) {
    return (
      <div>
        <BackLink href="/school" label="Back to School" />
        <p className="text-sm text-red-600">{error}</p>
      </div>
    );
  }
  if (!quiz || !questions) {
    return (
      <div>
        <BackLink href="/school" label="Back to School" />
        <Skeleton className="mb-6 h-8 w-1/2" />
        <Skeleton className="h-24 w-full" />
      </div>
    );
  }

  const backHref = quiz.skill_id ? `/school/skills/${quiz.skill_id}` : "/school";

  if (result) {
    const scorePercent = Math.round(result.score * 100);
    return (
      <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-8 text-center shadow-soft">
        <BackLink href={backHref} label="Back to Lesson" className="mb-4 justify-center" />
        <p
          className={`mb-2 text-sm font-semibold uppercase tracking-wide ${
            result.passed ? "text-accent-600" : "text-muted-foreground"
          }`}
        >
          {result.passed ? "Passed 🎉" : "Not quite — try again"}
        </p>
        <h2 className="mb-6 text-3xl font-semibold">
          {result.correct} / {result.total} correct
        </h2>
        <ProgressBar value={scorePercent} colorClassName="bg-accent-500" label="Score" />
        {result.passed ? (
          <p className="mt-6 text-sm text-muted-foreground">
            +10 XP earned.
            {skillUnlockedNow ? " A new skill just unlocked!" : ""}
          </p>
        ) : (
          <p className="mt-6 text-sm text-muted-foreground">
            You need {Math.round(quiz.pass_threshold * 100)}% to pass. Review the lesson and try
            again.
          </p>
        )}
      </div>
    );
  }

  return (
    <div>
      <BackLink href={backHref} label="Back to Lesson" />
      <h1 className="mb-6 text-2xl font-semibold">{quiz.title}</h1>
      <div className="space-y-6">
        {questions.map((question, index) => (
          <fieldset
            key={question.id}
            className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-5 shadow-soft"
          >
            <legend className="mb-3 font-medium">
              {index + 1}. {question.question}
            </legend>
            <div className="space-y-2">
              {question.options.map((option) => (
                <label key={option} className="flex items-center gap-2 text-sm">
                  <input
                    type="radio"
                    name={question.id}
                    value={option}
                    checked={answers[question.id] === option}
                    onChange={() =>
                      setAnswers((current) => ({ ...current, [question.id]: option }))
                    }
                  />
                  {option}
                </label>
              ))}
            </div>
          </fieldset>
        ))}
      </div>

      <Button
        className="mt-6"
        disabled={!allAnswered || isSubmitting}
        onClick={handleSubmit}
      >
        {isSubmitting ? "Submitting…" : "Submit answers"}
      </Button>
    </div>
  );
}
