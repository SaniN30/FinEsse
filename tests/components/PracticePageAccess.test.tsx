import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

vi.mock("@/components/Nav", () => ({ Nav: () => <nav /> }));
vi.mock("@/components/practice/PracticeFilters", () => ({
  PracticeFilters: () => <div data-testid="practice-filters" />,
}));
vi.mock("@/components/practice/PracticeList", () => ({
  PracticeList: () => <div data-testid="practice-list" />,
}));
vi.mock("@/components/practice/InterviewPracticeList", () => ({
  InterviewPracticeList: () => <div data-testid="interview-practice-list" />,
}));

describe("PracticePage access", () => {
  it("prompts a generic sign-in when there is no session", async () => {
    vi.resetModules();
    vi.doMock("@/lib/supabase/auth-context", () => ({
      useAuth: () => ({ session: null, profile: null, loading: false }),
    }));

    const { default: PracticePage } = await import("@/app/practice/page");
    render(<PracticePage />);

    expect(screen.getByText("Sign in to start practicing.")).toBeInTheDocument();
    expect(screen.queryByTestId("practice-list")).not.toBeInTheDocument();

    vi.doUnmock("@/lib/supabase/auth-context");
  });

  it("opens practice to a signed-in parent/working_professional account (previously blocked)", async () => {
    vi.resetModules();
    vi.doMock("@/lib/supabase/auth-context", () => ({
      useAuth: () => ({
        session: { user: { id: "parent-1" } },
        profile: { id: "parent-1", role: "parent", education_level: "working_professional", tier: "school" },
        loading: false,
      }),
    }));

    const { default: PracticePage } = await import("@/app/practice/page");
    render(<PracticePage />);

    expect(screen.queryByText(/sign in as a student/i)).not.toBeInTheDocument();
    expect(screen.getByTestId("practice-filters")).toBeInTheDocument();
    expect(screen.getByTestId("practice-list")).toBeInTheDocument();

    vi.doUnmock("@/lib/supabase/auth-context");
  });

  it("still opens practice for a real student account", async () => {
    vi.resetModules();
    vi.doMock("@/lib/supabase/auth-context", () => ({
      useAuth: () => ({
        session: { user: { id: "student-1" } },
        profile: { id: "student-1", role: "student", tier: "college" },
        loading: false,
      }),
    }));

    const { default: PracticePage } = await import("@/app/practice/page");
    render(<PracticePage />);

    expect(screen.getByTestId("practice-filters")).toBeInTheDocument();
    expect(screen.getByTestId("practice-list")).toBeInTheDocument();

    vi.doUnmock("@/lib/supabase/auth-context");
  });
});
