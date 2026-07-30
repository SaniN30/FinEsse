import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

const pushMock = vi.fn();

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: pushMock, replace: vi.fn() }),
}));

vi.mock("@/lib/supabase/auth-context", () => ({
  useAuth: () => ({
    session: null,
    profile: null,
    loading: false,
    refreshProfile: vi.fn(),
    signOut: vi.fn(),
  }),
}));

const signUpParentMock = vi.fn();
vi.mock("@/lib/supabase/auth-actions", () => ({
  signUpParent: (...args: unknown[]) => signUpParentMock(...args),
}));

import SignUpPage from "@/app/signup/page";

describe("SignUpPage", () => {
  beforeEach(() => {
    pushMock.mockClear();
    signUpParentMock.mockReset();
  });

  it("submits parent details and redirects to consent on immediate session", async () => {
    signUpParentMock.mockResolvedValue({
      data: { userId: "parent-1", needsEmailConfirmation: false },
      error: null,
    });
    const user = userEvent.setup();
    render(<SignUpPage />);

    await user.type(screen.getByLabelText("Your name"), "Jamie Parent");
    await user.type(screen.getByLabelText("Email"), "jamie@example.com");
    await user.type(screen.getByLabelText("Password"), "hunter2pass");
    await user.click(screen.getByRole("button", { name: /sign up/i }));

    expect(signUpParentMock).toHaveBeenCalledWith(
      "jamie@example.com",
      "hunter2pass",
      "Jamie Parent",
    );
    expect(pushMock).toHaveBeenCalledWith("/consent");
  });

  it("shows a confirmation message instead of redirecting when email confirmation is required", async () => {
    signUpParentMock.mockResolvedValue({
      data: { userId: "parent-1", needsEmailConfirmation: true },
      error: null,
    });
    const user = userEvent.setup();
    render(<SignUpPage />);

    await user.type(screen.getByLabelText("Your name"), "Jamie Parent");
    await user.type(screen.getByLabelText("Email"), "jamie@example.com");
    await user.type(screen.getByLabelText("Password"), "hunter2pass");
    await user.click(screen.getByRole("button", { name: /sign up/i }));

    expect(pushMock).not.toHaveBeenCalled();
    expect(await screen.findByText(/confirm your email/i)).toBeInTheDocument();
  });

  it("shows an error message when sign-up fails", async () => {
    signUpParentMock.mockResolvedValue({ data: null, error: "Email already registered" });
    const user = userEvent.setup();
    render(<SignUpPage />);

    await user.type(screen.getByLabelText("Your name"), "Jamie Parent");
    await user.type(screen.getByLabelText("Email"), "jamie@example.com");
    await user.type(screen.getByLabelText("Password"), "hunter2pass");
    await user.click(screen.getByRole("button", { name: /sign up/i }));

    expect(await screen.findByText("Email already registered")).toBeInTheDocument();
    expect(pushMock).not.toHaveBeenCalled();
  });
});
