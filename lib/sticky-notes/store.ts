/**
 * Shared in-memory cache for sticky notes, subscribed to via useSyncExternalStore
 * by both the floating widget (mounted once in app/layout.tsx) and the All Notes
 * page (a separate route/component instance). Without this, each held its own
 * fetched-once copy: a create/edit/delete in one wouldn't appear in the other
 * until a full remount, since nothing invalidated or re-fetched the other's state.
 */
import type { StickyNote } from "@/lib/supabase/types";
import {
  createStickyNote,
  deleteStickyNote,
  fetchStickyNotes,
  updateStickyNote,
  type CreateStickyNoteInput,
  type UpdateStickyNoteInput,
} from "@/lib/sticky-notes/queries";

type Listener = () => void;

let notes: StickyNote[] | null = null;
let loadedForProfileId: string | null = null;
let inFlight: Promise<void> | null = null;
const listeners = new Set<Listener>();

function notify(): void {
  listeners.forEach((listener) => listener());
}

export function subscribeStickyNotes(listener: Listener): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function getStickyNotesSnapshot(): StickyNote[] | null {
  return notes;
}

async function loadFromServer(profileId: string): Promise<void> {
  notes = await fetchStickyNotes();
  loadedForProfileId = profileId;
  notify();
}

export function ensureStickyNotesLoaded(profileId: string): void {
  if (loadedForProfileId === profileId && notes !== null) return;
  if (inFlight) return;
  inFlight = loadFromServer(profileId).finally(() => {
    inFlight = null;
  });
}

export function clearStickyNotesStore(): void {
  notes = null;
  loadedForProfileId = null;
  notify();
}

export async function createStickyNoteShared(input: CreateStickyNoteInput): Promise<StickyNote> {
  const created = await createStickyNote(input);
  notes = [created, ...(notes ?? [])];
  notify();
  return created;
}

/** Optimistically patches the shared cache without writing to the server — for per-keystroke edits ahead of a debounced/explicit save. */
export function patchStickyNoteLocal(id: string, input: UpdateStickyNoteInput): void {
  notes = (notes ?? []).map((note) =>
    note.id === id
      ? {
          ...note,
          ...(input.content !== undefined ? { content: input.content } : {}),
          ...(input.positionX !== undefined ? { position_x: input.positionX } : {}),
          ...(input.positionY !== undefined ? { position_y: input.positionY } : {}),
          ...(input.width !== undefined ? { width: input.width } : {}),
          ...(input.height !== undefined ? { height: input.height } : {}),
          updated_at: new Date().toISOString(),
        }
      : note,
  );
  notify();
}

export function updateStickyNoteShared(id: string, input: UpdateStickyNoteInput): void {
  patchStickyNoteLocal(id, input);
  void updateStickyNote(id, input);
}

export function deleteStickyNoteShared(id: string): void {
  notes = (notes ?? []).filter((note) => note.id !== id);
  notify();
  void deleteStickyNote(id);
}
