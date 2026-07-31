"use client";

import { motion } from "framer-motion";
import { cn } from "@/lib/cn";
import type { Role } from "@/lib/supabase/types";

interface RoleCardProps {
  role: Role;
  masteredSkillIds: Set<string>;
  index?: number;
}

export function RoleCard({ role, masteredSkillIds, index = 0 }: RoleCardProps) {
  const totalSkills = role.required_skill_ids.length;
  const masteredCount = role.required_skill_ids.filter((id) => masteredSkillIds.has(id)).length;
  const readyForRole = totalSkills > 0 && masteredCount === totalSkills;

  return (
    <motion.article
      initial={{ opacity: 0, y: 32 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const, delay: index * 0.08 }}
      whileHover={{ y: -6 }}
      className="group relative overflow-hidden rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft transition-shadow duration-300 hover:shadow-lg"
    >
      <div
        className={cn(
          "mb-4 inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold",
          readyForRole
            ? "bg-accent-400/15 text-accent-600"
            : "bg-primary-400/15 text-primary-600",
        )}
      >
        {readyForRole ? "Skills matched" : `${masteredCount}/${totalSkills} skills matched`}
      </div>

      <h3 className="mb-2 text-xl font-semibold">{role.title}</h3>
      <p className="mb-4 text-sm leading-relaxed text-neutral-500">{role.description}</p>
      <p className="text-sm font-medium text-neutral-700">{role.typical_pay_range}</p>
    </motion.article>
  );
}
