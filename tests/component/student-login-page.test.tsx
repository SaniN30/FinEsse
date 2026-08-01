import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

const replaceMock = vi.fn();

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: replaceMock }),
}));

const signInStudentMock = vi.fn();
vi.mock("@/lib/supabase/auth-actions", () => ({
  signInStudent: (...args: unknown[]) => signInStudentMock(...args),
}));

vi.mock("@/lib/supabase/student-registry", () => ({
  listKnownStudents: () => [
    { studentId: "student-1", displayName: "Robin", loginEmail: "robin@students.finesse.app" },
  ],
}));

let mockProfile: { role: string; tier: string | null } | null = null;
const refreshProfileMock = vi.fn(async () => {
  mockProfile = { role: "student", tier: "college" };
});
vi.mock("@/lib/supabase/auth-context", () => ({
  useAuth: () => ({
    profile: mockProfile,
    refreshProfile: refreshProfileMock,
  }),
}));

import StudentLoginPage from "@/app/student-login/page";

describe("StudentLoginPage", () => {
  beforeEach(() => {
    replaceMock.mockClear();
    signInStudentMock.mockReset();
    refreshProfileMock.mockClear();
    mockProfile = null;
  });

  it("redirects to the student's own tier path after a successful login instead of dead-ending", async () => {
    signInStudentMock.mockResolvedValue({ error: null });
    const user = userEvent.setup();

    const { rerender } = render(<StudentLoginPage />);

    await user.click(screen.getByRole("button", { name: /robin/i }));
    const digitBoxes = screen.getAllByLabelText(/PIN digit/) as HTMLInputElement[];
    const digits = "123456";
    for (let i = 0; i < digits.length; i += 1) {
      await user.type(digitBoxes[i], digits[i]);
    }
    await user.click(screen.getByRole("button", { name: /log in/i }));

    expect(await screen.findByText(/taking you to your lessons/i)).toBeInTheDocument();

    // Simulate the profile arriving asynchronously via AuthProvider, as it would in the app.
    rerender(<StudentLoginPage />);

    expect(replaceMock).toHaveBeenCalledWith("/college");
  });
});
