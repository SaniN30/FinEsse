import { getSupabaseClient } from "@/lib/supabase/client";
import type { StickyNote } from "@/lib/supabase/types";

export interface CreateStickyNoteInput {
  profileId: string;
  source: string;
  positionX: number;
  positionY: number;
}

export async function fetchStickyNotes(): Promise<StickyNote[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("sticky_notes")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) throw error;
  return (data ?? []) as StickyNote[];
}

export async function createStickyNote(
  input: CreateStickyNoteInput,
): Promise<StickyNote> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("sticky_notes")
    .insert({
      profile_id: input.profileId,
      source: input.source,
      position_x: input.positionX,
      position_y: input.positionY,
    })
    .select("*")
    .single();

  if (error) throw error;
  return data as StickyNote;
}

export interface UpdateStickyNoteInput {
  content?: string;
  positionX?: number;
  positionY?: number;
  width?: number;
  height?: number;
}

export async function updateStickyNote(
  id: string,
  input: UpdateStickyNoteInput,
): Promise<void> {
  const supabase = getSupabaseClient();
  const patch: Record<string, unknown> = { updated_at: new Date().toISOString() };
  if (input.content !== undefined) patch.content = input.content;
  if (input.positionX !== undefined) patch.position_x = input.positionX;
  if (input.positionY !== undefined) patch.position_y = input.positionY;
  if (input.width !== undefined) patch.width = input.width;
  if (input.height !== undefined) patch.height = input.height;

  const { error } = await supabase.from("sticky_notes").update(patch).eq("id", id);
  if (error) throw error;
}

export async function deleteStickyNote(id: string): Promise<void> {
  const supabase = getSupabaseClient();
  const { error } = await supabase.from("sticky_notes").delete().eq("id", id);
  if (error) throw error;
}
