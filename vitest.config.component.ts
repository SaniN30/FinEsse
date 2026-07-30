import { defineConfig } from "vitest/config";
import path from "node:path";

export default defineConfig({
  test: {
    include: ["tests/component/**/*.test.tsx"],
    environment: "jsdom",
    globals: true,
    setupFiles: ["./tests/component/setup.ts"],
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "."),
    },
  },
});
