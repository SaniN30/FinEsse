"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { getSupabaseClient } from "@/lib/supabase/client";
import type { Lesson, Quiz } from "@/lib/supabase/types";

interface LessonDetailProps {
  skillId: string;
  quizBasePath: string;
}

export function LessonDetail({ skillId, quizBasePath }: LessonDetailProps) {
  const [lessons, setLessons] = useState<Lesson[] | null>(null);
  const [quizzes, setQuizzes] = useState<Quiz[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    const supabase = getSupabaseClient();

    async function load() {
      const [lessonResult, quizResult] = await Promise.all([
        supabase
          .from("lessons")
          .select("*")
          .eq("skill_id", skillId)
          .order("order_index", { ascending: true }),
        supabase
          .from("quizzes")
          .select("*")
          .eq("skill_id", skillId),
      ]);

      if (lessonResult.error || quizResult.error) {
        if (isMounted) {
          setError(lessonResult.error?.message ?? quizResult.error?.message ?? "Failed to load lesson");
        }
        return;
      }

      if (isMounted) {
        setLessons(lessonResult.data ?? []);
        setQuizzes(quizResult.data ?? []);
      }
    }

    load();
    return () => {
      isMounted = false;
    };
  }, [skillId]);

  if (error) {
    return <p className="text-sm text-red-500">Couldn&apos;t load lesson: {error}</p>;
  }

  if (!lessons) {
    return <p className="text-sm text-neutral-500">Loading lesson…</p>;
  }

  return (
    <div className="space-y-8">
      {lessons.map((lesson) => (
        <article
          key={lesson.id}
          className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft"
        >
          {lesson.content_body ? (
            <p className="text-sm leading-relaxed text-neutral-600">{lesson.content_body}</p>
          ) : null}
          {lesson.content_url ? (
            <a
              href={lesson.content_url}
              target="_blank"
              rel="noreferrer"
              className="mt-2 inline-block text-sm font-medium text-primary-500 hover:text-primary-600"
            >
              Open {lesson.content_type} →
            </a>
          ) : null}
        </article>
      ))}

      {quizzes && quizzes.length > 0 ? (
        <div className="flex flex-wrap gap-3">
          {quizzes.map((quiz) => (
            <Link
              key={quiz.id}
              href={`${quizBasePath}/${quiz.id}`}
              className="rounded-full bg-primary-500 px-5 py-2.5 text-sm font-medium text-white shadow-soft hover:bg-primary-600"
            >
              Take quiz: {quiz.title}
            </Link>
          ))}
        </div>
      ) : null}
    </div>
  );
}
