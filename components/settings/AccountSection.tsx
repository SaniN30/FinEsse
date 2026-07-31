"use client";

import { useState } from "react";
import { Button } from "@/components/Button";
import { FormField } from "@/components/auth/FormField";
import { SettingsSection } from "@/components/settings/SettingsSection";
import { renameChildProfile, updateParentPassword } from "@/lib/settings/queries";
import type { Profile } from "@/lib/supabase/types";

interface AccountSectionProps {
  email: string | undefined;
  children: Profile[];
  onChildRenamed: (childId: string, displayName: string) => void;
}

export function AccountSection({ email, children, onChildRenamed }: AccountSectionProps) {
  const [newPassword, setNewPassword] = useState("");
  const [passwordStatus, setPasswordStatus] = useState<string | null>(null);
  const [editingChildId, setEditingChildId] = useState<string | null>(null);
  const [childNameDraft, setChildNameDraft] = useState("");
  const [childStatus, setChildStatus] = useState<string | null>(null);

  async function handlePasswordChange(e: React.FormEvent) {
    e.preventDefault();
    setPasswordStatus(null);
    try {
      await updateParentPassword(newPassword);
      setNewPassword("");
      setPasswordStatus("Password updated.");
    } catch (err: unknown) {
      setPasswordStatus(err instanceof Error ? err.message : "Could not update password.");
    }
  }

  async function handleChildRename(childId: string) {
    setChildStatus(null);
    try {
      await renameChildProfile(childId, childNameDraft);
      onChildRenamed(childId, childNameDraft);
      setEditingChildId(null);
      setChildStatus("Updated.");
    } catch (err: unknown) {
      setChildStatus(err instanceof Error ? err.message : "Could not rename child.");
    }
  }

  return (
    <SettingsSection title="Account" description="Your email, password, and linked children.">
      <div>
        <p className="text-sm font-medium text-foreground">Email</p>
        <p className="text-sm text-neutral-500">{email ?? "—"}</p>
      </div>

      <form onSubmit={handlePasswordChange} className="max-w-sm">
        <FormField
          label="New password"
          type="password"
          name="new-password"
          value={newPassword}
          onChange={(e) => setNewPassword(e.target.value)}
          minLength={8}
          required
        />
        <Button type="submit" size="md" variant="secondary">
          Change password
        </Button>
        {passwordStatus ? (
          <p className="mt-2 text-xs text-neutral-500">{passwordStatus}</p>
        ) : null}
      </form>

      <div>
        <p className="mb-2 text-sm font-medium text-foreground">Linked children</p>
        {children.length === 0 ? (
          <p className="text-sm text-neutral-500">No children linked yet.</p>
        ) : (
          <ul className="space-y-2">
            {children.map((child) => (
              <li
                key={child.id}
                className="flex items-center gap-3 rounded-xl border border-surface-border px-4 py-2.5"
              >
                {editingChildId === child.id ? (
                  <>
                    <input
                      className="flex-1 rounded-lg border border-surface-border bg-background px-3 py-1.5 text-sm"
                      value={childNameDraft}
                      onChange={(e) => setChildNameDraft(e.target.value)}
                    />
                    <Button size="md" onClick={() => handleChildRename(child.id)}>
                      Save
                    </Button>
                    <Button size="md" variant="ghost" onClick={() => setEditingChildId(null)}>
                      Cancel
                    </Button>
                  </>
                ) : (
                  <>
                    <span className="flex-1 text-sm">{child.display_name ?? "Unnamed"}</span>
                    <Button
                      size="md"
                      variant="ghost"
                      onClick={() => {
                        setEditingChildId(child.id);
                        setChildNameDraft(child.display_name ?? "");
                      }}
                    >
                      Rename
                    </Button>
                  </>
                )}
              </li>
            ))}
          </ul>
        )}
        {childStatus ? <p className="mt-2 text-xs text-neutral-500">{childStatus}</p> : null}
      </div>
    </SettingsSection>
  );
}
