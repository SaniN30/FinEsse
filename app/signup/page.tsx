"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { AuthCard } from "@/components/auth/AuthCard";
import { FormField } from "@/components/auth/FormField";
import { SelectField } from "@/components/auth/SelectField";
import { Button } from "@/components/Button";
import { signUpParent } from "@/lib/supabase/auth-actions";
import { educationLevelToTier, tierBasePath } from "@/lib/supabase/profile-helpers";
import type { EducationLevel } from "@/lib/supabase/types";

const EDUCATION_LEVEL_OPTIONS: { value: EducationLevel; label: string }[] = [
  { value: "school", label: "School" },
  { value: "college", label: "College" },
  { value: "working_professional", label: "Working professional" },
];

const PHONE_PATTERN = /^\+?[0-9]{7,15}$/;

function todayISODate(): string {
  return new Date().toISOString().slice(0, 10);
}

export default function SignUpPage() {
  const router = useRouter();
  const [displayName, setDisplayName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [dateOfBirth, setDateOfBirth] = useState("");
  const [educationLevel, setEducationLevel] = useState<EducationLevel | "">("");
  const [institutionName, setInstitutionName] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [needsConfirmation, setNeedsConfirmation] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    if (!educationLevel) {
      setError("Please select your education level.");
      return;
    }

    if (educationLevel !== "working_professional" && !institutionName.trim()) {
      setError("Please enter the name of your school or university.");
      return;
    }

    if (!PHONE_PATTERN.test(phoneNumber.trim())) {
      setError("Please enter a valid phone number (digits only, optionally starting with +).");
      return;
    }

    setSubmitting(true);

    const result = await signUpParent({
      email,
      password,
      displayName,
      dateOfBirth,
      educationLevel,
      institutionName: institutionName.trim() || null,
      phoneNumber: phoneNumber.trim(),
    });

    setSubmitting(false);

    if (result.error) {
      setError(result.error);
      return;
    }

    if (result.data?.needsEmailConfirmation) {
      setNeedsConfirmation(true);
      return;
    }

    // Only the working_professional path is a parent managing a separate
    // child login -- school/college signups are a direct, self-service
    // account for the person who just signed up (see profile-helpers.ts).
    if (educationLevel === "working_professional") {
      router.push("/consent");
      return;
    }

    router.push(tierBasePath(educationLevelToTier(educationLevel)));
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
          {educationLevel === "working_professional"
            ? "to set up parental consent and create your child's account."
            : "to start your lessons."}
        </p>
      </AuthCard>
    );
  }

  const isWorkingProfessional = educationLevel === "working_professional";

  return (
    <AuthCard
      eyebrow="Get started"
      title={isWorkingProfessional ? "Create your parent account" : "Create your account"}
      description={
        isWorkingProfessional
          ? "This account is yours — you'll set up your child's login in the next steps."
          : "This account is yours — sign up to start your own lessons right away."
      }
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
        <FormField
          label="Date of birth"
          name="dateOfBirth"
          type="date"
          value={dateOfBirth}
          onChange={(e) => setDateOfBirth(e.target.value)}
          required
          max={todayISODate()}
          autoComplete="bday"
        />
        <SelectField
          label="Education level"
          name="educationLevel"
          value={educationLevel}
          onChange={(e) => setEducationLevel(e.target.value as EducationLevel)}
          options={EDUCATION_LEVEL_OPTIONS}
          placeholder="Select your education level"
          required
        />
        <FormField
          label={
            educationLevel === "working_professional"
              ? "School or university (optional)"
              : "School or university"
          }
          name="institutionName"
          value={institutionName}
          onChange={(e) => setInstitutionName(e.target.value)}
          required={educationLevel !== "working_professional"}
          autoComplete="organization"
        />
        <FormField
          label="Phone number"
          name="phoneNumber"
          type="tel"
          value={phoneNumber}
          onChange={(e) => setPhoneNumber(e.target.value)}
          required
          autoComplete="tel"
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
