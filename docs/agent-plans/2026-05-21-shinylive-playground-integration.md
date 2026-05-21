# Shinylive Playground Integration — Plan

Status: proposal. Pilot scope: **Select**. Other components follow the same template.

## Goal

Replace the static preview at <https://nvelden.github.io/shinyblocks/components/select/> with an interactive Shinylive playground that mirrors the showcase app's Select playground: same input IDs, same Content / State / Styling / Actions controls grid, same Preview / value readout / UI Definition / Server Action code blocks.

Reference (target structure to reproduce):
- UI: [`inst/showcase/R/examples/select.R`](../../inst/showcase/R/examples/select.R)
- Server: [`inst/showcase/R/server_select.R`](../../inst/showcase/R/server_select.R)

## Why this is non-trivial

`shinyblocks` is not on `repo.r-wasm.org`. Shinylive's hosted iframe (`https://shinylive.io/r/app/#code=…`) loads webR from Shinylive's CDN and can only resolve packages from that repo. So the hosted iframe is a dead end until the package lands there.

The two viable paths:

| Approach | Notes |
|---|---|
| **A. Self-hosted Shinylive export per component** | Run `shinylive::export()` per app, place the static export under `docs-site/public/playgrounds/<slug>/`, mount the package's `library.data.gz` from a sibling path. Embed via `<iframe>`. Full control, predictable paths. |
| **B. Shinylive web component / npm** | `@posit-dev/shinylive` exposes a `<shinylive-r>` web component. Cleaner integration but requires running an Astro/Next plugin and still needs the package data hosted somewhere. More moving parts for v1 of this feature. |

**Recommendation: A** for the pilot. Revisit B once we have ≥3 component playgrounds and want to share a single webR runtime across iframes.

## Architecture

```
docs-site/
  playgrounds/                       ← R source (one folder per component)
    select/
      app.R                          ← mirrors showcase/select.R + server_select.R
  public/
    playgrounds/                     ← Shinylive exports, deployed to /shinyblocks/playgrounds/<slug>/
      select/                        ← output of shinylive::export()
        library.data.gz              ← copied in from release asset
        library.js.metadata
        index.html
        ...
  scripts/
    generate-playgrounds.R           ← new
```

### `app.R` mounts shinyblocks from a sibling wasm asset

`shinylive::export()` only resolves packages from `repo.r-wasm.org`. It does **not** bundle locally-installed packages. So each `app.R` must do its own `webr::mount("/packages", "library.data.gz")` — same pattern as the README, but with a **sibling-relative** path since the export folder is self-contained.

```r
if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)
  webr::mount("/packages", "library.data.gz")
  .libPaths(c("/packages", .libPaths()))
}
library(shiny)
library(shinyblocks)
```

`library.data.gz` resolves against the export's own directory (`/shinyblocks/playgrounds/select/library.data.gz`), so it sidesteps the GitHub Pages basePath gotcha that the README's root-relative `/wasm_binaries/...` warning is about.

### Build pipeline

`shinyblocks` isn't on `repo.r-wasm.org` and `shinylive::export()` can't bundle a local source package. So the wasm filesystem image (`library.data.gz` + `library.js.metadata`) has to be built separately and copied into each export. We have two sources:

- **`release-file-system-image.yml`** workflow (already in the repo) — produces the wasm image and attaches it to each GitHub release.
- A future per-commit rebuild using `rwasm::build()` in CI.

**v1 pivot**: use the **latest release asset**. Docs will reflect the most recent tagged release, not HEAD. Trade-off documented; revisit when the package stabilizes or when contributor workflow demands HEAD-tracking docs.

1. **CI step (in `docs-deploy.yml`)** — before `npx next build`:
   ```bash
   # Fetch the wasm image from the latest GitHub release.
   gh release download --pattern 'library.data.gz' --pattern 'library.js.metadata' \
     --dir docs-site/playgrounds/_wasm/

   Rscript -e 'install.packages("shinylive")'
   npm run prebuild
   Rscript docs-site/scripts/generate-playgrounds.R
   ```

2. **`generate-playgrounds.R`** — for each subdir under `docs-site/playgrounds/`:
   - `shinylive::export(src, dest)` produces the static export.
   - Copy `library.data.gz` + `library.js.metadata` from `docs-site/playgrounds/_wasm/` into the export root.
   - Merge `hasPlayground: true` and `playgroundHeight` into `lib/preview-manifest.json`.

3. **`next build`** picks up `public/playgrounds/<slug>/` and ships it as static assets.

### Detail-page embed

In [`docs-site/app/components/[slug]/page.tsx`](../../docs-site/app/components/%5Bslug%5D/page.tsx):

```tsx
{component.hasPlayground ? (
  <iframe
    src={`/shinyblocks/playgrounds/${slug}/`}
    className="w-full rounded-xl border border-border"
    style={{ height: "720px" }}
    title={`${component.name} playground`}
    loading="lazy"
  />
) : (
  <StaticPreview html={component.html} />
)}
```

`hasPlayground` lives in the existing `preview-manifest.json`, written by `generate-playgrounds.R`. Components without a playground keep the static fragment.

## Pilot: Select

Concrete steps:

1. **Create `docs-site/playgrounds/select/app.R`** — one-file Shiny app that:
   - Sources the bootstrap snippet above.
   - Reproduces the UI from `inst/showcase/R/examples/select.R` (already a self-contained `htmltools::tagList`).
   - Reproduces the server logic from `inst/showcase/R/server_select.R`.
   - Wraps both in `block_page()` so the playground inherits theme + favicon.

2. **Add `docs-site/scripts/generate-playgrounds.R`** with `shinylive::export()` per subdir + asset copy.

3. **Wire CI** — extend `.github/workflows/docs-deploy.yml`:
   - `setup-r` step (already present for previews).
   - `Rscript -e 'install.packages("shinylive")'`.
   - Download release assets, run generate-playgrounds.
   - Add `public/playgrounds/` to the Next build output (no config change needed — it's already under `public/`).

4. **Update `[slug]/page.tsx`** with the iframe branch.

5. **Verify** — open `https://nvelden.github.io/shinyblocks/components/select/`, interact with the Select playground, confirm input value readout updates, controls re-render preview, no console errors.

## Decisions

- **Iframe height**: per-component `playgroundHeight` field in `preview-manifest.json`. Default `720px`; bump per component as needed. No `postMessage` handshake for v1 — revisit only if a specific component needs it.
- **First-load latency**: `loading="lazy"` on the iframe + skeleton placeholder ("Loading interactive playground…"). No click-to-load — scroll-triggered lazy load + a visible loading state is enough.

## Out of scope for this iteration

- Per-iframe theme sync with the docs site (light/dark toggle on the parent doesn't propagate).
- A "fork in shinylive.io" button (would need lz-string encoding + hosting the bundle in a way shinylive.io can reach).
- Replacing the iframe with a single in-page webR runtime shared across all playgrounds (re-evaluate after 3+ playgrounds exist).

## Success criteria

- /components/select/ shows a working interactive playground identical in structure to the showcase Select tab.
- No regression on other component pages (static previews still render).
- CI build time increases by < 90s for the pilot (single export).
- Docs site bundle size in `public/playgrounds/select/` < 25 MB (Shinylive runtime is the bulk).
