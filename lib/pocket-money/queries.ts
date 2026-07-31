import { getSupabaseClient } from "@/lib/supabase/client";
import type { AccountBalance, SavingsGoalProgress } from "@/lib/supabase/types";

/**
 * Balances/progress are always derived on read from the postings ledger --
 * there is no stored balance column to read instead.
 */
export async function fetchAccountBalances(profileId: string): Promise<AccountBalance[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("account_balances")
    .select("*")
    .eq("profile_id", profileId);

  if (error) throw error;
  return data as AccountBalance[];
}

export async function fetchSavingsGoalProgress(profileId: string): Promise<SavingsGoalProgress[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("savings_goal_progress")
    .select("*")
    .eq("profile_id", profileId);

  if (error) throw error;
  return data as SavingsGoalProgress[];
}

export async function createSavingsGoal(name: string, targetAmountCents: number): Promise<string> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.rpc("create_savings_goal", {
    p_name: name,
    p_target_amount_cents: targetAmountCents,
  });

  if (error) throw error;
  return data as string;
}

export async function depositToSavingsGoal(
  goalAccountId: string,
  amountCents: number,
): Promise<void> {
  const supabase = getSupabaseClient();
  const { error } = await supabase.rpc("deposit_to_savings_goal", {
    p_goal_account_id: goalAccountId,
    p_amount_cents: amountCents,
  });

  if (error) throw error;
}

export async function withdrawFromSavingsGoal(
  goalAccountId: string,
  amountCents: number,
): Promise<void> {
  const supabase = getSupabaseClient();
  const { error } = await supabase.rpc("withdraw_from_savings_goal", {
    p_goal_account_id: goalAccountId,
    p_amount_cents: amountCents,
  });

  if (error) throw error;
}

export async function fundStudentWallet(
  studentProfileId: string,
  amountCents: number,
): Promise<void> {
  const supabase = getSupabaseClient();
  const { error } = await supabase.rpc("fund_student_wallet", {
    p_student_profile_id: studentProfileId,
    p_amount_cents: amountCents,
  });

  if (error) throw error;
}

export interface ChildProfile {
  id: string;
  display_name: string | null;
}

export async function fetchLinkedChildren(parentId: string): Promise<ChildProfile[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("profiles")
    .select("id, display_name")
    .eq("parent_id", parentId);

  if (error) throw error;
  return (data ?? []) as ChildProfile[];
}
