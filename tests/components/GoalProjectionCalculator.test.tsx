import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import { GoalProjectionCalculator } from "@/components/pocket-money/GoalProjectionCalculator";

afterEach(() => {
  cleanup();
});

describe("GoalProjectionCalculator", () => {
  it("renders nothing when the goal has no target amount", () => {
    const { container } = render(
      <GoalProjectionCalculator goalName="Bike" balanceCents={0} targetAmountCents={null} />,
    );

    expect(container).toBeEmptyDOMElement();
  });

  it("projects a weeks-to-goal estimate from the default $5/week inputs", () => {
    render(
      <GoalProjectionCalculator goalName="Bike" balanceCents={0} targetAmountCents={2000} />,
    );

    // Default inputs are $5.00 every 1 week -> 4 weeks to reach $20.00.
    expect(screen.getByText("4")).toBeInTheDocument();
    expect(screen.getByText(/You'll hit/)).toBeInTheDocument();
    expect(screen.getByText("$20.00")).toBeInTheDocument();
  });

  it("recomputes the projection live as the user edits contribution and frequency", () => {
    render(
      <GoalProjectionCalculator goalName="Bike" balanceCents={0} targetAmountCents={2000} />,
    );

    const amountInput = screen.getByLabelText("Amount (USD)");
    const frequencyInput = screen.getByLabelText("Every N weeks");

    fireEvent.change(amountInput, { target: { value: "10" } });
    fireEvent.change(frequencyInput, { target: { value: "3" } });

    // $10 every 3 weeks -> 2 payments of $10 -> 6 weeks to reach $20.00.
    expect(screen.getByText("6")).toBeInTheDocument();
  });

  it("tells the user their goal is already reached when balance meets target", () => {
    render(
      <GoalProjectionCalculator goalName="Bike" balanceCents={2500} targetAmountCents={2000} />,
    );

    expect(screen.getByText("You've already reached this goal.")).toBeInTheDocument();
  });

  it("prompts for a contribution when the amount is zero", () => {
    render(
      <GoalProjectionCalculator goalName="Bike" balanceCents={0} targetAmountCents={2000} />,
    );

    fireEvent.change(screen.getByLabelText("Amount (USD)"), { target: { value: "0" } });

    expect(
      screen.getByText("Enter a contribution greater than $0 to project a date."),
    ).toBeInTheDocument();
  });
});
