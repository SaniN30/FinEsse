import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { ChildRollupCard } from "@/components/parent-dashboard/ChildRollupCard";
import type { ParentDashboardChild } from "@/lib/supabase/types";

const updateChildTier = vi.fn().mockResolvedValue(undefined);

vi.mock("@/lib/parent-dashboard/queries", () => ({
  updateChildTier: (...args: unknown[]) => updateChildTier(...args),
}));

const child: ParentDashboardChild = {
  profile_id: "student-1",
  parent_id: "parent-1",
  display_name: "Alex",
  tier: "school",
  total_xp: 0,
  avg_mastery_pct: null,
  wallet_balance_cents: 0,
  savings_goals: [],
  interview_sessions: [],
};

describe("ChildRollupCard tier switcher", () => {
  it("lets a parent change a linked student's tier via a select control", async () => {
    const onTierChange = vi.fn();
    render(<ChildRollupCard child={child} onTierChange={onTierChange} />);

    const select = screen.getByLabelText("Tier for Alex") as HTMLSelectElement;
    expect(select.value).toBe("school");

    fireEvent.change(select, { target: { value: "job_ready" } });

    await waitFor(() => expect(updateChildTier).toHaveBeenCalledWith("student-1", "job_ready"));
    await waitFor(() => expect(onTierChange).toHaveBeenCalledWith("student-1", "job_ready"));
  });

  it("surfaces an error message when the tier update fails", async () => {
    updateChildTier.mockRejectedValueOnce(new Error("nope"));
    render(<ChildRollupCard child={child} />);

    const select = screen.getByLabelText("Tier for Alex") as HTMLSelectElement;
    fireEvent.change(select, { target: { value: "college" } });

    expect(await screen.findByText("nope")).toBeInTheDocument();
  });
});
