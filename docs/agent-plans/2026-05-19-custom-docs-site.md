# Custom Docs Site — Next.js + Static Prerender on GitHub Pages

> **Implementation deltas vs original plan** (2026-05-19, after Phase 1):
> - **No Fumadocs in v1.** The site is plain Next.js 16 App Router + Tailwind v4. Fumadocs added more surface area than three pages justify; we can adopt it later for code blocks/search if v2 needs it. Treat every "Fumadocs" mention below as a v2 reference.
> - **npm, not pnpm.** The root R package is already npm-based (`package.json` at the repo root pins `npm@11.6.2`). The docs site reuses npm. All `pnpm` snippets below should be read as `npm` / `npm run …`.
> - **No shinylive in v1.** Every Shiny preview is a static HTML fragment from `htmltools::renderTags()`. Shinylive is a v2 upgrade.

**Date:** 2026-05-19
**Status:** Draft plan
**Goal:** Replace pkgdown with a custom documentation site that visually matches [ui.shadcn.com](https://ui.shadcn.com) and embeds a live shinylive playground for every `block_*()` component. Hosted on GitHub Pages.

**Scope for v1 (this plan):** three surfaces only — **landing gallery**, **components** (index + per-component detail pages), **changelog**. Articles/vignettes and a full Rd→MDX reference section are explicitly deferred to a v2 plan. Anything below describing those surfaces is design lookahead, not in-scope work.

**Playground rendering for v1:** **All playground tabs are statically prerendered Shiny HTML**, same pipeline as the landing gallery. There is **no shinylive in v1** — the previews are non-interactive HTML fragments produced by `htmltools::renderTags()`. Shinylive (the "Run example" button, `<iframe>` to WebR, lz-encoded URLs) is a deferred upgrade for v2 once we have build-time + bandwidth budgets to spend. Wherever the design below mentions shinylive, treat it as a v2 reference.

## Why not pkgdown / altdoc

- pkgdown gives us the reference/vignette pipeline for free, but reskinning Bootstrap to truly match shadcn (sidebar layout, command palette, MDX-style component embeds, per-component playgrounds) is fighting the framework.
- altdoc + Quarto buys flexibility but still doesn't natively support React component embeds — and a Shiny component library's docs site is itself a component showcase.
- The docs site is a marketing surface for the package. Matching shadcn aesthetic credibly signals "this is a serious shadcn-for-Shiny project."

## Stack

| Layer | Choice | Notes |
|---|---|---|
| Framework | **Next.js 15** (App Router) | Same as shadcn.com. Static export for GH Pages. |
| Docs engine | **Fumadocs** (`fumadocs-core`, `fumadocs-ui`, `fumadocs-mdx`) | Built by shadcn-adjacent maintainers. Ships sidebar, TOC, search, command palette, code blocks that already look shadcn-native. |
| Content | **MDX** | React components embeddable inline. |
| Styling | **Tailwind v4** + existing shinyblocks tokens | Reuse `inst/www/shinyblocks.css` design tokens verbatim — single source of truth shared with the R runtime. |
| Font | **Geist** (Sans + Mono) | Via `next/font`. |
| Icons | **Lucide** (`lucide-react`) | Already our icon set inside the package. |
| Live demos | **shinylive** | Embed as iframe pointing at `https://shinylive.io/r/app/#code=...`, or self-host assets under `/shinylive/`. |
| Search | Fumadocs built-in (Orama) | No external service. |
| Hosting | **GitHub Pages** | Static export → `gh-pages` branch via Actions. |

## Repo layout

```
shinyblocks/             # R package (unchanged)
  R/, inst/, man/, vignettes/, NEWS.md, DESCRIPTION
  docs-site/             # NEW — Next.js app, gitignored from R build
    app/
      layout.tsx
      page.tsx           # Landing page (hero + featured components)
      docs/
        layout.tsx       # Fumadocs sidebar shell
        [[...slug]]/page.tsx
    content/
      docs/
        index.mdx        # "Getting Started" — generated from README
        installation.mdx
        components/
          button.mdx
          card.mdx
          ...            # one MDX per block_*()
        articles/        # generated from vignettes/
        changelog.mdx    # generated from NEWS.md
        reference/       # generated from man/*.Rd
    components/
      shinylive-block.tsx
      playground-tabs.tsx
      api-table.tsx
      component-preview.tsx
    lib/
      source.ts          # Fumadocs source loader
    scripts/
      generate-reference.ts   # Rd → MDX
      generate-vignettes.ts   # knit .Rmd → MDX
      generate-changelog.ts   # NEWS.md → MDX
      encode-shinylive.ts     # R snippets → shinylive #code= URLs
    next.config.ts       # basePath: '/shinyblocks', output: 'export'
    public/.nojekyll
```

`docs-site/` is self-contained — `R CMD check` ignores it via `.Rbuildignore`.

## Page wireframes

ASCII sketches for the five page templates. Layout copies shadcn.com's conventions: top nav, optional left sidebar, content column, right-side on-this-page TOC.

### Landing page (`/`) — prerendered component gallery

Modeled on ui.shadcn.com's homepage. A masonry/grid of **statically prerendered Shiny UI fragments**: real `block_*()` output, dumped to HTML at build time, displayed non-interactively. No shinylive, no server — pure markup styled by the same CSS the runtime uses, so the gallery is guaranteed pixel-identical to the live components.

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│  shinyblocks       Components   Changelog                             [GH] [☾]   │
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│                            < New preset commands → >                             │
│                                                                                  │
│                      The Foundation for your Shiny App                           │
│                                                                                  │
│            A set of beautifully designed shadcn-inspired components              │
│            for Shiny. Pure R. Open source. Open code.                            │
│                                                                                  │
│                  [ Get started ]   [ View Components ]                           │
│                                                                                  │
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌───────────┐ │
│  │ Payment Method   │  │  ◉ ◉ ◉           │  │ ⓘ https://       │  │ @ context │ │
│  │ Name on Card     │  │  No Team Members │  │ ┌──────────────┐ │  │           │ │
│  │ [ John Doe     ] │  │  Invite team…    │  │ │ 2FA  [Enable]│ │  │ Ask, …    │ │
│  │ Card  CVV        │  │  [ + Invite ]    │  │ └──────────────┘ │  │           │ │
│  │ [____] [___]     │  │                  │  │ ✓ Profile verified│  │ Auto  ➤  │ │
│  │ Month  Year      │  │  ● Syncing       │  │                  │  ├───────────┤ │
│  │ [MM ] [YYYY]     │  │  ○ Updating      │  │  Appearance      │  │ ← Archive │ │
│  │                  │  │  ○ Loading       │  │  Compute Env     │  │   Report  │ │
│  │ Billing Address  │  │                  │  │  [● Kubernetes ] │  │   Snooze  │ │
│  │ ☑ Same as ship.  │  │  Send a message… │  │  [○ Virtual Mach]│  │           │ │
│  │ Comments         │  │  Price Range     │  │  GPUs: [ 8  − +] │  │ ☑ I agree │ │
│  │ [____________ ]  │  │  ━━━●━━━━━━━●━━━ │  │  Wallpaper [ ●] │  │ 1 2 3 ← → │ │
│  │ [Submit] [Cancel]│  │  Search   12 res │  │                  │  └───────────┘ │
│  └──────────────────┘  │  example.com     │  └──────────────────┘  ┌───────────┐ │
│                        │  Ask, Chat…      │                        │ ↻ Process │ │
│                        │  Auto    52% ➤   │                        │ [Cancel]  │ │
│                        └──────────────────┘                        └───────────┘ │
│                                                                                  │
├──────────────────────────────────────────────────────────────────────────────────┤
│           Built in pure R · Source on GitHub · MIT licensed                      │
└──────────────────────────────────────────────────────────────────────────────────┘
```

Each card in the grid is one `<ComponentPreview>` (see below). The grid is CSS columns (masonry-style), responsive: 1 col mobile → 2 col tablet → 4 col desktop. Cards are non-interactive (`pointer-events: none` on the preview content, plus the whole card is a link to `/docs/components/<name>`).

### Component page (`/components/<name>`)

Three-column layout exactly like ui.shadcn.com component pages: left rail = full alphabetical components list (current item highlighted), center = title + playground + sections, right rail = "On This Page" anchors. Center column carries the interactive playground via shinylive and the API table — both ported from the Shiny showcase app's playground contract.

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│  shinyblocks      Components   Changelog                       [GH] [☾]          │
├────────────┬─────────────────────────────────────────────────┬───────────────────┤
│ COMPONENTS │  Button                                         │ ON THIS PAGE      │
│            │  Trigger an action with a click.                │                   │
│  Accordion │                                                 │  Preview          │
│  Alert     │  ┌──Content──┬──State──┬──Styling──┬──Actions─┐ │  Installation     │
│  Badge     │  │                                            │ │  Usage            │
│  Button  ● │  │   ┌──────────────────────────────────┐     │ │   Basic           │
│  Card      │  │   │                                  │     │ │   Variants        │
│  Checkbox  │  │   │      [shinylive iframe]          │     │ │   Sizes           │
│  Dialog    │  │   │                                  │     │ │  API Reference    │
│  Input     │  │   │   ● Run example  /  ◌ Loading…   │     │ │                   │
│  Select    │  │   │                                  │     │ │                   │
│  Slider    │  │   └──────────────────────────────────┘     │ │                   │
│  Switch    │  │                                            │ │                   │
│  Tabs      │  │   ┌──────────────────────────────────┐     │ │                   │
│  Tooltip   │  │   │ block_button(                    │     │ │                   │
│  …         │  │   │   "go", "Run model",      [View Code]   │                   │
│            │  │   │   variant = "default"    [⧉ Copy ]│   │ │                   │
│            │  │   │ )                                │     │ │                   │
│            │  │   └──────────────────────────────────┘     │ │                   │
│            │  └────────────────────────────────────────────┘ │                   │
│            │                                                 │                   │
│            │  ## Installation                                │                   │
│            │  ┌─Command─┬─Manual─────────────────────────┐   │                   │
│            │  │ [remotes] [pak] [devtools]               │   │                   │
│            │  │ ┌────────────────────────────────────┐   │   │                   │
│            │  │ │ remotes::install_github("…") [⧉]   │   │   │                   │
│            │  │ └────────────────────────────────────┘   │   │                   │
│            │  └──────────────────────────────────────────┘   │                   │
│            │                                                 │                   │
│            │  ## Usage                                       │                   │
│            │  Short prose describing common patterns,        │                   │
│            │  with inline code samples.                      │                   │
│            │                                                 │                   │
│            │  ## API Reference                               │                   │
│            │  ┌──────────┬────────┬──────────┬────────────┐  │                   │
│            │  │ arg      │ type   │ default  │ description│  │                   │
│            │  ├──────────┼────────┼──────────┼────────────┤  │                   │
│            │  │ inputId  │ chr    │ —        │ Shiny id   │  │                   │
│            │  │ label    │ chr    │ NULL     │ Button text│  │                   │
│            │  │ variant  │ chr    │ default  │ Visual …   │  │                   │
│            │  │ size     │ chr    │ md       │ Sizing …   │  │                   │
│            │  └──────────┴────────┴──────────┴────────────┘  │                   │
└────────────┴─────────────────────────────────────────────────┴───────────────────┘
```

Layout specifics:
- **Left rail** (`<ComponentsNav>`): single flat alphabetical list, no section headers. Current page highlighted with the shadcn-style filled chip background. Driven by `_registry.R`.
- **Playground tabs** (`<PlaygroundTabs>`): Content / State / Styling / Actions — same four tabs as the Shiny showcase, so the docs and the app stay in lock-step. Each tab swaps the shinylive iframe + the code snippet underneath.
- **Shinylive frame** (`<ShinyliveBlock>`): lazy-mounted behind a "Run example" button — first paint stays static (prerendered HTML from the previews pipeline as the placeholder), the user opts into the WebR cold-start.
- **"View Code"** button overlays the bottom-right of the preview, like shadcn.com — toggles the code block visibility on small screens.
- **Installation block**: tabbed Command / Manual, with R-flavored package-manager pills (`remotes` / `pak` / `devtools`) instead of pnpm/npm/yarn/bun.
- **API table** (`<ApiTable>`): hand-stubbed JSON in `content/api/<name>.json` for v1; v2 auto-generates from Rd.

### Changelog (`/changelog`)

```
┌────────────────────────────────────────────────────────────────────────────┐
│  shinyblocks       Components   Changelog                       [GH] [☾]   │
├────────────────────────────────────────────────────────────┬───────────────┤
│  Changelog                                                 │ VERSIONS      │
│                                                            │  0.4.0        │
│  ## 0.4.0  ·  2026-05-12                                   │  0.3.1        │
│  ### Added                                                 │  0.3.0        │
│   - block_select() with async loading                      │  0.2.0        │
│   - block_tabs() controlled mode                           │               │
│  ### Fixed                                                 │               │
│   - block_dialog() focus-trap on Safari                    │               │
│                                                            │               │
│  ## 0.3.1  ·  2026-04-28                                   │               │
│  ### Fixed                                                 │               │
│   - block_button() variant prop type                       │               │
└────────────────────────────────────────────────────────────┴───────────────┘
```

> Reference, articles, and command-palette wireframes are out of v1 scope — see the build plan's "Deferred to v2" section.

## Per-component MDX contract

Every `block_*()` page follows the same skeleton (mirrors the showcase playground per the team rule):

```mdx
---
title: Button
description: Trigger an action with a click.
component: block_button
---

import { ShinyliveBlock } from '@/components/shinylive-block'
import { PlaygroundTabs } from '@/components/playground-tabs'
import { ApiTable } from '@/components/api-table'

## Preview

<ShinyliveBlock file="button/default.R" height={240} />

## Installation

<CodeBlock lang="r">{`remotes::install_github("nielsvdvelden/shinyblocks")`}</CodeBlock>

## Usage

<PlaygroundTabs
  content="button/content.R"
  state="button/state.R"
  styling="button/styling.R"
  actions="button/actions.R"
/>

## API

<ApiTable fn="block_button" />

## Anatomy
## Accessibility
## Examples
```

R snippets live under `docs-site/content/examples/<component>/*.R` so they're authored in plain R, not embedded in MDX strings.

## Content pipelines (R → MDX)

Three Node scripts, run in CI before `next build`. Each is dumb and replaceable.

1. **`generate-reference.ts`** — walks `man/*.Rd`, calls `Rscript -e 'tools::Rd2HTML(...)'` or uses `Rd2md`, emits one MDX per topic with Fumadocs frontmatter. Cross-links between functions are a follow-up (regex over `\link{}` → MDX anchors).
2. **`generate-vignettes.ts`** — for each `vignettes/*.Rmd`, runs `Rscript -e 'rmarkdown::render(..., output_format = "md_document")'`, then wraps the markdown with frontmatter and drops it under `content/docs/articles/`.
3. **`generate-changelog.ts`** — copies `NEWS.md` → `content/docs/changelog.mdx` with frontmatter prepended. Trivial.
4. **`encode-shinylive.ts`** — reads `content/examples/**/*.R`, produces a JSON manifest of `{ file → shinylive URL }`. `<ShinyliveBlock>` reads this at build time.

All four run via `pnpm prebuild` and are idempotent.

## Static UI prerender (for the landing-page gallery)

The landing page is a gallery of **non-interactive component previews** rendered from real Shiny UI to static HTML at build time. This avoids spinning up shinylive iframes on the homepage (fast first paint) and guarantees the gallery looks identical to the live runtime because it *is* the runtime's HTML.

### How it works

R already produces HTML — `htmltools::renderTags()` converts a tag object to a `{html, head, dependencies}` triple. We write an R script that:

1. `library(shinyblocks)`
2. Sources `docs-site/content/previews/<component>.R` — each file returns a tag object (a curated, visually rich example, not the bare minimum)
3. Calls `htmltools::renderTags(ui)` on each
4. Writes `docs-site/content/previews/<component>.html` — just the inner HTML fragment, no `<html>`/`<head>`
5. Collects all HTML dependencies (e.g., the shinyblocks CSS bundle) and copies them once into `docs-site/public/runtime/`

The CSS payload is the same `inst/www/shinyblocks.css` the package ships, so prerendered fragments render against the exact same tokens, fonts, and class names as the live runtime.

### Preview source layout

```
docs-site/content/previews/
  button.R        # returns a tag list — a curated "marketing" example
  card.R          # often a richer composition than the docs page default
  dialog.R        # opened-state HTML so the preview shows the dialog
  select.R
  …
  _registry.R     # exports list(name = "Button", file = "button.R", featured = TRUE, …)
```

Examples are deliberately *opinionated* — for the landing gallery we want each card to look beautiful (filled forms, populated lists, "open" states for dialogs), not the empty default. The component-page previews stay separate and follow the playground contract.

### React side

```tsx
// components/component-preview.tsx
import previewHtml from '@/content/previews/button.html?raw'

<ComponentPreview name="Button" html={previewHtml} href="/docs/components/button" />
```

`<ComponentPreview>`:
- Wraps the raw HTML in a card with rounded border + shadow
- Sets `pointer-events: none` on the inner HTML so previews are visually live but non-interactive
- Whole card is `<Link>` to the component page
- Optional hover state: subtle lift, no preview-internal hover

Vite/Turbopack's `?raw` import reads the HTML fragment at build time. No runtime fetching.

### Build-time pipeline

`scripts/generate-previews.R` (run before `next build`):

```r
# Pseudocode
previews <- source("content/previews/_registry.R")$registry
for (entry in previews) {
  ui <- source(file.path("content/previews", entry$file))$value
  rendered <- htmltools::renderTags(ui)
  writeLines(rendered$html, sub("\\.R$", ".html", entry$file))
}
# Copy combined CSS deps to public/runtime/shinyblocks.css
deps <- htmltools::resolveDependencies(lapply(previews, function(e) attr(e$ui, "html_dependencies")))
htmltools::copyDependencyToDir(deps, "../public/runtime")
```

Wire into `pnpm prebuild`:
```json
"prebuild": "Rscript scripts/generate-previews.R && tsx scripts/encode-shinylive.ts && tsx scripts/generate-changelog.ts && tsx scripts/generate-vignettes.ts && tsx scripts/generate-reference.ts"
```

`app/layout.tsx` adds `<link rel=\"stylesheet\" href=\"/shinyblocks/runtime/shinyblocks.css\">` so the prerendered fragments are styled everywhere they appear (landing page + component pages can both reuse them).

### Why not just screenshot?

- Screenshots go stale silently. Prerendered HTML regenerates on every CI run, so visual drift between docs and runtime is impossible.
- Real HTML is themable: the gallery automatically respects light/dark via the same token system as the runtime.
- Real HTML is responsive: cards reflow correctly on mobile without needing per-breakpoint screenshots.
- Real HTML is accessible: screen readers can read the gallery.

### What's prerendered vs interactive

| Surface | v1 mode | v2 upgrade |
|---|---|---|
| Landing-page gallery cards | **Static prerender** | unchanged |
| Components-index cards | **Static prerender** | unchanged |
| Component-page top preview | **Static prerender** | optional shinylive |
| Component-page playground tabs (Content/State/Styling/Actions) | **Static prerender** — one HTML fragment per tab | swap each fragment for a shinylive iframe behind "Run example" |

**v1 rule of thumb**: if it shows a Shiny component, it's a static HTML fragment produced by the previews pipeline. No JavaScript R runtime is loaded anywhere. This keeps build time fast, bundle small, and Phase 5 simple.

## Shinylive embedding

Two modes, picked per page:

- **Hosted** — `<iframe src="https://shinylive.io/r/app/#code=<lz-encoded>">`. Zero infra. Cold load is ~30 MB (WebR). Use a "Run example" button so it's not auto-loaded on every component page.
- **Self-hosted** — vendor shinylive assets under `public/shinylive/` via `shinylive::export()`. Larger repo, faster loads, works offline. Decide later; start with hosted.

`<ShinyliveBlock>` props: `file`, `height`, `autoload` (default `false`).

## GitHub Pages deployment

**`next.config.ts`:**
```ts
export default {
  output: 'export',
  basePath: '/shinyblocks',
  assetPrefix: '/shinyblocks/',
  images: { unoptimized: true },
  trailingSlash: true,
}
```

**`.github/workflows/docs.yml`** (sketch):
1. `actions/checkout`
2. `r-lib/actions/setup-r` + `setup-r-dependencies`
3. `pnpm/action-setup` + `actions/setup-node`
4. `Rscript -e 'devtools::document()'` (refresh `man/`)
5. `cd docs-site && pnpm install && pnpm prebuild && pnpm build`
6. `touch docs-site/out/.nojekyll`
7. `actions/upload-pages-artifact` (path: `docs-site/out`)
8. `actions/deploy-pages`

Triggers: push to `main`, plus `workflow_dispatch`. Optional preview deploys per PR via Netlify or a `gh-pages-preview` branch.

## Phasing

| Phase | Deliverable | Effort |
|---|---|---|
| 0 | ADR + this plan reviewed and accepted | — |
| 1 | Next.js + Fumadocs scaffold, Geist/Lucide wired, shinyblocks tokens imported, landing page hero | 1–2 d |
| 2 | `<ShinyliveBlock>` + `<PlaygroundTabs>` + `<ApiTable>` components, one reference component page (`block_button`) end-to-end | 1 d |
| 3 | `generate-changelog` + `generate-vignettes` scripts working | 0.5 d |
| 4 | `generate-reference` script (Rd → MDX, no auto-link yet) | 1 d |
| 5 | Port all existing `block_*()` showcase examples to MDX pages | 1 d |
| 6 | GH Actions workflow, basePath + `.nojekyll` correct, first live deploy | 0.5 d |
| 7 | Rd cross-linking, search tuning, OG images | 1 d |
| 8 | Decommission pkgdown config (or keep as fallback under `/legacy/`) | 0.25 d |

Total: ~1 working week of focused effort.

## Risks & open questions

- **Two toolchains.** R contributors will need pnpm + Node to preview docs locally. Mitigation: docs-only changes don't need a local Next build (CI handles it); document the workflow in `CONTRIBUTING.md`.
- **Reference doc quality vs pkgdown.** pkgdown's auto-linking, signature rendering, and example execution are mature. Our generator will start cruder. Acceptable for v1; revisit if it bites.
- **Shinylive iframe weight.** WebR cold-start is heavy. "Run example" buttons keep first paint fast. Measure on first deploy.
- **MDX authoring burden.** Pure MDX rewrites of vignettes lose R chunks. The Rmd-knit pipeline preserves rendered chunks but not interactive Shiny — which is fine since interactive demos go through `<ShinyliveBlock>`.
- **Search across generated content.** Fumadocs indexes MDX at build time; the generated MDX needs proper frontmatter (`title`, `description`) for search results to be useful. Generators must guarantee this.
- **Decision needed:** keep pkgdown as a fallback under `/legacy/` for one release cycle, or cut over cleanly?

## Next steps

1. Land this plan + write a short ADR under `docs/decisions/` once approved.
2. Phase 1 scaffold in a feature branch.
3. Prototype `block_button` page end-to-end before generalizing.
