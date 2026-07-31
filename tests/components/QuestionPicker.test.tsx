import { render, screen, fireEvent } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { QuestionPicker } from "@/components/interview-coach/QuestionPicker";

vi.mock("@/lib/supabase/auth-context", () => ({
  useAuth: () => ({
    profile: { id: "student-1", role: "student", parent_id: "parent-1", tier: "job_ready", display_name: null },
    loading: false,
  }),
}));

vi.mock("@/lib/interview-coach/queries", () => ({
  fetchInterviewQuestions: vi.fn().mockResolvedValue([
    { id: "q-1", firm_style: "Goldman Sachs", question_text: "Tell me about a time you led a team.", category: "behavioral", published: true },
    { id: "q-2", firm_style: "JPMorgan Chase", question_text: "Walk me through a discounted cash flow.", category: "technical", published: true },
  ]),
  fetchInterviewSessions: vi.fn().mockResolvedValue([
    {
      id: "s-1",
      profile_id: "student-1",
      question_id: "q-1",
      firm_style: "Goldman Sachs",
      transcript: "…",
      rubric_scores: { star_structure: { score: 8, feedback: "Good" }, clarity: { score: 6, feedback: "OK" } },
      created_at: "2026-01-01T00:00:00Z",
    },
  ]),
}));

describe("QuestionPicker", () => {
  it("shows categories as plain-text tabs and recent attempts below", async () => {
    render(<QuestionPicker />);

    expect(await screen.findByText("Tell me about a time you led a team.")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Behavioral" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Technical" })).toBeInTheDocument();

    expect(screen.getByText("Recent attempts")).toBeInTheDocument();
    expect(screen.getByText("7/10")).toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: "Technical" }));
    expect(screen.getByText("Walk me through a discounted cash flow.")).toBeInTheDocument();
    expect(screen.queryByText("Tell me about a time you led a team.")).not.toBeInTheDocument();
  });
});
