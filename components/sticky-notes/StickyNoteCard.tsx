"use client";

import { useEffect, useRef, useState } from "react";
import type { StickyNote } from "@/lib/supabase/types";
import { getSourceTitle } from "@/lib/sticky-notes/source";

const MIN_WIDTH = 200;
const MIN_HEIGHT = 160;
const SAVED_FLASH_MS = 1400;

interface StickyNoteCardProps {
  note: StickyNote;
  onMove: (id: string, x: number, y: number) => void;
  onResize: (id: string, width: number, height: number) => void;
  onContentChange: (id: string, content: string) => void;
  onDelete: (id: string) => void;
}

export function StickyNoteCard({
  note,
  onMove,
  onResize,
  onContentChange,
  onDelete,
}: StickyNoteCardProps) {
  const [content, setContent] = useState(note.content);
  const [justSaved, setJustSaved] = useState(false);
  const dragState = useRef<{ startX: number; startY: number; originX: number; originY: number } | null>(null);
  const resizeState = useRef<{ startX: number; startY: number; originWidth: number; originHeight: number } | null>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // This card stays mounted across client-side navigation (the widget lives in the root
  // layout), so an edit made elsewhere (e.g. the All Notes page) arrives here as a prop
  // change, not a remount. Resetting local state from a prop change during render (rather
  // than in an effect) is React's documented pattern for this — see
  // https://react.dev/learn/you-might-not-need-an-effect#adjusting-some-state-when-a-prop-changes.
  const [prevNoteContent, setPrevNoteContent] = useState(note.content);
  if (note.content !== prevNoteContent) {
    setPrevNoteContent(note.content);
    setContent(note.content);
  }

  useEffect(() => {
    if (content === note.content) return;
    debounceRef.current = setTimeout(() => onContentChange(note.id, content), 500);
    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, [content, note.content, note.id, onContentChange]);

  useEffect(() => {
    if (!justSaved) return;
    const timeout = setTimeout(() => setJustSaved(false), SAVED_FLASH_MS);
    return () => clearTimeout(timeout);
  }, [justSaved]);

  // A note's saved position/size can come from a wider viewport (e.g. dragged
  // near the right edge on desktop). Clamp it back on screen whenever the
  // viewport is narrower than that, so it's never stuck off-screen and
  // undraggable on a phone.
  const noteGeometryRef = useRef(note);
  useEffect(() => {
    noteGeometryRef.current = note;
  }, [note]);

  useEffect(() => {
    function clampToViewport() {
      const current = noteGeometryRef.current;
      const maxWidth = Math.max(MIN_WIDTH, window.innerWidth - 16);
      const maxHeight = Math.max(MIN_HEIGHT, window.innerHeight - 16);
      const clampedWidth = Math.min(current.width, maxWidth);
      const clampedHeight = Math.min(current.height, maxHeight);
      if (clampedWidth !== current.width || clampedHeight !== current.height) {
        onResize(current.id, clampedWidth, clampedHeight);
      }
      const maxX = Math.max(0, window.innerWidth - clampedWidth);
      const maxY = Math.max(0, window.innerHeight - clampedHeight);
      const clampedX = Math.min(current.position_x, maxX);
      const clampedY = Math.min(current.position_y, maxY);
      if (clampedX !== current.position_x || clampedY !== current.position_y) {
        onMove(current.id, clampedX, clampedY);
      }
    }
    clampToViewport();
    window.addEventListener("resize", clampToViewport);
    return () => window.removeEventListener("resize", clampToViewport);
  }, [note.id, onMove, onResize]);

  function handleSaveClick(event: React.MouseEvent<HTMLButtonElement>) {
    event.stopPropagation();
    if (debounceRef.current) clearTimeout(debounceRef.current);
    onContentChange(note.id, content);
    setJustSaved(true);
  }

  function handleDragPointerDown(event: React.PointerEvent<HTMLDivElement>) {
    event.currentTarget.setPointerCapture(event.pointerId);
    dragState.current = {
      startX: event.clientX,
      startY: event.clientY,
      originX: note.position_x,
      originY: note.position_y,
    };
  }

  function handleDragPointerMove(event: React.PointerEvent<HTMLDivElement>) {
    if (!dragState.current) return;
    const { startX, startY, originX, originY } = dragState.current;
    const nextX = Math.max(0, originX + (event.clientX - startX));
    const nextY = Math.max(0, originY + (event.clientY - startY));
    onMove(note.id, nextX, nextY);
  }

  function handleDragPointerUp(event: React.PointerEvent<HTMLDivElement>) {
    event.currentTarget.releasePointerCapture(event.pointerId);
    dragState.current = null;
  }

  function handleResizePointerDown(event: React.PointerEvent<HTMLDivElement>) {
    event.stopPropagation();
    event.currentTarget.setPointerCapture(event.pointerId);
    resizeState.current = {
      startX: event.clientX,
      startY: event.clientY,
      originWidth: note.width,
      originHeight: note.height,
    };
  }

  function handleResizePointerMove(event: React.PointerEvent<HTMLDivElement>) {
    if (!resizeState.current) return;
    const { startX, startY, originWidth, originHeight } = resizeState.current;
    const nextWidth = Math.max(MIN_WIDTH, originWidth + (event.clientX - startX));
    const nextHeight = Math.max(MIN_HEIGHT, originHeight + (event.clientY - startY));
    onResize(note.id, nextWidth, nextHeight);
  }

  function handleResizePointerUp(event: React.PointerEvent<HTMLDivElement>) {
    event.stopPropagation();
    event.currentTarget.releasePointerCapture(event.pointerId);
    resizeState.current = null;
  }

  return (
    <div
      className="pointer-events-auto fixed z-50 flex flex-col overflow-hidden rounded-2xl border-2 border-foreground bg-surface shadow-[var(--shadow-offset)]"
      style={{
        left: note.position_x,
        top: note.position_y,
        width: note.width,
        height: note.height,
      }}
      data-testid="sticky-note"
    >
      <div
        onPointerDown={handleDragPointerDown}
        onPointerMove={handleDragPointerMove}
        onPointerUp={handleDragPointerUp}
        className="flex touch-none cursor-grab items-center justify-between gap-2 border-b-2 border-foreground bg-tier-school/20 px-3 py-1.5 active:cursor-grabbing"
      >
        <span
          className="truncate font-display text-sm font-semibold text-foreground"
          title={note.source}
        >
          {getSourceTitle(note.source)}
        </span>
        <div className="flex shrink-0 items-center gap-1">
          <button
            type="button"
            aria-label="Save note"
            title="Save"
            onPointerDown={(event) => event.stopPropagation()}
            onClick={handleSaveClick}
            className="flex h-6 items-center gap-1 rounded-full px-2 text-xs font-medium text-foreground/70 transition-colors hover:bg-surface hover:text-foreground"
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
            onPointerDown={(event) => event.stopPropagation()}
            onClick={() => onDelete(note.id)}
            className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full text-foreground/70 transition-colors hover:bg-surface hover:text-foreground"
          >
            ×
          </button>
        </div>
      </div>
      <textarea
        value={content}
        onChange={(event) => setContent(event.target.value)}
        placeholder="Write a note…"
        className="flex-1 resize-none bg-transparent p-3 text-sm text-foreground outline-none placeholder:text-muted-foreground"
      />
      <div
        onPointerDown={handleResizePointerDown}
        onPointerMove={handleResizePointerMove}
        onPointerUp={handleResizePointerUp}
        aria-hidden
        className="absolute bottom-0 right-0 h-6 w-6 touch-none cursor-nwse-resize"
      >
        <div className="absolute bottom-1 right-1 h-2 w-2 border-b-2 border-r-2 border-foreground/50" />
      </div>
    </div>
  );
}
