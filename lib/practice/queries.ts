import { getSupabaseClient } from "@/lib/supabase/client";
import type {
  GradePracticeAttemptResult,
  PracticeQuestion,
  QuestionDifficulty,
  QuizQuestionType,
  Tier,
} from "@/lib/supabase/types";

export interface PracticeFilters {
  tier?: Tier;
  difficulty?: QuestionDifficulty;
  questionType?: QuizQuestionType;
  caseStudyOnly?: boolean;
}

/** Quiz-question-sourced practice bank: gradeable via grade_practice_attempt. */
export async function fetchPracticeQuestions(filters: PracticeFilters = {}): Promise<PracticeQuestion[]> {
  const supabase = getSupabaseClient();
  let query = supabase.from("practice_questions").select("*").eq("source", "quiz");

  if (filters.tier) query = query.eq("tier", filters.tier);
  if (filters.difficulty) query = query.eq("difficulty", filters.difficulty);
  if (filters.questionType) query = query.eq("question_type", filters.questionType);
  if (filters.caseStudyOnly) query = query.eq("is_case_study", true);

  const { data, error } = await query.order("difficulty", { ascending: true });
  if (error) throw error;
  return (data ?? []) as PracticeQuestion[];
}

/** Interview-question-sourced practice bank: browse-only here, attempted via the existing Interview Coach flow. */
export async function fetchInterviewPracticeQuestions(
  filters: Pick<PracticeFilters, "difficulty"> = {},
): Promise<PracticeQuestion[]> {
  const supabase = getSupabaseClient();
  let query = supabase.from("practice_questions").select("*").eq("source", "interview");
  if (filters.difficulty) query = query.eq("difficulty", filters.difficulty);

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as PracticeQuestion[];
}

/** Grades one question in isolation and logs it to practice_attempts only -- never touches quiz_attempts/skill_attempts/xp_events/badges. */
export async function gradePracticeAttempt(
  questionId: string,
  answer: string,
): Promise<GradePracticeAttemptResult> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.rpc("grade_practice_attempt", {
    p_question_id: questionId,
    p_answer: answer,
  });
  if (error) throw error;
  return data as GradePracticeAttemptResult;
}
