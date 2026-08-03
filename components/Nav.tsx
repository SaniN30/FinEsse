"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Button } from "@/components/Button";
import { Logo } from "@/components/Logo";
import { useAuth } from "@/lib/supabase/auth-context";
import { isParentWithChildFlow } from "@/lib/supabase/profile-helpers";

const links = [
  { href: "/school", label: "School" },
  { href: "/college", label: "College" },
  { href: "/job-ready", label: "Job-Ready" },
  { href: "/practice", label: "Practice" },
];

export function Nav() {
  const router = useRouter();
  const { session, profile, signOut } = useAuth();
  const showParentDashboard = Boolean(session) && isParentWithChildFlow(profile);
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  return (
    <motion.header
      initial={{ opacity: 0, y: -16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, ease: [0.25, 1, 0.5, 1] as const }}
      className="sticky top-0 z-40 bg-background/0 px-4 pt-4"
    >
      <div className="mx-auto flex max-w-6xl items-center justify-between rounded-full border-2 border-foreground bg-surface px-5 py-3 shadow-[var(--shadow-offset)]">
        <Link href="/" className="flex items-center gap-2">
          <Logo size="sm" />
          <span className="font-display text-lg font-semibold tracking-tight">
            FinEsse
          </span>
        </Link>
        <nav className="hidden items-center gap-8 text-sm font-medium text-muted-foreground sm:flex">
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
        <div className="flex items-center gap-2 sm:hidden">
          <button
            type="button"
            aria-label={isMenuOpen ? "Close menu" : "Open menu"}
            aria-expanded={isMenuOpen}
            onClick={() => setIsMenuOpen((open) => !open)}
            className="flex h-11 w-11 items-center justify-center rounded-full text-foreground transition-colors hover:bg-surface"
          >
            <span className="sr-only">Menu</span>
            <div className="flex h-4 w-5 flex-col justify-between">
              <span
                className={`h-0.5 w-full bg-current transition-transform ${isMenuOpen ? "translate-y-[7px] rotate-45" : ""}`}
              />
              <span className={`h-0.5 w-full bg-current transition-opacity ${isMenuOpen ? "opacity-0" : ""}`} />
              <span
                className={`h-0.5 w-full bg-current transition-transform ${isMenuOpen ? "-translate-y-[7px] -rotate-45" : ""}`}
              />
            </div>
          </button>
        </div>
        <div className="hidden sm:flex">
          {session ? (
            <div className="flex items-center gap-3">
              {showParentDashboard ? (
                <a href="/dashboard" className="text-sm font-medium text-muted-foreground hover:text-foreground">
                  Dashboard
                </a>
              ) : null}
              <a href="/notes" className="text-sm font-medium text-muted-foreground hover:text-foreground">
                Notes
              </a>
              <a href="/settings" className="text-sm font-medium text-muted-foreground hover:text-foreground">
                Settings
              </a>
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
      </div>
      {isMenuOpen ? (
        <nav className="mx-auto mt-2 flex max-w-6xl flex-col gap-1 rounded-2xl border-2 border-foreground bg-surface px-4 py-3 text-sm font-medium text-muted-foreground shadow-[var(--shadow-offset)] sm:hidden">
          {links.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="rounded-lg px-2 py-3 transition-colors hover:bg-surface hover:text-foreground"
              onClick={() => setIsMenuOpen(false)}
            >
              {link.label}
            </a>
          ))}
          {session ? (
            <>
              {showParentDashboard ? (
                <a
                  href="/dashboard"
                  className="rounded-lg px-2 py-3 transition-colors hover:bg-surface hover:text-foreground"
                  onClick={() => setIsMenuOpen(false)}
                >
                  Dashboard
                </a>
              ) : null}
              <a
                href="/notes"
                className="rounded-lg px-2 py-3 transition-colors hover:bg-surface hover:text-foreground"
                onClick={() => setIsMenuOpen(false)}
              >
                Notes
              </a>
              <a
                href="/settings"
                className="rounded-lg px-2 py-3 transition-colors hover:bg-surface hover:text-foreground"
                onClick={() => setIsMenuOpen(false)}
              >
                Settings
              </a>
              <Button
                size="md"
                variant="secondary"
                onClick={async () => {
                  setIsMenuOpen(false);
                  await signOut();
                  router.push("/");
                }}
              >
                Log out
              </Button>
            </>
          ) : (
            <Button
              size="md"
              onClick={() => {
                setIsMenuOpen(false);
                router.push("/signup");
              }}
            >
              Get started
            </Button>
          )}
        </nav>
      ) : null}
    </motion.header>
  );
}
