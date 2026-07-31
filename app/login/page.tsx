"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { AuthCard } from "@/components/auth/AuthCard";
import { FormField } from "@/components/auth/FormField";
import { Button } from "@/components/Button";
import { signInParent, ensureParentProfile } from "@/lib/supabase/auth-actions";
import { useAuth } from "@/lib/supabase/auth-context";

export default function LoginPage() {
  const router = useRouter();
  const { refreshProfile } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);

    const result = await signInParent(email, password);

    if (result.error) {
      setSubmitting(false);
      setError(result.error);
      return;
    }

    const profileResult = await ensureParentProfile();
    await refreshProfile();
    setSubmitting(false);

    if (profileResult.error) {
      setError(profileResult.error);
      return;
    }

    router.push("/dashboard");
  }

  return (
    <AuthCard eyebrow="Welcome back" title="Log in">
      <form onSubmit={handleSubmit}>
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
          autoComplete="current-password"
        />
        {error ? <p className="mb-4 text-sm font-medium text-red-500">{error}</p> : null}
        <Button type="submit" size="lg" className="w-full" disabled={submitting}>
          {submitting ? "Logging in…" : "Log in"}
        </Button>
      </form>
      <p className="mt-4 text-center text-sm text-muted-foreground">
        New to FinEsse?{" "}
        <Link href="/signup" className="font-medium text-primary-500 hover:text-primary-600">
          Create a parent account
        </Link>
      </p>
    </AuthCard>
  );
}
