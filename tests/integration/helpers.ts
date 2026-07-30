// Shared helpers for integration tests that run against a local Supabase
// instance started with `supabase start`. See BACKEND.md for setup.
import { createClient, type SupabaseClient } from "@supabase/supabase-js";

const SUPABASE_URL = process.env.SUPABASE_URL ?? "http://127.0.0.1:54321";
const ANON_KEY = process.env.SUPABASE_ANON_KEY;
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!ANON_KEY || !SERVICE_ROLE_KEY) {
  throw new Error(
    "SUPABASE_ANON_KEY and SUPABASE_SERVICE_ROLE_KEY must be set (see `supabase status` " +
      "after `supabase start`, or BACKEND.md for the local dev defaults).",
  );
}

export function anonClient(): SupabaseClient {
  return createClient(SUPABASE_URL, ANON_KEY!);
}

export function serviceClient(): SupabaseClient {
  return createClient(SUPABASE_URL, SERVICE_ROLE_KEY!);
}

let counter = 0;
export function uniqueEmail(prefix: string): string {
  counter += 1;
  return `${prefix}-${Date.now()}-${counter}@example.test`;
}

export async function signUpParent(displayName: string) {
  const client = anonClient();
  const email = uniqueEmail("parent");
  const password = "test-password-123";

  const { data, error } = await client.auth.signUp({ email, password });
  if (error || !data.user) {
    throw new Error(`parent signup failed: ${error?.message}`);
  }

  const admin = serviceClient();
  const { error: profileError } = await admin.from("profiles").insert({
    id: data.user.id,
    role: "parent",
    display_name: displayName,
  });
  if (profileError) {
    throw new Error(`parent profile insert failed: ${profileError.message}`);
  }

  const { data: signIn, error: signInError } = await client.auth.signInWithPassword({
    email,
    password,
  });
  if (signInError || !signIn.session) {
    throw new Error(`parent sign-in failed: ${signInError?.message}`);
  }

  return {
    userId: data.user.id,
    email,
    accessToken: signIn.session.access_token,
    client: createClient(SUPABASE_URL, ANON_KEY!, {
      global: { headers: { Authorization: `Bearer ${signIn.session.access_token}` } },
    }),
  };
}

export async function recordConsent(
  accessToken: string,
  childDisplayName: string,
): Promise<string> {
  const res = await fetch(`${SUPABASE_URL}/functions/v1/record-consent`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ child_display_name: childDisplayName, consent_given: true }),
  });
  const body = await res.json();
  if (!res.ok) {
    throw new Error(`record-consent failed: ${JSON.stringify(body)}`);
  }
  return body.consent_id as string;
}

export async function createStudentAccount(
  accessToken: string,
  opts: { consentId: string; displayName: string; pin: string },
) {
  const res = await fetch(`${SUPABASE_URL}/functions/v1/create-student-account`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      consent_id: opts.consentId,
      display_name: opts.displayName,
      pin: opts.pin,
    }),
  });
  const body = await res.json();
  return { status: res.status, body };
}

export async function signInStudent(email: string, pin: string) {
  const client = anonClient();
  const { data, error } = await client.auth.signInWithPassword({ email, password: pin });
  if (error || !data.session) {
    throw new Error(`student sign-in failed: ${error?.message}`);
  }
  return {
    userId: data.user!.id,
    accessToken: data.session.access_token,
    client: createClient(SUPABASE_URL, ANON_KEY!, {
      global: { headers: { Authorization: `Bearer ${data.session.access_token}` } },
    }),
  };
}
