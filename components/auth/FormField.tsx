"use client";

import { cn } from "@/lib/cn";

interface FormFieldProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
}

export function FormField({ label, error, className, id, ...props }: FormFieldProps) {
  const inputId = id ?? props.name;

  return (
    <div className="mb-4">
      <label htmlFor={inputId} className="mb-1.5 block text-sm font-medium text-foreground">
        {label}
      </label>
      <input
        id={inputId}
        className={cn(
          "w-full rounded-xl border border-surface-border bg-background px-4 py-2.5 text-sm text-foreground placeholder:text-neutral-400 focus:border-primary-400 focus:outline-none focus:ring-2 focus:ring-primary-400/30",
          error && "border-red-400 focus:border-red-400 focus:ring-red-400/30",
          className,
        )}
        {...props}
      />
      {error ? <p className="mt-1.5 text-xs font-medium text-red-500">{error}</p> : null}
    </div>
  );
}
