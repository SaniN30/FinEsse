"use client";

import { motion } from "framer-motion";
import { useRouter } from "next/navigation";
import { Button } from "@/components/Button";
import { useAuth } from "@/lib/supabase/auth-context";

const links = [
  { href: "/school", label: "School" },
  { href: "/college", label: "College" },
  { href: "/job-ready", label: "Job-Ready" },
];

export function Nav() {
  const router = useRouter();
  const { session, profile, signOut } = useAuth();
  const isParent = Boolean(session) && profile?.role !== "student";

  return (
    <motion.header
      initial={{ opacity: 0, y: -16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, ease: [0.25, 1, 0.5, 1] as const }}
      className="sticky top-0 z-40 border-b border-surface-border/70 bg-background/80 backdrop-blur-md"
    >
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
        <span className="font-display text-lg font-semibold tracking-tight">
          FinEsse
        </span>
        <nav className="hidden items-center gap-8 text-sm font-medium text-neutral-500 sm:flex">
          {links.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="transition-colors hover:text-foreground"
            >
              {link.label}
            </a>
          ))}
        </nav>
        {session ? (
          <div className="flex items-center gap-3">
            {isParent ? (
              <a href="/dashboard" className="text-sm font-medium text-neutral-500 hover:text-foreground">
                Dashboard
              </a>
            ) : null}
            <Button
              size="md"
              variant="secondary"
              onClick={async () => {
                await signOut();
                router.push("/");
              }}
            >
              Log out
            </Button>
          </div>
        ) : (
          <Button size="md" onClick={() => router.push("/signup")}>
            Get started
          </Button>
        )}
      </div>
    </motion.header>
  );
}
