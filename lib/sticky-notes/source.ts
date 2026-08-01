/**
 * A lightweight label of "where" a note was created. The app has no
 * per-page document titles (only the root layout sets one), so the route
 * path is the reliable signal -- captured once at create time and stored on
 * the note row, never re-derived later.
 */
export function getCurrentSourceLabel(pathname: string): string {
  return pathname || "/";
}
