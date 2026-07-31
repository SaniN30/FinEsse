import type { InterviewRubricScores } from "@/lib/supabase/types";

/** Average of the 0-10 sub-scores in a session's rubric_scores; null until scored. */
export function rubricOverallScore(rubricScores: InterviewRubricScores): number | null {
  const subScores = [rubricScores.star_structure?.score, rubricScores.clarity?.score].filter(
    (score): score is number => typeof score === "number",
  );
  if (subScores.length === 0) return null;
  const total = subScores.reduce((sum, score) => sum + score, 0);
  return Math.round((total / subScores.length) * 10) / 10;
}
