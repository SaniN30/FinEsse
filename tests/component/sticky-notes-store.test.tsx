import { beforeEach, describe, expect, it, vi } from "vitest";
import type { StickyNote } from "@/lib/supabase/types";

vi.mock("@/lib/sticky-notes/queries", () => ({
  fetchStickyNotes: vi.fn(),
  createStickyNote: vi.fn(),
  updateStickyNote: vi.fn(),
  deleteStickyNote: vi.fn(),
}));

import {
  clearStickyNotesStore,
  deleteStickyNoteShared,
  ensureStickyNotesLoaded,
  getStickyNotesSnapshot,
  updateStickyNoteShared,
} from "@/lib/sticky-notes/store";
import {
  deleteStickyNote,
  fetchStickyNotes,
  updateStickyNote,
} from "@/lib/sticky-notes/queries";

function makeNote(overrides: Partial<StickyNote> = {}): StickyNote {
  return {
    id: "note-1",
    profile_id: "profile-1",
    content: "hello",
    source: "/dashboard",
    position_x: 24,
    position_y: 24,
    width: 240,
    height: 220,
    created_at: "2026-08-01T00:00:00.000Z",
    updated_at: "2026-08-01T00:00:00.000Z",
    ...overrides,
  };
}

describe("sticky notes shared store", () => {
  beforeEach(() => {
    clearStickyNotesStore();
    vi.clearAllMocks();
  });

  it("makes an edit made via one surface (e.g. the widget) immediately visible to another surface reading the same snapshot (e.g. All Notes)", async () => {
    vi.mocked(fetchStickyNotes).mockResolvedValue([makeNote({ content: "original" })]);
    vi.mocked(updateStickyNote).mockResolvedValue(undefined);

    ensureStickyNotesLoaded("profile-1");
    await vi.waitFor(() => expect(getStickyNotesSnapshot()).not.toBeNull());

    updateStickyNoteShared("note-1", { content: "edited from widget" });

    const snapshot = getStickyNotesSnapshot();
    expect(snapshot?.find((n) => n.id === "note-1")?.content).toBe("edited from widget");
    expect(updateStickyNote).toHaveBeenCalledWith("note-1", { content: "edited from widget" });
  });

  it("removes a note from the shared snapshot when deleted from one surface, so the other surface no longer sees it", async () => {
    vi.mocked(fetchStickyNotes).mockResolvedValue([makeNote({ id: "note-1" }), makeNote({ id: "note-2" })]);
    vi.mocked(deleteStickyNote).mockResolvedValue(undefined);

    ensureStickyNotesLoaded("profile-1");
    await vi.waitFor(() => expect(getStickyNotesSnapshot()).not.toBeNull());

    deleteStickyNoteShared("note-1");

    const snapshot = getStickyNotesSnapshot();
    expect(snapshot?.some((n) => n.id === "note-1")).toBe(false);
    expect(snapshot?.some((n) => n.id === "note-2")).toBe(true);
    expect(deleteStickyNote).toHaveBeenCalledWith("note-1");
  });
});
