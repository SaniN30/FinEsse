import { describe, expect, it } from "vitest";
import {
  createStudentAccount,
  recordConsent,
  scoreInterviewSession,
  serviceClient,
  signInStudent,
  signUpParent,
} from "./helpers";

// Exercises the live-LLM path end to end against the real Gemini API (see
// GEMINI_API_KEY as a Supabase Edge Function secret). Unlike the RPC-only
// tests in interview-sessions.test.ts, this hits score-interview-session,
// so it depends on that secret being configured on the linked project.
describe("interview session scoring (live LLM)", () => {
  it("scores a submitted transcript and awards XP", async () => {
    const parent = await signUpParent("Parent Scoring");
    const consentId = await recordConsent(parent.accessToken, "Kid Scoring");
    const created = await createStudentAccount(parent.accessToken, {
      consentId,
      displayName: "Kid Scoring",
      pin: "6543",
    });
    expect(created.status).toBe(200);
    const student = await signInStudent(created.body.login_email, "6543");

    const admin = serviceClient();
    const { data: question, error: questionError } = await admin
      .from("interview_questions")
      .select("id")
      .eq("published", true)
      .limit(1)
      .single();
    expect(questionError).toBeNull();

    const { data: sessionId, error: submitError } = await student.client.rpc(
      "submit_interview_session",
      {
        p_question_id: question!.id,
        p_transcript:
          "Um, so, last year I led a group project under a tight deadline. I broke the work " +
          "into smaller tasks, assigned each teammate a piece based on their strengths, and we " +
          "checked in daily. We delivered on time and the client was happy with the result.",
      },
    );
    expect(submitError).toBeNull();

    const { status, body } = await scoreInterviewSession(student.accessToken, sessionId as string);
    expect(status).toBe(200);
    expect(body.rubric_scores.star_structure).toHaveProperty("score");
    expect(body.rubric_scores.clarity).toHaveProperty("score");
    expect(typeof body.rubric_scores.filler_word_count).toBe("number");
    expect(typeof body.rubric_scores.overall_feedback).toBe("string");

    const { data: sessionRow, error: readError } = await admin
      .from("interview_sessions")
      .select("rubric_scores")
      .eq("id", sessionId)
      .single();
    expect(readError).toBeNull();
    expect(sessionRow!.rubric_scores).toEqual(body.rubric_scores);

    const { data: xpRows, error: xpError } = await admin
      .from("xp_events")
      .select("source, source_id, xp_delta")
      .eq("source_id", sessionId)
      .eq("source", "interview_session");
    expect(xpError).toBeNull();
    expect(xpRows).toHaveLength(1);
    expect(xpRows![0].xp_delta).toBeGreaterThan(0);
  });

  it("rejects scoring another student's session", async () => {
    const parentA = await signUpParent("Parent Scoring A");
    const consentA = await recordConsent(parentA.accessToken, "Kid Scoring A");
    const createdA = await createStudentAccount(parentA.accessToken, {
      consentId: consentA,
      displayName: "Kid Scoring A",
      pin: "1122",
    });
    const studentA = await signInStudent(createdA.body.login_email, "1122");

    const parentB = await signUpParent("Parent Scoring B");
    const consentB = await recordConsent(parentB.accessToken, "Kid Scoring B");
    const createdB = await createStudentAccount(parentB.accessToken, {
      consentId: consentB,
      displayName: "Kid Scoring B",
      pin: "3344",
    });
    const studentB = await signInStudent(createdB.body.login_email, "3344");

    const admin = serviceClient();
    const { data: question } = await admin
      .from("interview_questions")
      .select("id")
      .eq("published", true)
      .limit(1)
      .single();

    const { data: sessionId } = await studentA.client.rpc("submit_interview_session", {
      p_question_id: question!.id,
      p_transcript: "This transcript belongs to student A.",
    });

    // studentB has no select policy visibility into studentA's session at
    // all (is_own_or_linked_profile), so the Edge Function's own RLS-scoped
    // read finds nothing -- a 404, not a 403, since it can't even see the
    // row exists to compare ownership against.
    const { status } = await scoreInterviewSession(studentB.accessToken, sessionId as string);
    expect(status).toBe(404);
  });
});
