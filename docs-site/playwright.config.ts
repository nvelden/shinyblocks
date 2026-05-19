import { defineConfig, devices } from "@playwright/test";

// The site is served at /shinyblocks/ (via Next basePath). Tests use the
// `PATH` constants exported from `tests/e2e/paths.ts` so they read naturally
// and stay easy to update if the basePath ever changes.
const PORT = 3000;
const baseURL = process.env.PLAYWRIGHT_BASE_URL ?? `http://localhost:${PORT}`;

export default defineConfig({
  testDir: "./tests/e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? [["html"], ["github"]] : "list",
  use: {
    baseURL,
    trace: "on-first-retry",
    screenshot: "only-on-failure",
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "webkit", use: { ...devices["Desktop Safari"] } },
  ],
  // Skip starting a server if a base URL is supplied (e.g. when running
  // against an already-running local preview).
  //
  // Otherwise build the static export and serve it through the same wrapper
  // used by `npm run preview` (so `/shinyblocks/` resolves the same way it
  // will on GitHub Pages).
  webServer: process.env.PLAYWRIGHT_BASE_URL
    ? undefined
    : {
        command: "npm run build && PORT=3000 node scripts/serve-preview.mjs",
        url: `http://localhost:${PORT}/shinyblocks/`,
        timeout: 180_000,
        reuseExistingServer: !process.env.CI,
      },
});
