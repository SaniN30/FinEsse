"use client";

import { useRef } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/cn";

interface PinInputProps {
  length?: number;
  value: string;
  onChange: (value: string) => void;
  label?: string;
  autoFocus?: boolean;
}

export function PinInput({ length = 6, value, onChange, label, autoFocus }: PinInputProps) {
  const digits = value.padEnd(length, " ").slice(0, length).split("");
  const refs = useRef<Array<HTMLInputElement | null>>([]);

  function setDigit(index: number, char: string) {
    const clean = char.replace(/[^0-9]/g, "").slice(-1);
    const next = value.split("");
    next[index] = clean;
    const joined = next.join("").slice(0, length);
    onChange(joined);
    if (clean && index < length - 1) {
      refs.current[index + 1]?.focus();
    }
  }

  function handleKeyDown(index: number, event: React.KeyboardEvent<HTMLInputElement>) {
    if (event.key === "Backspace" && !digits[index].trim() && index > 0) {
      refs.current[index - 1]?.focus();
    }
  }

  return (
    <div className="mb-4">
      {label ? (
        <p className="mb-2 text-sm font-medium text-foreground">{label}</p>
      ) : null}
      <div className="flex gap-2" role="group" aria-label={label ?? "PIN"}>
        {Array.from({ length }).map((_, index) => (
          <motion.input
            key={index}
            ref={(el) => {
              refs.current[index] = el;
            }}
            autoFocus={autoFocus && index === 0}
            inputMode="numeric"
            pattern="[0-9]*"
            maxLength={1}
            value={digits[index].trim()}
            onChange={(e) => setDigit(index, e.target.value)}
            onKeyDown={(e) => handleKeyDown(index, e)}
            whileFocus={{ scale: 1.05 }}
            aria-label={`PIN digit ${index + 1}`}
            className={cn(
              "h-14 w-12 rounded-xl border border-surface-border bg-background text-center text-2xl font-semibold text-foreground focus:border-primary-400 focus:outline-none focus:ring-2 focus:ring-primary-400/30 sm:h-16 sm:w-14",
            )}
          />
        ))}
      </div>
    </div>
  );
}
