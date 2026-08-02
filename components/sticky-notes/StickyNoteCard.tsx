"use client";

import { useEffect, useRef, useState } from "react";
import type { StickyNote } from "@/lib/supabase/types";

const MIN_WIDTH = 200;
const MIN_HEIGHT = 160;

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
  const dragState = useRef<{ startX: number; startY: number; originX: number; originY: number } | null>(null);
  const resizeState = useRef<{ startX: number; startY: number; originWidth: number; originHeight: number } | null>(null);

  useEffect(() => {
    if (content === note.content) return;
    const timeout = setTimeout(() => onContentChange(note.id, content), 500);
    return () => clearTimeout(timeout);
  }, [content, note.content, note.id, onContentChange]);

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
        className="flex cursor-grab items-center justify-between gap-2 border-b-2 border-foreground bg-tier-school/20 px-3 py-1.5 active:cursor-grabbing"
      >
        <span className="truncate text-xs font-medium text-muted-foreground" title={note.source}>
          {note.source}
        </span>
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
        className="absolute bottom-0 right-0 h-4 w-4 cursor-nwse-resize"
      >
        <div className="absolute bottom-1 right-1 h-2 w-2 border-b-2 border-r-2 border-foreground/50" />
      </div>
    </div>
  );
}
