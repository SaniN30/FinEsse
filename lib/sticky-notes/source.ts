/**
 * A lightweight label of "where" a note was created. The app has no
 * per-page document titles (only the root layout sets one), so the route
 * path is the reliable signal -- captured once at create time and stored on
 * the note row, never re-derived later.
 */
export function getCurrentSourceLabel(pathname: string): string {
  return pathname || "/";
}

const SEGMENT_TITLES: Record<string, string> = {
  school: "School",
  college: "College",
  "job-ready": "Job-Ready",
  lessons: "Lessons",
  lesson: "Lesson",
  quiz: "Quiz",
  roles: "Roles",
  modeling: "Modeling",
  interview: "Interview Coach",
  "pocket-money": "Pocket Money",
  settings: "Settings",
  dashboard: "Dashboard",
  parent: "Parent",
  notes: "Notes",
};

function titleCaseSegment(segment: string): string {
  return SEGMENT_TITLES[segment] ?? segment.replace(/-/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

/**
 * A readable page title derived from a note's stored `source` route path,
 * used to style the note's heading like the rest of the app's headings
 * rather than showing the raw path.
 */
export function getSourceTitle(source: string): string {
  if (!source || source === "/") return "Home";
  const segments = source.split("/").filter(Boolean).slice(0, 2);
  return segments.map(titleCaseSegment).join(" · ");
}
