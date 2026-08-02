"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Nav } from "@/components/Nav";
import { useAuth } from "@/lib/supabase/auth-context";
import {
  deleteStickyNote,
  fetchStickyNotes,
  updateStickyNote,
} from "@/lib/sticky-notes/queries";
import { getSourceTitle } from "@/lib/sticky-notes/source";
import type { StickyNote } from "@/lib/supabase/types";

const SAVED_FLASH_MS = 1400;

function formatTimestamp(iso: string): string {
  return new Date(iso).toLocaleString(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  });
}

export default function AllNotesPage() {
  const router = useRouter();
  const { session, loading } = useAuth();
  const [notes, setNotes] = useState<StickyNote[] | null>(null);
  const [savedIds, setSavedIds] = useState<Record<string, boolean>>({});
  const savedTimeouts = useRef<Record<string, ReturnType<typeof setTimeout>>>({});

  useEffect(() => {
    if (!loading && !session) {
      router.replace("/login");
    }
  }, [loading, session, router]);

  useEffect(() => {
    if (!session) return;
    fetchStickyNotes().then(setNotes);
  }, [session]);

  useEffect(() => {
    const timeouts = savedTimeouts.current;
    return () => {
      Object.values(timeouts).forEach(clearTimeout);
    };
  }, []);

  function handleContentChange(id: string, content: string) {
    setNotes((prev) => (prev ?? []).map((note) => (note.id === id ? { ...note, content } : note)));
  }

  function handleContentBlur(id: string, content: string) {
    void updateStickyNote(id, { content });
  }

  function handleSaveClick(id: string, content: string) {
    void updateStickyNote(id, { content });
    setSavedIds((prev) => ({ ...prev, [id]: true }));
    if (savedTimeouts.current[id]) clearTimeout(savedTimeouts.current[id]);
    savedTimeouts.current[id] = setTimeout(() => {
      setSavedIds((prev) => ({ ...prev, [id]: false }));
    }, SAVED_FLASH_MS);
  }

  function handleDelete(id: string) {
    setNotes((prev) => (prev ?? []).filter((note) => note.id !== id));
    void deleteStickyNote(id);
  }

  if (loading || !session) {
    return null;
  }

  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-3xl flex-1 px-6 py-16">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: [0.25, 1, 0.5, 1] as const }}
        >
          <p className="mb-2 text-sm font-semibold uppercase tracking-wide text-primary-500">
            Notes
          </p>
          <h1 className="mb-8 text-3xl font-semibold tracking-tight">All notes</h1>

          {notes === null ? (
            <p className="text-sm text-muted-foreground">Loading notes…</p>
          ) : notes.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              No notes yet — use the sticky note button in the corner of any page to add one.
            </p>
          ) : (
            <ul className="space-y-4">
              {notes.map((note) => (
                <li
                  key={note.id}
                  className="rounded-[var(--radius-card)] border-2 border-foreground bg-surface p-5 shadow-[var(--shadow-offset)]"
                >
                  <div className="mb-3 flex items-center justify-between gap-4">
                    <span className="truncate font-display text-lg font-semibold text-foreground">
                      {getSourceTitle(note.source)}
                    </span>
                    <div className="flex shrink-0 items-center gap-3">
                      <span className="text-xs text-muted-foreground">
                        {formatTimestamp(note.created_at)}
                      </span>
                      <button
                        type="button"
                        aria-label="Save note"
                        onClick={() => handleSaveClick(note.id, note.content)}
                        className="text-xs font-medium text-foreground/70 transition-colors hover:text-foreground"
                      >
                        {savedIds[note.id] ? (
                          <span className="text-primary-500" aria-live="polite">
                            ✓ Saved
                          </span>
                        ) : (
                          "Save"
                        )}
                      </button>
                      <button
                        type="button"
                        aria-label="Delete note"
                        onClick={() => handleDelete(note.id)}
                        className="text-xs font-medium text-foreground/70 transition-colors hover:text-foreground"
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                  <textarea
                    value={note.content}
                    onChange={(event) => handleContentChange(note.id, event.target.value)}
                    onBlur={(event) => handleContentBlur(note.id, event.target.value)}
                    placeholder="Write a note…"
                    rows={3}
                    className="w-full resize-y rounded-lg bg-transparent text-sm text-foreground outline-none placeholder:text-muted-foreground"
                  />
                </li>
              ))}
            </ul>
          )}
        </motion.div>
      </main>
    </div>
  );
}
