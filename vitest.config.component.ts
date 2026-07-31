import path from "node:path";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "."),
    },
  },
  test: {
    environment: "jsdom",
    globals: true,
    include: ["tests/component/**/*.test.tsx", "tests/components/**/*.test.tsx"],
    setupFiles: ["./tests/component/setup.ts", "tests/components/setup.ts"],
  },
});
