"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import {
  fetchLesson,
  fetchLessonsForSkill,
  fetchQuizzesForLesson,
  fetchSkill,
} from "@/lib/school/queries";
import { BackLink } from "@/components/BackLink";
import { Skeleton } from "@/components/Skeleton";
import { getSupabaseClient } from "@/lib/supabase/client";
import type { Lesson, Quiz, Skill } from "@/lib/supabase/types";
import { lessonContentOverrides } from "@/lib/lessons/content-overrides";
import { LessonBlockList } from "@/components/lessons/blocks/LessonBlockRenderer";
import { LessonHeading } from "@/components/lessons/LessonHeading";
import { LessonBody } from "@/components/lessons/LessonBody";

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

  const blocks = lessonContentOverrides[`${lesson.skill_id}:${lesson.order_index}`];
  if (blocks) {
    return <LessonBlockList tier="school" blocks={blocks} />;
  }

  if (!lesson.content_body) {
    return <p className="text-sm text-muted-foreground">This lesson has no content yet.</p>;
  }

  return <LessonBody text={lesson.content_body} />;
}

export function LessonDetail({ lessonId }: { lessonId: string }) {
  const [lesson, setLesson] = useState<Lesson | null>(null);
  const [skill, setSkill] = useState<Skill | null>(null);
  const [siblingLessons, setSiblingLessons] = useState<Lesson[] | null>(null);
  const [quizzes, setQuizzes] = useState<Quiz[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    fetchLesson(lessonId)
      .then((lessonResult) =>
        Promise.all([
          Promise.resolve(lessonResult),
          fetchQuizzesForLesson(lessonId),
          fetchSkill(lessonResult.skill_id),
          fetchLessonsForSkill(lessonResult.skill_id),
        ]),
      )
      .then(([lessonResult, quizzesResult, skillResult, siblingsResult]) => {
        if (!isMounted) return;
        setLesson(lessonResult);
        setQuizzes(quizzesResult);
        setSkill(skillResult);
        setSiblingLessons(siblingsResult);

        // Best-effort: powers the "first lesson completed" badge only, so a
        // failure here shouldn't interrupt the student reading the lesson.
        getSupabaseClient()
          .rpc("mark_lesson_complete", { p_lesson_id: lessonId })
          .then(() => {});
      })
      .catch((err: unknown) => {
        if (isMounted) setError(err instanceof Error ? err.message : "Could not load lesson.");
      });

    return () => {
      isMounted = false;
    };
  }, [lessonId]);

  if (error) {
    return (
      <div>
        <BackLink href="/school" label="Back to School" />
        <p className="text-sm text-red-600">{error}</p>
      </div>
    );
  }
  if (!lesson) {
    return (
      <div>
        <Skeleton className="mb-4 h-6 w-1/3" />
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  const ordered = siblingLessons ?? [];
  const currentIndex = ordered.findIndex((sibling) => sibling.id === lesson.id);
  const previousLesson = currentIndex > 0 ? ordered[currentIndex - 1] : null;
  const nextLesson =
    currentIndex >= 0 && currentIndex < ordered.length - 1 ? ordered[currentIndex + 1] : null;

  return (
    <div>
      <BackLink href={`/school/skills/${lesson.skill_id}`} label="Back to Lessons" />
      {skill ? <LessonHeading title={skill.title} /> : null}
      {ordered.length > 1 ? (
        <p className="mb-4 text-sm text-muted-foreground">
          Lesson {currentIndex + 1} of {ordered.length}
        </p>
      ) : null}
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

      {previousLesson || nextLesson ? (
        <div className="mt-8 flex items-center justify-between border-t border-surface-border pt-6">
          {previousLesson ? (
            <Link
              href={`/school/lessons/${previousLesson.id}`}
              className="text-sm font-medium text-primary-500 hover:text-primary-600"
            >
              ← Previous lesson
            </Link>
          ) : (
            <span />
          )}
          {nextLesson ? (
            <Link
              href={`/school/lessons/${nextLesson.id}`}
              className="text-sm font-medium text-primary-500 hover:text-primary-600"
            >
              Next lesson →
            </Link>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}
