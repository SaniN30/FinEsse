import { beforeAll, describe, expect, it } from "vitest";
import {
  createStudentAccount,
  recordConsent,
  serviceClient,
  signInStudent,
  signUpParent,
} from "./helpers";

const WHAT_IS_MONEY_QUIZ_ID = "00000000-0000-0000-0003-000000000001";

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

describe("quiz auto-grading", () => {
  let studentA: Awaited<ReturnType<typeof signInStudent>>;
  let studentB: Awaited<ReturnType<typeof signInStudent>>;
  let parentA: Awaited<ReturnType<typeof signUpParent>>;
  let questions: QuizQuestion[];

  beforeAll(async () => {
    parentA = await signUpParent("Grading Parent A");
    const parentB = await signUpParent("Grading Parent B");

    const consentA = await recordConsent(parentA.accessToken, "Grading Kid A");
    const createdA = await createStudentAccount(parentA.accessToken, {
      consentId: consentA,
      displayName: "Grading Kid A",
      pin: "1111",
    });
    expect(createdA.status).toBe(200);
    studentA = await signInStudent(createdA.body.login_email, "1111");

    const consentB = await recordConsent(parentB.accessToken, "Grading Kid B");
    const createdB = await createStudentAccount(parentB.accessToken, {
      consentId: consentB,
      displayName: "Grading Kid B",
      pin: "2222",
    });
    expect(createdB.status).toBe(200);
    studentB = await signInStudent(createdB.body.login_email, "2222");

    questions = await fetchCorrectAnswers(WHAT_IS_MONEY_QUIZ_ID);
    expect(questions.length).toBeGreaterThan(0);
  });

  it("awards a passing skill_attempt and XP for an all-correct submission", async () => {
    const answers = toAnswers(questions, questions.length);

    const { data, error } = await studentA.client.rpc("grade_quiz_attempt", {
      p_quiz_id: WHAT_IS_MONEY_QUIZ_ID,
      p_answers: answers,
    });

    expect(error).toBeNull();
    expect(data.passed).toBe(true);
    expect(data.score).toBe(1);

    const { data: attempts } = await studentA.client
      .from("quiz_attempts")
      .select("id, passed, score")
      .eq("id", data.attempt_id);
    expect(attempts).toHaveLength(1);
    expect(attempts![0].passed).toBe(true);

    const { data: skillAttempts } = await studentA.client
      .from("skill_attempts")
      .select("is_correct")
      .eq("profile_id", studentA.userId);
    expect(skillAttempts!.some((a) => a.is_correct)).toBe(true);

    const { data: xpEvents } = await studentA.client
      .from("xp_events")
      .select("xp_delta, source")
      .eq("profile_id", studentA.userId)
      .eq("source", "quiz_attempt");
    expect(xpEvents!.length).toBeGreaterThan(0);
    expect(xpEvents![0].xp_delta).toBeGreaterThan(0);
  });

  it("does not award a skill_attempt or XP for a below-threshold submission", async () => {
    const answers = toAnswers(questions, 0);

    const { data, error } = await studentB.client.rpc("grade_quiz_attempt", {
      p_quiz_id: WHAT_IS_MONEY_QUIZ_ID,
      p_answers: answers,
    });

    expect(error).toBeNull();
    expect(data.passed).toBe(false);

    const { data: skillAttempts } = await studentB.client
      .from("skill_attempts")
      .select("id")
      .eq("profile_id", studentB.userId);
    expect(skillAttempts).toHaveLength(0);

    const { data: xpEvents } = await studentB.client
      .from("xp_events")
      .select("id")
      .eq("profile_id", studentB.userId)
      .eq("source", "quiz_attempt");
    expect(xpEvents).toHaveLength(0);
  });

  it("never trusts a client-submitted score: grading ignores any extra client fields", async () => {
    const answers = toAnswers(questions, 0).map((a) => ({ ...a, score: 1, passed: true }));

    const { data, error } = await studentB.client.rpc("grade_quiz_attempt", {
      p_quiz_id: WHAT_IS_MONEY_QUIZ_ID,
      p_answers: answers,
    });

    expect(error).toBeNull();
    expect(data.passed).toBe(false);
    expect(data.score).toBe(0);
  });

  it("prevents a student from reading another student's quiz_attempts", async () => {
    const { data, error } = await studentB.client
      .from("quiz_attempts")
      .select("id")
      .eq("profile_id", studentA.userId);

    expect(error).toBeNull();
    expect(data).toHaveLength(0);
  });

  it("prevents a student from inserting a quiz_attempt for another student", async () => {
    const { error } = await studentB.client.from("quiz_attempts").insert({
      profile_id: studentA.userId,
      quiz_id: WHAT_IS_MONEY_QUIZ_ID,
      score: 1,
      passed: true,
      answers: [],
    });

    expect(error).not.toBeNull();
  });

  it("lets a linked parent read but not write a child's quiz_attempts", async () => {
    const { data: readData, error: readError } = await parentA.client
      .from("quiz_attempts")
      .select("id")
      .eq("profile_id", studentA.userId);

    expect(readError).toBeNull();
    expect(readData!.length).toBeGreaterThan(0);

    const { error: writeError } = await parentA.client.from("quiz_attempts").insert({
      profile_id: studentA.userId,
      quiz_id: WHAT_IS_MONEY_QUIZ_ID,
      score: 1,
      passed: true,
      answers: [],
    });

    expect(writeError).not.toBeNull();
  });

  it("does not expose correct_answer through the base quiz_questions table to a student", async () => {
    const { data, error } = await studentA.client
      .from("quiz_questions")
      .select("id, correct_answer")
      .eq("quiz_id", WHAT_IS_MONEY_QUIZ_ID);

    expect(error).toBeNull();
    expect(data).toHaveLength(0);
  });

  it("exposes question content (without answers) via quiz_questions_public", async () => {
    const { data, error } = await studentA.client
      .from("quiz_questions_public")
      .select("id, question, options")
      .eq("quiz_id", WHAT_IS_MONEY_QUIZ_ID);

    expect(error).toBeNull();
    expect(data!.length).toBeGreaterThan(0);
  });
});
