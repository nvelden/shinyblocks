# shinyblocks docs site

Static docs site for the `shinyblocks` R package. Next.js 15 + Tailwind v4, static export to GitHub Pages.

## Local dev

```bash
npm install
npm run dev
```

Site runs at <http://localhost:3000/shinyblocks> (note the `/shinyblocks` prefix — basePath is set in `next.config.ts` to match the eventual GitHub Pages URL).

## Build + local preview

```bash
npm run build            # static export → out/
npm run preview          # build + serve out/ at http://localhost:4173/shinyblocks/
```

## Tests

```bash
npm run test:e2e         # Playwright against the built site (auto-builds + serves)
npm run test:e2e:install # one-time browser install
```

## Playgrounds (Shinylive) — how they run

Each `playgrounds/<slug>/app.R` is a Shiny app exported to a self-contained
Shinylive (webR/WASM) site under `public/playgrounds/<slug>/` and embedded in an
`<iframe>`. At runtime each app installs `shinyblocks` as a pre-built
WebAssembly binary from <https://nvelden.r-universe.dev> (dependencies come
from the default webR repo). r-universe rebuilds that binary from `main` on
every push, so it can lag `HEAD` by ~15-45 min after a push — and playgrounds
pick up the new build on the next page load without a redeploy.

Exports require **shinylive >= 0.5.0** (enforced by
`scripts/generate-playgrounds.R`): its assets bundle webR 0.6 / R 4.6,
matching the R version r-universe builds wasm binaries for. Older shinylive
(webR 0.5 / R 4.5) requests `bin/emscripten/contrib/4.5/`, which r-universe
no longer populates, so every playground fails to install shinyblocks.

Playground `app.R` bootstraps must test installedness with
`"shinyblocks" %in% rownames(installed.packages())` — **not**
`requireNamespace()`, which webR shims to return `NULL` (not `FALSE`) for
packages missing from the default webR repo, so negating it errors before
`install.packages()` ever runs.

## Troubleshooting a blank playground iframe

If the docs page loads but a playground iframe stays blank, the error is almost
always inside the **nested Shinylive frame**, not the top page:

1. **Open the iframe's own devtools console** (right-click *inside* the frame →
   *Inspect*, or load the app directly, e.g.
   `…/shinyblocks/playgrounds/gallery/`). The top-page console usually shows
   nothing useful.
2. **Common cause — r-universe binary lagging `main`.** Symptoms in that
   console: `shinyblocks` not found, or `could not find function "block_…"`
   for a function that exists on `HEAD` but is not yet in the wasm binary at
   <https://nvelden.r-universe.dev/shinyblocks> (builds take ~15-45 min after
   a push; unpushed local-only changes never appear in playgrounds). Check the
   built commit on that page; once the build lands the playground self-heals
   on reload.
3. **Keep `app.json` small.** Keep it to `app.R` only (~tens of KB, like the
   other slugs) — bundling large binary assets inflates it and the Shinylive
   loader chokes → blank frame. Packages install from r-universe at runtime;
   nothing is embedded.
4. **After changing any playground:** re-run
   `Rscript scripts/generate-playgrounds.R` (regenerates `public/playgrounds/`),
   then **restart `npm run preview`**. `preview` serves a *copied snapshot* at
   `.preview/shinyblocks/` (taken from `out/` at startup), so edits under
   `public/` or `out/` are not picked up until the server is restarted. Also
   hard-refresh the browser (Cmd/Ctrl+Shift+R) — the Shinylive service worker
   caches `app.json`.

Note: `next dev` does not resolve directory-index URLs (`…/gallery/` → 404), so
embedded playgrounds only render under the static `npm run preview` build.

### Verifying a production playground change

A successful local build does not update GitHub Pages. After pushing the
change, wait for the `Deploy docs site` workflow to complete, then verify both
the page and the exported playground payload. Use a cache-busting query because
the Shinylive service worker may retain an older `app.json`:

```bash
curl -fsS "https://nvelden.github.io/shinyblocks/playgrounds/<slug>/app.json?rev=<commit>" \
  | grep '<marker unique to the change>'
```

Do not describe the public playground as updated until this live-payload check
passes. Local `out/` and `.preview/` checks only verify the local build.

## Deploy

Push to `main` triggers `.github/workflows/docs-deploy.yml`, which builds and publishes to <https://nvelden.github.io/shinyblocks/>.
