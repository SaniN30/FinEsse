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

async function fillCommonFields(user: ReturnType<typeof userEvent.setup>) {
  await user.type(screen.getByLabelText("Your name"), "Jamie Parent");
  await user.type(screen.getByLabelText("Email"), "jamie@example.com");
  await user.type(screen.getByLabelText("Password"), "hunter2pass");
  await user.type(screen.getByLabelText("Date of birth"), "1985-04-12");
  await user.selectOptions(screen.getByLabelText("Education level"), "college");
  await user.type(screen.getByLabelText("School or university"), "State University");
  await user.type(screen.getByLabelText("Phone number"), "+15551234567");
}

describe("SignUpPage", () => {
  beforeEach(() => {
    pushMock.mockClear();
    signUpParentMock.mockReset();
  });

  it("submits college signup details and redirects directly to college content (no parent/child flow)", async () => {
    signUpParentMock.mockResolvedValue({
      data: { userId: "parent-1", needsEmailConfirmation: false },
      error: null,
    });
    const user = userEvent.setup();
    render(<SignUpPage />);

    await fillCommonFields(user);
    await user.click(screen.getByRole("button", { name: /sign up/i }));

    expect(signUpParentMock).toHaveBeenCalledWith({
      email: "jamie@example.com",
      password: "hunter2pass",
      displayName: "Jamie Parent",
      dateOfBirth: "1985-04-12",
      educationLevel: "college",
      institutionName: "State University",
      phoneNumber: "+15551234567",
    });
    expect(pushMock).toHaveBeenCalledWith("/college");
  });

  it("redirects working_professional signups to consent (parent/child flow)", async () => {
    signUpParentMock.mockResolvedValue({
      data: { userId: "parent-1", needsEmailConfirmation: false },
      error: null,
    });
    const user = userEvent.setup();
    render(<SignUpPage />);

    await user.type(screen.getByLabelText("Your name"), "Jamie Parent");
    await user.type(screen.getByLabelText("Email"), "jamie@example.com");
    await user.type(screen.getByLabelText("Password"), "hunter2pass");
    await user.type(screen.getByLabelText("Date of birth"), "1985-04-12");
    await user.selectOptions(screen.getByLabelText("Education level"), "working_professional");
    await user.type(screen.getByLabelText("Phone number"), "+15551234567");
    await user.click(screen.getByRole("button", { name: /sign up/i }));

    expect(signUpParentMock).toHaveBeenCalledWith(
      expect.objectContaining({ educationLevel: "working_professional", institutionName: null }),
    );
    expect(pushMock).toHaveBeenCalledWith("/consent");
  });

  it("redirects school signups directly to school content (no parent/child flow)", async () => {
    signUpParentMock.mockResolvedValue({
      data: { userId: "parent-1", needsEmailConfirmation: false },
      error: null,
    });
    const user = userEvent.setup();
    render(<SignUpPage />);

    await user.type(screen.getByLabelText("Your name"), "Jamie Parent");
    await user.type(screen.getByLabelText("Email"), "jamie@example.com");
    await user.type(screen.getByLabelText("Password"), "hunter2pass");
    await user.type(screen.getByLabelText("Date of birth"), "1985-04-12");
    await user.selectOptions(screen.getByLabelText("Education level"), "school");
    await user.type(screen.getByLabelText("School or university"), "Riverside High");
    await user.type(screen.getByLabelText("Phone number"), "+15551234567");
    await user.click(screen.getByRole("button", { name: /sign up/i }));

    expect(signUpParentMock).toHaveBeenCalledWith(
      expect.objectContaining({ educationLevel: "school" }),
    );
    expect(pushMock).toHaveBeenCalledWith("/school");
  });

  it("rejects an invalid phone number before calling signUpParent", async () => {
    const user = userEvent.setup();
    render(<SignUpPage />);

    await user.type(screen.getByLabelText("Your name"), "Jamie Parent");
    await user.type(screen.getByLabelText("Email"), "jamie@example.com");
    await user.type(screen.getByLabelText("Password"), "hunter2pass");
    await user.type(screen.getByLabelText("Date of birth"), "1985-04-12");
    await user.selectOptions(screen.getByLabelText("Education level"), "college");
    await user.type(screen.getByLabelText("School or university"), "State University");
    await user.type(screen.getByLabelText("Phone number"), "not-a-phone");
    await user.click(screen.getByRole("button", { name: /sign up/i }));

    expect(await screen.findByText(/valid phone number/i)).toBeInTheDocument();
    expect(signUpParentMock).not.toHaveBeenCalled();
  });

  it("shows a confirmation message instead of redirecting when email confirmation is required", async () => {
    signUpParentMock.mockResolvedValue({
      data: { userId: "parent-1", needsEmailConfirmation: true },
      error: null,
    });
    const user = userEvent.setup();
    render(<SignUpPage />);

    await fillCommonFields(user);
    await user.click(screen.getByRole("button", { name: /sign up/i }));

    expect(pushMock).not.toHaveBeenCalled();
    expect(await screen.findByText(/confirm your email/i)).toBeInTheDocument();
  });

  it("shows an error message when sign-up fails", async () => {
    signUpParentMock.mockResolvedValue({ data: null, error: "Email already registered" });
    const user = userEvent.setup();
    render(<SignUpPage />);

    await fillCommonFields(user);
    await user.click(screen.getByRole("button", { name: /sign up/i }));

    expect(await screen.findByText("Email already registered")).toBeInTheDocument();
    expect(pushMock).not.toHaveBeenCalled();
  });

  it("shows a duplicate phone number error returned from signUpParent", async () => {
    signUpParentMock.mockResolvedValue({
      data: null,
      error: "An account with this phone number already exists.",
    });
    const user = userEvent.setup();
    render(<SignUpPage />);

    await fillCommonFields(user);
    await user.click(screen.getByRole("button", { name: /sign up/i }));

    expect(
      await screen.findByText("An account with this phone number already exists."),
    ).toBeInTheDocument();
    expect(pushMock).not.toHaveBeenCalled();
  });
});
