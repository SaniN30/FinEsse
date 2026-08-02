"use client";

import type { PracticeFilters as PracticeFiltersValue } from "@/lib/practice/queries";
import type { Tier } from "@/lib/supabase/types";

const TIER_OPTIONS: { value: Tier; label: string }[] = [
  { value: "school", label: "School" },
  { value: "college", label: "College" },
  { value: "job_ready", label: "Job-Ready" },
];

const selectClassName =
  "rounded-full border border-surface-border bg-surface px-4 py-2 text-sm text-foreground focus:border-purple-400 focus:outline-none";

interface PracticeFiltersProps {
  value: PracticeFiltersValue;
  onChange: (next: PracticeFiltersValue) => void;
}

export function PracticeFilters({ value, onChange }: PracticeFiltersProps) {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <select
        aria-label="Filter by tier"
        className={selectClassName}
        value={value.tier ?? ""}
        onChange={(event) =>
          onChange({ ...value, tier: (event.target.value || undefined) as Tier | undefined })
        }
      >
        <option value="">All tiers</option>
        {TIER_OPTIONS.map((tier) => (
          <option key={tier.value} value={tier.value}>
            {tier.label}
          </option>
        ))}
      </select>

      <select
        aria-label="Filter by difficulty"
        className={selectClassName}
        value={value.difficulty ?? ""}
        onChange={(event) =>
          onChange({
            ...value,
            difficulty: (event.target.value || undefined) as PracticeFiltersValue["difficulty"],
          })
        }
      >
        <option value="">All difficulties</option>
        <option value="easy">Easy</option>
        <option value="medium">Medium</option>
        <option value="hard">Hard</option>
      </select>

      <select
        aria-label="Filter by question type"
        className={selectClassName}
        value={value.questionType ?? ""}
        onChange={(event) =>
          onChange({
            ...value,
            questionType: (event.target.value || undefined) as PracticeFiltersValue["questionType"],
          })
        }
      >
        <option value="">All types</option>
        <option value="multiple_choice">Multiple choice</option>
        <option value="free_response">Free response</option>
      </select>

      <label className="flex items-center gap-2 text-sm text-muted-foreground">
        <input
          type="checkbox"
          checked={Boolean(value.caseStudyOnly)}
          onChange={(event) => onChange({ ...value, caseStudyOnly: event.target.checked || undefined })}
        />
        Case studies only
      </label>
    </div>
  );
}
