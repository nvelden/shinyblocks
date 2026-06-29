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
`<iframe>`. The apps do **not** install `shinyblocks` from a webR repo — they
mount a prebuilt package image (`library.data.gz` + `library.js.metadata`) from
`public/playgrounds/` at runtime. That image is normally produced by CI from the
**latest release** (`playgrounds/_wasm/`), so locally it can be stale or absent.

## Troubleshooting a blank playground iframe

If the docs page loads but a playground iframe stays blank, the error is almost
always inside the **nested Shinylive frame**, not the top page:

1. **Open the iframe's own devtools console** (right-click *inside* the frame →
   *Inspect*, or load the app directly, e.g.
   `…/shinyblocks/playgrounds/gallery/`). The top-page console usually shows
   nothing useful.
2. **Common cause — wrong/old WASM package image.** Symptoms in that console:
   `shinyblocks` not found, or `could not find function "block_…"` for a function
   that exists on `HEAD` but not in the mounted image (the release image lags
   `HEAD`). Fix: build the **current local** `shinyblocks`, pack it into
   `library.data.gz` / `library.js.metadata`, and place them in
   `public/playgrounds/` (and `playgrounds/_wasm/` so `generate-playgrounds.R`
   restages them). Any playground using newly added components/functions needs a
   freshly built image, not the released one.
3. **Don't embed the image in `app.json`.** Keep `app.json` to `app.R` only
   (~tens of KB, like the other slugs). Bundling the ~14 MB image inflates it to
   ~19 MB and the Shinylive loader chokes → blank frame. The image is mounted
   from the separately served `../library.data.gz`, not from `app.json`.
4. **After changing any playground or the image:** re-run
   `Rscript scripts/generate-playgrounds.R` (regenerates `public/playgrounds/`),
   then **restart `npm run preview`**. `preview` serves a *copied snapshot* at
   `.preview/shinyblocks/` (taken from `out/` at startup), so edits under
   `public/` or `out/` are not picked up until the server is restarted. Also
   hard-refresh the browser (Cmd/Ctrl+Shift+R) — the Shinylive service worker
   caches `app.json`.

Note: `next dev` does not resolve directory-index URLs (`…/gallery/` → 404), so
embedded playgrounds only render under the static `npm run preview` build.

## Deploy

Push to `main` triggers `.github/workflows/docs-deploy.yml`, which builds and publishes to <https://nvelden.github.io/shinyblocks/>.
