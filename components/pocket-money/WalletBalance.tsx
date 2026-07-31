import type { AccountBalance } from "@/lib/supabase/types";

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

export function WalletBalance({ accounts }: { accounts: AccountBalance[] }) {
  const wallet = accounts.find((account) => account.type === "student_wallet");

  return (
    <div className="mb-8 rounded-[var(--radius-card)] border border-surface-border bg-surface px-6 py-5 shadow-soft">
      <p className="text-sm font-medium text-neutral-500">Wallet balance</p>
      <p className="mt-1 text-5xl font-semibold tabular-nums tracking-tight sm:text-6xl">
        {formatCents(wallet?.balance_cents ?? 0)}
      </p>
    </div>
  );
}
