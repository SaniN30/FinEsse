"use client";

import { useEffect, useState } from "react";
import { getSupabaseClient } from "@/lib/supabase/client";
import { Button } from "@/components/Button";
import { BackLink } from "@/components/BackLink";
import { QuizResult } from "@/components/quiz/QuizResult";
import type { QuizGradeResult, QuizQuestionPublic } from "@/lib/supabase/types";
import { cn } from "@/lib/cn";

type QuizRunnerTier = "college" | "job_ready";

interface QuizRunnerProps {
  quizId: string;
  tier?: QuizRunnerTier;
}

export function QuizRunner({ quizId, tier = "college" }: QuizRunnerProps) {
  const [questions, setQuestions] = useState<QuizQuestionPublic[] | null>(null);
  const [skillId, setSkillId] = useState<string | null>(null);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [result, setResult] = useState<QuizGradeResult | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    const supabase = getSupabaseClient();

    supabase
      .from("quiz_questions_public")
      .select("id, quiz_id, question, options, order_index")
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
      .select("skill_id")
      .eq("id", quizId)
      .maybeSingle()
      .then(({ data }) => {
        if (!isMounted) return;
        setSkillId(data?.skill_id ?? null);
      });

    return () => {
      isMounted = false;
    };
  }, [quizId]);

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

  const allAnswered = questions.every((question) => answers[question.id]);

  return (
    <div className="space-y-6">
      <BackLink href={backHref} label="Back to Lesson" />
      {questions.map((question, index) => (
        <div
          key={question.id}
          className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft"
        >
          <p className="mb-4 font-medium">
            {index + 1}. {question.question}
          </p>
          <div className="space-y-2">
            {question.options.map((option) => (
              <button
                key={option}
                type="button"
                onClick={() =>
                  setAnswers((prev) => ({ ...prev, [question.id]: option }))
                }
                className={cn(
                  "block w-full rounded-xl border px-4 py-2.5 text-left text-sm transition-colors",
                  answers[question.id] === option
                    ? "border-primary-500 bg-primary-500/10 text-primary-600"
                    : "border-surface-border hover:border-primary-300",
                )}
              >
                {option}
              </button>
            ))}
          </div>
        </div>
      ))}

      <Button disabled={!allAnswered || submitting} onClick={handleSubmit}>
        {submitting ? "Submitting…" : "Submit quiz"}
      </Button>
    </div>
  );
}
