import { formatUsdCents } from "@/lib/currency/format";
import type { AccountBalance } from "@/lib/supabase/types";

interface WalletBalanceProps {
  accounts: AccountBalance[];
  currency: string | null;
}

export function WalletBalance({ accounts, currency }: WalletBalanceProps) {
  const wallet = accounts.find((account) => account.type === "student_wallet");
  const balanceCents = wallet?.balance_cents ?? 0;
  const isNegative = balanceCents < 0;

  return (
    <div className="mb-8 rounded-[var(--radius-card)] border border-surface-border bg-surface px-6 py-5 shadow-soft">
      <p className="text-sm font-medium text-muted-foreground">Wallet balance</p>
      <p
        className={`mt-1 text-5xl font-semibold tabular-nums tracking-tight sm:text-6xl ${
          isNegative ? "text-red-600" : ""
        }`}
      >
        {formatUsdCents(balanceCents, currency)}
      </p>
      {isNegative ? (
        <p className="mt-2 text-sm text-red-600">
          This balance is unexpectedly negative -- contact support.
        </p>
      ) : null}
    </div>
  );
}
