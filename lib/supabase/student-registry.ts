// The backend never exposes a way to look up a student's synthetic login
// email from just their display name (profiles has no public read policy for
// unauthenticated clients, by design - see BACKEND.md RLS section). So the PIN
// login screen can only offer accounts this device has already seen: each
// login_email returned by create-student-account is cached here, keyed to
// this browser, purely to make the child-facing PIN pad usable without typing
// an email. It is not an auth mechanism - the PIN itself is still verified by
// Supabase Auth on every sign-in.
const STORAGE_KEY = "finesse:known-students";

export interface KnownStudent {
  studentId: string;
  displayName: string;
  loginEmail: string;
}

export function rememberStudent(student: KnownStudent) {
  if (typeof window === "undefined") return;
  const existing = listKnownStudents().filter((s) => s.studentId !== student.studentId);
  const next = [...existing, student];
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
}

export function listKnownStudents(): KnownStudent[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    return JSON.parse(raw) as KnownStudent[];
  } catch {
    return [];
  }
}
