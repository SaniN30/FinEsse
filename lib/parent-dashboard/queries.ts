import { getSupabaseClient } from "@/lib/supabase/client";
import type { ParentDashboardChild } from "@/lib/supabase/types";

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
