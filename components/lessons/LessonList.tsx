"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import { getSupabaseClient } from "@/lib/supabase/client";
import type { Lesson, Skill } from "@/lib/supabase/types";
import { cn } from "@/lib/cn";

interface LessonListProps {
  tier: Skill["tier"];
  basePath: string;
  accentClassName?: string;
}

interface SkillWithLessons extends Skill {
  lessons: Lesson[];
}

export function LessonList({
  tier,
  basePath,
  accentClassName = "bg-tier-college",
}: LessonListProps) {
  const [skills, setSkills] = useState<SkillWithLessons[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    const supabase = getSupabaseClient();

    async function load() {
      const { data: skillRows, error: skillError } = await supabase
        .from("skills")
        .select("id, tier, slug, title, prerequisite_skill_id, mastery_threshold")
        .eq("tier", tier);

      if (skillError || !skillRows) {
        if (isMounted) setError(skillError?.message ?? "Failed to load skills");
        return;
      }

      const { data: lessonRows, error: lessonError } = await supabase
        .from("lessons")
        .select("*")
        .in(
          "skill_id",
          skillRows.map((skill) => skill.id),
        )
        .order("order_index", { ascending: true });

      if (lessonError) {
        if (isMounted) setError(lessonError.message);
        return;
      }

      const combined: SkillWithLessons[] = skillRows.map((skill) => ({
        ...skill,
        lessons: (lessonRows ?? []).filter((lesson) => lesson.skill_id === skill.id),
      }));

      if (isMounted) setSkills(combined);
    }

    load();
    return () => {
      isMounted = false;
    };
  }, [tier]);

  if (error) {
    return <p className="text-sm text-red-500">Couldn&apos;t load lessons: {error}</p>;
  }

  if (!skills) {
    return <p className="text-sm text-muted-foreground">Loading lessons…</p>;
  }

  return (
    <div className="grid gap-4 sm:grid-cols-2">
      {skills.map((skill, index) => (
        <motion.div
          key={skill.id}
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-80px" }}
          transition={{
            duration: 0.6,
            ease: [0.25, 1, 0.5, 1] as const,
            delay: index * 0.08,
          }}
          className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft"
        >
          <div className={cn("mb-3 h-1.5 w-10 rounded-full", accentClassName)} />
          <h3 className="mb-1 text-lg font-semibold">{skill.title}</h3>
          <p className="mb-4 text-sm text-muted-foreground">
            {skill.lessons.length} lesson{skill.lessons.length === 1 ? "" : "s"}
          </p>
          <Link
            href={`${basePath}/${skill.id}`}
            className="text-sm font-medium text-primary-500 hover:text-primary-600"
          >
            Start learning →
          </Link>
        </motion.div>
      ))}
    </div>
  );
}
