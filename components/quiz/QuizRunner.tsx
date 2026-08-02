"use client";

import { useEffect, useState } from "react";
import { getSupabaseClient } from "@/lib/supabase/client";
import { Button } from "@/components/Button";
import { BackLink } from "@/components/BackLink";
import { QuizResult } from "@/components/quiz/QuizResult";
import type { Quiz, QuizGradeResult, QuizQuestionPublic } from "@/lib/supabase/types";
import { cn } from "@/lib/cn";

type QuizRunnerTier = "college" | "job_ready";

interface QuizRunnerProps {
  quizId: string;
  tier?: QuizRunnerTier;
}

export function QuizRunner({ quizId, tier = "college" }: QuizRunnerProps) {
  const [questions, setQuestions] = useState<QuizQuestionPublic[] | null>(null);
  const [quiz, setQuiz] = useState<Pick<Quiz, "skill_id" | "quiz_type" | "scenario_body" | "context_tag"> | null>(
    null,
  );
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [result, setResult] = useState<QuizGradeResult | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    const supabase = getSupabaseClient();

    supabase
      .from("quiz_questions_public")
      .select("id, quiz_id, question, options, order_index, difficulty, question_type, scenario_context")
      .eq("quiz_id", quizId)
      .order("order_index", { ascending: true })
      .then(({ data, error: fetchError }) => {
        if (!isMounted) return;
        if (fetchError) {
          setError(fetchError.message);
          return;
        }
        setQuestions(data ?? []);
      });

    supabase
      .from("quizzes")
      .select("skill_id, quiz_type, scenario_body, context_tag")
      .eq("id", quizId)
      .maybeSingle()
      .then(({ data }) => {
        if (!isMounted) return;
        setQuiz(data ?? null);
      });

    return () => {
      isMounted = false;
    };
  }, [quizId]);

  const skillId = quiz?.skill_id ?? null;

  const tierRoot = tier === "job_ready" ? "/job-ready" : "/college";
  const backHref = skillId ? `${tierRoot}/lessons/${skillId}` : tierRoot;

  async function handleSubmit() {
    if (!questions) return;
    setSubmitting(true);
    setError(null);

    const supabase = getSupabaseClient();
    const payload = questions.map((question) => ({
      question_id: question.id,
      answer: answers[question.id] ?? "",
    }));

    const { data, error: rpcError } = await supabase.rpc("grade_quiz_attempt", {
      p_quiz_id: quizId,
      p_answers: payload,
    });

    setSubmitting(false);

    if (rpcError) {
      setError(rpcError.message);
      return;
    }

    setResult({ score: data.score, passed: data.passed });
  }

  if (error) {
    return (
      <div>
        <BackLink href={backHref} label="Back to Lesson" />
        <p className="text-sm text-red-500">Couldn&apos;t load quiz: {error}</p>
      </div>
    );
  }

  if (result) {
    return (
      <div>
        <BackLink href={backHref} label="Back to Lesson" />
        <QuizResult
          result={result}
          onRetry={() => {
            setResult(null);
            setAnswers({});
          }}
        />
      </div>
    );
  }

  if (!questions) {
    return (
      <div>
        <BackLink href={backHref} label="Back to Lesson" />
        <p className="text-sm text-muted-foreground">Loading quiz…</p>
      </div>
    );
  }

  const allAnswered = questions.every((question) => answers[question.id]?.trim());

  return (
    <div className="space-y-6">
      <BackLink href={backHref} label="Back to Lesson" />

      {quiz?.quiz_type === "case_study" && quiz.scenario_body ? (
        <div className="rounded-[var(--radius-card)] border border-primary-300 bg-primary-500/5 p-6 shadow-soft">
          {quiz.context_tag ? (
            <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-primary-500">
              {quiz.context_tag}
            </p>
          ) : null}
          <p className="text-sm leading-relaxed text-foreground">{quiz.scenario_body}</p>
        </div>
      ) : null}

      {questions.map((question, index) => (
        <div
          key={question.id}
          className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft"
        >
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
          </div>
          {question.scenario_context ? (
            <p className="mb-3 rounded-lg bg-primary-500/5 px-3 py-2 text-xs text-muted-foreground">
              {question.scenario_context}
            </p>
          ) : null}
          <p className="mb-4 font-medium">
            {index + 1}. {question.question}
          </p>
          {question.question_type === "free_response" ? (
            <textarea
              value={answers[question.id] ?? ""}
              onChange={(event) =>
                setAnswers((prev) => ({ ...prev, [question.id]: event.target.value }))
              }
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
                  onClick={() =>
                    setAnswers((prev) => ({ ...prev, [question.id]: option }))
                  }
                  className={cn(
                    "block w-full rounded-xl border px-4 py-2.5 text-left text-sm transition-colors",
                    answers[question.id] === option
                      ? "border-purple-500 bg-purple-500/10 text-purple-600"
                      : "border-surface-border hover:border-purple-300",
                  )}
                >
                  {option}
                </button>
              ))}
            </div>
          )}
        </div>
      ))}

      <Button disabled={!allAnswered || submitting} onClick={handleSubmit}>
        {submitting ? "Submitting…" : "Submit quiz"}
      </Button>
    </div>
  );
}
