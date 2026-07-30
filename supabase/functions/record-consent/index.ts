// Records explicit, separate parental consent for enabling a child account.
//
// This is deliberately its own endpoint, distinct from general terms-of-service
// acceptance during parent signup (COPPA/GDPR-K requires consent to be its own
// explicit step). It runs as the calling parent (forwarded JWT, not service
// role) so RLS on parental_consents enforces parent_id = auth.uid() -- a
// parent can only ever record consent for themselves, never for another
// parent's account.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const CURRENT_CONSENT_VERSION = "coppa-gdprk-v1";

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

    const { child_display_name, consent_given } = await req.json();

    if (typeof child_display_name !== "string" || child_display_name.trim().length === 0) {
      return new Response(
        JSON.stringify({ error: "child_display_name is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (consent_given !== true) {
      return new Response(
        JSON.stringify({ error: "consent_given must be explicitly true" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "invalid session" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { data, error } = await supabase
      .from("parental_consents")
      .insert({
        parent_id: user.id,
        child_display_name,
        consent_given: true,
        consent_version: CURRENT_CONSENT_VERSION,
        consented_at: new Date().toISOString(),
      })
      .select("id")
      .single();

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ consent_id: data.id }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
