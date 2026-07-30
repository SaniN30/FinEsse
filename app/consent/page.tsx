"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AuthCard } from "@/components/auth/AuthCard";
import { FormField } from "@/components/auth/FormField";
import { Button } from "@/components/Button";
import { recordConsent } from "@/lib/supabase/auth-actions";
import { useAuth } from "@/lib/supabase/auth-context";

export default function ConsentPage() {
  const router = useRouter();
  const { session, loading } = useAuth();
  const [childName, setChildName] = useState("");
  const [consentChecked, setConsentChecked] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!loading && !session) {
      router.replace("/login");
    }
  }, [loading, session, router]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    if (!consentChecked) {
      setError("You must explicitly confirm consent before continuing.");
      return;
    }

    setSubmitting(true);
    const result = await recordConsent(childName);
    setSubmitting(false);

    if (result.error || !result.data) {
      setError(result.error ?? "Could not record consent.");
      return;
    }

    router.push(
      `/create-student?consent_id=${encodeURIComponent(result.data.consent_id)}&name=${encodeURIComponent(childName)}`,
    );
  }

  if (loading || !session) {
    return null;
  }

  return (
    <AuthCard
      eyebrow="Step 1 of 2"
      title="Parental consent"
      description="This is a separate, explicit step from any terms of service — required before we create your child's login."
    >
      <form onSubmit={handleSubmit}>
        <FormField
          label="Child's display name"
          name="childName"
          value={childName}
          onChange={(e) => setChildName(e.target.value)}
          required
          autoComplete="off"
        />

        <label className="mb-6 flex items-start gap-3 rounded-xl border border-surface-border bg-background p-4 text-sm leading-relaxed text-neutral-600">
          <input
            type="checkbox"
            checked={consentChecked}
            onChange={(e) => setConsentChecked(e.target.checked)}
            className="mt-0.5 h-4 w-4 shrink-0 rounded border-surface-border text-primary-500 focus:ring-primary-400"
          />
          <span>
            I am this child&apos;s parent or legal guardian, and I explicitly consent to
            creating a FinEsse account for them, in accordance with COPPA and GDPR-K.
          </span>
        </label>

        {error ? <p className="mb-4 text-sm font-medium text-red-500">{error}</p> : null}
        <Button type="submit" size="lg" className="w-full" disabled={submitting}>
          {submitting ? "Recording consent…" : "Give consent & continue"}
        </Button>
      </form>
    </AuthCard>
  );
}
