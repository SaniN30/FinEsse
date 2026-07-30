import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { SkillDashboard } from "@/components/school/SkillDashboard";

vi.mock("@/lib/supabase/auth-context", () => ({
  useAuth: () => ({
    profile: { id: "student-1", role: "student", parent_id: "parent-1", tier: "school", display_name: null },
    loading: false,
  }),
}));

vi.mock("@/lib/school/queries", () => ({
  fetchSkillsWithMastery: vi.fn().mockResolvedValue([
    {
      id: "skill-1",
      tier: "school",
      slug: "earning-pocket-money",
      title: "Earning Pocket Money",
      prerequisite_skill_id: null,
      mastery_threshold: 0.8,
      rollingAccuracy: 0.9,
      attemptsConsidered: 5,
      isUnlocked: true,
    },
    {
      id: "skill-2",
      tier: "school",
      slug: "saving-basics",
      title: "Saving Basics",
      prerequisite_skill_id: "skill-1",
      mastery_threshold: 0.8,
      rollingAccuracy: null,
      attemptsConsidered: 0,
      isUnlocked: false,
    },
  ]),
  fetchTotalXp: vi.fn().mockResolvedValue(120),
}));

describe("SkillDashboard", () => {
  it("shows unlocked skills as links and locked skills as non-interactive", async () => {
    render(<SkillDashboard />);

    expect(await screen.findByText("Earning Pocket Money")).toBeInTheDocument();
    expect(screen.getByText("Saving Basics")).toBeInTheDocument();
    expect(screen.getByText(/Total XP/)).toBeInTheDocument();
    expect(screen.getByText("120")).toBeInTheDocument();

    const unlockedLink = screen.getByRole("link", { name: /Earning Pocket Money/ });
    expect(unlockedLink).toHaveAttribute("href", "/school/skills/skill-1");

    expect(
      screen.queryByRole("link", { name: /Saving Basics/ }),
    ).not.toBeInTheDocument();
    expect(screen.getByText(/Locked/)).toBeInTheDocument();
  });
});
