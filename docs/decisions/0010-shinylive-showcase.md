# ADR 0010: Shinylive Showcase Deployment

## Status

Accepted (2026-05-08)

## Context

shinyblocks needs an accompanying interactive showcase app. The original
plan allowed deployment to shinyapps.io or shinylive. The project should use
Shinylive so the showcase runs entirely in the browser as a static site.

`shinylive::export(appdir, destdir)` converts a regular Shiny app directory
into a static site that runs through webR. That has three important
constraints:

- webR cannot install R packages from source in the browser. Packages must be
  available as precompiled WebAssembly binaries from `repo.r-wasm.org`.
- `shinylive::export()` recursively serializes the app directory into
  `app.json`, so exports must stage a clean app directory and never export from
  the repository root.
- The repository already uses `docs/` for maintainer planning material, and
  future pkgdown output may also need to be composed into the public site. A
  root `docs/` export would collide with those concerns.

The showcase cannot assume `library(shinyblocks)` works inside webR until the
package is available as a WASM binary. The package is currently pre-CRAN, so
the export must be designed around a clean staging copy.

## Decision

The showcase has two modes:

1. **Local package mode**

   `shinyblocks::run_showcase()` runs the showcase from the installed or
   `devtools::load_all()` package. This is the maintainer/developer loop.

2. **Shinylive export mode**

   A build helper stages a clean app directory and exports it with
   `shinylive::export()`.

   The staging directory contains only:

   ```text
   app.R
   R/
     shinyblocks/        # copied package R helpers needed by showcase
     showcase/           # showcase-specific app code
   www/
     shinyblocks/        # copied package assets from inst/www
   ```

   The staged `app.R` uses `library(shiny)` and `library(htmltools)`, then
   relies on Shiny's automatic `R/` sourcing. It does not call
   `library(shinyblocks)` while the package is not available to webR.

## Asset Dependency Contract

`shinyblocks_dependency()` must support both package mode and app-asset mode:

- package mode: `htmltools::htmlDependency(package = "shinyblocks", src = "www",
  ...)`;
- app-asset mode: `htmltools::htmlDependency(src = c(href = "shinyblocks"),
  ...)`, with assets copied to `www/shinyblocks/` in the staged app.

The mode can be controlled by an internal option set in staged Shinylive
exports, for example:

```r
options(shinyblocks.asset_mode = "app")
```

Normal package users never need to set this option.

## Export Command and Site Layout

Add a maintainer build target that stages cleanly:

```bash
make shinylive-export
```

The target should:

1. remove any previous `.shinylive-stage/` and `site/showcase/` export output;
2. copy only the required showcase app files, selected package `R/` files, and
   `inst/www` assets into `.shinylive-stage/`;
3. run
   `shinylive::export(appdir = ".shinylive-stage", destdir = "site/showcase")`;
4. inspect `site/showcase/app.json` size so accidental repo-file bundling is
   caught;
5. leave `site/showcase/` ready to be composed with the pkgdown site and
   uploaded as a static hosting artifact.

The plan should not export from the repository root.

The public website should be composed as generated output, not maintained by
hand:

```text
site/
  pkgdown/      # optional package docs output
  showcase/     # Shinylive output
```

GitHub Pages should publish a built artifact from `site/` when available. Do
not use root `docs/` as the Pages source unless the planning docs and pkgdown
output strategy have first been reorganized by a separate decision.

## Package Availability Check

Before relying on any package in the Shinylive showcase, verify that it exists
in the r-wasm package index for the target R version:

```bash
curl -s "https://repo.r-wasm.org/bin/emscripten/contrib/4.5/PACKAGES" |
  grep -E "^Package: (shiny|htmltools|bslib)$" | sort -u
```

If a dependency is not available, either remove it from the showcase path or
defer the feature from the Shinylive app until a WASM binary is available.

## Local Preview

Preview with a static server that serves `.wasm` correctly:

```bash
python3 -m http.server 8080 --directory site --bind 127.0.0.1
```

Then open `/showcase/`.

Do not rely on `httpuv::runStaticServer()` for final Shinylive verification
because incorrect `.wasm` MIME types can break Chrome's streaming compile.

## Testing

The Shinylive smoke test should run after normal Shiny tests pass:

- export to `site/showcase/`;
- serve with `python3 -m http.server`;
- use a browser test with a long first-load timeout because webR can take
  1-2 minutes on first visit;
- verify the app iframe loads;
- verify the shell, sidebar, theme, and at least one component example;
- run desktop and mobile viewport checks.

Documentation near the app link must warn users that the first visit can take
1-2 minutes while browser runtime assets download and cache.

## Deployment

Primary target: GitHub Pages from a built `site/` artifact, with the showcase
available under `/showcase/`.

If the repository remains private, GitHub Pages may require GitHub Pro, Team,
or Enterprise. If Pages is unavailable for the private repository, deploy the
same `site/` artifact to Cloudflare Pages, Netlify, or another static host.

## Consequences

- The showcase remains a static site and needs no Shiny server.
- First-load size is larger than a hosted Shiny app because webR and package
  binaries are downloaded to the browser.
- The export process must be kept clean; accidental files in the staged app
  directly inflate `app.json`.
- The staged Shinylive app exercises package-generated HTML and assets, but it
  does not prove the package can be installed inside webR until shinyblocks has
  a WASM binary.

## References

- `posit-dev/r-shinylive`: `shinylive::export(appdir, destdir)` exports a Shiny
  app to a static site.
- `repo.r-wasm.org`: package availability index for webR.
- Shinylive skill: clean staging, package availability checks, static-server
  preview, GitHub Pages deployment, and first-load warnings.
