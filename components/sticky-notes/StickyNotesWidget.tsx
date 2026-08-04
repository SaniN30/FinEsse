"use client";

import { useCallback, useEffect, useSyncExternalStore } from "react";
import { usePathname } from "next/navigation";
import { useAuth } from "@/lib/supabase/auth-context";
import { getCurrentSourceLabel } from "@/lib/sticky-notes/source";
import {
  clearStickyNotesStore,
  createStickyNoteShared,
  deleteStickyNoteShared,
  ensureStickyNotesLoaded,
  getStickyNotesSnapshot,
  subscribeStickyNotes,
  updateStickyNoteShared,
} from "@/lib/sticky-notes/store";
import { StickyNoteCard } from "@/components/sticky-notes/StickyNoteCard";

const NEW_NOTE_OFFSET = 32;

export function StickyNotesWidget() {
  const { session } = useAuth();
  const pathname = usePathname();
  const notes = useSyncExternalStore(subscribeStickyNotes, getStickyNotesSnapshot, () => null);

  useEffect(() => {
    if (!session) {
      clearStickyNotesStore();
      return;
    }
    ensureStickyNotesLoaded(session.user.id);
  }, [session]);

  const handleCreate = useCallback(async () => {
    if (!session) return;
    const offset = ((notes?.length ?? 0) % 6) * NEW_NOTE_OFFSET;
    await createStickyNoteShared({
      profileId: session.user.id,
      source: getCurrentSourceLabel(pathname),
      positionX: 24 + offset,
      positionY: 96 + offset,
    });
  }, [session, notes, pathname]);

  const handleMove = useCallback((id: string, x: number, y: number) => {
    updateStickyNoteShared(id, { positionX: x, positionY: y });
  }, []);

  const handleResize = useCallback((id: string, width: number, height: number) => {
    updateStickyNoteShared(id, { width, height });
  }, []);

  const handleContentChange = useCallback((id: string, content: string) => {
    updateStickyNoteShared(id, { content });
  }, []);

  const handleDelete = useCallback((id: string) => {
    deleteStickyNoteShared(id);
  }, []);

  if (!session) return null;

  return (
    <>
      {(notes ?? []).map((note) => (
        <StickyNoteCard
          key={note.id}
          note={note}
          onMove={handleMove}
          onResize={handleResize}
          onContentChange={handleContentChange}
          onDelete={handleDelete}
        />
      ))}
      <div className="group fixed bottom-6 right-6 z-50">
        <span
          role="tooltip"
          className="pointer-events-none absolute bottom-full right-0 mb-2 w-max max-w-[14rem] rounded-lg border-2 border-foreground bg-surface px-3 py-1.5 text-xs font-medium text-foreground opacity-0 shadow-[var(--shadow-offset)] transition-opacity duration-150 group-hover:opacity-100"
        >
          Click to jot down your important notes
        </span>
        <button
          type="button"
          onClick={handleCreate}
          aria-label="New sticky note"
          title="Click to jot down your important notes"
          className="flex h-14 w-14 items-center justify-center rounded-full border-2 border-foreground bg-primary-500 text-2xl font-semibold text-white shadow-[var(--shadow-offset)] transition-transform hover:-translate-y-0.5"
        >
          +
        </button>
      </div>
    </>
  );
}
