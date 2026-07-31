// Security audit Finding 1b: per-account lockout/backoff for student PIN
// login. GoTrue's signInWithPassword has no failed-attempt hook, so this
// function is the *only* supported path for student sign-in going forward
// (see auth-actions.ts) -- it checks/increments a counter on `profiles`
// around a service-role signInWithPassword call.
//
// Lockout: 5 failed attempts locks the account for 15 minutes. A successful
// login resets the counter. The counter and lock live on `profiles`
// (login_email/failed_login_attempts/locked_until, migration 00000000000022)
// rather than in GoTrue itself.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { getCorsHeaders } from "../_shared/cors.ts";

const MAX_FAILED_ATTEMPTS = 5;
const LOCKOUT_MINUTES = 15;

function jsonResponse(
  body: unknown,
  status: number,
  corsHeaders: Record<string, string>,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  const corsHeaders = getCorsHeaders(req.headers.get("origin"));

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { login_email, pin } = await req.json();

    if (typeof login_email !== "string" || typeof pin !== "string") {
      return jsonResponse({ error: "login_email and pin are required" }, 400, corsHeaders);
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: profile, error: profileError } = await admin
      .from("profiles")
      .select("id, failed_login_attempts, locked_until")
      .eq("login_email", login_email)
      .eq("role", "student")
      .maybeSingle();

    if (profileError || !profile) {
      return jsonResponse({ error: "Invalid login or PIN." }, 401, corsHeaders);
    }

    const now = new Date();
    if (profile.locked_until && new Date(profile.locked_until) > now) {
      return jsonResponse(
        {
          error: "Account temporarily locked due to too many failed attempts. Try again later.",
          locked_until: profile.locked_until,
        },
        423,
        corsHeaders,
      );
    }

    const { data: signInData, error: signInError } = await admin.auth.signInWithPassword({
      email: login_email,
      password: pin,
    });

    if (signInError || !signInData.session) {
      const attempts = (profile.failed_login_attempts ?? 0) + 1;
      const lockedUntil =
        attempts >= MAX_FAILED_ATTEMPTS
          ? new Date(now.getTime() + LOCKOUT_MINUTES * 60_000).toISOString()
          : null;

      await admin
        .from("profiles")
        .update({
          failed_login_attempts: attempts >= MAX_FAILED_ATTEMPTS ? 0 : attempts,
          locked_until: lockedUntil,
        })
        .eq("id", profile.id);

      if (lockedUntil) {
        return jsonResponse(
          {
            error: "Account locked due to too many failed attempts. Try again in 15 minutes.",
            locked_until: lockedUntil,
          },
          423,
          corsHeaders,
        );
      }

      return jsonResponse({ error: "Invalid login or PIN." }, 401, corsHeaders);
    }

    await admin
      .from("profiles")
      .update({ failed_login_attempts: 0, locked_until: null })
      .eq("id", profile.id);

    return jsonResponse(
      {
        user_id: signInData.user.id,
        access_token: signInData.session.access_token,
        refresh_token: signInData.session.refresh_token,
      },
      200,
      corsHeaders,
    );
  } catch (err) {
    console.error("Unexpected error during student login", err);
    return jsonResponse({ error: "internal server error" }, 500, corsHeaders);
  }
});
