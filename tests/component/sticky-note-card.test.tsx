import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { StickyNoteCard } from "@/components/sticky-notes/StickyNoteCard";
import type { StickyNote } from "@/lib/supabase/types";

// jsdom doesn't implement the Pointer Events capture API that the drag/resize
// handlers call; real browsers do, so this only needs to be a no-op stub here.
if (!Element.prototype.setPointerCapture) {
  Element.prototype.setPointerCapture = () => {};
}
if (!Element.prototype.releasePointerCapture) {
  Element.prototype.releasePointerCapture = () => {};
}

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

describe("StickyNoteCard", () => {
  it("deletes the note when its header delete button is clicked, without the drag handler swallowing the click", async () => {
    const user = userEvent.setup();
    const onDelete = vi.fn();
    render(
      <StickyNoteCard
        note={makeNote()}
        onMove={vi.fn()}
        onResize={vi.fn()}
        onContentChange={vi.fn()}
        onDelete={onDelete}
      />,
    );

    await user.click(screen.getByRole("button", { name: /delete note/i }));

    expect(onDelete).toHaveBeenCalledWith("note-1");
  });

  it("allows editing the note's text and debounces the content-change callback", async () => {
    vi.useFakeTimers();
    const onContentChange = vi.fn();
    const note = makeNote({ content: "" });
    render(
      <StickyNoteCard
        note={note}
        onMove={vi.fn()}
        onResize={vi.fn()}
        onContentChange={onContentChange}
        onDelete={vi.fn()}
      />,
    );

    const textarea = screen.getByPlaceholderText(/write a note/i);
    fireEvent.change(textarea, { target: { value: "buy milk" } });

    expect(onContentChange).not.toHaveBeenCalled();
    vi.advanceTimersByTime(600);
    expect(onContentChange).toHaveBeenCalledWith("note-1", "buy milk");
    vi.useRealTimers();
  });

  it("shows the source label in the header", () => {
    render(
      <StickyNoteCard
        note={makeNote({ source: "/college/lessons/budgeting-basics" })}
        onMove={vi.fn()}
        onResize={vi.fn()}
        onContentChange={vi.fn()}
        onDelete={vi.fn()}
      />,
    );

    expect(screen.getByTitle("/college/lessons/budgeting-basics")).toBeInTheDocument();
  });
});
