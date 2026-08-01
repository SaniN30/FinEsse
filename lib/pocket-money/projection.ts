export interface ProjectionInput {
  balanceCents: number;
  targetAmountCents: number;
  contributionCents: number;
  frequencyWeeks: number;
}

export interface ProjectionPoint {
  week: number;
  balanceCents: number;
}

export interface ProjectionResult {
  weeksToGoal: number | null;
  projectedDate: Date | null;
  timeline: ProjectionPoint[];
}

const MAX_PROJECTION_WEEKS = 260;

/**
 * Pure function so the calculator can preview "what if I saved $X every N
 * weeks" without writing anything to the ledger -- only an explicit
 * deposit/withdraw call (GoalTransferForm) ever touches real balances.
 */
export function projectSavingsGoal({
  balanceCents,
  targetAmountCents,
  contributionCents,
  frequencyWeeks,
}: ProjectionInput): ProjectionResult {
  const timeline: ProjectionPoint[] = [{ week: 0, balanceCents }];

  if (balanceCents >= targetAmountCents) {
    return { weeksToGoal: 0, projectedDate: new Date(), timeline };
  }

  if (contributionCents <= 0 || frequencyWeeks <= 0) {
    return { weeksToGoal: null, projectedDate: null, timeline };
  }

  let balance = balanceCents;
  let week = 0;
  let weeksToGoal: number | null = null;

  while (week < MAX_PROJECTION_WEEKS) {
    week += frequencyWeeks;
    balance += contributionCents;
    timeline.push({ week, balanceCents: balance });

    if (balance >= targetAmountCents && weeksToGoal === null) {
      weeksToGoal = week;
      break;
    }
  }

  const projectedDate =
    weeksToGoal !== null
      ? new Date(Date.now() + weeksToGoal * 7 * 24 * 60 * 60 * 1000)
      : null;

  return { weeksToGoal, projectedDate, timeline };
}
