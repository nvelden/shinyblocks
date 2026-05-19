# Docs Site — Development Plan, Gates & Tests

**Date:** 2026-05-19
**Companion to:** `2026-05-19-custom-docs-site.md`, `2026-05-19-docs-site-build-plan.md`, `2026-05-19-docs-site-DESIGN.md`
**Purpose:** Per-phase exit gate + smoke tests + Playwright suites. No phase merges without a green gate.

> **Implementation deltas** (2026-05-19): docs site uses **npm** (not pnpm) and plain Next.js (no Fumadocs). Substitute `npm run <script>` for `pnpm <script>` everywhere in this file. Phase 1 is already green — see `docs-site/`.

---

## How gates work

Every phase has three checks. **All three must pass before opening a PR:**

1. **Gate** — objective exit criteria (files exist, build passes, no console errors).
2. **Manual smoke** — quick human pass on `pnpm dev` against the listed checklist.
3. **Playwright** — automated `pnpm test:e2e` covering the surfaces touched.

CI runs the same Playwright suite headlessly on every push.

---

## Tooling

- **Test runner**: Playwright (`@playwright/test`), Chromium + WebKit projects
- **Static asset checks**: `pnpm build` + Playwright runs against `pnpm start` of the export
- **Visual regression** (deferred): Playwright `toHaveScreenshot()` — wire fixtures in Phase 5+ once the layout settles
- **Lighthouse**: one-off CLI run in Phase 7, not part of CI

```
docs-site/
  tests/
    e2e/
      smoke.spec.ts            # nav, theme, prerender presence (every phase)
      landing.spec.ts          # Phase 3
      components-index.spec.ts # Phase 4
      component-detail.spec.ts # Phase 5
      changelog.spec.ts        # Phase 6
      a11y.spec.ts             # axe-core scan, all pages
    fixtures/
      registry.json            # snapshot of _registry.R for stable selectors
  playwright.config.ts
```

`playwright.config.ts` essentials:
- `webServer`: `pnpm build && pnpm start` (or `pnpm dev` in watch mode)
- `baseURL`: `http://localhost:3000/shinyblocks/`
- Two projects: Chromium desktop (1280×800), WebKit mobile (iPhone 12)
- `expect.timeout: 5000`, `retries: 1` on CI

Install once: `pnpm add -D @playwright/test @axe-core/playwright && pnpm playwright install --with-deps chromium webkit`.

---

## Phase 0 — Decommission pkgdown

**Gate**
- [ ] `_pkgdown.yml` removed
- [ ] `pkgdown` removed from `DESCRIPTION` Suggests
- [ ] pkgdown CI workflow deleted
- [ ] `docs-site/`, `docs-site/node_modules/`, `.next/`, `out/` added to `.gitignore` / `.Rbuildignore`
- [ ] `rg -i pkgdown` returns no hits outside `docs/agent-plans/`
- [ ] `R CMD check` passes

**Smoke**
- [ ] `devtools::check()` from R is clean

**Playwright** — n/a (no site yet).

---

## Phase 1 — Scaffold

**Gate**
- [ ] `docs-site/` exists with Fumadocs scaffold
- [ ] `next.config.ts` has `output: 'export'`, `basePath: '/shinyblocks'`, `assetPrefix: '/shinyblocks/'`, `trailingSlash: true`
- [ ] `pnpm build` succeeds with **zero errors** and zero new warnings
- [ ] `out/.nojekyll` exists
- [ ] Geist Sans + Mono load via `next/font` (no external font requests in Network tab)
- [ ] No console errors on `/`

**Smoke**
- [ ] `pnpm dev` → landing stub at `localhost:3000`
- [ ] Dark/light toggle flips `<html class="dark">`
- [ ] Toggle preference persists across reload
- [ ] System-preference change updates immediately when toggle is on "System"

**Playwright** — `smoke.spec.ts`
```ts
test('landing renders', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/shinyblocks/i);
  expect(await page.evaluate(() => document.fonts.ready.then(() => 'ok'))).toBe('ok');
});

test('theme toggle persists', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: /toggle theme/i }).click();
  await page.getByRole('menuitem', { name: /dark/i }).click();
  await expect(page.locator('html')).toHaveClass(/dark/);
  await page.reload();
  await expect(page.locator('html')).toHaveClass(/dark/);
});

test('no console errors on /', async ({ page }) => {
  const errors: string[] = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => m.type() === 'error' && errors.push(m.text()));
  await page.goto('/');
  expect(errors).toEqual([]);
});
```

---

## Phase 2 — Static UI prerender pipeline

**Gate**
- [ ] `content/previews/_registry.R` exists and lists every component planned for v1
- [ ] `content/previews/<name>.R` exists for every registered component
- [ ] `Rscript scripts/generate-previews.R` writes a `.html` sibling for every `.R`
- [ ] `public/runtime/shinyblocks.css` exists after running the script
- [ ] Re-running the script on a clean checkout produces byte-identical output (deterministic)
- [ ] `<ComponentPreview>` component built, imports `.html` via `?raw`
- [ ] `app/layout.tsx` loads `/shinyblocks/runtime/shinyblocks.css`

**Smoke**
- [ ] A scratch test page renders 4 `<ComponentPreview>` cards using real prerendered HTML
- [ ] Inner HTML doesn't receive clicks (test by trying to click a button inside a preview)
- [ ] Cards visually identical between light and dark mode (no broken token references)

**Playwright** — `smoke.spec.ts` additions
```ts
test('prerender CSS loads', async ({ page }) => {
  await page.goto('/');
  const css = await page.evaluate(() => {
    const link = [...document.styleSheets].find(s => s.href?.includes('runtime/shinyblocks.css'));
    return link?.href ?? null;
  });
  expect(css).toContain('runtime/shinyblocks.css');
});

test('previews are non-interactive', async ({ page }) => {
  await page.goto('/');
  const previews = page.locator('[data-component-preview]');
  for (const preview of await previews.all()) {
    await expect(preview).toHaveCSS('pointer-events', 'none');
  }
});
```

---

## Phase 3 — Landing page (gallery)

**Gate**
- [ ] Hero matches DESIGN.md typography and CTA layout
- [ ] Gallery uses CSS columns, `featured: true` entries only
- [ ] Every gallery card links to `/components/<name>`
- [ ] Responsive at 375 / 768 / 1280 / 1920 px widths

**Smoke**
- [ ] Resize browser through breakpoints — no horizontal scroll, cards reflow
- [ ] Cards look right in both themes
- [ ] Tab through the page — focus visible on every interactive element

**Playwright** — `landing.spec.ts`
```ts
test('hero CTAs are present', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('link', { name: /get started/i })).toBeVisible();
  await expect(page.getByRole('link', { name: /view components/i })).toBeVisible();
});

test('gallery renders featured components', async ({ page }) => {
  await page.goto('/');
  const registry = require('./fixtures/registry.json');
  const featured = registry.filter((c: any) => c.featured);
  const cards = page.locator('[data-component-preview]');
  await expect(cards).toHaveCount(featured.length);
  for (const c of featured) {
    await expect(page.getByRole('link', { name: new RegExp(c.name, 'i') })).toBeVisible();
  }
});

test('card click navigates to detail page', async ({ page }) => {
  await page.goto('/');
  await page.locator('[data-component-preview]').first().click();
  await expect(page).toHaveURL(/\/components\/[a-z-]+$/);
});

test('no layout shift on mobile', async ({ page, viewport }) => {
  await page.setViewportSize({ width: 375, height: 800 });
  await page.goto('/');
  const overflow = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
  expect(overflow).toBe(false);
});
```

---

## Phase 4 — Components index

**Gate**
- [ ] `/components` lists every registered component (not just featured)
- [ ] Filter input narrows the grid live
- [ ] Empty-state shown when filter matches nothing

**Smoke**
- [ ] Type partial name into filter — grid updates without page reload
- [ ] Clear filter — grid restores in full
- [ ] Keyboard: Tab focuses filter, Esc clears it (if implemented)

**Playwright** — `components-index.spec.ts`
```ts
test('lists every registered component', async ({ page }) => {
  await page.goto('/components');
  const registry = require('./fixtures/registry.json');
  await expect(page.locator('[data-component-preview]')).toHaveCount(registry.length);
});

test('filter narrows list', async ({ page }) => {
  await page.goto('/components');
  await page.getByPlaceholder(/filter/i).fill('but');
  await expect(page.getByRole('link', { name: /button/i })).toBeVisible();
  const visible = await page.locator('[data-component-preview]:visible').count();
  expect(visible).toBeLessThan(5);
});

test('empty filter state', async ({ page }) => {
  await page.goto('/components');
  await page.getByPlaceholder(/filter/i).fill('zzz-no-match');
  await expect(page.getByText(/no components/i)).toBeVisible();
});
```

---

## Phase 5 — Per-component detail pages

**Gate**
- [ ] Every registered component has a static route at `/components/<name>`
- [ ] Three-column layout on `xl:`, two-column on `lg:`, single on `< md`
- [ ] Left rail (`<ComponentsNav>`) lists every component alphabetically with current highlighted
- [ ] Right rail (TOC) scroll-spies correctly
- [ ] `<PlaygroundTabs>` switches between Content / State / Styling / Actions
- [ ] Each tab shows a **prerendered HTML fragment** (no shinylive in v1) plus the R source under it
- [ ] Preview fragments are non-interactive (`pointer-events: none`)
- [ ] Installation block has Command / Manual tabs and `remotes` / `pak` / `devtools` pills
- [ ] `<ApiTable>` renders from `content/api/<slug>.json`
- [ ] `content/examples/<slug>/{content,state,styling,actions}.R` exist for every component
- [ ] `content/examples/<slug>/{content,state,styling,actions}.html` are generated by `generate-previews.R`
- [ ] `content/api/<slug>.json` exists for every component
- [ ] No `<iframe>` elements anywhere on the page

**Smoke**
- [ ] Navigate by clicking left rail — Next `<Link>` (no full reload)
- [ ] Click each playground tab — preview HTML + code swap; layout stays stable
- [ ] Copy button on code block shows "Copied" toast
- [ ] Mobile (`375px`): left rail collapses into a Sheet (or hides — designer's call)
- [ ] Both themes look right; no broken token references in any preview fragment

**Playwright** — `component-detail.spec.ts`
```ts
test('every registered component has a working page', async ({ page }) => {
  const registry = require('./fixtures/registry.json');
  for (const c of registry) {
    const res = await page.goto(`/components/${c.slug}`);
    expect(res?.status()).toBeLessThan(400);
    await expect(page.locator('h1')).toContainText(c.name);
  }
});

test('left rail navigation does not full-reload', async ({ page }) => {
  await page.goto('/components/button');
  const nav = page.getByRole('navigation', { name: /components/i });
  const before = await page.evaluate(() => performance.now());
  await nav.getByRole('link', { name: /^card$/i }).click();
  await expect(page).toHaveURL(/\/components\/card$/);
  const after = await page.evaluate(() => performance.now());
  expect(after - before).toBeLessThan(2000);
});

test('playground tabs swap content', async ({ page }) => {
  await page.goto('/components/button');
  const codeBefore = await page.locator('pre code').first().innerText();
  await page.getByRole('tab', { name: /actions/i }).click();
  const codeAfter = await page.locator('pre code').first().innerText();
  expect(codeAfter).not.toEqual(codeBefore);
});

test('no iframes on the playground (v1: prerendered only)', async ({ page }) => {
  await page.goto('/components/button');
  await expect(page.locator('iframe')).toHaveCount(0);
});

test('playground preview is non-interactive', async ({ page }) => {
  await page.goto('/components/button');
  const preview = page.locator('[data-playground-preview]').first();
  await expect(preview).toHaveCSS('pointer-events', 'none');
});

test('API table renders from JSON', async ({ page }) => {
  await page.goto('/components/button');
  await expect(page.getByRole('cell', { name: /inputId/i })).toBeVisible();
  await expect(page.getByRole('cell', { name: /label/i })).toBeVisible();
});

test('right TOC scroll-spies', async ({ page }) => {
  await page.goto('/components/button');
  await page.locator('h2', { hasText: /api reference/i }).scrollIntoViewIfNeeded();
  await expect(
    page.getByRole('navigation', { name: /on this page/i })
        .getByRole('link', { name: /api reference/i })
  ).toHaveAttribute('data-active', 'true');
});

test('mobile collapses left rail into a sheet', async ({ page }) => {
  await page.setViewportSize({ width: 375, height: 800 });
  await page.goto('/components/button');
  await expect(page.getByRole('navigation', { name: /components/i })).not.toBeVisible();
  await page.getByRole('button', { name: /open menu/i }).click();
  await expect(page.getByRole('dialog')).toBeVisible();
});
```

---

## Phase 6 — Changelog

**Gate**
- [ ] `scripts/generate-changelog.ts` reads `../NEWS.md` and writes `content/changelog.mdx`
- [ ] `/changelog` renders all versions
- [ ] Right TOC lists versions
- [ ] Anchor links work (`/changelog#0-4-0`)

**Smoke**
- [ ] Append a fake entry to `NEWS.md`, run `pnpm prebuild`, verify it appears

**Playwright** — `changelog.spec.ts`
```ts
test('changelog lists at least one version', async ({ page }) => {
  await page.goto('/changelog');
  await expect(page.locator('h2')).toHaveCount.greaterThan(0);
});

test('version anchors work', async ({ page }) => {
  await page.goto('/changelog');
  const firstHeading = page.locator('h2').first();
  const id = await firstHeading.getAttribute('id');
  await page.goto(`/changelog#${id}`);
  await expect(firstHeading).toBeInViewport();
});
```

---

## Phase 7 — GitHub Actions deploy

**Gate**
- [ ] `.github/workflows/docs.yml` exists and runs on push to `main` + `workflow_dispatch`
- [ ] Workflow: setup R → setup Node/pnpm → `pnpm build` → upload artifact → deploy
- [ ] Repo Settings → Pages → Source = GitHub Actions
- [ ] First green workflow run
- [ ] Live URL serves the site under `/shinyblocks/` with correct asset paths

**Smoke**
- [ ] All four surfaces (landing, /components, /components/button, /changelog) load on the live URL
- [ ] Dark/light toggle works on the live URL
- [ ] No 404s in DevTools Network tab on any page

**Playwright** — re-run the full suite against the deployed URL (`PLAYWRIGHT_BASE_URL=https://nvelden.github.io/shinyblocks/ pnpm test:e2e`).

**Lighthouse**
- [ ] `lhci autorun --collect.url=https://nvelden.github.io/shinyblocks/` reports ≥ 95 across Performance / Accessibility / Best Practices / SEO

---

## Cross-cutting tests (all phases ≥ 3)

**`a11y.spec.ts`** — axe-core scan, runs on every page in the registry plus landing and changelog:
```ts
import AxeBuilder from '@axe-core/playwright';

for (const path of ['/', '/components', '/changelog']) {
  test(`no a11y violations: ${path}`, async ({ page }) => {
    await page.goto(path);
    const results = await new AxeBuilder({ page }).analyze();
    expect(results.violations).toEqual([]);
  });
}
```

**Theme parity** — every Playwright spec runs in both themes via a fixture that toggles dark on `beforeEach`. Catches token regressions automatically.

---

## CI workflow

`.github/workflows/docs-tests.yml` — separate from the deploy workflow, runs on every PR:

```yaml
name: Docs site tests
on:
  pull_request:
    paths: ['docs-site/**', 'inst/www/**', 'NEWS.md']
jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-r@v2
      - uses: r-lib/actions/setup-r-dependencies@v2
        with: { extra-packages: any::htmltools, local::. }
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm, cache-dependency-path: docs-site/package-lock.json }
      - run: npm ci
        working-directory: docs-site
      - run: npx playwright install --with-deps chromium webkit
        working-directory: docs-site
      - run: npm run build
        working-directory: docs-site
      - run: npm run test:e2e
        working-directory: docs-site
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: docs-site/playwright-report/
```

`docs-site/package.json` script:
```json
"test:e2e": "playwright test"
```

---

## Definition of Done (v1 release)

- [ ] All 8 phase gates green
- [ ] Full Playwright suite passes on Chromium + WebKit
- [ ] axe-core scan clean on all surfaces
- [ ] Lighthouse ≥ 95 on the deployed URL
- [ ] `README.md` links to the live site
- [ ] `DESCRIPTION` `URL:` field updated
- [ ] ADR landed under `docs/decisions/`
- [ ] No pkgdown references anywhere (`rg pkgdown` empty)
- [ ] CONTRIBUTING.md documents the docs-site dev loop
