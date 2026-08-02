"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { fetchInterviewPracticeQuestions } from "@/lib/practice/queries";
import type { PracticeQuestion, QuestionDifficulty } from "@/lib/supabase/types";
import { Skeleton } from "@/components/Skeleton";
import { cn } from "@/lib/cn";

function getErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Something went wrong.";
}

/**
 * The parent keys this component by `difficulty`, so a filter change
 * remounts a fresh instance instead of resetting state from an effect.
 */
export function InterviewPracticeList({ difficulty }: { difficulty?: QuestionDifficulty }) {
  const [questions, setQuestions] = useState<PracticeQuestion[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    fetchInterviewPracticeQuestions({ difficulty })
      .then((data) => {
        if (isMounted) setQuestions(data);
      })
      .catch((err: unknown) => {
        if (isMounted) setError(getErrorMessage(err));
      });
    return () => {
      isMounted = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (error) {
    return <p className="text-sm text-red-500">Couldn&apos;t load interview questions: {error}</p>;
  }

  if (!questions) {
    return <Skeleton className="h-24 w-full" />;
  }

  if (questions.length === 0) {
    return <p className="text-sm text-muted-foreground">No interview questions match this filter.</p>;
  }

  return (
    <div className="space-y-3">
      {questions.map((question) => (
        <Link
          key={question.id}
          href={`/job-ready/interview/${question.id}`}
          className="block rounded-[var(--radius-card)] border border-surface-border bg-surface p-5 shadow-soft transition-colors hover:border-purple-300"
        >
          <div className="mb-2 flex flex-wrap items-center gap-2">
            <span
              className={cn(
                "rounded-full px-2.5 py-0.5 text-xs font-medium capitalize",
                question.difficulty === "easy" && "bg-green-500/10 text-green-600",
                question.difficulty === "medium" && "bg-amber-500/10 text-amber-600",
                question.difficulty === "hard" && "bg-red-500/10 text-red-600",
              )}
            >
              {question.difficulty}
            </span>
            <span className="text-xs text-muted-foreground">{question.topic_title}</span>
          </div>
          <p className="text-sm font-medium">{question.question}</p>
        </Link>
      ))}
    </div>
  );
}
