"use client";

import { useEffect, useRef, useState, useSyncExternalStore } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Nav } from "@/components/Nav";
import { useAuth } from "@/lib/supabase/auth-context";
import {
  clearStickyNotesStore,
  deleteStickyNoteShared,
  ensureStickyNotesLoaded,
  getStickyNotesSnapshot,
  subscribeStickyNotes,
  updateStickyNoteShared,
} from "@/lib/sticky-notes/store";
import { getSourceTitle } from "@/lib/sticky-notes/source";
import type { StickyNote } from "@/lib/supabase/types";

const SAVED_FLASH_MS = 1400;

function formatTimestamp(iso: string): string {
  return new Date(iso).toLocaleString(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  });
}

interface NoteListItemProps {
  note: StickyNote;
  onDelete: (id: string) => void;
}

/**
 * Buffers edits in local state (like StickyNoteCard's textarea) rather than binding
 * the textarea directly to the shared store: a fully store-controlled value here would
 * be raced by every store notify() while typing, silently discarding keystrokes before
 * Save ever sees them.
 */
function NoteListItem({ note, onDelete }: NoteListItemProps) {
  const [content, setContent] = useState(note.content);
  const [justSaved, setJustSaved] = useState(false);
  const savedTimeout = useRef<ReturnType<typeof setTimeout> | null>(null);

  // This row stays mounted across shared-store updates from elsewhere (e.g. an edit made
  // in the widget), so it needs to resync when note.content changes underneath it.
  // Resetting local state from a prop change during render (rather than in an effect) is
  // React's documented pattern — see
  // https://react.dev/learn/you-might-not-need-an-effect#adjusting-some-state-when-a-prop-changes.
  const [prevNoteContent, setPrevNoteContent] = useState(note.content);
  if (note.content !== prevNoteContent) {
    setPrevNoteContent(note.content);
    setContent(note.content);
  }

  useEffect(() => {
    return () => {
      if (savedTimeout.current) clearTimeout(savedTimeout.current);
    };
  }, []);

  function handleBlur() {
    if (content === note.content) return;
    updateStickyNoteShared(note.id, { content });
  }

  function handleSaveClick() {
    updateStickyNoteShared(note.id, { content });
    setJustSaved(true);
    if (savedTimeout.current) clearTimeout(savedTimeout.current);
    savedTimeout.current = setTimeout(() => setJustSaved(false), SAVED_FLASH_MS);
  }

  return (
    <li className="rounded-[var(--radius-card)] border-2 border-foreground bg-surface p-5 shadow-[var(--shadow-offset)]">
      <div className="mb-3 flex items-center justify-between gap-4">
        <span className="truncate font-display text-lg font-semibold text-foreground">
          {getSourceTitle(note.source)}
        </span>
        <div className="flex shrink-0 items-center gap-3">
          <span className="text-xs text-muted-foreground">{formatTimestamp(note.created_at)}</span>
          <button
            type="button"
            aria-label="Save note"
            onClick={handleSaveClick}
            className="text-xs font-medium text-foreground/70 transition-colors hover:text-foreground"
          >
            {justSaved ? (
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
            onClick={() => onDelete(note.id)}
            className="text-xs font-medium text-foreground/70 transition-colors hover:text-foreground"
          >
            Delete
          </button>
        </div>
      </div>
      <textarea
        value={content}
        onChange={(event) => setContent(event.target.value)}
        onBlur={handleBlur}
        placeholder="Write a note…"
        rows={3}
        className="w-full resize-y rounded-lg bg-transparent text-sm text-foreground outline-none placeholder:text-muted-foreground"
      />
    </li>
  );
}

export default function AllNotesPage() {
  const router = useRouter();
  const { session, loading } = useAuth();
  const notes = useSyncExternalStore(subscribeStickyNotes, getStickyNotesSnapshot, () => null);

  useEffect(() => {
    if (!loading && !session) {
      router.replace("/login");
    }
  }, [loading, session, router]);

  useEffect(() => {
    if (!session) {
      clearStickyNotesStore();
      return;
    }
    ensureStickyNotesLoaded(session.user.id);
  }, [session]);

  function handleDelete(id: string) {
    deleteStickyNoteShared(id);
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
                <NoteListItem key={note.id} note={note} onDelete={handleDelete} />
              ))}
            </ul>
          )}
        </motion.div>
      </main>
    </div>
  );
}
