"use client";

import { useEffect, useState } from "react";
import { fetchInterviewQuestion, submitAndScoreInterviewSession } from "@/lib/interview-coach/queries";
import { TranscriptEntry } from "@/components/interview-coach/TranscriptEntry";
import { ScoreReveal } from "@/components/interview-coach/ScoreReveal";
import type { InterviewQuestion, InterviewRubricScores } from "@/lib/supabase/types";

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message;
  return "Something went wrong scoring your answer.";
}

interface InterviewSessionProps {
  questionId: string;
}

export function InterviewSession({ questionId }: InterviewSessionProps) {
  const [question, setQuestion] = useState<InterviewQuestion | null>(null);
  const [rubricScores, setRubricScores] = useState<InterviewRubricScores | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [submitError, setSubmitError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    fetchInterviewQuestion(questionId)
      .then((result) => {
        if (isMounted) setQuestion(result);
      })
      .catch((err: unknown) => {
        if (isMounted) setLoadError(getErrorMessage(err));
      });

    return () => {
      isMounted = false;
    };
  }, [questionId]);

  async function handleSubmit(transcript: string) {
    setSubmitting(true);
    setSubmitError(null);

    try {
      const result = await submitAndScoreInterviewSession(questionId, transcript);
      setRubricScores(result.rubric_scores);
    } catch (err) {
      setSubmitError(getErrorMessage(err));
    } finally {
      setSubmitting(false);
    }
  }

  if (loadError) return <p className="text-sm text-red-500">{loadError}</p>;
  if (!question) return <p className="text-sm text-neutral-500">Loading question…</p>;

  if (rubricScores) {
    return (
      <ScoreReveal
        rubricScores={rubricScores}
        onPracticeAgain={() => {
          setRubricScores(null);
          setSubmitError(null);
        }}
      />
    );
  }

  return (
    <TranscriptEntry
      question={question}
      onSubmit={handleSubmit}
      submitting={submitting}
      error={submitError}
    />
  );
}
