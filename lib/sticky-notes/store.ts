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

/**
 * Ids created/deleted locally while a loadFromServer() fetch is in flight. The fetch's
 * response reflects a server snapshot taken when the request was sent, so it can resolve
 * after — and silently overwrite — a create/delete that happened during the round trip.
 * Reconciled against the fetch result in loadFromServer rather than assigning it directly.
 */
let createdSinceLoadStarted: StickyNote[] = [];
let deletedSinceLoadStarted = new Set<string>();

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
  createdSinceLoadStarted = [];
  deletedSinceLoadStarted = new Set();
  const fetched = await fetchStickyNotes();

  const fetchedIds = new Set(fetched.map((note) => note.id));
  const missingLocalCreates = createdSinceLoadStarted.filter(
    (note) => !fetchedIds.has(note.id) && !deletedSinceLoadStarted.has(note.id),
  );
  notes = [...missingLocalCreates, ...fetched].filter(
    (note) => !deletedSinceLoadStarted.has(note.id),
  );
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
  if (inFlight) createdSinceLoadStarted = [created, ...createdSinceLoadStarted];
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

/**
 * A failed update must not leave the UI showing a "Saved" state for content the server
 * never received — reverting the optimistic patch on rejection surfaces the loss instead
 * of silently diverging from what's actually persisted.
 */
export function updateStickyNoteShared(id: string, input: UpdateStickyNoteInput): void {
  const previous = (notes ?? []).find((note) => note.id === id);
  patchStickyNoteLocal(id, input);
  updateStickyNote(id, input).catch(() => {
    if (!previous) return;
    notes = (notes ?? []).map((note) => (note.id === id ? previous : note));
    notify();
  });
}

export function deleteStickyNoteShared(id: string): void {
  if (inFlight) deletedSinceLoadStarted.add(id);
  notes = (notes ?? []).filter((note) => note.id !== id);
  notify();
  void deleteStickyNote(id);
}
