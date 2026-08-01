export type Tier = "school" | "college" | "job_ready";
export type ContentType = "article" | "video" | "interactive";
export type ProfileRole = "parent" | "student";
export type AccountType = "student_wallet" | "parent_wallet" | "savings_goal";
export type EducationLevel = "school" | "college" | "working_professional";

export interface Profile {
  id: string;
  role: ProfileRole;
  parent_id: string | null;
  tier: Tier | null;
  display_name: string | null;
  date_of_birth?: string | null;
  education_level?: EducationLevel | null;
  institution_name?: string | null;
  phone_number?: string | null;
}

export interface Skill {
  id: string;
  tier: Tier;
  slug: string;
  title: string;
  prerequisite_skill_id: string | null;
  mastery_threshold: number;
}

export interface SkillMastery {
  profile_id: string;
  skill_id: string;
  attempts_considered: number;
  rolling_accuracy: number;
}

export interface Lesson {
  id: string;
  skill_id: string;
  content_type: ContentType;
  content_url: string | null;
  content_body: string | null;
  order_index: number;
  published: boolean;
}

export interface Quiz {
  id: string;
  skill_id: string | null;
  lesson_id: string | null;
  title: string;
  pass_threshold: number;
  published: boolean;
}

export type QuestionDifficulty = "easy" | "medium" | "hard";
export type QuizQuestionType = "multiple_choice" | "free_response";

export interface QuizQuestionPublic {
  id: string;
  quiz_id: string;
  question: string;
  options: string[];
  order_index: number;
  difficulty: QuestionDifficulty;
  question_type: QuizQuestionType;
  scenario_context: string | null;
}

export interface GradeQuizAttemptResult {
  attempt_id: string;
  score: number;
  passed: boolean;
  correct: number;
  total: number;
}

export interface QuizGradeResult {
  score: number;
  passed: boolean;
}

export interface AccountBalance {
  account_id: string;
  profile_id: string;
  type: AccountType;
  name: string;
  target_amount_cents: number | null;
  balance_cents: number;
}

export interface SavingsGoalProgress {
  account_id: string;
  profile_id: string;
  name: string;
  target_amount_cents: number | null;
  balance_cents: number;
  percent_complete: number | null;
}

export interface DashboardSavingsGoal {
  account_id: string;
  name: string;
  balance_cents: number;
  target_amount_cents: number | null;
  percent_complete: number | null;
}

export interface DashboardInterviewSession {
  session_id: string;
  firm_style: string;
  rubric_scores: Record<string, unknown>;
  created_at: string;
}

/** One row per linked child, from the `parent_dashboard_children` view. */
export interface ParentDashboardChild {
  profile_id: string;
  parent_id: string | null;
  display_name: string | null;
  tier: Tier | null;
  total_xp: number;
  avg_mastery_pct: number | null;
  wallet_balance_cents: number;
  savings_goals: DashboardSavingsGoal[];
  interview_sessions: DashboardInterviewSession[];
}

export interface Role {
  id: string;
  slug: string;
  title: string;
  description: string;
  typical_pay_range: string;
  required_skill_ids: string[];
}

export interface ModelingExercisePublic {
  id: string;
  skill_id: string;
  title: string;
  instructions: string;
  pass_threshold: number;
}

export interface ModelingGradeResult {
  score: number;
  passed: boolean;
  breakdown: Record<string, { correct: boolean }>;
  alreadyCompleted: boolean;
}

export type InterviewQuestionCategory = "behavioral" | "technical";

export interface InterviewQuestion {
  id: string;
  firm_style: string;
  question_text: string;
  category: InterviewQuestionCategory;
  published: boolean;
}

export interface RubricScoreEntry {
  score: number;
  feedback: string;
}

/** Shape written by supabase/functions/score-interview-session; `{}` before scoring. */
export interface InterviewRubricScores {
  star_structure?: RubricScoreEntry;
  clarity?: RubricScoreEntry;
  filler_word_count?: number;
  overall_feedback?: string;
}

export interface InterviewSession {
  id: string;
  profile_id: string;
  question_id: string;
  firm_style: string;
  transcript: string;
  rubric_scores: InterviewRubricScores;
  created_at: string;
}

export interface ScoreInterviewSessionResult {
  session_id: string;
  rubric_scores: InterviewRubricScores;
}

export type BadgeCriteriaType =
  | "first_lesson_completed"
  | "first_quiz_passed"
  | "first_modeling_exercise_passed"
  | "tier_completed";

export interface Badge {
  id: string;
  slug: string;
  title: string;
  description: string;
  criteria_type: BadgeCriteriaType;
}

export interface ProfileBadge {
  id: string;
  profile_id: string;
  badge_id: string;
  awarded_at: string;
  badges: Badge;
}
