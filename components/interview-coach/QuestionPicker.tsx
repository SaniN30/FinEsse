"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { useAuth } from "@/lib/supabase/auth-context";
import { fetchInterviewQuestions, fetchInterviewSessions } from "@/lib/interview-coach/queries";
import { rubricOverallScore } from "@/lib/interview-coach/rubric";
import { cn } from "@/lib/cn";
import type {
  InterviewQuestion,
  InterviewQuestionCategory,
  InterviewSession,
} from "@/lib/supabase/types";

const categoryLabel: Record<InterviewQuestionCategory, string> = {
  behavioral: "Behavioral",
  technical: "Technical",
};

export function QuestionPicker() {
  const { profile, loading: isAuthLoading } = useAuth();
  const [questions, setQuestions] = useState<InterviewQuestion[] | null>(null);
  const [sessions, setSessions] = useState<InterviewSession[] | null>(null);
  const [activeCategory, setActiveCategory] = useState<InterviewQuestionCategory | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!profile) return;

    let isMounted = true;

    Promise.all([fetchInterviewQuestions(), fetchInterviewSessions(profile.id)])
      .then(([questionsResult, sessionsResult]) => {
        if (!isMounted) return;
        setQuestions(questionsResult);
        setSessions(sessionsResult);
        setActiveCategory(questionsResult[0]?.category ?? null);
      })
      .catch((err: unknown) => {
        if (isMounted) setError(err instanceof Error ? err.message : "Could not load questions.");
      });

    return () => {
      isMounted = false;
    };
  }, [profile]);

  if (error) return <p className="text-sm text-red-600">{error}</p>;
  if (isAuthLoading || !questions || !sessions) {
    return <p className="text-sm text-neutral-500">Loading questions…</p>;
  }

  const categories = Array.from(new Set(questions.map((question) => question.category)));
  const visibleQuestions = questions.filter((question) => question.category === activeCategory);

  return (
    <div>
      <div className="mb-6 flex gap-6 border-b border-surface-border text-sm font-medium">
        {categories.map((category) => (
          <button
            key={category}
            type="button"
            onClick={() => setActiveCategory(category)}
            className={cn(
              "-mb-px border-b-2 pb-3 transition-colors",
              activeCategory === category
                ? "border-primary-500 text-foreground"
                : "border-transparent text-neutral-500 hover:text-foreground",
            )}
          >
            {categoryLabel[category]}
          </button>
        ))}
      </div>

      <div className="space-y-3">
        {visibleQuestions.map((question) => (
          <Link
            key={question.id}
            href={`/job-ready/interview/${question.id}`}
            className="block rounded-[var(--radius-card)] border border-surface-border bg-surface p-5 shadow-soft transition-colors hover:border-primary-400"
          >
            <p className="mb-1 text-xs font-semibold uppercase tracking-wide text-primary-500">
              {question.firm_style}
            </p>
            <p className="text-sm font-medium text-foreground">{question.question_text}</p>
          </Link>
        ))}
        {visibleQuestions.length === 0 ? (
          <p className="text-sm text-neutral-500">No questions in this category yet.</p>
        ) : null}
      </div>

      <div className="mt-12">
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-neutral-500">
          Recent attempts
        </h2>
        {sessions.length === 0 ? (
          <p className="text-sm text-neutral-500">No practice sessions yet.</p>
        ) : (
          <ul className="space-y-2">
            {sessions.slice(0, 5).map((session) => {
              const overall = rubricOverallScore(session.rubric_scores);
              return (
                <li
                  key={session.id}
                  className="flex items-center justify-between rounded-xl border border-surface-border bg-background/40 px-4 py-2.5 text-sm"
                >
                  <span className="text-neutral-600">{session.firm_style}</span>
                  <span className="font-medium text-foreground">
                    {overall !== null ? `${overall}/10` : "Scoring…"}
                  </span>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </div>
  );
}
