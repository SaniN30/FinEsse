const METRIC_KEY_PATTERN = /"([a-zA-Z0-9_]+)":\s*<number>/g;

/**
 * Modeling exercise instructions always spell out the exact submission shape
 * as `{"key": <number>, ...}` (see seed content in
 * supabase/migrations/00000000000016_seed_college_content.sql) since the
 * rubric itself is never exposed to the client. Parsing the keys out of that
 * convention lets the form render one numeric input per metric without
 * hardcoding exercise-specific field lists.
 */
export function extractMetricKeys(instructions: string): string[] {
  const keys: string[] = [];
  for (const match of instructions.matchAll(METRIC_KEY_PATTERN)) {
    keys.push(match[1]);
  }
  return keys;
}

export function humanizeMetricKey(key: string): string {
  return key
    .split("_")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}
