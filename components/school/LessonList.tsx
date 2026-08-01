"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { fetchLessonsForSkill } from "@/lib/school/queries";
import { Skeleton } from "@/components/Skeleton";
import type { Lesson } from "@/lib/supabase/types";

const contentTypeLabel: Record<Lesson["content_type"], string> = {
  article: "Article",
  video: "Video",
  interactive: "Interactive",
};

export function LessonList({ skillId }: { skillId: string }) {
  const [lessons, setLessons] = useState<Lesson[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    fetchLessonsForSkill(skillId)
      .then((result) => {
        if (isMounted) setLessons(result);
      })
      .catch((err: unknown) => {
        if (isMounted) setError(err instanceof Error ? err.message : "Could not load lessons.");
      });

    return () => {
      isMounted = false;
    };
  }, [skillId]);

  if (error) return <p className="text-sm text-red-600">{error}</p>;
  if (!lessons) {
    return (
      <div className="space-y-3">
        <Skeleton className="h-16 w-full" />
        <Skeleton className="h-16 w-full" />
        <Skeleton className="h-16 w-full" />
      </div>
    );
  }
  if (lessons.length === 0) {
    return <p className="text-sm text-muted-foreground">No lessons published for this skill yet.</p>;
  }

  return (
    <ul className="space-y-3">
      {lessons.map((lesson, index) => (
        <li key={lesson.id}>
          <Link
            href={`/school/lessons/${lesson.id}`}
            className="flex items-center justify-between rounded-[var(--radius-card)] border border-surface-border bg-surface p-5 shadow-soft transition-shadow hover:shadow-lg"
          >
            <span className="font-medium">
              {index + 1}. {contentTypeLabel[lesson.content_type]}
            </span>
            <span className="text-sm text-secondary-500">Open →</span>
          </Link>
        </li>
      ))}
    </ul>
  );
}
