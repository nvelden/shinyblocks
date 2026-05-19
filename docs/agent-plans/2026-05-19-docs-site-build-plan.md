# Docs Site — Build Plan (v1)

**Date:** 2026-05-19
**Companion to:** `2026-05-19-custom-docs-site.md` (architecture)
**Scope:** Three surfaces only — **landing gallery**, **components** (index + per-component detail pages), **changelog**. No articles, no Rd→MDX reference generator. pkgdown is removed; no legacy fallback.

> **Implementation deltas vs this plan** (2026-05-19, after Phase 1 landed):
> - Phase 1 uses **plain Next.js 16 + Tailwind v4** (no Fumadocs). Phase 1 is already done — see `docs-site/`.
> - **npm**, not pnpm — the root R package is npm-based. The deploy workflow already uses npm.
> - The Phase 7 GH Actions snippet below is the original draft; the live workflow at `.github/workflows/docs-deploy.yml` is npm + Next 16.

Each phase is independently mergeable, ends in a working state, and has a clear acceptance check.

---

## Site map

```
/                         Landing page — gallery of prerendered components
/components               Index — searchable list of every block_*()
/components/<name>        Per-component detail page (preview + playground + API)
/changelog                Generated from NEWS.md
```

---

## Phase 0 — Decommission pkgdown

**Goal:** Single source of truth.

- Delete `_pkgdown.yml`
- Delete generated pkgdown output dir — keep `docs/agent-plans/`, `docs/decisions/`, `docs/ROADMAP.md`
- Remove `pkgdown` from `DESCRIPTION` Suggests
- Remove pkgdown GH Actions workflow (`.github/workflows/pkgdown.yml`)
- Add `docs-site/` to `.Rbuildignore`
- Add `docs-site/node_modules/`, `docs-site/.next/`, `docs-site/out/` to `.gitignore`

**Acceptance:** `R CMD check` passes. `rg pkgdown` returns nothing.

---

## Phase 1 — Scaffold Next.js + Fumadocs

**Goal:** Empty site renders with shadcn-matching chrome.

```bash
cd docs-site
pnpm create fumadocs-app .   # Next.js App Router, MDX, Tailwind v4
pnpm add lucide-react geist
```

Edit:
- `next.config.ts` — `output: 'export'`, `basePath: '/shinyblocks'`, `assetPrefix: '/shinyblocks/'`, `trailingSlash: true`, `images.unoptimized: true`
- `app/layout.tsx` — Geist Sans + Geist Mono via `next/font`, top nav (Components, Changelog, GitHub, theme toggle)
- `app/global.css` — Tailwind v4 + shinyblocks design tokens (copy from `inst/www/shinyblocks.css`)
- `public/.nojekyll` — empty file

Drop the Fumadocs scaffold's default "Docs" / "Articles" sidebar — we don't need it for v1. Keep Fumadocs for code blocks, MDX, command palette, and styling primitives only.

**Acceptance:** `pnpm dev` → landing stub at `localhost:3000`, dark/light toggle, Geist visible. `pnpm build` writes static export to `out/` with `/shinyblocks/` prefix.

---

## Phase 2 — Static UI prerender pipeline

**Goal:** Real `block_*()` HTML fragments on disk for the gallery and component pages.

- `docs-site/content/previews/` — one `.R` file per component returning a curated tag object, plus `_registry.R` listing `{ name, file, featured }`
- `scripts/generate-previews.R` — sources each file, `htmltools::renderTags()`, writes `.html` siblings, copies HTML dependencies to `docs-site/public/runtime/`
- `app/layout.tsx` loads `/shinyblocks/runtime/shinyblocks.css`
- `components/component-preview.tsx` — imports `.html` via `?raw`, renders inside a card with `pointer-events: none`, whole card is a `<Link>`
- `package.json` `prebuild`: `Rscript scripts/generate-previews.R`

**Acceptance:** Test page with 4 `<ComponentPreview>` cards shows correctly-styled real component HTML. Cards are click-through links; preview internals don't receive interaction.

---

## Phase 3 — Landing page (gallery)

**Goal:** The homepage matches the shadcn.com aesthetic.

- `app/page.tsx`:
  - Hero: small pill (e.g. "v0.x released"), large title, subtitle, `[ Get started ]` + `[ View Components ]`
  - Gallery: CSS-columns masonry of `<ComponentPreview>` cards driven by `_registry.R` `featured: true` entries
  - Footer: "Built in R · Source on GitHub · MIT"
- Responsive: 1 col mobile → 2 col tablet → 4 col desktop

**Acceptance:** Landing page resembles the reference screenshot. Gallery cards click through to `/components/<name>` (broken link OK at this phase). Mobile reflows cleanly.

---

## Phase 4 — Components index page

**Goal:** Browseable catalogue of every `block_*()`.

- `app/components/page.tsx`:
  - Header + short blurb
  - Grid (denser than landing — 3–4 col desktop) of every entry in `_registry.R`, not just `featured`
  - Each card uses `<ComponentPreview>` and links to its detail page
  - Optional client-side filter input ("Filter components…") doing simple substring match against names

**Acceptance:** Every registered component appears. Filter narrows the grid live. All cards link to working detail pages (stubs OK at this phase).

---

## Phase 5 — Per-component detail pages

**Goal:** Three-column shadcn-style detail page with a **statically prerendered** playground + API table. See "Component page" wireframe in the architecture doc.

**No shinylive in v1.** Each playground tab is just another prerendered HTML fragment, produced by the same `generate-previews.R` pipeline as the landing gallery. Tabs swap which fragment is visible — no iframes, no WebR, no encoder script.

Page surface: `app/components/[slug]/page.tsx` — static params from the registry. Layout has three columns: components rail (left), content (center), on-this-page TOC (right).

Build in this order:

1. **`<ComponentsNav>`** (left rail) — flat alphabetical list driven by `_registry.R`. Current item highlighted shadcn-style. Sticky on desktop, collapses (or hides) on mobile.
2. **On-this-page TOC** (right rail) — scroll-spy over the page's `<h2>` headings. Small client component using `IntersectionObserver`.
3. **Extend `generate-previews.R`** — in addition to the landing-gallery preview, source `content/examples/<slug>/{content,state,styling,actions}.R` for each component and write four extra HTML fragments per slug into `content/examples/<slug>/<tab>.html`. The R source string is also captured into the manifest so the "code" pane under each tab can render it.
4. **`<PlaygroundTabs>`** — four tabs (Content / State / Styling / Actions). State lives in `useState`. Each tab swaps **two** things: the preview fragment (raw HTML, `pointer-events: none`) and the displayed R source (inside a `<pre>` with a copy button). No "Run example" button, no iframe.
5. **Installation block** — tabbed Command / Manual, with R package-manager pills (`remotes` / `pak` / `devtools`) and a copy button.
6. **`<ApiTable>`** — reads `content/api/<slug>.json` (hand-stubbed for v1: `[{ name, type, default, description }]`) and renders the table.
7. **Page assembly** — title, description, playground, installation, usage prose, API reference, all with proper `<h2>` anchors so the right TOC populates.

For v1, author `content/examples/<slug>/*.R` (the four tabs) and `content/api/<slug>.json` by hand for each component. Both can be lifted from existing showcase code under `inst/showcase/`.

**Acceptance:**
- Every entry in the registry has a working detail page
- Left rail navigates between pages without full reload (Next `<Link>`)
- Clicking a playground tab swaps both the preview HTML and the displayed R source
- Preview fragments are static HTML and non-interactive (`pointer-events: none`)
- API table renders from JSON
- Right TOC reflects the page's `<h2>` headings and scroll-spies correctly
- Mobile: rails collapse cleanly, content stays readable
- No iframes anywhere on the page (grep the rendered HTML for `<iframe`)

---

## Phase 6 — Changelog page

**Goal:** `/changelog` from `NEWS.md`.

- `scripts/generate-changelog.ts` — read `../NEWS.md`, prepend frontmatter, write `content/changelog.mdx`. Transform `# shinyblocks X.Y.Z` headings into `## X.Y.Z` for nicer TOC
- `app/changelog/page.tsx` — render the MDX with the standard prose styling

**Acceptance:** Editing `NEWS.md` and running `pnpm prebuild` updates `/changelog`. Versions show in the right-side TOC.

---

## Phase 7 — GitHub Actions deploy

**Goal:** Push to `main` → live at `https://<user>.github.io/shinyblocks/`.

`.github/workflows/docs.yml`:

```yaml
name: Deploy docs
on:
  push: { branches: [main] }
  workflow_dispatch:
permissions:
  contents: read
  pages: write
  id-token: write
concurrency:
  group: pages
  cancel-in-progress: false
jobs:
  build:
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
      - run: npm run build
        working-directory: docs-site
      - run: touch docs-site/out/.nojekyll
      - uses: actions/upload-pages-artifact@v3
        with: { path: docs-site/out }
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/deploy-pages@v4
        id: deployment
```

Repo Settings → Pages → Source: **GitHub Actions**.

**Acceptance:** Push to `main` → green workflow → live site with working gallery, components index, detail pages, and changelog.

---

## Cross-phase checklist

- [ ] `CONTRIBUTING.md` documents `cd docs-site && pnpm install && pnpm dev`
- [ ] `README.md` links to the live GH Pages URL
- [ ] `DESCRIPTION` `URL:` field updated
- [ ] ADR written under `docs/decisions/` once Phase 1 lands
- [ ] No `pkgdown` references remain

## Effort estimate

| Phase | Effort |
|---|---|
| 0 — Decommission pkgdown | 0.25 d |
| 1 — Scaffold | 1 d |
| 2 — Prerender pipeline | 0.75 d |
| 3 — Landing page | 0.5 d |
| 4 — Components index | 0.5 d |
| 5 — Per-component detail pages (3-col layout + static playground + API table) | 1.5 d |
| 6 — Changelog | 0.25 d |
| 7 — GH Actions deploy | 0.5 d |
| **Total** | **~6 working days** |

## Deferred to v2

Captured here so we don't forget — none of these are in v1 scope:

- **Articles/vignettes section** — `Rmd → MDX` generator, `/articles` sidebar
- **Reference section** — `Rd → MDX` generator, `/reference/<fn>` pages, cross-linking
- **API table auto-generation** — v1 stubs API tables by hand in `content/api/<slug>.json`; v2 derives them from parsed Rd
- **Interactive playgrounds via shinylive** — v1 playgrounds are static prerendered HTML, identical to the gallery cards. v2 upgrades each tab to a lazy-mounted shinylive iframe behind a "Run example" button. Will require: `scripts/encode-shinylive.ts` (lz-encode example `.R` files), a `<ShinyliveBlock>` component that swaps the static HTML for the iframe on click, and a decision on hosted vs self-hosted shinylive assets.
- **Search / command palette** — defer until articles/reference exist

## Order-of-operations notes

- 0 → 1 → 2 are sequential. 3–6 can interleave once 2 lands.
- Phase 7 (deploy) can ship as soon as Phase 3 looks acceptable — push and iterate live.
