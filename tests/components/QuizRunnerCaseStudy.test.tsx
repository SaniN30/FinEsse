import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

function mockSupabaseForCaseStudy() {
  return {
    from: (table: string) => {
      if (table === "quiz_questions_public") {
        return {
          select: () => ({
            eq: () => ({
              order: () =>
                Promise.resolve({
                  data: [
                    {
                      id: "q-mc",
                      quiz_id: "quiz-case-1",
                      question: "Which metric best measures short-term liquidity?",
                      options: ["Current ratio", "ROE", "EPS"],
                      order_index: 0,
                      difficulty: "medium",
                      question_type: "multiple_choice",
                    },
                    {
                      id: "q-fr",
                      quiz_id: "quiz-case-1",
                      question: "Explain how you would prioritize this client's request.",
                      options: null,
                      order_index: 1,
                      difficulty: "hard",
                      question_type: "free_response",
                    },
                  ],
                  error: null,
                }),
            }),
          }),
        };
      }
      return {
        select: () => ({
          eq: () => ({
            maybeSingle: () =>
              Promise.resolve({
                data: {
                  skill_id: "skill-case",
                  quiz_type: "case_study",
                  scenario_body: "A mid-size retailer is evaluating a new credit line.",
                  context_tag: "Credit Risk Case",
                },
              }),
          }),
        }),
      };
    },
  };
}

describe("QuizRunner case study rendering", () => {
  it("shows the scenario banner, difficulty labels, and a free-response textarea", async () => {
    vi.resetModules();
    vi.doMock("@/lib/supabase/client", () => ({
      getSupabaseClient: () => mockSupabaseForCaseStudy(),
    }));
    const { QuizRunner } = await import("@/components/quiz/QuizRunner");
    render(<QuizRunner quizId="quiz-case-1" tier="job_ready" />);

    expect(await screen.findByText("Credit Risk Case")).toBeInTheDocument();
    expect(
      screen.getByText("A mid-size retailer is evaluating a new credit line."),
    ).toBeInTheDocument();

    expect(screen.getByText("Medium")).toBeInTheDocument();
    expect(screen.getByText("Hard")).toBeInTheDocument();

    expect(
      screen.getByPlaceholderText("Type your answer…"),
    ).toBeInTheDocument();
    expect(screen.getByText("Current ratio")).toBeInTheDocument();

    vi.doUnmock("@/lib/supabase/client");
  });
});
