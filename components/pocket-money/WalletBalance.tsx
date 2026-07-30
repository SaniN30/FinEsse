import type { AccountBalance } from "@/lib/supabase/types";

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

export function WalletBalance({ accounts }: { accounts: AccountBalance[] }) {
  const wallet = accounts.find((account) => account.type === "student_wallet");

  return (
    <div className="mb-8 inline-flex items-center gap-3 rounded-full border border-surface-border bg-surface px-5 py-3 shadow-soft">
      <span className="text-sm font-medium text-neutral-500">Wallet balance</span>
      <span className="text-lg font-semibold">{formatCents(wallet?.balance_cents ?? 0)}</span>
    </div>
  );
}
