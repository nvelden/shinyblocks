// Single source of truth for site paths used in Playwright tests.
// Mirrors `basePath` in `next.config.ts`. If the basePath changes, edit here.

const BASE = "/shinyblocks";

export const PATH = {
  home: `${BASE}/`,
  getStarted: `${BASE}/get-started/`,
  components: `${BASE}/components/`,
  componentDetail: (slug: string) => `${BASE}/components/${slug}/`,
  changelog: `${BASE}/changelog/`,
} as const;
