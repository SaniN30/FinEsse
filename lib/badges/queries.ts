import { getSupabaseClient } from "@/lib/supabase/client";
import type { EarnedBadge } from "@/lib/supabase/types";

interface ProfileBadgeRow {
  earned_at: string;
  badges: { slug: string; title: string; description: string; icon: string } | null;
}

/** Badges a profile has actually earned, newest first -- read via `profile_badges` joined to `badges` (RLS-scoped to the caller or their linked child, see 00000000000043). */
export async function fetchEarnedBadges(profileId: string): Promise<EarnedBadge[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("profile_badges")
    .select("earned_at, badges(slug, title, description, icon)")
    .eq("profile_id", profileId)
    .order("earned_at", { ascending: false })
    .returns<ProfileBadgeRow[]>();

  if (error) throw error;

  return (data ?? [])
    .filter((row): row is ProfileBadgeRow & { badges: NonNullable<ProfileBadgeRow["badges"]> } =>
      Boolean(row.badges),
    )
    .map((row) => ({ ...row.badges, earned_at: row.earned_at }));
}
