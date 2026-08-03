"use client";

import { useEffect, useState } from "react";
import { getSupabaseClient } from "@/lib/supabase/client";
import { useAuth } from "@/lib/supabase/auth-context";
import { isParentWithChildFlow } from "@/lib/supabase/profile-helpers";
import type { ProfileBadge } from "@/lib/supabase/types";

const BADGE_ICON: Record<string, string> = {
  first_lesson_completed: "📖",
  first_quiz_passed: "🧠",
  first_modeling_exercise_passed: "📊",
  tier_completed: "🏆",
};

export function BadgeShelf() {
  const { profile } = useAuth();
  const [badges, setBadges] = useState<ProfileBadge[] | null>(null);

  useEffect(() => {
    if (!profile || isParentWithChildFlow(profile)) {
      return;
    }

    let isMounted = true;
    const supabase = getSupabaseClient();

    supabase
      .from("profile_badges")
      .select("id, profile_id, badge_id, awarded_at, badges(id, slug, title, description, criteria_type)")
      .eq("profile_id", profile.id)
      .order("awarded_at", { ascending: true })
      .then(({ data, error }) => {
        if (!isMounted || error) return;
        setBadges((data ?? []) as unknown as ProfileBadge[]);
      });

    return () => {
      isMounted = false;
    };
  }, [profile]);

  if (!badges || badges.length === 0) return null;

  return (
    <div className="flex flex-wrap gap-3">
      {badges.map((entry) => (
        <div
          key={entry.id}
          title={entry.badges.description}
          className="flex items-center gap-2 rounded-full border-2 border-foreground bg-surface px-4 py-2 text-sm font-medium shadow-[var(--shadow-offset)]"
        >
          <span aria-hidden="true">{BADGE_ICON[entry.badges.criteria_type] ?? "🏅"}</span>
          {entry.badges.title}
        </div>
      ))}
    </div>
  );
}
