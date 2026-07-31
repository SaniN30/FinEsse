import { supabase } from "@/lib/supabase/client";

export interface ConsentRecord {
  id: string;
  child_display_name: string;
  consent_given: boolean;
  consent_version: string;
  consented_at: string | null;
  created_at: string;
}

export async function fetchParentConsentRecords(): Promise<ConsentRecord[]> {
  const { data, error } = await supabase
    .from("parental_consents")
    .select("id, child_display_name, consent_given, consent_version, consented_at, created_at")
    .order("created_at", { ascending: false });

  if (error) throw new Error(error.message);
  return (data as ConsentRecord[]) ?? [];
}

export async function renameChildProfile(childId: string, displayName: string): Promise<void> {
  const { error } = await supabase
    .from("profiles")
    .update({ display_name: displayName })
    .eq("id", childId);

  if (error) throw new Error(error.message);
}

export async function updateParentPassword(newPassword: string): Promise<void> {
  const { error } = await supabase.auth.updateUser({ password: newPassword });
  if (error) throw new Error(error.message);
}
