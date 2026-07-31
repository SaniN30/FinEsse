import { beforeAll, describe, expect, it } from "vitest";
import {
  anonClient,
  createStudentAccount,
  recordConsent,
  serviceClient,
  signInStudent,
  signUpParent,
} from "./helpers";

const FINANCE_ROLES_QUIZ_ID = "00000000-0000-0000-0003-000000000101";
const MODELING_EXERCISE_ID = "00000000-0000-0000-0004-000000000001";

interface QuizQuestion {
  id: string;
  correct_answer: string;
}

async function fetchCorrectAnswers(quizId: string): Promise<QuizQuestion[]> {
  const admin = serviceClient();
  const { data, error } = await admin
    .from("quiz_questions")
    .select("id, correct_answer")
    .eq("quiz_id", quizId);
  if (error || !data) {
    throw new Error(`failed to load quiz questions: ${error?.message}`);
  }
  return data as QuizQuestion[];
}

function toAnswers(questions: QuizQuestion[], correctCount: number) {
  return questions.map((q, i) => ({
    question_id: q.id,
    answer: i < correctCount ? q.correct_answer : "wrong answer",
  }));
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
  const student = await signInStudent(created.body.login_email, pin);
  return { parent, student };
}

describe("college-tier content: quizzes", () => {
  let studentA: Awaited<ReturnType<typeof signInStudent>>;
  let studentB: Awaited<ReturnType<typeof signInStudent>>;
  let parentA: Awaited<ReturnType<typeof signUpParent>>;
  let questions: QuizQuestion[];

  beforeAll(async () => {
    const a = await makeCollegeStudent("College Parent A", "College Kid A", "3111");
    const b = await makeCollegeStudent("College Parent B", "College Kid B", "3222");
    parentA = a.parent;
    studentA = a.student;
    studentB = b.student;

    questions = await fetchCorrectAnswers(FINANCE_ROLES_QUIZ_ID);
    expect(questions.length).toBeGreaterThan(0);
  });

  it("grades a College quiz end-to-end via the reused grade_quiz_attempt RPC", async () => {
    const answers = toAnswers(questions, questions.length);

    const { data, error } = await studentA.client.rpc("grade_quiz_attempt", {
      p_quiz_id: FINANCE_ROLES_QUIZ_ID,
      p_answers: answers,
    });

    expect(error).toBeNull();
    expect(data.passed).toBe(true);

    const { data: xpEvents } = await studentA.client
      .from("xp_events")
      .select("xp_delta, source")
      .eq("profile_id", studentA.userId)
      .eq("source", "quiz_attempt");
    expect(xpEvents!.length).toBeGreaterThan(0);
  });

  it("prevents a College student from reading another student's quiz_attempts", async () => {
    const { data, error } = await studentB.client
      .from("quiz_attempts")
      .select("id")
      .eq("profile_id", studentA.userId);

    expect(error).toBeNull();
    expect(data).toHaveLength(0);
  });

  it("lets a linked parent read but not write a College child's quiz_attempts", async () => {
    const { data: readData, error: readError } = await parentA.client
      .from("quiz_attempts")
      .select("id")
      .eq("profile_id", studentA.userId);

    expect(readError).toBeNull();
    expect(readData!.length).toBeGreaterThan(0);

    const { error: writeError } = await parentA.client.from("quiz_attempts").insert({
      profile_id: studentA.userId,
      quiz_id: FINANCE_ROLES_QUIZ_ID,
      score: 1,
      passed: true,
      answers: [],
    });
    expect(writeError).not.toBeNull();
  });
});

describe("college-tier content: modeling exercise grading", () => {
  let studentA: Awaited<ReturnType<typeof signInStudent>>;
  let studentB: Awaited<ReturnType<typeof signInStudent>>;
  let parentA: Awaited<ReturnType<typeof signUpParent>>;

  beforeAll(async () => {
    const a = await makeCollegeStudent("Modeling Parent A", "Modeling Kid A", "4111");
    const b = await makeCollegeStudent("Modeling Parent B", "Modeling Kid B", "4222");
    parentA = a.parent;
    studentA = a.student;
    studentB = b.student;
  });

  it("scores a correct submission as a pass and awards XP + a skill_attempt", async () => {
    const { data, error } = await studentA.client.rpc("grade_modeling_submission", {
      p_exercise_id: MODELING_EXERCISE_ID,
      p_submitted_values: { projected_revenue: 1100000, revenue_growth_pct: 10 },
    });

    expect(error).toBeNull();
    expect(data.passed).toBe(true);
    expect(data.score).toBe(1);

    const { data: submissions } = await studentA.client
      .from("modeling_submissions")
      .select("id, passed, score")
      .eq("id", data.submission_id);
    expect(submissions).toHaveLength(1);
    expect(submissions![0].passed).toBe(true);

    const { data: skillAttempts } = await studentA.client
      .from("skill_attempts")
      .select("is_correct")
      .eq("profile_id", studentA.userId);
    expect(skillAttempts!.some((a) => a.is_correct)).toBe(true);

    const { data: xpEvents } = await studentA.client
      .from("xp_events")
      .select("xp_delta, source")
      .eq("profile_id", studentA.userId)
      .eq("source", "modeling_submission");
    expect(xpEvents!.length).toBeGreaterThan(0);
    expect(xpEvents![0].xp_delta).toBeGreaterThan(0);
  });

  it("awards zero additional XP on a second passing submission of the same exercise", async () => {
    const { data: firstXp } = await studentA.client
      .from("xp_events")
      .select("id")
      .eq("profile_id", studentA.userId)
      .eq("source", "modeling_submission");
    const xpEventsBefore = firstXp!.length;

    const { data, error } = await studentA.client.rpc("grade_modeling_submission", {
      p_exercise_id: MODELING_EXERCISE_ID,
      p_submitted_values: { projected_revenue: 1100000, revenue_growth_pct: 10 },
    });

    expect(error).toBeNull();
    expect(data.passed).toBe(true);
    expect(data.already_completed).toBe(true);

    const { data: submissions } = await studentA.client
      .from("modeling_submissions")
      .select("id")
      .eq("profile_id", studentA.userId)
      .eq("exercise_id", MODELING_EXERCISE_ID);
    expect(submissions!.length).toBeGreaterThanOrEqual(2);

    const { data: xpEvents } = await studentA.client
      .from("xp_events")
      .select("id")
      .eq("profile_id", studentA.userId)
      .eq("source", "modeling_submission");
    expect(xpEvents!.length).toBe(xpEventsBefore);
  });

  it("scores a wildly incorrect submission as a fail and awards nothing", async () => {
    const { data, error } = await studentB.client.rpc("grade_modeling_submission", {
      p_exercise_id: MODELING_EXERCISE_ID,
      p_submitted_values: { projected_revenue: 1, revenue_growth_pct: -50 },
    });

    expect(error).toBeNull();
    expect(data.passed).toBe(false);

    const { data: xpEvents } = await studentB.client
      .from("xp_events")
      .select("id")
      .eq("profile_id", studentB.userId)
      .eq("source", "modeling_submission");
    expect(xpEvents).toHaveLength(0);
  });

  it("never trusts a client-submitted score/passed field", async () => {
    const { data, error } = await studentB.client.rpc("grade_modeling_submission", {
      p_exercise_id: MODELING_EXERCISE_ID,
      p_submitted_values: { projected_revenue: 1, revenue_growth_pct: -50, score: 1, passed: true },
    });

    expect(error).toBeNull();
    expect(data.passed).toBe(false);
    expect(data.score).toBeLessThan(1);
  });

  it("does not crash on malformed (non-numeric) submitted values", async () => {
    const { data, error } = await studentB.client.rpc("grade_modeling_submission", {
      p_exercise_id: MODELING_EXERCISE_ID,
      p_submitted_values: { projected_revenue: "not a number", revenue_growth_pct: null },
    });

    expect(error).toBeNull();
    expect(data.passed).toBe(false);
  });

  it("never exposes the rubric's expected values through the base modeling_exercises table", async () => {
    const { data, error } = await studentA.client
      .from("modeling_exercises")
      .select("id, rubric")
      .eq("id", MODELING_EXERCISE_ID);

    expect(error).toBeNull();
    expect(data).toHaveLength(0);
  });

  it("exposes exercise instructions (without the rubric) via modeling_exercises_public", async () => {
    const { data, error } = await studentA.client
      .from("modeling_exercises_public")
      .select("id, title, instructions, pass_threshold")
      .eq("id", MODELING_EXERCISE_ID);

    expect(error).toBeNull();
    expect(data!.length).toBeGreaterThan(0);
  });

  it("prevents a student from inserting a self-authored modeling_submission directly, bypassing grading", async () => {
    const { error } = await studentA.client.from("modeling_submissions").insert({
      profile_id: studentA.userId,
      exercise_id: MODELING_EXERCISE_ID,
      submitted_values: {},
      score: 1,
      passed: true,
    });
    expect(error).not.toBeNull();
  });

  it("prevents a student from reading another student's modeling_submissions", async () => {
    const { data, error } = await studentB.client
      .from("modeling_submissions")
      .select("id")
      .eq("profile_id", studentA.userId);

    expect(error).toBeNull();
    expect(data).toHaveLength(0);
  });

  it("prevents a student from writing a modeling_submission for another student", async () => {
    const { error } = await studentB.client.from("modeling_submissions").insert({
      profile_id: studentA.userId,
      exercise_id: MODELING_EXERCISE_ID,
      submitted_values: {},
      score: 1,
      passed: true,
    });
    expect(error).not.toBeNull();
  });

  it("lets a linked parent read but not write a child's modeling_submissions", async () => {
    const { data: readData, error: readError } = await parentA.client
      .from("modeling_submissions")
      .select("id")
      .eq("profile_id", studentA.userId);

    expect(readError).toBeNull();
    expect(readData!.length).toBeGreaterThan(0);

    const { error: writeError } = await parentA.client.from("modeling_submissions").insert({
      profile_id: studentA.userId,
      exercise_id: MODELING_EXERCISE_ID,
      submitted_values: {},
      score: 1,
      passed: true,
    });
    expect(writeError).not.toBeNull();
  });
});

describe("roles reference table", () => {
  it("is publicly readable to any authenticated user", async () => {
    const a = await makeCollegeStudent("Roles Parent A", "Roles Kid A", "5111");

    const { data, error } = await a.student.client
      .from("roles")
      .select("slug, title, typical_pay_range, required_skill_ids")
      .eq("published", true);

    expect(error).toBeNull();
    expect(data!.length).toBeGreaterThan(0);
  });

  it("is not writable by an authenticated (non-service-role) client", async () => {
    const a = await makeCollegeStudent("Roles Parent B", "Roles Kid B", "5222");

    const { error } = await a.student.client.from("roles").insert({
      slug: "hacker-role",
      title: "Hacker",
      description: "should not be insertable",
      typical_pay_range: "$0",
    });
    expect(error).not.toBeNull();
  });

  it("is unreadable by an unauthenticated client", async () => {
    const { data, error } = await anonClient().from("roles").select("slug");
    expect(error).toBeNull();
    expect(data).toHaveLength(0);
  });
});
