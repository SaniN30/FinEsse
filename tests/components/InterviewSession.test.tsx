import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { InterviewSession } from "@/components/interview-coach/InterviewSession";

const { submitAndScoreInterviewSession } = vi.hoisted(() => ({
  submitAndScoreInterviewSession: vi.fn().mockResolvedValue({
    session_id: "s-1",
    rubric_scores: {
      star_structure: { score: 8, feedback: "Clear structure." },
      clarity: { score: 6, feedback: "Mostly clear." },
      filler_word_count: 3,
      overall_feedback: "Good practice run, keep it up.",
    },
  }),
}));

vi.mock("@/lib/interview-coach/queries", () => ({
  fetchInterviewQuestion: vi.fn().mockResolvedValue({
    id: "q-1",
    firm_style: "Goldman Sachs",
    question_text: "Tell me about a time you led a team.",
    category: "behavioral" as const,
    published: true,
  }),
  submitAndScoreInterviewSession,
}));

describe("InterviewSession", () => {
  it("only shows the transcript input while answering, then reveals every sub-score together at once", async () => {
    render(<InterviewSession questionId="q-1" />);

    expect(await screen.findByText("Tell me about a time you led a team.")).toBeInTheDocument();
    expect(screen.queryByText(/Your practice score/)).not.toBeInTheDocument();

    fireEvent.change(screen.getByPlaceholderText(/Type or paste your answer transcript/), {
      target: { value: "My answer transcript." },
    });
    fireEvent.click(screen.getByRole("button", { name: /Submit for scoring/ }));

    await waitFor(() => expect(submitAndScoreInterviewSession).toHaveBeenCalledWith("q-1", "My answer transcript."));

    expect(await screen.findByText("Your practice score")).toBeInTheDocument();
    expect(screen.getByText("7/10")).toBeInTheDocument();
    expect(screen.getByText("STAR structure")).toBeInTheDocument();
    expect(screen.getByText("Clarity")).toBeInTheDocument();
    expect(screen.getByText("Filler words")).toBeInTheDocument();
    expect(screen.queryByPlaceholderText(/Type or paste your answer transcript/)).not.toBeInTheDocument();
  });
});
