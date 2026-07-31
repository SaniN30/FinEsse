"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Nav } from "@/components/Nav";
import { AccountSection } from "@/components/settings/AccountSection";
import { AppearanceSection } from "@/components/settings/AppearanceSection";
import { NotificationsSection } from "@/components/settings/NotificationsSection";
import { HelpSection } from "@/components/settings/HelpSection";
import { LegalSection } from "@/components/settings/LegalSection";
import { useAuth } from "@/lib/supabase/auth-context";
import { fetchLinkedChildren } from "@/lib/supabase/auth-actions";
import type { Profile } from "@/lib/supabase/types";

export default function SettingsPage() {
  const router = useRouter();
  const { session, loading } = useAuth();
  const [children, setChildren] = useState<Profile[]>([]);

  useEffect(() => {
    if (!loading && !session) {
      router.replace("/login");
    }
  }, [loading, session, router]);

  useEffect(() => {
    if (!session) return;
    fetchLinkedChildren(session.user.id).then(({ data }) => {
      if (data) setChildren(data);
    });
  }, [session]);

  function handleChildRenamed(childId: string, displayName: string) {
    setChildren((prev) =>
      prev.map((child) => (child.id === childId ? { ...child, display_name: displayName } : child)),
    );
  }

  if (loading || !session) {
    return null;
  }

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-2xl flex-1 px-6 py-16">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
        >
          <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-primary-500">
            Settings
          </p>
          <h1 className="mb-8 text-3xl font-semibold tracking-tight">Account &amp; preferences</h1>

          <div className="space-y-6">
            <AccountSection
              email={session.user.email}
              linkedChildren={children}
              onChildRenamed={handleChildRenamed}
            />
            <AppearanceSection />
            <NotificationsSection />
            <HelpSection />
            <LegalSection />
          </div>
        </motion.div>
      </main>
    </div>
  );
}
