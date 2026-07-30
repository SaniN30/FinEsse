export type ProfileRole = "parent" | "student";
export type Tier = "school" | "college" | "job_ready";

export interface Profile {
  id: string;
  role: ProfileRole;
  parent_id: string | null;
  tier: Tier | null;
  display_name: string | null;
}
