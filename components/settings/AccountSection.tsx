"use client";

import { useState } from "react";
import { Button } from "@/components/Button";
import { FormField } from "@/components/auth/FormField";
import { SettingsSection } from "@/components/settings/SettingsSection";
import { renameChildProfile, updateParentPassword, updateProfileCurrency } from "@/lib/settings/queries";
import { CURRENCY_OPTIONS, currencyOrDefault, type CurrencyCode } from "@/lib/currency/config";
import type { Profile } from "@/lib/supabase/types";

interface AccountSectionProps {
  email: string | undefined;
  profile: Profile | null;
  linkedChildren: Profile[];
  onChildRenamed: (childId: string, displayName: string) => void;
  onChildCurrencyChanged: (childId: string, currency: CurrencyCode) => void;
}

export function AccountSection({
  email,
  profile,
  linkedChildren,
  onChildRenamed,
  onChildCurrencyChanged,
}: AccountSectionProps) {
  const [newPassword, setNewPassword] = useState("");
  const [passwordStatus, setPasswordStatus] = useState<string | null>(null);
  const [editingChildId, setEditingChildId] = useState<string | null>(null);
  const [childNameDraft, setChildNameDraft] = useState("");
  const [childStatus, setChildStatus] = useState<string | null>(null);
  const [currency, setCurrency] = useState<CurrencyCode>(currencyOrDefault(profile?.currency));
  const [currencyStatus, setCurrencyStatus] = useState<string | null>(null);
  const [childCurrencyStatus, setChildCurrencyStatus] = useState<string | null>(null);

  async function handleCurrencyChange(nextCurrency: CurrencyCode) {
    if (!profile || nextCurrency === currency) return;
    const previousCurrency = currency;
    setCurrency(nextCurrency);
    setCurrencyStatus(null);
    try {
      await updateProfileCurrency(profile.id, nextCurrency);
      setCurrencyStatus("Updated.");
    } catch (err: unknown) {
      setCurrency(previousCurrency);
      setCurrencyStatus(err instanceof Error ? err.message : "Could not update currency.");
    }
  }

  async function handleChildCurrencyChange(childId: string, nextCurrency: CurrencyCode) {
    setChildCurrencyStatus(null);
    try {
      await updateProfileCurrency(childId, nextCurrency);
      onChildCurrencyChanged(childId, nextCurrency);
      setChildCurrencyStatus("Updated.");
    } catch (err: unknown) {
      setChildCurrencyStatus(err instanceof Error ? err.message : "Could not update currency.");
    }
  }

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
        <p className="text-sm text-muted-foreground">{email ?? "—"}</p>
      </div>

      {profile ? (
        <div className="max-w-sm">
          <label htmlFor="account-currency" className="mb-1.5 block text-sm font-medium text-foreground">
            Pocket Money currency
          </label>
          <select
            id="account-currency"
            value={currency}
            onChange={(e) => handleCurrencyChange(e.target.value as CurrencyCode)}
            className="w-full rounded-xl border border-surface-border bg-background px-4 py-2.5 text-sm text-foreground focus:border-primary-400 focus:outline-none focus:ring-2 focus:ring-primary-400/30"
          >
            {CURRENCY_OPTIONS.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
          {currencyStatus ? (
            <p className="mt-2 text-xs text-muted-foreground">{currencyStatus}</p>
          ) : null}
        </div>
      ) : null}

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
          <p className="mt-2 text-xs text-muted-foreground">{passwordStatus}</p>
        ) : null}
      </form>

      <div>
        <p className="mb-2 text-sm font-medium text-foreground">Linked children</p>
        {linkedChildren.length === 0 ? (
          <p className="text-sm text-muted-foreground">No children linked yet.</p>
        ) : (
          <ul className="space-y-2">
            {linkedChildren.map((child) => (
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
                    <label className="sr-only" htmlFor={`child-currency-${child.id}`}>
                      Currency for {child.display_name ?? "this student"}
                    </label>
                    <select
                      id={`child-currency-${child.id}`}
                      value={currencyOrDefault(child.currency)}
                      onChange={(e) =>
                        handleChildCurrencyChange(child.id, e.target.value as CurrencyCode)
                      }
                      className="rounded-lg border border-surface-border bg-background px-2 py-1.5 text-xs"
                    >
                      {CURRENCY_OPTIONS.map((option) => (
                        <option key={option.value} value={option.value}>
                          {option.value}
                        </option>
                      ))}
                    </select>
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
        {childStatus ? <p className="mt-2 text-xs text-muted-foreground">{childStatus}</p> : null}
        {childCurrencyStatus ? (
          <p className="mt-2 text-xs text-muted-foreground">{childCurrencyStatus}</p>
        ) : null}
      </div>
    </SettingsSection>
  );
}
