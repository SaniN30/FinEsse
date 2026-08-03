import type { Profile, Tier } from "@/lib/supabase/types";

/**
 * True only for the `working_professional` signup path, where a `role: "parent"`
 * profile is a real parent managing a separate linked child (`/dashboard`,
 * `/consent`, `/create-student`). `school`/`college` signups also get
 * `role: "parent"` (the only self-signup identity this schema has) but act as a
 * direct, self-service account with no child profile -- treat them like a
 * student for content/feature gating instead.
 */
export function isParentWithChildFlow(profile: Profile | null): boolean {
  return profile?.role === "parent" && profile?.education_level === "working_professional";
}

/**
 * Maps a signup `education_level` to the `profiles.tier` the account should
 * read/write content as. `working_professional` accounts don't consume tier
 * content directly (they use the parent/child flow instead), so this only
 * matters for the `school`/`college` self-service paths -- default to
 * `school` for `working_professional` since `profiles.tier` is `not null`.
 */
export function educationLevelToTier(educationLevel: string | null | undefined): Tier {
  return educationLevel === "college" ? "college" : "school";
}

// A student profile always has a tier set at creation, but the column is
// nullable at the type level, so this falls back to School rather than
// producing an invalid "/null" route.
export function tierBasePath(tier: Tier | null): string {
  if (tier === "job_ready") return "/job-ready";
  return `/${tier ?? "school"}`;
}
