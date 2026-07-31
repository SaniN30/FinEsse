import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

const pushMock = vi.fn();
const replaceMock = vi.fn();

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: pushMock, replace: replaceMock }),
  useSearchParams: () => new URLSearchParams("consent_id=consent-123&name=Robin"),
}));

vi.mock("@/lib/supabase/auth-context", () => ({
  useAuth: () => ({
    session: { user: { id: "parent-1" } },
    profile: { id: "parent-1", role: "parent", parent_id: null, tier: null, display_name: "Jamie" },
    loading: false,
    refreshProfile: vi.fn(),
    signOut: vi.fn(),
  }),
}));

const createStudentAccountMock = vi.fn();
vi.mock("@/lib/supabase/auth-actions", () => ({
  createStudentAccount: (...args: unknown[]) => createStudentAccountMock(...args),
}));

vi.mock("@/lib/supabase/student-registry", () => ({
  rememberStudent: vi.fn(),
}));

import CreateStudentPage from "@/app/create-student/page";

async function fillPin(user: ReturnType<typeof userEvent.setup>, label: string, digits: string) {
  const allDigitBoxes = screen.getAllByLabelText(/PIN digit/) as HTMLInputElement[];
  const targetBoxes = label === "Choose a PIN" ? allDigitBoxes.slice(0, 6) : allDigitBoxes.slice(6, 12);
  for (let i = 0; i < digits.length; i += 1) {
    await user.type(targetBoxes[i], digits[i]);
  }
}

describe("CreateStudentPage", () => {
  beforeEach(() => {
    pushMock.mockClear();
    createStudentAccountMock.mockReset();
  });

  it("rejects a PIN shorter than 6 digits", async () => {
    const user = userEvent.setup();
    render(<CreateStudentPage />);

    await fillPin(user, "Choose a PIN", "1234");
    await fillPin(user, "Confirm PIN", "1234");
    await user.click(screen.getByRole("button", { name: /create account/i }));

    expect(await screen.findByText(/PIN must be 6 digits/i)).toBeInTheDocument();
    expect(createStudentAccountMock).not.toHaveBeenCalled();
  });

  it("accepts a 6-digit PIN and submits", async () => {
    createStudentAccountMock.mockResolvedValue({
      data: { student_id: "student-1", login_email: "robin@internal.finesse" },
      error: null,
    });
    const user = userEvent.setup();
    render(<CreateStudentPage />);

    await fillPin(user, "Choose a PIN", "123456");
    await fillPin(user, "Confirm PIN", "123456");
    await user.click(screen.getByRole("button", { name: /create account/i }));

    expect(await screen.findByText(/account is ready/i)).toBeInTheDocument();
    expect(createStudentAccountMock).toHaveBeenCalledWith(
      expect.objectContaining({ consentId: "consent-123", pin: "123456" }),
    );
  });
});
