import { getSupabaseClient } from "@/lib/supabase/client";
import type {
  InterviewQuestion,
  InterviewSession,
  ScoreInterviewSessionResult,
} from "@/lib/supabase/types";

export async function fetchInterviewQuestions(): Promise<InterviewQuestion[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("interview_questions")
    .select("id, firm_style, question_text, category, published, difficulty, improvement_guide")
    .eq("published", true)
    .order("firm_style", { ascending: true });

  if (error) throw error;
  return (data ?? []) as InterviewQuestion[];
}

export async function fetchInterviewQuestion(questionId: string): Promise<InterviewQuestion> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("interview_questions")
    .select("id, firm_style, question_text, category, published, difficulty, improvement_guide")
    .eq("id", questionId)
    .single();

  if (error) throw error;
  return data as InterviewQuestion;
}

export async function fetchInterviewSessions(profileId: string): Promise<InterviewSession[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("interview_sessions")
    .select("id, profile_id, question_id, firm_style, transcript, rubric_scores, created_at")
    .eq("profile_id", profileId)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return (data ?? []) as InterviewSession[];
}

/** Submits the transcript, then scores it via the score-interview-session Edge Function -- one synchronous round trip, no streaming. */
export async function submitAndScoreInterviewSession(
  questionId: string,
  transcript: string,
): Promise<ScoreInterviewSessionResult> {
  const supabase = getSupabaseClient();

  const { data: sessionId, error: submitError } = await supabase.rpc("submit_interview_session", {
    p_question_id: questionId,
    p_transcript: transcript,
  });

  if (submitError) throw submitError;

  const { data, error: scoreError } = await supabase.functions.invoke<ScoreInterviewSessionResult>(
    "score-interview-session",
    { body: { session_id: sessionId } },
  );

  if (scoreError) throw scoreError;
  if (!data) throw new Error("scoring returned no result");

  return data;
}
