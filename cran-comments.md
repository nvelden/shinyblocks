# cran-comments.md

This file documents notes accompanying CRAN submissions. Update at
each release; clear stale entries between submissions.

## Test environments

* local: <fill in: macOS / R version> (`devtools::check(remote = TRUE,
  manual = TRUE)`)
* GitHub Actions: ubuntu-latest, macos-latest, windows-latest;
  R release and devel.
* `R-hub`: <fill in if used>

## R CMD check results

* 0 errors
* 0 warnings
* 0 notes

(Pre-release: this section reflects the most recent local run. Update
before submitting.)

## Downstream dependencies

None at v0.1. (`revdepcheck::revdep_check()` will run once the
package is on CRAN.)

## Notes for the reviewer

* shinyshadcn ships a compiled CSS file under
  `inst/www/shinyshadcn.css`. It is generated from
  `inst/www/src/shinyshadcn.css` via Tailwind v4 at maintainer
  build time. Source is excluded from the package tarball via
  `.Rbuildignore`. End users do not need Node.
* shinyshadcn vendors a curated subset of Lucide SVG icons under
  `inst/www/icons/sprite.svg`. Lucide is ISC-licensed; attribution
  is at `inst/www/icons/LICENSE`.
* Components emit Bootstrap-flavored classes when wrapping
  `shiny::tabsetPanel()` (which delegates to `bslib`). This is
  documented in the tabs reference page and in
  `vignette("coexistence")`.
