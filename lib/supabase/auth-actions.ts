import { supabase } from "@/lib/supabase/client";
import { educationLevelToTier } from "@/lib/supabase/profile-helpers";
import type { EducationLevel, Profile } from "@/lib/supabase/types";

export interface ActionResult<T> {
  data: T | null;
  error: string | null;
}

export interface ParentSignUpDetails {
  email: string;
  password: string;
  displayName: string;
  dateOfBirth: string;
  educationLevel: EducationLevel;
  institutionName: string | null;
  phoneNumber: string;
}

interface ParentProfileFields {
  displayName: string;
  dateOfBirth?: string | null;
  educationLevel?: string | null;
  institutionName?: string | null;
  phoneNumber?: string | null;
}

const PROFILE_SELECT = "id, role, parent_id, tier, display_name, education_level" as const;

/** Postgres unique_violation -- see idx_profiles_phone_number_unique. */
const UNIQUE_VIOLATION = "23505";

async function insertParentProfile(
  userId: string,
  fields: ParentProfileFields,
): Promise<ActionResult<Profile>> {
  const { data, error } = await supabase
    .from("profiles")
    .insert({
      id: userId,
      role: "parent",
      display_name: fields.displayName,
      date_of_birth: fields.dateOfBirth ?? null,
      education_level: fields.educationLevel ?? null,
      institution_name: fields.institutionName ?? null,
      phone_number: fields.phoneNumber ?? null,
      // Only meaningful for the school/college self-service path (a
      // working_professional account uses the parent/child flow instead
      // and never reads tier content directly) -- see
      // profile-helpers.ts#educationLevelToTier.
      tier: educationLevelToTier(fields.educationLevel),
    })
    .select(PROFILE_SELECT)
    .single();

  if (error) {
    const message =
      error.code === UNIQUE_VIOLATION
        ? "An account with this phone number already exists."
        : error.message;
    return { data: null, error: message };
  }

  return { data: data as Profile, error: null };
}

export async function signUpParent(
  details: ParentSignUpDetails,
): Promise<ActionResult<{ userId: string; needsEmailConfirmation: boolean }>> {
  const { email, password, displayName, dateOfBirth, educationLevel, institutionName, phoneNumber } =
    details;

  // Checked before creating the auth user so a duplicate phone number
  // doesn't leave behind an orphaned auth account with no profile.
  const { data: phoneTaken, error: phoneCheckError } = await supabase.rpc(
    "is_phone_number_taken",
    { candidate: phoneNumber },
  );

  if (phoneCheckError) {
    return { data: null, error: phoneCheckError.message };
  }

  if (phoneTaken) {
    return { data: null, error: "An account with this phone number already exists." };
  }

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        display_name: displayName,
        date_of_birth: dateOfBirth,
        education_level: educationLevel,
        institution_name: institutionName,
        phone_number: phoneNumber,
      },
    },
  });

  if (error || !data.user) {
    return { data: null, error: error?.message ?? "Sign-up failed." };
  }

  // With email confirmation + enumeration protection enabled, signing up
  // with an already-registered, already-confirmed email succeeds but
  // returns an empty `identities` array instead of an error -- the
  // documented way to detect this case client-side.
  if (data.user.identities && data.user.identities.length === 0) {
    return {
      data: null,
      error: "An account with this email already exists. Try logging in instead.",
    };
  }

  if (!data.session) {
    // Project has email confirmation enabled: no session yet, so RLS won't
    // let us insert the profile row until the parent confirms and signs in.
    // All the new fields are preserved in user_metadata for ensureParentProfile.
    return { data: { userId: data.user.id, needsEmailConfirmation: true }, error: null };
  }

  const { error: profileError } = await insertParentProfile(data.user.id, {
    displayName,
    dateOfBirth,
    educationLevel,
    institutionName,
    phoneNumber,
  });

  if (profileError) {
    return { data: null, error: profileError };
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
    .select(PROFILE_SELECT)
    .eq("id", user.id)
    .maybeSingle();

  if (existing) {
    return { data: existing as Profile, error: null };
  }

  const metadata = user.user_metadata ?? {};

  return insertParentProfile(user.id, {
    displayName: (metadata.display_name as string | undefined) ?? "Parent",
    dateOfBirth: metadata.date_of_birth as string | undefined,
    educationLevel: metadata.education_level as string | undefined,
    institutionName: metadata.institution_name as string | undefined,
    phoneNumber: metadata.phone_number as string | undefined,
  });
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
  // Routed through the student-login Edge Function (not
  // supabase.auth.signInWithPassword directly) so failed attempts count
  // against the per-account lockout in `profiles` -- see
  // supabase/functions/student-login.
  const { data, error } = await supabase.functions.invoke<{
    user_id: string;
    access_token: string;
    refresh_token: string;
    error?: string;
    locked_until?: string;
  }>("student-login", {
    body: { login_email: loginEmail, pin },
  });

  if (error || !data || data.error) {
    // On non-2xx (e.g. 423 locked), supabase-js puts the response on
    // error.context rather than data -- try to recover the server's
    // message before falling back to the generic error.
    const contextBody =
      !data && error && "context" in error
        ? await (error as { context: Response }).context
            .clone()
            .json()
            .catch(() => null)
        : null;

    return {
      data: null,
      error: data?.error ?? contextBody?.error ?? error?.message ?? "Login failed.",
    };
  }

  const { error: sessionError } = await supabase.auth.setSession({
    access_token: data.access_token,
    refresh_token: data.refresh_token,
  });

  if (sessionError) {
    return { data: null, error: sessionError.message };
  }

  return { data: { userId: data.user_id }, error: null };
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
