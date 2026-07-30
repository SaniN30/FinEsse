import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

const pushMock = vi.fn();
const replaceMock = vi.fn();

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: pushMock, replace: replaceMock }),
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

const recordConsentMock = vi.fn();
vi.mock("@/lib/supabase/auth-actions", () => ({
  recordConsent: (...args: unknown[]) => recordConsentMock(...args),
}));

import ConsentPage from "@/app/consent/page";

describe("ConsentPage", () => {
  beforeEach(() => {
    pushMock.mockClear();
    recordConsentMock.mockReset();
  });

  it("blocks submission until the consent checkbox is explicitly checked", async () => {
    const user = userEvent.setup();
    render(<ConsentPage />);

    await user.type(screen.getByLabelText("Child's display name"), "Robin");
    await user.click(screen.getByRole("button", { name: /give consent/i }));

    expect(recordConsentMock).not.toHaveBeenCalled();
    expect(
      await screen.findByText(/must explicitly confirm consent/i),
    ).toBeInTheDocument();
  });

  it("calls record-consent and navigates to create-student once checked", async () => {
    recordConsentMock.mockResolvedValue({ data: { consent_id: "consent-123" }, error: null });
    const user = userEvent.setup();
    render(<ConsentPage />);

    await user.type(screen.getByLabelText("Child's display name"), "Robin");
    await user.click(screen.getByRole("checkbox"));
    await user.click(screen.getByRole("button", { name: /give consent/i }));

    expect(recordConsentMock).toHaveBeenCalledWith("Robin");
    expect(pushMock).toHaveBeenCalledWith(
      expect.stringContaining("/create-student?consent_id=consent-123"),
    );
  });
});
