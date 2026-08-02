"use client";

import { useEffect, useMemo, useState } from "react";
import { fetchPracticeQuestions, type PracticeFilters as PracticeFiltersValue } from "@/lib/practice/queries";
import type { PracticeQuestion } from "@/lib/supabase/types";
import { PracticeQuestionCard } from "@/components/practice/PracticeQuestionCard";
import { Skeleton } from "@/components/Skeleton";

function getErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Something went wrong.";
}

/**
 * The parent keys this component by its filter values, so a filter change
 * remounts a fresh instance (fresh loading state) instead of resetting
 * state from inside an effect.
 */
export function PracticeList({ filters }: { filters: PracticeFiltersValue }) {
  const [questions, setQuestions] = useState<PracticeQuestion[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [topic, setTopic] = useState<string>("");

  useEffect(() => {
    let isMounted = true;

    fetchPracticeQuestions(filters)
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

  const topics = useMemo(() => {
    if (!questions) return [];
    const seen = new Map<string, string>();
    for (const question of questions) {
      if (question.topic_slug && question.topic_title && !seen.has(question.topic_slug)) {
        seen.set(question.topic_slug, question.topic_title);
      }
    }
    return Array.from(seen.entries());
  }, [questions]);

  const visibleQuestions = useMemo(() => {
    if (!questions) return [];
    return topic ? questions.filter((question) => question.topic_slug === topic) : questions;
  }, [questions, topic]);

  if (error) {
    return <p className="text-sm text-red-500">Couldn&apos;t load practice questions: {error}</p>;
  }

  if (!questions) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-32 w-full" />
        <Skeleton className="h-32 w-full" />
      </div>
    );
  }

  if (questions.length === 0) {
    return <p className="text-sm text-muted-foreground">No practice questions match these filters yet.</p>;
  }

  return (
    <div className="space-y-6">
      {topics.length > 1 ? (
        <select
          aria-label="Filter by topic"
          className="rounded-full border border-surface-border bg-surface px-4 py-2 text-sm text-foreground focus:border-purple-400 focus:outline-none"
          value={topic}
          onChange={(event) => setTopic(event.target.value)}
        >
          <option value="">All topics</option>
          {topics.map(([slug, title]) => (
            <option key={slug} value={slug}>
              {title}
            </option>
          ))}
        </select>
      ) : null}

      {visibleQuestions.map((question) => (
        <PracticeQuestionCard key={question.id} question={question} />
      ))}
    </div>
  );
}
