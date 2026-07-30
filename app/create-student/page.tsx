"use client";

import { Suspense, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { AuthCard } from "@/components/auth/AuthCard";
import { FormField } from "@/components/auth/FormField";
import { PinInput } from "@/components/auth/PinInput";
import { Button } from "@/components/Button";
import { createStudentAccount } from "@/lib/supabase/auth-actions";
import { rememberStudent } from "@/lib/supabase/student-registry";
import { useAuth } from "@/lib/supabase/auth-context";

function CreateStudentForm() {
  const router = useRouter();
  const params = useSearchParams();
  const { session, loading } = useAuth();

  const consentId = params.get("consent_id") ?? "";
  const [displayName, setDisplayName] = useState(params.get("name") ?? "");
  const [pin, setPin] = useState("");
  const [confirmPin, setConfirmPin] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState<{ displayName: string } | null>(null);

  useEffect(() => {
    if (!loading && !session) {
      router.replace("/login");
    }
  }, [loading, session, router]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    if (!consentId) {
      setError("Missing consent record — please restart from the consent step.");
      return;
    }

    if (!/^[0-9]{4,6}$/.test(pin)) {
      setError("PIN must be 4-6 digits.");
      return;
    }

    if (pin !== confirmPin) {
      setError("PINs don't match.");
      return;
    }

    setSubmitting(true);
    const result = await createStudentAccount({ consentId, displayName, pin });
    setSubmitting(false);

    if (result.error || !result.data) {
      setError(result.error ?? "Could not create the student account.");
      return;
    }

    rememberStudent({
      studentId: result.data.student_id,
      displayName,
      loginEmail: result.data.login_email,
    });

    setSuccess({ displayName });
  }

  if (loading || !session) {
    return null;
  }

  if (success) {
    return (
      <AuthCard eyebrow="All set" title={`${success.displayName}'s account is ready`}>
        <p className="mb-6 text-sm leading-relaxed text-neutral-500">
          They can log in any time with their PIN on this device.
        </p>
        <div className="flex flex-col gap-3">
          <Link href="/student-login">
            <Button size="lg" className="w-full">
              Go to student login
            </Button>
          </Link>
          <Link href="/dashboard">
            <Button variant="secondary" size="lg" className="w-full">
              Back to dashboard
            </Button>
          </Link>
        </div>
      </AuthCard>
    );
  }

  return (
    <AuthCard
      eyebrow="Step 2 of 2"
      title="Create your child's account"
      description="Choose a 4-6 digit PIN together — this is how they'll log in."
    >
      <form onSubmit={handleSubmit}>
        <FormField
          label="Display name"
          name="displayName"
          value={displayName}
          onChange={(e) => setDisplayName(e.target.value)}
          required
          autoComplete="off"
        />
        <PinInput label="Choose a PIN" value={pin} onChange={setPin} />
        <PinInput label="Confirm PIN" value={confirmPin} onChange={setConfirmPin} />
        {error ? <p className="mb-4 text-sm font-medium text-red-500">{error}</p> : null}
        <Button type="submit" size="lg" className="w-full" disabled={submitting}>
          {submitting ? "Creating account…" : "Create account"}
        </Button>
      </form>
    </AuthCard>
  );
}

export default function CreateStudentPage() {
  return (
    <Suspense fallback={null}>
      <CreateStudentForm />
    </Suspense>
  );
}
