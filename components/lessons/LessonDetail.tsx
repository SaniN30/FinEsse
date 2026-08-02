"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import { getSupabaseClient } from "@/lib/supabase/client";
import type { Lesson, ModelingExercisePublic, Quiz, Skill, Tier } from "@/lib/supabase/types";
import { lessonContentOverrides } from "@/lib/lessons/content-overrides";
import { LessonBlockList } from "@/components/lessons/blocks/LessonBlockRenderer";
import { LessonHeading } from "@/components/lessons/LessonHeading";
import { LessonBody } from "@/components/lessons/LessonBody";

const EASE_OUT_QUART = [0.25, 1, 0.5, 1] as const;

interface LessonDetailProps {
  skillId: string;
  tier: Tier;
  quizBasePath: string;
  modelingBasePath?: string;
}

export function LessonDetail({ skillId, tier, quizBasePath, modelingBasePath }: LessonDetailProps) {
  const [skill, setSkill] = useState<Skill | null>(null);
  const [lessons, setLessons] = useState<Lesson[] | null>(null);
  const [quizzes, setQuizzes] = useState<Quiz[] | null>(null);
  const [modelingExercises, setModelingExercises] = useState<ModelingExercisePublic[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    const supabase = getSupabaseClient();

    async function load() {
      const [skillResult, lessonResult, quizResult, modelingResult] = await Promise.all([
        supabase.from("skills").select("*").eq("id", skillId).single(),
        supabase
          .from("lessons")
          .select("*")
          .eq("skill_id", skillId)
          .order("order_index", { ascending: true }),
        supabase
          .from("quizzes")
          .select("*")
          .eq("skill_id", skillId),
        modelingBasePath
          ? supabase
              .from("modeling_exercises_public")
              .select("*")
              .eq("skill_id", skillId)
          : Promise.resolve({ data: [], error: null }),
      ]);

      if (skillResult.error || lessonResult.error || quizResult.error || modelingResult.error) {
        if (isMounted) {
          setError(
            skillResult.error?.message ??
              lessonResult.error?.message ??
              quizResult.error?.message ??
              modelingResult.error?.message ??
              "Failed to load lesson"
          );
        }
        return;
      }

      if (isMounted) {
        setSkill(skillResult.data as Skill);
        setLessons(lessonResult.data ?? []);
        setQuizzes(quizResult.data ?? []);
        setModelingExercises(modelingResult.data ?? []);
      }

      for (const lesson of lessonResult.data ?? []) {
        // Best-effort: powers the "first lesson completed" badge only, so a
        // failure here shouldn't interrupt the student reading the lesson.
        supabase.rpc("mark_lesson_complete", { p_lesson_id: lesson.id }).then(() => {});
      }
    }

    load();
    return () => {
      isMounted = false;
    };
  }, [skillId, modelingBasePath]);

  if (error) {
    return <p className="text-sm text-red-500">Couldn&apos;t load lesson: {error}</p>;
  }

  if (!lessons) {
    return <p className="text-sm text-muted-foreground">Loading lesson…</p>;
  }

  return (
    <div className="space-y-8">
      {skill ? <LessonHeading title={skill.title} /> : null}

      {lessons.map((lesson, index) => {
        const blocks = lessonContentOverrides[lesson.skill_id];

        return (
          <motion.article
            key={lesson.id}
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-60px" }}
            transition={{ duration: 0.5, ease: EASE_OUT_QUART, delay: index * 0.06 }}
            className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft"
          >
            {blocks ? (
              <LessonBlockList tier={tier} blocks={blocks} />
            ) : lesson.content_body ? (
              <LessonBody text={lesson.content_body} />
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
          </motion.article>
        );
      })}

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

      {modelingBasePath && modelingExercises && modelingExercises.length > 0 ? (
        <div className="flex flex-wrap gap-3">
          {modelingExercises.map((exercise) => (
            <Link
              key={exercise.id}
              href={`${modelingBasePath}/${exercise.id}`}
              className="rounded-full border border-primary-500 px-5 py-2.5 text-sm font-medium text-primary-600 hover:bg-primary-50"
            >
              Case exercise: {exercise.title}
            </Link>
          ))}
        </div>
      ) : null}
    </div>
  );
}
