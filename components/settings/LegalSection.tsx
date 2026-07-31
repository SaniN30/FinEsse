"use client";

import { useEffect, useState } from "react";
import { Button } from "@/components/Button";
import { SettingsSection } from "@/components/settings/SettingsSection";
import { fetchParentConsentRecords, type ConsentRecord } from "@/lib/settings/queries";

export function LegalSection() {
  const [records, setRecords] = useState<ConsentRecord[] | null>(null);
  const [deleteRequested, setDeleteRequested] = useState(false);

  useEffect(() => {
    let isMounted = true;
    fetchParentConsentRecords()
      .then((data) => {
        if (isMounted) setRecords(data);
      })
      .catch(() => {
        if (isMounted) setRecords([]);
      });
    return () => {
      isMounted = false;
    };
  }, []);

  return (
    <SettingsSection title="Legal">
      <a href="/privacy" className="text-sm font-medium text-primary-500 hover:underline">
        Privacy policy
      </a>

      <div>
        <p className="mb-2 text-sm font-medium text-foreground">Consent records</p>
        {records === null ? (
          <p className="text-sm text-neutral-500">Loading…</p>
        ) : records.length === 0 ? (
          <p className="text-sm text-neutral-500">No consent records yet.</p>
        ) : (
          <ul className="space-y-2">
            {records.map((record) => (
              <li
                key={record.id}
                className="rounded-xl border border-surface-border px-4 py-2.5 text-sm"
              >
                <span className="font-medium">{record.child_display_name}</span>
                <span className="text-neutral-500">
                  {" "}
                  — {record.consent_given ? "consent given" : "not given"}, v
                  {record.consent_version}, recorded{" "}
                  {new Date(record.created_at).toLocaleDateString()}
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>

      <div>
        {deleteRequested ? (
          <p className="text-sm text-neutral-500">
            Request received. Email us at{" "}
            <a href="mailto:privacy@finesse.app" className="text-primary-500 hover:underline">
              privacy@finesse.app
            </a>{" "}
            from your account email to confirm — we&apos;ll process the deletion from there.
          </p>
        ) : (
          <Button size="md" variant="secondary" onClick={() => setDeleteRequested(true)}>
            Delete account
          </Button>
        )}
      </div>
    </SettingsSection>
  );
}
