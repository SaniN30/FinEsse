export type Tier = "school" | "college" | "job_ready";
export type ContentType = "article" | "video" | "interactive";
export type ProfileRole = "parent" | "student";
export type AccountType = "student_wallet" | "parent_wallet" | "savings_goal";

export interface Profile {
  id: string;
  role: ProfileRole;
  parent_id: string | null;
  tier: Tier | null;
  display_name: string | null;
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

export interface QuizQuestionPublic {
  id: string;
  quiz_id: string;
  question: string;
  options: string[];
  order_index: number;
}

export interface GradeQuizAttemptResult {
  attempt_id: string;
  score: number;
  passed: boolean;
  correct: number;
  total: number;
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
