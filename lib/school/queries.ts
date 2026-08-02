import { getSupabaseClient } from "@/lib/supabase/client";
import type {
  GradeQuizAttemptResult,
  Lesson,
  Quiz,
  QuizQuestionPublic,
  Skill,
  SkillMastery,
  Tier,
} from "@/lib/supabase/types";

export interface SkillWithMastery extends Skill {
  rollingAccuracy: number | null;
  attemptsConsidered: number;
  isUnlocked: boolean;
}

/**
 * Mastery/unlock state is always derived live from skill_attempts (via the
 * skill_mastery view) -- there is no stored "current level" to read instead.
 */
export async function fetchSkillsWithMastery(
  profileId: string,
  tier: Tier,
): Promise<SkillWithMastery[]> {
  const supabase = getSupabaseClient();

  const [{ data: skills, error: skillsError }, { data: mastery, error: masteryError }] =
    await Promise.all([
      supabase.from("skills").select("*").eq("tier", tier).order("created_at"),
      supabase.from("skill_mastery").select("*").eq("profile_id", profileId),
    ]);

  if (skillsError) throw skillsError;
  if (masteryError) throw masteryError;

  const masteryBySkill = new Map<string, SkillMastery>(
    (mastery ?? []).map((row) => [row.skill_id, row as SkillMastery]),
  );

  return (skills as Skill[]).map((skill) => {
    const skillMastery = masteryBySkill.get(skill.id);
    const prerequisiteMastery = skill.prerequisite_skill_id
      ? masteryBySkill.get(skill.prerequisite_skill_id)
      : undefined;

    const isUnlocked =
      !skill.prerequisite_skill_id ||
      (prerequisiteMastery !== undefined &&
        prerequisiteMastery.rolling_accuracy >= skill.mastery_threshold);

    return {
      ...skill,
      rollingAccuracy: skillMastery?.rolling_accuracy ?? null,
      attemptsConsidered: skillMastery?.attempts_considered ?? 0,
      isUnlocked,
    };
  });
}

export async function fetchTotalXp(profileId: string): Promise<number> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("xp_events")
    .select("xp_delta")
    .eq("profile_id", profileId);

  if (error) throw error;
  return (data ?? []).reduce((sum, row) => sum + row.xp_delta, 0);
}

export async function fetchLessonsForSkill(skillId: string): Promise<Lesson[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("lessons")
    .select("*")
    .eq("skill_id", skillId)
    .order("order_index");

  if (error) throw error;
  return data as Lesson[];
}

export async function fetchSkill(skillId: string): Promise<Skill> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.from("skills").select("*").eq("id", skillId).single();

  if (error) throw error;
  return data as Skill;
}

export async function fetchLesson(lessonId: string): Promise<Lesson> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("lessons")
    .select("*")
    .eq("id", lessonId)
    .single();

  if (error) throw error;
  return data as Lesson;
}

export async function fetchQuizzesForLesson(lessonId: string): Promise<Quiz[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("quizzes")
    .select("*")
    .eq("lesson_id", lessonId);

  if (error) throw error;
  return data as Quiz[];
}

export async function fetchQuiz(quizId: string): Promise<Quiz> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.from("quizzes").select("*").eq("id", quizId).single();

  if (error) throw error;
  return data as Quiz;
}

export async function fetchQuizQuestions(quizId: string): Promise<QuizQuestionPublic[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("quiz_questions_public")
    .select("*")
    .eq("quiz_id", quizId)
    .order("order_index");

  if (error) throw error;
  return data as QuizQuestionPublic[];
}

export interface QuizAnswer {
  question_id: string;
  answer: string;
}

/**
 * Grading always happens server-side in grade_quiz_attempt -- the client
 * never computes or submits a score/pass result itself.
 */
export async function submitQuizAttempt(
  quizId: string,
  answers: QuizAnswer[],
): Promise<GradeQuizAttemptResult> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.rpc("grade_quiz_attempt", {
    p_quiz_id: quizId,
    p_answers: answers,
  });

  if (error) throw error;
  return data as GradeQuizAttemptResult;
}
