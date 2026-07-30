import { beforeAll, describe, expect, it } from "vitest";
import {
  createStudentAccount,
  recordConsent,
  serviceClient,
  signInStudent,
  signUpParent,
} from "./helpers";

async function fetchAQuestionId(): Promise<string> {
  const admin = serviceClient();
  const { data, error } = await admin
    .from("interview_questions")
    .select("id")
    .eq("published", true)
    .limit(1)
    .single();
  if (error || !data) {
    throw new Error(`failed to load a seeded interview question: ${error?.message}`);
  }
  return data.id as string;
}

async function makeStudent(parentLabel: string, kidLabel: string, pin: string) {
  const parent = await signUpParent(parentLabel);
  const consentId = await recordConsent(parent.accessToken, kidLabel);
  const created = await createStudentAccount(parent.accessToken, {
    consentId,
    displayName: kidLabel,
    pin,
  });
  expect(created.status).toBe(200);
  const student = await signInStudent(created.body.login_email, pin);
  return { parent, student };
}

describe("interview session submission", () => {
  let questionId: string;

  beforeAll(async () => {
    questionId = await fetchAQuestionId();
  });

  it("creates a session row for the submitting student via the RPC", async () => {
    const { student } = await makeStudent("Parent Submit", "Kid Submit", "1111");

    const { data: sessionId, error } = await student.client.rpc("submit_interview_session", {
      p_question_id: questionId,
      p_transcript: "I once led a project under a tight deadline by breaking it into tasks.",
    });

    expect(error).toBeNull();
    expect(sessionId).toBeTruthy();

    const { data: rows, error: readError } = await student.client
      .from("interview_sessions")
      .select("id, profile_id, question_id, transcript, rubric_scores")
      .eq("id", sessionId);

    expect(readError).toBeNull();
    expect(rows).toHaveLength(1);
    expect(rows![0].profile_id).toBe(student.userId);
    expect(rows![0].question_id).toBe(questionId);
    expect(rows![0].transcript).toContain("tight deadline");
    expect(rows![0].rubric_scores).toEqual({});
  });

  it("rejects an empty transcript", async () => {
    const { student } = await makeStudent("Parent Empty", "Kid Empty", "2222");

    const { error } = await student.client.rpc("submit_interview_session", {
      p_question_id: questionId,
      p_transcript: "   ",
    });

    expect(error).not.toBeNull();
  });

  it("prevents a student from reading another student's sessions", async () => {
    const { student: studentA } = await makeStudent("Parent A2", "Kid A2", "3333");
    const { student: studentB } = await makeStudent("Parent B2", "Kid B2", "4444");

    const { data: sessionId } = await studentA.client.rpc("submit_interview_session", {
      p_question_id: questionId,
      p_transcript: "This is student A's transcript.",
    });

    const { data: rows, error } = await studentB.client
      .from("interview_sessions")
      .select("id")
      .eq("id", sessionId);

    expect(error).toBeNull();
    expect(rows).toHaveLength(0);
  });

  it("lets a linked parent read (but not write) a child's session", async () => {
    const { parent, student } = await makeStudent("Parent Read", "Kid Read", "5555");

    const { data: sessionId } = await student.client.rpc("submit_interview_session", {
      p_question_id: questionId,
      p_transcript: "This is the child's transcript for the parent to read.",
    });

    const { data: rows, error: readError } = await parent.client
      .from("interview_sessions")
      .select("id, transcript")
      .eq("id", sessionId);

    expect(readError).toBeNull();
    expect(rows).toHaveLength(1);
    expect(rows![0].transcript).toContain("child's transcript");

    const { error: insertError } = await parent.client.from("interview_sessions").insert({
      profile_id: student.userId,
      question_id: questionId,
      firm_style: "JPMorgan Chase",
      transcript: "parent trying to write on behalf of the child",
    });
    expect(insertError).not.toBeNull();

    const { data: parentSessionId, error: rpcError } = await parent.client.rpc(
      "submit_interview_session",
      { p_question_id: questionId, p_transcript: "parent trying to submit as if they were the student" },
    );
    // The RPC always writes profile_id = auth.uid(), so this creates a
    // session owned by the PARENT, not the child -- proving the parent still
    // cannot write into the child's session data even through the RPC.
    expect(rpcError).toBeNull();

    const { data: ownedRow } = await parent.client
      .from("interview_sessions")
      .select("profile_id")
      .eq("id", parentSessionId)
      .single();
    expect(ownedRow!.profile_id).toBe(parent.userId);
  });
});
