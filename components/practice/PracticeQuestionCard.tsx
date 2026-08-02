"use client";

import { useState } from "react";
import { gradePracticeAttempt } from "@/lib/practice/queries";
import type { PracticeQuestion } from "@/lib/supabase/types";
import { Button } from "@/components/Button";
import { cn } from "@/lib/cn";

function getErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Something went wrong.";
}

export function PracticeQuestionCard({ question }: { question: PracticeQuestion }) {
  const [answer, setAnswer] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [isCorrect, setIsCorrect] = useState<boolean | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit() {
    setSubmitting(true);
    setError(null);
    try {
      const result = await gradePracticeAttempt(question.id, answer);
      setIsCorrect(result.is_correct);
    } catch (err: unknown) {
      setError(getErrorMessage(err));
    } finally {
      setSubmitting(false);
    }
  }

  function handleRetry() {
    setIsCorrect(null);
    setAnswer("");
    setError(null);
  }

  return (
    <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft">
      <div className="mb-3 flex flex-wrap items-center gap-2">
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
        <span className="rounded-full bg-primary-500/10 px-2.5 py-0.5 text-xs font-medium capitalize text-primary-600">
          {question.tier.replace("_", "-")}
        </span>
        {question.is_case_study ? (
          <span className="rounded-full bg-purple-500/10 px-2.5 py-0.5 text-xs font-medium text-purple-600">
            Case study
          </span>
        ) : null}
        {question.topic_title ? (
          <span className="text-xs text-muted-foreground">{question.topic_title}</span>
        ) : null}
      </div>

      {question.scenario_context ? (
        <p className="mb-3 rounded-lg bg-primary-500/5 px-3 py-2 text-xs text-muted-foreground">
          {question.scenario_context}
        </p>
      ) : null}

      <p className="mb-4 font-medium">{question.question}</p>

      {isCorrect !== null ? (
        <div
          className={cn(
            "mb-4 rounded-lg px-3 py-2 text-sm font-medium",
            isCorrect ? "bg-green-500/10 text-green-600" : "bg-red-500/10 text-red-600",
          )}
        >
          {isCorrect ? "Correct!" : "Not quite -- give it another look."}
        </div>
      ) : null}

      {isCorrect === null ? (
        question.question_type === "free_response" ? (
          <textarea
            value={answer}
            onChange={(event) => setAnswer(event.target.value)}
            placeholder="Type your answer…"
            rows={3}
            className="w-full rounded-xl border border-surface-border bg-transparent px-4 py-2.5 text-sm focus:border-purple-400 focus:outline-none"
          />
        ) : (
          <div className="space-y-2">
            {question.options?.map((option) => (
              <button
                key={option}
                type="button"
                onClick={() => setAnswer(option)}
                className={cn(
                  "block w-full rounded-xl border px-4 py-2.5 text-left text-sm transition-colors",
                  answer === option
                    ? "border-purple-500 bg-purple-500/10 text-purple-600"
                    : "border-surface-border hover:border-purple-300",
                )}
              >
                {option}
              </button>
            ))}
          </div>
        )
      ) : null}

      {error ? <p className="mt-3 text-sm text-red-500">{error}</p> : null}

      <div className="mt-4">
        {isCorrect === null ? (
          <Button size="md" disabled={!answer.trim() || submitting} onClick={handleSubmit}>
            {submitting ? "Checking…" : "Check answer"}
          </Button>
        ) : (
          <Button size="md" variant="secondary" onClick={handleRetry}>
            Try another attempt
          </Button>
        )}
      </div>
    </div>
  );
}
