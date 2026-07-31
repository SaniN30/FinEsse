import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

function mockSupabaseFor(skillId: string | null) {
  return {
    from: (table: string) => {
      if (table === "quiz_questions_public") {
        return {
          select: () => ({
            eq: () => ({
              order: () =>
                Promise.resolve({
                  data: [
                    { id: "q-1", quiz_id: "quiz-1", question: "2+2?", options: ["3", "4"], order_index: 0 },
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
            maybeSingle: () => Promise.resolve({ data: { skill_id: skillId } }),
          }),
        }),
      };
    },
  };
}

describe("QuizRunner BackLink", () => {
  it("links back to the job-ready lesson when tier is job_ready", async () => {
    vi.resetModules();
    vi.doMock("@/lib/supabase/client", () => ({
      getSupabaseClient: () => mockSupabaseFor("skill-42"),
    }));
    const { QuizRunner: JobReadyQuizRunner } = await import("@/components/quiz/QuizRunner");
    render(<JobReadyQuizRunner quizId="quiz-1" tier="job_ready" />);

    const link = await screen.findByRole("link", { name: /back to lesson/i });
    expect(link).toHaveAttribute("href", "/job-ready/lessons/skill-42");
    vi.doUnmock("@/lib/supabase/client");
  });

  it("links back to the college lesson by default", async () => {
    vi.resetModules();
    vi.doMock("@/lib/supabase/client", () => ({
      getSupabaseClient: () => mockSupabaseFor("skill-7"),
    }));
    const { QuizRunner: CollegeQuizRunner } = await import("@/components/quiz/QuizRunner");
    render(<CollegeQuizRunner quizId="quiz-1" />);

    const link = await screen.findByRole("link", { name: /back to lesson/i });
    expect(link).toHaveAttribute("href", "/college/lessons/skill-7");
    vi.doUnmock("@/lib/supabase/client");
  });
});
