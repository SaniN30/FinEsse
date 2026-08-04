import { getSupabaseClient } from "@/lib/supabase/client";
import type { CurrencyCode } from "@/lib/currency/config";
import type { ParentDashboardChild, Tier } from "@/lib/supabase/types";

/**
 * One row per linked child, aggregated on read from `parent_dashboard_children`
 * (tier, XP, mastery %, pocket money, Interview Coach scores) -- see
 * supabase/migrations/00000000000021_parent_dashboard_aggregate.sql. RLS
 * (`is_own_or_linked_profile`, security_invoker = true) scopes this to the
 * calling parent's own linked children; it is never filtered client-side.
 */
export async function fetchParentDashboardChildren(): Promise<ParentDashboardChild[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("parent_dashboard_children")
    .select("*")
    .order("display_name", { ascending: true });

  if (error) throw error;
  return (data ?? []) as ParentDashboardChild[];
}

/**
 * Changes a linked child's tier -- the only way to move a student past the
 * tier chosen at account creation (see the "College/Job-Ready 0 lessons"
 * postmortem in AGENTS.md: `profiles.tier` was previously fixed for life,
 * silently locking every pre-fix account, and most existing accounts, to
 * School). `profiles_update` RLS already permits a parent to update their
 * linked child's row, so this is a plain client-side update, not an RPC.
 */
export async function updateChildTier(profileId: string, tier: Tier): Promise<void> {
  const supabase = getSupabaseClient();
  const { error } = await supabase.from("profiles").update({ tier }).eq("id", profileId);
  if (error) throw error;
}

/**
 * Changes a linked child's Pocket Money Planner display currency -- same
 * RLS/update shape as updateChildTier above, no new RPC needed. See
 * lib/currency/config.ts for the supported currency list and static-rate
 * conversion this drives.
 */
export async function updateChildCurrency(profileId: string, currency: CurrencyCode): Promise<void> {
  const supabase = getSupabaseClient();
  const { error } = await supabase.from("profiles").update({ currency }).eq("id", profileId);
  if (error) throw error;
}
