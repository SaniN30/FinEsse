"use client";

import { useEffect, useState } from "react";
import { getSupabaseClient } from "@/lib/supabase/client";
import { useAuth } from "@/lib/supabase/auth-context";
import { RoleCard } from "@/components/roles/RoleCard";
import type { Role, SkillMastery } from "@/lib/supabase/types";

const MASTERY_THRESHOLD_FALLBACK = 0.8;

export function RoleExplorerGrid() {
  const { profile } = useAuth();
  const [roles, setRoles] = useState<Role[] | null>(null);
  const [masteredSkillIds, setMasteredSkillIds] = useState<Set<string>>(new Set());
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    const supabase = getSupabaseClient();

    async function load() {
      const { data: roleRows, error: roleError } = await supabase
        .from("roles")
        .select("id, slug, title, description, typical_pay_range, required_skill_ids");

      if (roleError) {
        if (isMounted) setError(roleError.message);
        return;
      }

      if (isMounted) setRoles(roleRows ?? []);

      if (!profile) return;

      const { data: masteryRows } = await supabase
        .from("skill_mastery")
        .select("skill_id, attempts_considered, rolling_accuracy")
        .eq("profile_id", profile.id);

      if (!isMounted || !masteryRows) return;

      const mastered = new Set<string>(
        (masteryRows as SkillMastery[])
          .filter((row) => row.rolling_accuracy >= MASTERY_THRESHOLD_FALLBACK)
          .map((row) => row.skill_id),
      );
      setMasteredSkillIds(mastered);
    }

    load();
    return () => {
      isMounted = false;
    };
  }, [profile]);

  if (error) {
    return <p className="text-sm text-red-500">Couldn&apos;t load roles: {error}</p>;
  }

  if (!roles) {
    return <p className="text-sm text-neutral-500">Loading roles…</p>;
  }

  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {roles.map((role, index) => (
        <RoleCard key={role.id} role={role} masteredSkillIds={masteredSkillIds} index={index} />
      ))}
    </div>
  );
}
