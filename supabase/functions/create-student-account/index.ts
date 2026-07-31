// Creates a student's linked login, gated on a prior recorded parental consent.
//
// Runs with the service_role key because creating an auth.users row requires
// the Auth Admin API, but the *consent gate itself* is enforced twice:
//  1. here, before calling the admin API at all;
//  2. at the database level, by the enforce_student_consent trigger on
//     `profiles`, which fires regardless of which client/role performs the
//     insert -- so this check can't be bypassed even by a future code path
//     that inserts into profiles directly.
//
// Data minimization: the student gets a synthetic internal email (no real
// contact info collected) and a PIN as their password. There is no
// independent student sign-up path.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "missing Authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { consent_id, display_name, date_of_birth, pin, tier } = await req.json();

    if (typeof consent_id !== "string") {
      return new Response(
        JSON.stringify({ error: "consent_id is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (typeof pin !== "string" || !/^[0-9]{6}$/.test(pin)) {
      return new Response(
        JSON.stringify({ error: "pin must be 6 digits" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Identify the caller from their own JWT (not service role) so we know
    // who "the parent" actually is.
    const callerClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const {
      data: { user: parent },
      error: userError,
    } = await callerClient.auth.getUser();

    if (userError || !parent) {
      return new Response(
        JSON.stringify({ error: "invalid session" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Consent gate: must exist, belong to this parent, and be affirmatively given.
    const { data: consent, error: consentError } = await admin
      .from("parental_consents")
      .select("id, parent_id, consent_given")
      .eq("id", consent_id)
      .single();

    if (consentError || !consent) {
      return new Response(
        JSON.stringify({ error: "consent record not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (consent.parent_id !== parent.id || consent.consent_given !== true) {
      return new Response(
        JSON.stringify({ error: "no valid parental consent for this account" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const syntheticEmail = `student-${crypto.randomUUID()}@students.finesse.internal`;

    const { data: created, error: createError } = await admin.auth.admin.createUser({
      email: syntheticEmail,
      password: pin,
      email_confirm: true,
    });

    if (createError || !created.user) {
      return new Response(
        JSON.stringify({ error: createError?.message ?? "failed to create student login" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { error: profileError } = await admin.from("profiles").insert({
      id: created.user.id,
      role: "student",
      parent_id: parent.id,
      tier: tier ?? "school",
      display_name,
      date_of_birth: date_of_birth ?? null,
      consent_id,
    });

    if (profileError) {
      // Roll back the orphaned auth user if the consent-gated profile insert fails.
      await admin.auth.admin.deleteUser(created.user.id);
      return new Response(
        JSON.stringify({ error: profileError.message }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ student_id: created.user.id, login_email: syntheticEmail }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
