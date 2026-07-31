"use client";

import { useState } from "react";
import { SettingsSection } from "@/components/settings/SettingsSection";

const STORAGE_KEY = "finesse-notification-prefs";

interface NotificationPrefs {
  weeklyDigest: boolean;
  streakReminders: boolean;
}

const DEFAULT_PREFS: NotificationPrefs = { weeklyDigest: true, streakReminders: true };

function loadPrefs(): NotificationPrefs {
  if (typeof window === "undefined") return DEFAULT_PREFS;
  try {
    const stored = window.localStorage.getItem(STORAGE_KEY);
    return stored ? { ...DEFAULT_PREFS, ...JSON.parse(stored) } : DEFAULT_PREFS;
  } catch {
    return DEFAULT_PREFS;
  }
}

export function NotificationsSection() {
  const [prefs, setPrefs] = useState<NotificationPrefs>(() => loadPrefs());

  function toggle(key: keyof NotificationPrefs) {
    const next = { ...prefs, [key]: !prefs[key] };
    setPrefs(next);
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
  }

  return (
    <SettingsSection
      title="Notifications"
      description="No backend delivery yet for these — your choice is saved on this device."
    >
      <label className="flex items-center justify-between gap-4">
        <span className="text-sm">Weekly progress digest</span>
        <input
          type="checkbox"
          checked={prefs.weeklyDigest}
          onChange={() => toggle("weeklyDigest")}
          className="h-5 w-5 accent-primary-500"
        />
      </label>
      <label className="flex items-center justify-between gap-4">
        <span className="text-sm">Streak reminders</span>
        <input
          type="checkbox"
          checked={prefs.streakReminders}
          onChange={() => toggle("streakReminders")}
          className="h-5 w-5 accent-primary-500"
        />
      </label>
    </SettingsSection>
  );
}
