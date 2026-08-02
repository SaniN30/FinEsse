// Scores a submitted interview transcript with the Gemini API and writes
// the result back onto the session -- this is the one place a rubric score
// for an interview session is ever computed. The client never supplies a
// score, same principle as grade_quiz_attempt/grade_modeling_submission.
// Gemini (not Claude) because the free tier is the only one available for
// this project's budget -- same fixed-rubric JSON-output approach either
// way, so swapping providers later needs no schema/RLS changes.
//
// The rubric prompt is deliberately framed as self-practice feedback (STAR
// structure, clarity, filler-word count), never "pass/fail" or "you failed"
// language -- the AI coach is positioned as a rehearsal tool, not a
// gatekeeper (see .lavish/finesse-plan.html "AI Interview Prep"). Output is
// constrained to structured JSON, not free prose, so the frontend can
// render it as scores/tips rather than parsing prose.
//
// Runs as the calling student (forwarded JWT) to look up the session under
// normal RLS -- a student can only ever score their own session, since
// interview_sessions has no select policy that would expose someone else's
// row. The rubric_scores UPDATE and xp_events INSERT then use the
// service_role key, because there is deliberately no self-update/self-insert
// policy for those (see migrations 005/020) -- this function is the only
// place allowed to write them.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { getCorsHeaders } from "../_shared/cors.ts";

const GEMINI_MODEL = "gemini-flash-latest";

const RUBRIC_SYSTEM_PROMPT = `You are a supportive interview-practice coach helping a student rehearse for a finance internship interview. This is self-practice, not a real interview and not a pass/fail evaluation -- frame all feedback as coaching for next time, never as "you failed" or a verdict on the student's worth. Be specific and encouraging.

Score the transcript against this rubric and respond with ONLY a JSON object (no prose, no markdown fences) matching exactly this shape:
{
  "star_structure": {"score": <0-10>, "feedback": "<1-2 sentences>"},
  "clarity": {"score": <0-10>, "feedback": "<1-2 sentences>"},
  "filler_word_count": <integer count of filler words like "um", "uh", "like", "you know">,
  "overall_feedback": "<2-3 sentences of encouraging, practice-oriented coaching>"
}`;

interface RubricScores {
  star_structure: { score: number; feedback: string };
  clarity: { score: number; feedback: string };
  filler_word_count: number;
  overall_feedback: string;
}

function jsonResponse(
  body: unknown,
  status: number,
  corsHeaders: Record<string, string>,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

class ScoringError extends Error {}

async function scoreTranscript(
  apiKey: string,
  questionText: string,
  transcript: string,
): Promise<RubricScores> {
  let res: Response;
  try {
    res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: RUBRIC_SYSTEM_PROMPT }] },
          contents: [
            {
              role: "user",
              parts: [
                { text: `Interview question: ${questionText}\n\nStudent's transcript:\n${transcript}` },
              ],
            },
          ],
          generationConfig: { responseMimeType: "application/json" },
        }),
      },
    );
  } catch (err) {
    console.error("Gemini API request failed", err);
    throw new ScoringError("failed to reach the scoring service");
  }

  if (!res.ok) {
    console.error("Gemini API error", res.status, await res.text());
    throw new ScoringError("the scoring service returned an error");
  }

  const data = await res.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof text !== "string") {
    console.error("Gemini API returned no text content", data);
    throw new ScoringError("the scoring service returned an unexpected response");
  }

  return JSON.parse(text) as RubricScores;
}

Deno.serve(async (req) => {
  const corsHeaders = getCorsHeaders(req.headers.get("origin"));

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "missing Authorization header" }, 401, corsHeaders);
    }

    const { session_id } = await req.json();
    if (typeof session_id !== "string") {
      return jsonResponse({ error: "session_id is required" }, 400, corsHeaders);
    }

    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiApiKey) {
      return jsonResponse({ error: "GEMINI_API_KEY is not configured" }, 500, corsHeaders);
    }

    const callerClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const {
      data: { user },
      error: userError,
    } = await callerClient.auth.getUser();

    if (userError || !user) {
      return jsonResponse({ error: "invalid session" }, 401, corsHeaders);
    }

    // Read the session as the caller so RLS confirms ownership (or linked
    // parenthood) before anything is scored.
    const { data: session, error: sessionError } = await callerClient
      .from("interview_sessions")
      .select("id, profile_id, transcript, question_id, rubric_scores")
      .eq("id", session_id)
      .single();

    if (sessionError || !session) {
      return jsonResponse({ error: "session not found" }, 404, corsHeaders);
    }

    if (session.profile_id !== user.id) {
      return jsonResponse({ error: "only the student who submitted a session can score it" }, 403, corsHeaders);
    }

    // Idempotency guard (security audit Finding 2): a session already scored
    // shouldn't be re-sent to Gemini or awarded xp_events a second time.
    if (session.rubric_scores) {
      return jsonResponse({ session_id, rubric_scores: session.rubric_scores }, 200, corsHeaders);
    }

    const { data: question, error: questionError } = await callerClient
      .from("interview_questions")
      .select("question_text")
      .eq("id", session.question_id)
      .single();

    if (questionError || !question) {
      return jsonResponse({ error: "interview question not found" }, 404, corsHeaders);
    }

    const rubricScores = await scoreTranscript(geminiApiKey, question.question_text, session.transcript);

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Conditional on rubric_scores still being null so this update itself is
    // the idempotency gate, not the earlier read above: if a concurrent call
    // already scored this session, this update affects zero rows and we
    // return its result instead of double-awarding xp_events.
    const { data: updatedRows, error: updateError } = await admin
      .from("interview_sessions")
      .update({ rubric_scores: rubricScores, updated_at: new Date().toISOString() })
      .eq("id", session_id)
      .is("rubric_scores", null)
      .select("rubric_scores");

    if (updateError) {
      return jsonResponse({ error: updateError.message }, 400, corsHeaders);
    }

    if (!updatedRows || updatedRows.length === 0) {
      const { data: existing, error: existingError } = await admin
        .from("interview_sessions")
        .select("rubric_scores")
        .eq("id", session_id)
        .single();

      if (existingError || !existing) {
        return jsonResponse({ error: "session not found" }, 404, corsHeaders);
      }

      return jsonResponse({ session_id, rubric_scores: existing.rubric_scores }, 200, corsHeaders);
    }

    const { error: xpError } = await admin.from("xp_events").insert({
      profile_id: session.profile_id,
      source: "interview_session",
      source_id: session_id,
      xp_delta: 10,
    });

    if (xpError) {
      return jsonResponse({ error: xpError.message }, 400, corsHeaders);
    }

    // Best-effort: a badge-award failure shouldn't fail a scoring request
    // that already succeeded and already recorded xp_events.
    const { error: badgeError } = await admin.rpc("award_badge", {
      p_profile_id: session.profile_id,
      p_criteria_type: "first_mock_interview",
    });

    if (badgeError) {
      console.error("Failed to award first-mock-interview badge", badgeError);
    }

    return jsonResponse({ session_id, rubric_scores: rubricScores }, 200, corsHeaders);
  } catch (err) {
    if (err instanceof ScoringError) {
      return jsonResponse({ error: err.message }, 502, corsHeaders);
    }
    console.error("Unexpected error scoring interview session", err);
    return jsonResponse({ error: "internal server error" }, 500, corsHeaders);
  }
});
