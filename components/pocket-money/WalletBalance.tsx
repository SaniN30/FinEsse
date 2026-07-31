import type { AccountBalance } from "@/lib/supabase/types";

/**
 * Deposits can no longer drive the wallet negative (see
 * deposit_to_savings_goal's balance check in
 * supabase/migrations/00000000000024_pocket_money_funding.sql), but this
 * stays defensive in case a dev/test database still has historical
 * corrupted data -- a negative balance should render as an unmistakable
 * "owed" state, never a confusing plain dollar amount.
 */
function formatCents(cents: number): string {
  const isNegative = cents < 0;
  const amount = `$${(Math.abs(cents) / 100).toFixed(2)}`;
  return isNegative ? `-${amount}` : amount;
}

export function WalletBalance({ accounts }: { accounts: AccountBalance[] }) {
  const wallet = accounts.find((account) => account.type === "student_wallet");
  const balanceCents = wallet?.balance_cents ?? 0;
  const isNegative = balanceCents < 0;

  return (
    <div className="mb-8 rounded-[var(--radius-card)] border border-surface-border bg-surface px-6 py-5 shadow-soft">
      <p className="text-sm font-medium text-neutral-500">Wallet balance</p>
      <p
        className={`mt-1 text-5xl font-semibold tabular-nums tracking-tight sm:text-6xl ${
          isNegative ? "text-red-600" : ""
        }`}
      >
        {formatCents(balanceCents)}
      </p>
      {isNegative ? (
        <p className="mt-2 text-sm text-red-600">
          This balance is unexpectedly negative -- contact support.
        </p>
      ) : null}
    </div>
  );
}
