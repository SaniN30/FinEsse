"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { AuthCard } from "@/components/auth/AuthCard";
import { FormField } from "@/components/auth/FormField";
import { Button } from "@/components/Button";
import { signUpParent } from "@/lib/supabase/auth-actions";

export default function SignUpPage() {
  const router = useRouter();
  const [displayName, setDisplayName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [needsConfirmation, setNeedsConfirmation] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);

    const result = await signUpParent(email, password, displayName);

    setSubmitting(false);

    if (result.error) {
      setError(result.error);
      return;
    }

    if (result.data?.needsEmailConfirmation) {
      setNeedsConfirmation(true);
      return;
    }

    router.push("/consent");
  }

  if (needsConfirmation) {
    return (
      <AuthCard eyebrow="Almost there" title="Confirm your email">
        <p className="text-sm leading-relaxed text-muted-foreground">
          We sent a confirmation link to <strong className="text-foreground">{email}</strong>.
          Once you confirm it, come back and{" "}
          <Link href="/login" className="font-medium text-primary-500 hover:text-primary-600">
            log in
          </Link>{" "}
          to set up parental consent and create your child&apos;s account.
        </p>
      </AuthCard>
    );
  }

  return (
    <AuthCard
      eyebrow="Get started"
      title="Create your parent account"
      description="This account is yours — you'll set up your child's login in the next steps."
    >
      <form onSubmit={handleSubmit}>
        <FormField
          label="Your name"
          name="displayName"
          value={displayName}
          onChange={(e) => setDisplayName(e.target.value)}
          required
          autoComplete="name"
        />
        <FormField
          label="Email"
          name="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          autoComplete="email"
        />
        <FormField
          label="Password"
          name="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          minLength={8}
          autoComplete="new-password"
        />
        {error ? <p className="mb-4 text-sm font-medium text-red-500">{error}</p> : null}
        <Button type="submit" size="lg" className="w-full" disabled={submitting}>
          {submitting ? "Creating account…" : "Sign up"}
        </Button>
      </form>
      <p className="mt-4 text-center text-sm text-muted-foreground">
        Already have an account?{" "}
        <Link href="/login" className="font-medium text-primary-500 hover:text-primary-600">
          Log in
        </Link>
      </p>
    </AuthCard>
  );
}
