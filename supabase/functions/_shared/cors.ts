// Scopes Access-Control-Allow-Origin to the deployed frontend's actual
// origin(s) instead of "*", per security audit Finding 3. There's no single
// known production URL hardcoded here (Vercel preview URLs are per-branch),
// so the allowlist is env-var-driven: set ALLOWED_ORIGINS (comma-separated)
// as a Supabase Edge Function secret to the real production/preview
// origin(s). With no ALLOWED_ORIGINS set, this falls back to "*" -- fine for
// local dev, but every deployed environment should set it.
const allowedOrigins = (Deno.env.get("ALLOWED_ORIGINS") ?? "")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);

export function getCorsHeaders(origin: string | null): Record<string, string> {
  const allowOrigin =
    allowedOrigins.length === 0
      ? "*"
      : origin && allowedOrigins.includes(origin)
        ? origin
        : allowedOrigins[0];

  return {
    "Access-Control-Allow-Origin": allowOrigin,
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    Vary: "Origin",
  };
}
