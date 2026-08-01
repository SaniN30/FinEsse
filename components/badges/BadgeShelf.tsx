"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/lib/supabase/auth-context";
import { fetchEarnedBadges } from "@/lib/badges/queries";
import type { EarnedBadge } from "@/lib/supabase/types";

/** Shows a student's earned milestone badges (see 00000000000043) -- silently renders nothing if there are none yet or the viewer isn't signed in, rather than an empty-state message, since this is a supplementary shelf, not a primary page section. */
export function BadgeShelf() {
  const { profile } = useAuth();
  const [badges, setBadges] = useState<EarnedBadge[] | null>(null);

  useEffect(() => {
    if (!profile) return;

    let isMounted = true;
    fetchEarnedBadges(profile.id).then((result) => {
      if (isMounted) setBadges(result);
    });

    return () => {
      isMounted = false;
    };
  }, [profile]);

  if (!badges || badges.length === 0) return null;

  return (
    <div className="mt-10 w-full max-w-3xl">
      <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-muted-foreground">
        Badges earned
      </h2>
      <div className="flex flex-wrap justify-center gap-3">
        {badges.map((badge) => (
          <div
            key={badge.slug}
            title={badge.description}
            className="flex items-center gap-2 rounded-full border border-surface-border bg-surface px-4 py-2 shadow-soft"
          >
            <span className="text-lg">{badge.icon}</span>
            <span className="text-sm font-medium text-foreground">{badge.title}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
