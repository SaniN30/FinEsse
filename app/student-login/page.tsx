"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { AuthCard } from "@/components/auth/AuthCard";
import { PinInput } from "@/components/auth/PinInput";
import { Button } from "@/components/Button";
import { signInStudent } from "@/lib/supabase/auth-actions";
import { listKnownStudents, type KnownStudent } from "@/lib/supabase/student-registry";
import { useAuth } from "@/lib/supabase/auth-context";

export default function StudentLoginPage() {
  const { refreshProfile } = useAuth();
  // Starts empty and loads in an effect (not a lazy useState initializer)
  // because localStorage isn't available during SSR - a lazy initializer
  // would render [] on the server and the real list on the client, causing a
  // hydration mismatch.
  const [students, setStudents] = useState<KnownStudent[]>([]);
  const [selected, setSelected] = useState<KnownStudent | null>(null);
  const [pin, setPin] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [loggedInAs, setLoggedInAs] = useState<string | null>(null);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect -- one-time read of this device's localStorage, not derivable from props/state.
    setStudents(listKnownStudents());
  }, []);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!selected) return;

    setError(null);

    if (!/^[0-9]{4,6}$/.test(pin)) {
      setError("Enter your full PIN.");
      return;
    }

    setSubmitting(true);
    const result = await signInStudent(selected.loginEmail, pin);
    setSubmitting(false);

    if (result.error) {
      setError("That PIN didn't work. Try again.");
      setPin("");
      return;
    }

    await refreshProfile();
    setLoggedInAs(selected.displayName);
  }

  if (loggedInAs) {
    return (
      <AuthCard eyebrow="You're in" title={`Hey ${loggedInAs}! 👋`}>
        <p className="text-sm leading-relaxed text-neutral-500">
          Lessons and quizzes are coming in a later phase — for now, you&apos;re logged in
          and ready to go.
        </p>
      </AuthCard>
    );
  }

  if (!selected) {
    return (
      <AuthCard
        eyebrow="Student login"
        title="Who's playing?"
        description="Pick your name to enter your PIN."
      >
        {students.length === 0 ? (
          <p className="text-sm leading-relaxed text-neutral-500">
            No student accounts found on this device yet. Ask your parent to create one from
            their dashboard.
          </p>
        ) : (
          <div className="grid grid-cols-2 gap-3">
            {students.map((student) => (
              <motion.button
                key={student.studentId}
                type="button"
                onClick={() => setSelected(student)}
                whileHover={{ y: -3 }}
                whileTap={{ scale: 0.97 }}
                className="flex flex-col items-center justify-center gap-2 rounded-[var(--radius-card)] border border-surface-border bg-background p-6 text-center shadow-soft transition-shadow hover:shadow-lg"
              >
                <span className="flex h-14 w-14 items-center justify-center rounded-full bg-primary-100 text-xl font-semibold text-primary-600">
                  {student.displayName.charAt(0).toUpperCase()}
                </span>
                <span className="text-sm font-medium text-foreground">
                  {student.displayName}
                </span>
              </motion.button>
            ))}
          </div>
        )}
      </AuthCard>
    );
  }

  return (
    <AuthCard eyebrow="Student login" title={`Hi ${selected.displayName}!`} description="Enter your PIN.">
      <form onSubmit={handleSubmit}>
        <PinInput value={pin} onChange={setPin} autoFocus />
        {error ? <p className="mb-4 text-sm font-medium text-red-500">{error}</p> : null}
        <div className="flex flex-col gap-3">
          <Button type="submit" size="lg" className="w-full" disabled={submitting}>
            {submitting ? "Checking…" : "Log in"}
          </Button>
          <Button
            type="button"
            variant="ghost"
            size="md"
            className="w-full"
            onClick={() => {
              setSelected(null);
              setPin("");
              setError(null);
            }}
          >
            Not me — pick someone else
          </Button>
        </div>
      </form>
    </AuthCard>
  );
}
