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
  createStickyNoteShared,
  deleteStickyNoteShared,
  ensureStickyNotesLoaded,
  getStickyNotesSnapshot,
  updateStickyNoteShared,
} from "@/lib/sticky-notes/store";
import {
  createStickyNote,
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

  it("keeps a note created while the initial load is still in flight, instead of the fetch response wiping it out on arrival", async () => {
    let resolveFetch: (notes: StickyNote[]) => void = () => {};
    vi.mocked(fetchStickyNotes).mockReturnValue(
      new Promise((resolve) => {
        resolveFetch = resolve;
      }),
    );
    const created = makeNote({ id: "note-new", content: "written before load resolved" });
    vi.mocked(createStickyNote).mockResolvedValue(created);

    ensureStickyNotesLoaded("profile-1");
    // The fetch this triggered is still pending -- simulates a real create/save race
    // against network latency, which is exactly what a page-reload snapshot masks.
    await createStickyNoteShared({
      profileId: "profile-1",
      source: "/dashboard",
      positionX: 24,
      positionY: 24,
    });
    expect(getStickyNotesSnapshot()?.some((n) => n.id === "note-new")).toBe(true);

    resolveFetch([makeNote({ id: "note-old" })]);
    await vi.waitFor(() =>
      expect(getStickyNotesSnapshot()?.some((n) => n.id === "note-old")).toBe(true),
    );

    expect(getStickyNotesSnapshot()?.some((n) => n.id === "note-new")).toBe(true);
  });

  it("reverts an optimistic edit if the server update actually fails, rather than leaving the UI showing unsaved content as saved", async () => {
    vi.mocked(fetchStickyNotes).mockResolvedValue([makeNote({ content: "original" })]);
    vi.mocked(updateStickyNote).mockRejectedValue(new Error("network error"));

    ensureStickyNotesLoaded("profile-1");
    await vi.waitFor(() => expect(getStickyNotesSnapshot()).not.toBeNull());

    updateStickyNoteShared("note-1", { content: "edited but will fail to save" });
    expect(getStickyNotesSnapshot()?.find((n) => n.id === "note-1")?.content).toBe(
      "edited but will fail to save",
    );

    await vi.waitFor(() =>
      expect(getStickyNotesSnapshot()?.find((n) => n.id === "note-1")?.content).toBe("original"),
    );
  });

  it("does not let an older, slow-to-fail update revert a note after a newer update already succeeded", async () => {
    vi.mocked(fetchStickyNotes).mockResolvedValue([makeNote({ content: "original" })]);

    let rejectFirst: (error: Error) => void = () => {};
    vi.mocked(updateStickyNote).mockImplementationOnce(
      () =>
        new Promise((_resolve, reject) => {
          rejectFirst = reject;
        }),
    );
    vi.mocked(updateStickyNote).mockResolvedValueOnce(undefined);

    ensureStickyNotesLoaded("profile-1");
    await vi.waitFor(() => expect(getStickyNotesSnapshot()).not.toBeNull());

    // First save starts (slow) but hasn't resolved yet.
    updateStickyNoteShared("note-1", { content: "first edit" });
    // Second save starts and resolves before the first one fails.
    updateStickyNoteShared("note-1", { content: "second edit" });
    await vi.waitFor(() =>
      expect(getStickyNotesSnapshot()?.find((n) => n.id === "note-1")?.content).toBe(
        "second edit",
      ),
    );

    // Now the stale first save fails -- it must not clobber the successfully-saved second edit.
    rejectFirst(new Error("network error"));
    await Promise.resolve().then(() => Promise.resolve());

    expect(getStickyNotesSnapshot()?.find((n) => n.id === "note-1")?.content).toBe(
      "second edit",
    );
  });
});
