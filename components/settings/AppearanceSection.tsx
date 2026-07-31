"use client";

import { useEffect, useState } from "react";
import { cn } from "@/lib/cn";
import { SettingsSection } from "@/components/settings/SettingsSection";
import {
  getStoredThemePreference,
  setThemePreference,
  type ThemePreference,
} from "@/lib/settings/theme";

const OPTIONS: { value: ThemePreference; label: string }[] = [
  { value: "light", label: "Light" },
  { value: "dark", label: "Dark" },
  { value: "system", label: "System" },
];

export function AppearanceSection() {
  const [preference, setPreference] = useState<ThemePreference>("system");

  useEffect(() => {
    setPreference(getStoredThemePreference());
  }, []);

  function handleSelect(value: ThemePreference) {
    setPreference(value);
    setThemePreference(value);
  }

  return (
    <SettingsSection title="Appearance" description="Light, dark, or match your system.">
      <div className="flex gap-2">
        {OPTIONS.map((option) => (
          <button
            key={option.value}
            type="button"
            onClick={() => handleSelect(option.value)}
            className={cn(
              "rounded-xl border px-4 py-2 text-sm font-medium transition-colors",
              preference === option.value
                ? "border-primary-500 bg-primary-50 text-primary-700"
                : "border-surface-border text-neutral-500 hover:border-primary-400",
            )}
          >
            {option.label}
          </button>
        ))}
      </div>
    </SettingsSection>
  );
}
