"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { fetchLesson, fetchQuizzesForLesson } from "@/lib/school/queries";
import type { Lesson, Quiz } from "@/lib/supabase/types";

function LessonContent({ lesson }: { lesson: Lesson }) {
  if (lesson.content_type === "video" && lesson.content_url) {
    return (
      <video controls className="w-full rounded-[var(--radius-card)]" src={lesson.content_url} />
    );
  }

  if (lesson.content_type === "interactive" && lesson.content_url) {
    return (
      <iframe
        src={lesson.content_url}
        className="h-[480px] w-full rounded-[var(--radius-card)] border border-surface-border"
        title="Interactive lesson"
      />
    );
  }

  return (
    <div className="prose prose-neutral max-w-none whitespace-pre-wrap text-neutral-700">
      {lesson.content_body ?? "This lesson has no content yet."}
    </div>
  );
}

export function LessonDetail({ lessonId }: { lessonId: string }) {
  const [lesson, setLesson] = useState<Lesson | null>(null);
  const [quizzes, setQuizzes] = useState<Quiz[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    Promise.all([fetchLesson(lessonId), fetchQuizzesForLesson(lessonId)])
      .then(([lessonResult, quizzesResult]) => {
        if (!isMounted) return;
        setLesson(lessonResult);
        setQuizzes(quizzesResult);
      })
      .catch((err: unknown) => {
        if (isMounted) setError(err instanceof Error ? err.message : "Could not load lesson.");
      });

    return () => {
      isMounted = false;
    };
  }, [lessonId]);

  if (error) return <p className="text-sm text-red-600">{error}</p>;
  if (!lesson) return <p className="text-sm text-neutral-500">Loading lesson…</p>;

  return (
    <div>
      <LessonContent lesson={lesson} />

      {quizzes && quizzes.length > 0 ? (
        <div className="mt-8 flex flex-col gap-3 sm:flex-row">
          {quizzes.map((quiz) => (
            <Link
              key={quiz.id}
              href={`/school/quizzes/${quiz.id}`}
              className="inline-flex items-center justify-center rounded-full bg-primary-500 px-6 py-3 text-sm font-medium text-white shadow-soft hover:bg-primary-600"
            >
              Take quiz: {quiz.title}
            </Link>
          ))}
        </div>
      ) : null}
    </div>
  );
}
