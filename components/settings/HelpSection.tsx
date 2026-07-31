"use client";

import { useState } from "react";
import { Button } from "@/components/Button";
import { FormField } from "@/components/auth/FormField";
import { SettingsSection } from "@/components/settings/SettingsSection";

export function HelpSection() {
  const [message, setMessage] = useState("");
  const [sent, setSent] = useState(false);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSent(true);
  }

  return (
    <SettingsSection
      title="Help & issues"
      description="All systems normal. Tell us what's wrong and we'll follow up by email."
    >
      {sent ? (
        <p className="text-sm text-neutral-500">
          Thanks — we&apos;ve got your message and will follow up by email.
        </p>
      ) : (
        <form onSubmit={handleSubmit} className="max-w-md">
          <FormField
            label="What's going on?"
            name="issue"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            required
          />
          <Button type="submit" size="md" variant="secondary">
            Send
          </Button>
        </form>
      )}
    </SettingsSection>
  );
}
