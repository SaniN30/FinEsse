"use client";

import { useEffect, useState } from "react";
import { getSupabaseClient } from "@/lib/supabase/client";
import { useAuth } from "@/lib/supabase/auth-context";
import { Button } from "@/components/Button";
import { ModelingResult } from "@/components/modeling/ModelingResult";
import { extractMetricKeys, humanizeMetricKey } from "@/lib/modeling";
import type { ModelingExercisePublic, ModelingGradeResult } from "@/lib/supabase/types";

interface ModelingExerciseFormProps {
  exerciseId: string;
}

export function ModelingExerciseForm({ exerciseId }: ModelingExerciseFormProps) {
  const { session } = useAuth();
  const [exercise, setExercise] = useState<ModelingExercisePublic | null>(null);
  const [values, setValues] = useState<Record<string, string>>({});
  const [result, setResult] = useState<ModelingGradeResult | null>(null);
  const [alreadyPassed, setAlreadyPassed] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    const supabase = getSupabaseClient();

    supabase
      .from("modeling_exercises_public")
      .select("id, skill_id, title, instructions, pass_threshold")
      .eq("id", exerciseId)
      .maybeSingle()
      .then(({ data, error: fetchError }) => {
        if (!isMounted) return;
        if (fetchError || !data) {
          setError(fetchError?.message ?? "Modeling exercise not found");
          return;
        }
        setExercise(data);
      });

    return () => {
      isMounted = false;
    };
  }, [exerciseId]);

  useEffect(() => {
    if (!session?.user.id) return;
    let isMounted = true;
    const supabase = getSupabaseClient();

    supabase
      .from("modeling_submissions")
      .select("id")
      .eq("exercise_id", exerciseId)
      .eq("profile_id", session.user.id)
      .eq("passed", true)
      .limit(1)
      .then(({ data }) => {
        if (!isMounted) return;
        if (data && data.length > 0) {
          setAlreadyPassed(true);
        }
      });

    return () => {
      isMounted = false;
    };
  }, [exerciseId, session?.user.id]);

  async function handleSubmit() {
    if (!exercise) return;
    setSubmitting(true);
    setError(null);

    const supabase = getSupabaseClient();
    const submittedValues = Object.fromEntries(
      Object.entries(values).map(([key, value]) => [key, Number(value)]),
    );

    const { data, error: rpcError } = await supabase.rpc("grade_modeling_submission", {
      p_exercise_id: exerciseId,
      p_submitted_values: submittedValues,
    });

    setSubmitting(false);

    if (rpcError) {
      setError(rpcError.message);
      return;
    }

    setResult({
      score: data.score,
      passed: data.passed,
      breakdown: Object.fromEntries(
        Object.entries(data.metrics as Record<string, boolean>).map(([key, correct]) => [
          key,
          { correct },
        ]),
      ),
      alreadyCompleted: Boolean(data.already_completed),
    });
    if (data.passed) {
      setAlreadyPassed(true);
    }
  }

  if (error) {
    return <p className="text-sm text-red-500">Couldn&apos;t load exercise: {error}</p>;
  }

  if (result) {
    return (
      <ModelingResult
        result={result}
        onRetry={() => {
          setResult(null);
          setValues({});
        }}
      />
    );
  }

  if (!exercise) {
    return <p className="text-sm text-neutral-500">Loading exercise…</p>;
  }

  const metricKeys = extractMetricKeys(exercise.instructions);
  const allFilled = metricKeys.length > 0 && metricKeys.every((key) => values[key]?.trim());

  return (
    <div className="space-y-6">
      <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft">
        <h3 className="mb-2 text-lg font-semibold">{exercise.title}</h3>
        <p className="text-sm leading-relaxed text-neutral-600">{exercise.instructions}</p>
      </div>

      {alreadyPassed ? (
        <p className="rounded-[var(--radius-card)] border border-accent-400/40 bg-accent-400/10 px-4 py-3 text-sm font-medium text-accent-600">
          You&apos;ve already passed this exercise. Resubmitting is fine for practice, but won&apos;t
          award additional XP.
        </p>
      ) : null}

      <div className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft">
        <div className="space-y-4">
          {metricKeys.map((key) => (
            <label key={key} className="block">
              <span className="mb-1.5 block text-sm font-medium text-neutral-600">
                {humanizeMetricKey(key)}
              </span>
              <input
                type="number"
                inputMode="decimal"
                value={values[key] ?? ""}
                onChange={(event) =>
                  setValues((prev) => ({ ...prev, [key]: event.target.value }))
                }
                className="w-full rounded-xl border border-surface-border bg-background px-4 py-2.5 text-sm focus:border-primary-400 focus:outline-none"
              />
            </label>
          ))}
        </div>

        <Button disabled={!allFilled || submitting} className="mt-6" onClick={handleSubmit}>
          {submitting ? "Submitting…" : "Submit answer"}
        </Button>
      </div>
    </div>
  );
}
