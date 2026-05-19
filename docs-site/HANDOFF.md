# Docs site — Handoff guide

**You are picking up a partially-built docs site for the `shinyblocks` R package.**

Phase 0 (kill pkgdown), Phase 1 (Next.js scaffold), and Phase 7 (GitHub Actions) are **already done**. You will implement Phases 2–6.

---

## Before you start: read these files, in this order

1. **`docs/agent-plans/2026-05-19-custom-docs-site.md`** — architecture, wireframes, what every page should look like
2. **`docs/agent-plans/2026-05-19-docs-site-build-plan.md`** — the 8 phases and what each one delivers
3. **`docs/agent-plans/2026-05-19-docs-site-DESIGN.md`** — exact colors, spacing, fonts, components per surface
4. **`docs/agent-plans/2026-05-19-docs-site-DEVELOPMENT.md`** — per-phase gates + Playwright tests you must pass

If anything in this handoff disagrees with those four docs, **the docs win**.

---

## The rules

1. **Do exactly one phase at a time. Do not skip ahead.**
2. **Every phase ends in a green `npm run test:e2e`.** If tests fail, fix them before moving on.
3. **Never touch the R package** (anything outside `docs-site/`). The R package is unrelated to this work.
4. **Do not add new dependencies** unless the phase explicitly says so. The current `package.json` has everything you need for Phases 2–6.
5. **Do not change `next.config.ts`.** The `basePath: "/shinyblocks"` is correct and must stay.
6. **No shinylive in v1.** Every Shiny preview — landing gallery, components index, component detail playground — is **static HTML prerendered from R**. Never embed `<iframe src="https://shinylive.io/...">`, never install `lz-string`, never add a "Run example" button. Shinylive is a v2 upgrade.
7. **If you get stuck, stop and write what you tried into a comment in the file. Do not delete tests to make them pass.**

---

## How to run the site locally

From inside `docs-site/`:

```bash
npm install            # first time only
npm run dev                # opens http://localhost:3000/shinyblocks  (fast dev mode)
npm run build              # static export → out/
npm run preview            # build + serve out/ at http://localhost:4173/shinyblocks/
npm run test:e2e           # Playwright tests (auto-builds + serves)
npm run test:e2e:install   # one-time: install Playwright browsers
```

The site is served at **`/shinyblocks`** (not `/`). This is because GitHub Pages serves it at `https://nvelden.github.io/shinyblocks/`. If `npm run dev` shows a blank page at `localhost:3000`, go to `localhost:3000/shinyblocks` instead.

### Reviewing a CI build locally

The repo is private, so PR previews aren't deployed online. Instead the `docs-tests` workflow uploads the static export as an artifact called **`docs-site-out`**. To review a PR:

```bash
# In GitHub: PR → Checks → "Docs site tests" → Artifacts → download docs-site-out.zip
unzip docs-site-out.zip -d preview
npx serve preview --listen 4173
open http://localhost:4173/shinyblocks/
```

---

## What's already built (Phase 1 — DO NOT REDO)

```
docs-site/
  app/
    layout.tsx                  ← root layout, fonts, theme provider, header, footer
    page.tsx                    ← landing PLACEHOLDER (Phase 3 replaces this)
    globals.css                 ← Tailwind v4 + shinyblocks design tokens
    components/page.tsx         ← /components PLACEHOLDER (Phase 4 replaces this)
    changelog/page.tsx          ← /changelog PLACEHOLDER (Phase 6 replaces this)
  components/
    site-header.tsx             ← top nav with logo, links, GitHub, theme toggle
    site-footer.tsx
    theme-provider.tsx          ← wraps next-themes
    theme-toggle.tsx            ← 3-state Light/Dark/System buttons
  lib/
    utils.ts                    ← cn() helper for class names
  public/.nojekyll              ← required for GitHub Pages
  tests/e2e/
    smoke.spec.ts               ← Phase 1 smoke tests (KEEP GREEN)
  next.config.ts                ← basePath="/shinyblocks", output="export"
  playwright.config.ts
  postcss.config.mjs            ← Tailwind v4 plugin
  tsconfig.json
  package.json
```

GitHub Actions (already wired):
- `.github/workflows/docs-deploy.yml` — push to main → deploy to GH Pages
- `.github/workflows/docs-tests.yml` — PR → run Playwright

---

## Phase 2 — Static UI prerender pipeline

**Read first**: build plan Phase 2, architecture doc section "Static UI prerender".

**Goal**: an R script that takes Shiny UI from `block_*()` functions and writes static HTML fragments to disk. The landing page and components index will display these as non-interactive previews.

### Files you create

1. `docs-site/content/previews/_registry.R` — the list of components. Each entry must have `name`, `slug`, `file`, `description`, `featured`. Example:

   ```r
   registry <- list(
     list(name = "Button",   slug = "button",   file = "button.R",   description = "Trigger an action with a click.",   featured = TRUE),
     list(name = "Card",     slug = "card",     file = "card.R",     description = "Group related content.",            featured = TRUE)
     # …
   )
   ```

   **Important**: only add a component to the registry once its preview file (next step) exists. Empty entries break the build.

2. `docs-site/content/previews/<slug>.R` — one per registered component. Each file must end with a single `htmltools::tagList(...)` or Shiny tag object. Look at `inst/showcase/` in the R package for real `block_*()` calls you can copy.

3. `docs-site/scripts/generate-previews.R` — the generator. It must:
   - Source `_registry.R`
   - For each entry, source the preview file, call `htmltools::renderTags()`, write the HTML to `<slug>.html` next to the `.R` file
   - Resolve all HTML dependencies and copy them into `docs-site/public/runtime/` (so the CSS is reachable at `/shinyblocks/runtime/shinyblocks.css`)
   - Write a JSON manifest at `docs-site/lib/preview-manifest.json` listing every `{ slug, name, description, featured }` so React code doesn't need to parse R

4. `docs-site/components/component-preview.tsx` — React component that:
   - Accepts props: `slug`, `name`, `href`, `html` (raw HTML string)
   - Wraps the HTML in a card with `pointer-events: none` on the inner div
   - The whole card is a `<Link>` to `href`
   - Has `data-component-preview="<slug>"` for tests

5. Update `app/layout.tsx` to also load the prerendered CSS:
   ```tsx
   <link rel="stylesheet" href="/shinyblocks/runtime/shinyblocks.css" />
   ```
   (Add it to the `<head>` — Next.js layouts support this via the `head` export or via a `<link>` inside the layout. Use whichever pattern Next 15 docs recommend.)

6. Update `package.json` prebuild script:
   ```json
   "prebuild": "Rscript scripts/generate-previews.R"
   ```

### Phase 2 Playwright tests (add to `tests/e2e/`)

Create `tests/e2e/prerender.spec.ts`:

```ts
import { test, expect } from "@playwright/test";
import { existsSync } from "node:fs";

test("preview manifest is generated", () => {
  expect(existsSync("lib/preview-manifest.json")).toBe(true);
});

test("runtime CSS is loaded on every page", async ({ page }) => {
  await page.goto("/");
  const hasCss = await page.evaluate(() =>
    [...document.styleSheets].some((s) => s.href?.includes("runtime/shinyblocks.css")),
  );
  expect(hasCss).toBe(true);
});
```

### Phase 2 gate

- [ ] `Rscript scripts/generate-previews.R` runs without errors
- [ ] Every registered component has a `.html` sibling
- [ ] `lib/preview-manifest.json` exists and lists every component
- [ ] `public/runtime/shinyblocks.css` exists
- [ ] `npm run test:e2e` is green

---

## Phase 3 — Landing page gallery

**Read first**: build plan Phase 3, architecture doc "Landing page" wireframe.

**Goal**: replace `app/page.tsx` with a hero + a gallery of `<ComponentPreview>` cards.

### Steps

1. Edit `app/page.tsx`:
   - Keep the hero (badge, H1, subtitle, 2 CTAs) as-is from the placeholder
   - Below the hero, render the gallery:
     ```tsx
     import previewManifest from "@/lib/preview-manifest.json";
     // For each featured entry, import its HTML via raw text.
     // Use Next 15's `import { readFile } from "fs/promises"` in a Server Component,
     // or pre-bake the HTML into the manifest itself.
     ```
   - **Simpler approach**: have `generate-previews.R` embed the HTML directly into `preview-manifest.json` as a string field. Then React can iterate the manifest without any file IO.
2. Use CSS columns for the masonry: `columns-1 md:columns-2 lg:columns-4 gap-4`
3. Each card uses `<ComponentPreview>` from Phase 2

### Phase 3 Playwright tests

Create `tests/e2e/landing.spec.ts`:

```ts
import { test, expect } from "@playwright/test";

test("hero CTAs are present", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("link", { name: /get started/i })).toBeVisible();
  await expect(page.getByRole("link", { name: /view components/i })).toBeVisible();
});

test("gallery renders featured component cards", async ({ page }) => {
  await page.goto("/");
  const cards = page.locator("[data-component-preview]");
  expect(await cards.count()).toBeGreaterThan(0);
});

test("clicking a gallery card navigates to detail page", async ({ page }) => {
  await page.goto("/");
  await page.locator("[data-component-preview]").first().click();
  await expect(page).toHaveURL(/\/components\/[a-z-]+\/?$/);
});

test("no horizontal scroll on mobile", async ({ page }) => {
  await page.setViewportSize({ width: 375, height: 800 });
  await page.goto("/");
  const overflow = await page.evaluate(
    () => document.documentElement.scrollWidth > window.innerWidth,
  );
  expect(overflow).toBe(false);
});
```

### Phase 3 gate

- [ ] Hero matches Phase 1 placeholder layout
- [ ] Gallery shows every `featured: true` registry entry
- [ ] All cards link to `/components/<slug>` (404s are OK at this phase; Phase 5 fixes them)
- [ ] `npm run test:e2e` is green in both Chromium and WebKit

---

## Phase 4 — Components index page

**Read first**: build plan Phase 4, architecture doc "Components index".

**Goal**: replace `app/components/page.tsx` with a denser grid of every component (not only featured), plus a client-side filter input.

### Steps

1. Make it a Client Component (`"use client"` at the top) so the filter state can live in `useState`
2. Grid: `grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4`
3. Filter: `<input>` with `aria-label="Filter components"`, substring match on `name`
4. Empty state: show "No components match" when filter yields zero

### Phase 4 Playwright tests

Create `tests/e2e/components-index.spec.ts`. Test the full list, the filter, and the empty state. See DEVELOPMENT.md Phase 4 for examples.

### Phase 4 gate

- [ ] Every registry entry visible by default
- [ ] Typing in the filter narrows the grid
- [ ] Empty state appears for a non-matching filter
- [ ] `npm run test:e2e` is green

---

## Phase 5 — Per-component detail pages

**Read first**: build plan Phase 5, architecture doc "Component page" wireframe, DESIGN.md "Component detail page".

**Plan to spend ~1.5 days here.**

**Goal**: a static route at `/components/<slug>` for every component, with a three-column layout: components rail (left), playground (center), on-this-page TOC (right).

### IMPORTANT: v1 has NO shinylive

The playground is **statically prerendered HTML**, exactly like the landing gallery — just shown one tab at a time. There are **no iframes**, **no "Run example" button**, **no lz-encoding**, **no shinylive of any kind**. Shinylive is a v2 upgrade we will tackle later. If you find yourself reaching for `lz-string` or `https://shinylive.io/...`, stop — you've gone off-plan.

Each component has four playground variants (Content / State / Styling / Actions), each is a separate R file, and each gets prerendered to its own static HTML fragment. The tabs just swap which fragment is displayed.

### Steps (in this order — do not skip)

1. **Author example files** for every component:
   - `content/examples/<slug>/content.R`
   - `content/examples/<slug>/state.R`
   - `content/examples/<slug>/styling.R`
   - `content/examples/<slug>/actions.R`

   Each file must end with a single `htmltools::tagList(...)` or Shiny tag object (same contract as Phase 2 preview files). Lift the snippets from `inst/showcase/` in the R package — that's where the existing playground source lives.

2. **Extend `scripts/generate-previews.R` from Phase 2** to also process these example files. For each component slug, for each of the four tabs:
   - Source the `.R` file
   - `htmltools::renderTags()` → write to `<tab>.html` next to the `.R`
   - Capture the raw R source as a string

   Then update the manifest to also include, per component:
   ```json
   {
     "slug": "button",
     "playground": {
       "content":  { "html": "<...>", "source": "block_button(...)" },
       "state":    { "html": "<...>", "source": "..." },
       "styling":  { "html": "<...>", "source": "..." },
       "actions":  { "html": "<...>", "source": "..." }
     }
   }
   ```
   Embedding both `html` and `source` strings directly in the manifest is the easiest path — React reads one file at build time.

3. **Author API stubs** for every component: `content/api/<slug>.json`. Look at `man/<fn>.Rd` for the arg list. Shape:
   ```json
   [
     { "name": "inputId", "type": "character", "default": "—", "description": "Shiny input id." },
     { "name": "label",   "type": "character", "default": "NULL", "description": "Visible button text." }
   ]
   ```

4. **Add the route**: `app/components/[slug]/page.tsx`. Use `generateStaticParams()` to pre-render every slug from the manifest. Mark as a Server Component (no `"use client"` at the top).

5. **`<ComponentsNav>` (left rail)**: alphabetical list of every component from the manifest. Current slug gets `bg-accent text-accent-foreground`. Sticky on desktop (`lg:sticky lg:top-14`). On mobile (`< lg`), hide it or move into a Sheet — your call, just keep the page readable.

6. **Right-side TOC** (`<TableOfContents>`): scroll-spy over the page's `<h2>` headings. Small Client Component using `IntersectionObserver`. Active heading: `text-foreground font-medium`.

7. **`<PlaygroundTabs>` component** — this is the heart of the page:
   - Client Component
   - Props: `playground` (the four-tab object from the manifest for this slug)
   - State: `const [tab, setTab] = useState<"content" | "state" | "styling" | "actions">("content")`
   - Renders four tab triggers + a preview area + a code pane
   - Preview area: `<div data-playground-preview dangerouslySetInnerHTML={{ __html: playground[tab].html }} className="pointer-events-none" />`
   - Code pane: `<pre><code>{playground[tab].source}</code></pre>` with a copy button
   - **No iframes. No Run button. No shinylive.**

8. **Installation block**: tabs for Command / Manual. Inside Command, three pills for `remotes` / `pak` / `devtools`, each showing the install snippet. Tiny copy button per snippet.

9. **`<ApiTable>` component**: Server Component, reads `content/api/<slug>.json` (use `fs.readFileSync` since it's build-time) and renders a styled HTML table. Header row uses `bg-muted/40 text-xs uppercase`.

10. **Page assembly** in `[slug]/page.tsx`: title `<h1>`, description, then `<h2>` headings for Preview, Installation, Usage, API Reference — these are what the right TOC scroll-spies on.

### Phase 5 Playwright tests

Create `tests/e2e/component-detail.spec.ts`:

```ts
import { test, expect } from "@playwright/test";
import manifest from "../../lib/preview-manifest.json";

test("every registered component has a page", async ({ page }) => {
  for (const entry of manifest as Array<{ slug: string; name: string }>) {
    const res = await page.goto(`/components/${entry.slug}`);
    expect(res?.status()).toBeLessThan(400);
    await expect(page.getByRole("heading", { level: 1 })).toContainText(entry.name);
  }
});

test("left rail SPA-navigates (no full reload)", async ({ page }) => {
  await page.goto("/components/button");
  const start = await page.evaluate(() => performance.now());
  await page.getByRole("navigation", { name: /components/i })
            .getByRole("link", { name: /^card$/i }).click();
  await expect(page).toHaveURL(/\/components\/card\/?$/);
  const elapsed = (await page.evaluate(() => performance.now())) - start;
  expect(elapsed).toBeLessThan(2000);
});

test("playground tabs swap both preview and source", async ({ page }) => {
  await page.goto("/components/button");
  const sourceBefore = (await page.locator("pre code").first().innerText());
  await page.getByRole("tab", { name: /actions/i }).click();
  const sourceAfter = (await page.locator("pre code").first().innerText());
  expect(sourceAfter).not.toEqual(sourceBefore);
});

test("no iframes on the playground (v1 is static)", async ({ page }) => {
  await page.goto("/components/button");
  await expect(page.locator("iframe")).toHaveCount(0);
});

test("playground preview is non-interactive", async ({ page }) => {
  await page.goto("/components/button");
  const preview = page.locator("[data-playground-preview]").first();
  await expect(preview).toHaveCSS("pointer-events", "none");
});

test("API table renders from JSON", async ({ page }) => {
  await page.goto("/components/button");
  await expect(page.getByRole("cell", { name: /inputId/i }).first()).toBeVisible();
});
```

### Phase 5 gate

- [ ] Every registry entry has a page
- [ ] 3-column layout on desktop, 2-column on `lg:`, 1-column on mobile
- [ ] Playground tabs swap content statically (no iframes)
- [ ] All Phase 5 tests green
- [ ] Tested manually in both light and dark mode

---

## Phase 6 — Changelog page

**Goal**: replace `app/changelog/page.tsx` with rendered `../NEWS.md`.

### Steps

1. **`scripts/generate-changelog.ts`** (TypeScript, run via `tsx`):
   - Read `../NEWS.md` (relative to `docs-site/`)
   - Parse it with `marked` or a tiny custom parser. Install if needed: `npm install marked`
   - Output `content/changelog.html` (raw HTML)
   - Also extract a list of versions and write `lib/changelog-toc.json` for the right-side version TOC

2. Add to `prebuild`:
   ```json
   "prebuild": "Rscript scripts/generate-previews.R && tsx scripts/generate-changelog.ts"
   ```

3. `app/changelog/page.tsx` reads `content/changelog.html` at build time (use `fs.readFileSync` in the Server Component) and renders it via `dangerouslySetInnerHTML`. Wrap in a `<article className="prose">` and style headings to match DESIGN.md.

### Phase 6 Playwright tests

Create `tests/e2e/changelog.spec.ts`:

```ts
import { test, expect } from "@playwright/test";

test("changelog lists at least one version", async ({ page }) => {
  await page.goto("/changelog");
  const headings = page.locator("h2");
  expect(await headings.count()).toBeGreaterThan(0);
});

test("version anchors work", async ({ page }) => {
  await page.goto("/changelog");
  const first = page.locator("h2").first();
  const id = await first.getAttribute("id");
  if (!id) throw new Error("first h2 has no id");
  await page.goto(`/changelog#${id}`);
  await expect(first).toBeInViewport();
});
```

### Phase 6 gate

- [ ] `/changelog` lists every version from `NEWS.md`
- [ ] Anchor links work
- [ ] `npm run test:e2e` is green

---

## When you finish

When all six phases are green:

1. Open a PR against `main`
2. Confirm both `docs-tests` and `R-CMD-check` workflows pass
3. Merge — `docs-deploy.yml` will publish to <https://nvelden.github.io/shinyblocks/>
4. Edit `README.md` in the repo root to link to the live site
5. Tick the boxes in GitHub issue #14

---

## Common pitfalls

| Symptom | Cause | Fix |
|---|---|---|
| `npm run dev` shows a 404 at `localhost:3000` | basePath is `/shinyblocks` | Go to `localhost:3000/shinyblocks` |
| Tokens look wrong in dark mode | Selector mismatch | Tokens use `[data-theme="dark"]`, NOT `.dark`. Don't change this — next-themes is configured to match. |
| Tailwind v4 utility not working | Tailwind v4 differs from v3 | No `tailwind.config.js`; everything is in `app/globals.css` via `@theme inline`. |
| Playwright can't find selector | Strict mode | Use `getByRole` with a specific `name` regex; avoid raw `text=`. |
| GH Actions deploy shows blank page | Missing `.nojekyll` | The deploy workflow runs `touch out/.nojekyll`. Don't remove it. |
| Asset 404s after deploy | Wrong asset prefix | `next.config.ts` has both `basePath` AND `assetPrefix`. Both must match `/shinyblocks`. |
| `Rscript` fails in CI | R package not installed | The deploy workflow runs `setup-r-dependencies` with `local::.` — don't remove it. |

---

## If you must escalate

If a phase blocks you for more than a session, write a clear comment in the phase's main file explaining:
1. What you tried
2. What broke
3. What the failing test output was

Then stop and wait for review. Do **not** delete or skip tests to make the gate pass.
