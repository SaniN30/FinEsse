import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { GoalTransferForm } from "@/components/pocket-money/GoalTransferForm";

vi.mock("@/lib/pocket-money/queries", () => ({
  depositToSavingsGoal: vi.fn(),
  withdrawFromSavingsGoal: vi.fn(),
}));

afterEach(() => {
  cleanup();
});

describe("GoalTransferForm", () => {
  it("renders deposit and withdraw as equally-weighted, unlocked actions", () => {
    render(
      <GoalTransferForm goalAccountId="goal-1" balanceCents={5000} onComplete={() => {}} />,
    );

    const depositTab = screen.getByRole("tab", { name: "Add money" });
    const withdrawTab = screen.getByRole("tab", { name: "Withdraw" });

    expect(depositTab).toBeInTheDocument();
    expect(withdrawTab).toBeInTheDocument();

    // Same element type, same base sizing/shape classes -- neither action
    // should read as more gated or permission-requiring than the other.
    expect(depositTab.tagName).toBe(withdrawTab.tagName);
    expect(depositTab.className).toContain("flex-1");
    expect(withdrawTab.className).toContain("flex-1");
    expect(depositTab.className).toContain("rounded-full");
    expect(withdrawTab.className).toContain("rounded-full");

    const bodyText = document.body.textContent ?? "";
    expect(bodyText.toLowerCase()).not.toContain("approval");
    expect(bodyText.toLowerCase()).not.toContain("ask a parent");
    expect(bodyText.toLowerCase()).not.toContain("permission");
  });

  it("submits the withdraw RPC without any extra confirmation step", async () => {
    const { withdrawFromSavingsGoal } = await import("@/lib/pocket-money/queries");
    const onComplete = vi.fn();
    const { getByRole } = render(
      <GoalTransferForm goalAccountId="goal-1" balanceCents={5000} onComplete={onComplete} />,
    );

    fireEvent.click(getByRole("tab", { name: "Withdraw" }));
    const amountInput = getByRole("spinbutton") as HTMLInputElement;
    fireEvent.change(amountInput, { target: { value: "10" } });

    fireEvent.click(getByRole("button", { name: "Withdraw" }));

    await vi.waitFor(() => expect(withdrawFromSavingsGoal).toHaveBeenCalledWith("goal-1", 1000));
    await vi.waitFor(() => expect(onComplete).toHaveBeenCalled());
  });
});
