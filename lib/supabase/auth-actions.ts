import { supabase } from "@/lib/supabase/client";
import type { Profile } from "@/lib/supabase/types";

export interface ActionResult<T> {
  data: T | null;
  error: string | null;
}

export async function signUpParent(
  email: string,
  password: string,
  displayName: string,
): Promise<ActionResult<{ userId: string; needsEmailConfirmation: boolean }>> {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: { data: { display_name: displayName } },
  });

  if (error || !data.user) {
    return { data: null, error: error?.message ?? "Sign-up failed." };
  }

  if (!data.session) {
    // Project has email confirmation enabled: no session yet, so RLS won't
    // let us insert the profile row until the parent confirms and signs in.
    // display_name is preserved in user_metadata for ensureParentProfile.
    return { data: { userId: data.user.id, needsEmailConfirmation: true }, error: null };
  }

  const { error: profileError } = await supabase.from("profiles").insert({
    id: data.user.id,
    role: "parent",
    display_name: displayName,
  });

  if (profileError) {
    return { data: null, error: profileError.message };
  }

  return { data: { userId: data.user.id, needsEmailConfirmation: false }, error: null };
}

export async function signInParent(
  email: string,
  password: string,
): Promise<ActionResult<{ userId: string }>> {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });

  if (error || !data.user) {
    return { data: null, error: error?.message ?? "Login failed." };
  }

  return { data: { userId: data.user.id }, error: null };
}

/**
 * Creates the parent's `profiles` row on first login after email confirmation,
 * for the case where signUp() couldn't insert it directly (no session yet).
 */
export async function ensureParentProfile(): Promise<ActionResult<Profile>> {
  const { data: userData } = await supabase.auth.getUser();
  const user = userData.user;
  if (!user) {
    return { data: null, error: "No active session." };
  }

  const { data: existing } = await supabase
    .from("profiles")
    .select("id, role, parent_id, tier, display_name")
    .eq("id", user.id)
    .maybeSingle();

  if (existing) {
    return { data: existing as Profile, error: null };
  }

  const displayName = (user.user_metadata?.display_name as string | undefined) ?? "Parent";

  const { data: inserted, error } = await supabase
    .from("profiles")
    .insert({ id: user.id, role: "parent", display_name: displayName })
    .select("id, role, parent_id, tier, display_name")
    .single();

  if (error) {
    return { data: null, error: error.message };
  }

  return { data: inserted as Profile, error: null };
}

async function callEdgeFunction<T>(
  name: string,
  body: Record<string, unknown>,
): Promise<ActionResult<T>> {
  const { data, error } = await supabase.functions.invoke<T>(name, { body });

  if (error) {
    return { data: null, error: error.message };
  }

  return { data: data as T, error: null };
}

export function recordConsent(childDisplayName: string) {
  return callEdgeFunction<{ consent_id: string }>("record-consent", {
    child_display_name: childDisplayName,
    consent_given: true,
  });
}

export function createStudentAccount(opts: {
  consentId: string;
  displayName: string;
  pin: string;
  tier?: string;
}) {
  return callEdgeFunction<{ student_id: string; login_email: string }>(
    "create-student-account",
    {
      consent_id: opts.consentId,
      display_name: opts.displayName,
      pin: opts.pin,
      tier: opts.tier,
    },
  );
}

export async function signInStudent(
  loginEmail: string,
  pin: string,
): Promise<ActionResult<{ userId: string }>> {
  const { data, error } = await supabase.auth.signInWithPassword({
    email: loginEmail,
    password: pin,
  });

  if (error || !data.user) {
    return { data: null, error: error?.message ?? "Login failed." };
  }

  return { data: { userId: data.user.id }, error: null };
}

export async function fetchLinkedChildren(parentId: string): Promise<ActionResult<Profile[]>> {
  const { data, error } = await supabase
    .from("profiles")
    .select("id, role, parent_id, tier, display_name")
    .eq("parent_id", parentId)
    .eq("role", "student");

  if (error) {
    return { data: null, error: error.message };
  }

  return { data: data as Profile[], error: null };
}
