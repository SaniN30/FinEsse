// Verifies the exact data shapes the Phase 8 College-tier frontend
// components read/write, end-to-end against a live Supabase project: the
// LessonList/LessonDetail/QuizRunner reads, the Role Explorer's roles +
// skill_mastery cross-link, and the modeling submission RPC's per-metric
// breakdown that ModelingResult renders (see BACKEND.md and
// supabase/migrations/00000000000022_grade_modeling_submission_metric_breakdown.sql).
import { beforeAll, describe, expect, it } from "vitest";
import {
  createStudentAccount,
  recordConsent,
  serviceClient,
  signInStudent,
  signUpParent,
} from "./helpers";
import { extractMetricKeys } from "../../lib/modeling";

const FINANCE_ROLES_SKILL_ID = "00000000-0000-0000-0001-000000000101";
const FINANCE_ROLES_QUIZ_ID = "00000000-0000-0000-0003-000000000101";
const MODELING_EXERCISE_ID = "00000000-0000-0000-0004-000000000001";

interface QuizQuestion {
  id: string;
  correct_answer: string;
}

async function makeCollegeStudent(parentLabel: string, kidLabel: string, pin: string) {
  const parent = await signUpParent(parentLabel);
  const consentId = await recordConsent(parent.accessToken, kidLabel);
  const created = await createStudentAccount(parent.accessToken, {
    consentId,
    displayName: kidLabel,
    pin,
    tier: "college",
  });
  expect(created.status).toBe(200);
  return signInStudent(created.body.login_email, pin);
}

describe("Phase 8 College frontend: lesson/quiz reads", () => {
  let student: Awaited<ReturnType<typeof signInStudent>>;

  beforeAll(async () => {
    student = await makeCollegeStudent(
      "Frontend Parent A",
      "Frontend Kid A",
      "4111",
    );
  });

  it("LessonList's skill read returns college-tier skills", async () => {
    const { data, error } = await student.client
      .from("skills")
      .select("id, tier, title")
      .eq("tier", "college");

    expect(error).toBeNull();
    expect(data?.length).toBeGreaterThan(0);
  });

  it("LessonDetail's lesson/quiz reads return rows for a known skill", async () => {
    const { data: lessons, error: lessonError } = await student.client
      .from("lessons")
      .select("id, skill_id, content_type, content_body, order_index")
      .eq("skill_id", FINANCE_ROLES_SKILL_ID);

    expect(lessonError).toBeNull();
    expect(lessons?.length).toBeGreaterThan(0);

    const { data: quizzes, error: quizError } = await student.client
      .from("quizzes")
      .select("id, title")
      .eq("skill_id", FINANCE_ROLES_SKILL_ID);

    expect(quizError).toBeNull();
    expect(quizzes?.length).toBeGreaterThan(0);
  });

  it("QuizRunner's question read never exposes correct_answer", async () => {
    const { data, error } = await student.client
      .from("quiz_questions_public")
      .select("id, quiz_id, question, options, order_index")
      .eq("quiz_id", FINANCE_ROLES_QUIZ_ID)
      .order("order_index", { ascending: true });

    expect(error).toBeNull();
    expect(data?.length).toBeGreaterThan(0);
    expect(data?.[0]).not.toHaveProperty("correct_answer");
  });

  it("QuizRunner's grade_quiz_attempt call returns {score, passed}", async () => {
    const admin = serviceClient();
    const { data: questions } = await admin
      .from("quiz_questions")
      .select("id, correct_answer")
      .eq("quiz_id", FINANCE_ROLES_QUIZ_ID);

    const answers = (questions as QuizQuestion[]).map((q) => ({
      question_id: q.id,
      answer: q.correct_answer,
    }));

    const { data, error } = await student.client.rpc("grade_quiz_attempt", {
      p_quiz_id: FINANCE_ROLES_QUIZ_ID,
      p_answers: answers,
    });

    expect(error).toBeNull();
    expect(typeof data.score).toBe("number");
    expect(data.passed).toBe(true);
  });
});

describe("Phase 8 College frontend: Role Explorer", () => {
  let student: Awaited<ReturnType<typeof signInStudent>>;

  beforeAll(async () => {
    student = await makeCollegeStudent(
      "Frontend Parent B",
      "Frontend Kid B",
      "4222",
    );
  });

  it("RoleExplorerGrid's roles read includes required_skill_ids for cross-linking", async () => {
    const { data, error } = await student.client
      .from("roles")
      .select("id, slug, title, typical_pay_range, required_skill_ids");

    expect(error).toBeNull();
    expect(data?.length).toBeGreaterThan(0);
    expect(Array.isArray(data?.[0].required_skill_ids)).toBe(true);
  });

  it("RoleExplorerGrid's mastery read is scoped to the caller's own profile", async () => {
    const { data, error } = await student.client
      .from("skill_mastery")
      .select("skill_id, rolling_accuracy")
      .eq("profile_id", student.userId);

    expect(error).toBeNull();
    expect(data).toEqual([]);
  });
});

describe("Phase 8 College frontend: modeling exercise", () => {
  let student: Awaited<ReturnType<typeof signInStudent>>;

  beforeAll(async () => {
    student = await makeCollegeStudent(
      "Frontend Parent C",
      "Frontend Kid C",
      "4333",
    );
  });

  it("ModelingExerciseForm's read never exposes the rubric", async () => {
    const { data, error } = await student.client
      .from("modeling_exercises_public")
      .select("id, title, instructions, pass_threshold")
      .eq("id", MODELING_EXERCISE_ID)
      .maybeSingle();

    expect(error).toBeNull();
    expect(data).not.toBeNull();
    expect(data).not.toHaveProperty("rubric");
  });

  it("extractMetricKeys parses the submission shape out of seeded instructions", async () => {
    const { data } = await student.client
      .from("modeling_exercises_public")
      .select("instructions")
      .eq("id", MODELING_EXERCISE_ID)
      .maybeSingle();

    const keys = extractMetricKeys(data!.instructions as string);
    expect(keys).toEqual(["projected_revenue", "revenue_growth_pct"]);
  });

  it("ModelingResult's per-metric breakdown reflects correct/incorrect submissions", async () => {
    const { data, error } = await student.client.rpc("grade_modeling_submission", {
      p_exercise_id: MODELING_EXERCISE_ID,
      p_submitted_values: { projected_revenue: 1100000, revenue_growth_pct: 0 },
    });

    expect(error).toBeNull();
    expect(data.passed).toBe(false);
    expect(data.metrics).toEqual({
      projected_revenue: true,
      revenue_growth_pct: false,
    });
  });
});
