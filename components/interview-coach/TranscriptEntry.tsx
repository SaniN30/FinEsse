"use client";

import { useState } from "react";
import { Button } from "@/components/Button";
import type { InterviewQuestion } from "@/lib/supabase/types";

interface TranscriptEntryProps {
  question: InterviewQuestion;
  onSubmit: (transcript: string) => void;
  submitting: boolean;
  error: string | null;
}

/** The record/transcript input is the only thing on screen while answering -- no scores or other content until submitted. */
export function TranscriptEntry({ question, onSubmit, submitting, error }: TranscriptEntryProps) {
  const [transcript, setTranscript] = useState("");

  return (
    <div className="space-y-6">
      <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft">
        <p className="mb-1 text-xs font-semibold uppercase tracking-wide text-primary-500">
          {question.firm_style}
        </p>
        <p className="text-lg font-medium text-foreground">{question.question_text}</p>
      </div>

      <textarea
        value={transcript}
        onChange={(event) => setTranscript(event.target.value)}
        placeholder="Type or paste your answer transcript here…"
        rows={10}
        className="w-full rounded-[var(--radius-card)] border border-surface-border bg-surface p-4 text-sm text-foreground shadow-soft focus:border-primary-400 focus:outline-none"
      />

      {error ? <p className="text-sm text-red-500">{error}</p> : null}

      <Button
        disabled={transcript.trim().length === 0 || submitting}
        onClick={() => onSubmit(transcript)}
      >
        {submitting ? "Scoring…" : "Submit for scoring"}
      </Button>
    </div>
  );
}
