import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import type { PracticeQuestion } from "@/lib/supabase/types";

const mcQuestion: PracticeQuestion = {
  id: "pq-mc-1",
  source: "quiz",
  question: "Which metric best measures short-term liquidity?",
  options: ["Current ratio", "ROE", "EPS"],
  question_type: "multiple_choice",
  difficulty: "medium",
  tier: "college",
  is_case_study: false,
  scenario_context: null,
  topic_slug: "ratio-analysis",
  topic_title: "Ratio Analysis",
  ref_id: "qq-1",
};

describe("PracticeQuestionCard", () => {
  it("submits an answer, calls grade_practice_attempt, and shows instant scoring feedback", async () => {
    const gradePracticeAttempt = vi.fn().mockResolvedValue({ is_correct: true });
    vi.resetModules();
    vi.doMock("@/lib/practice/queries", () => ({ gradePracticeAttempt }));

    const { PracticeQuestionCard } = await import("@/components/practice/PracticeQuestionCard");
    render(<PracticeQuestionCard question={mcQuestion} />);

    fireEvent.click(screen.getByText("Current ratio"));
    fireEvent.click(screen.getByText("Check answer"));

    expect(await screen.findByText("Correct!")).toBeInTheDocument();
    expect(gradePracticeAttempt).toHaveBeenCalledWith("pq-mc-1", "Current ratio");
    expect(gradePracticeAttempt).toHaveBeenCalledTimes(1);

    vi.doUnmock("@/lib/practice/queries");
  });

  it("shows incorrect feedback and allows retrying without re-submitting automatically", async () => {
    const gradePracticeAttempt = vi.fn().mockResolvedValue({ is_correct: false });
    vi.resetModules();
    vi.doMock("@/lib/practice/queries", () => ({ gradePracticeAttempt }));

    const { PracticeQuestionCard } = await import("@/components/practice/PracticeQuestionCard");
    render(<PracticeQuestionCard question={mcQuestion} />);

    fireEvent.click(screen.getByText("ROE"));
    fireEvent.click(screen.getByText("Check answer"));

    expect(await screen.findByText("Not quite -- give it another look.")).toBeInTheDocument();

    fireEvent.click(screen.getByText("Try another attempt"));
    expect(screen.getByText("Check answer")).toBeDisabled();
    expect(gradePracticeAttempt).toHaveBeenCalledTimes(1);

    vi.doUnmock("@/lib/practice/queries");
  });
});
