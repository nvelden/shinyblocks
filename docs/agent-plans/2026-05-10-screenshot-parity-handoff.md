# Screenshot + Parity Handoff (2026-05-10)

Goal: finish the remaining Phase 5 work now that the written
component-spec backfill is complete.

## Current state

- Every exported `block_*()` now has a written spec doc under
  `docs/component-specs/`.
- `tests/testthat/test-doc-coverage.R` enforces spec presence for all
  exports.
- `tools/spec-screenshots.R` and
  `docs/component-specs/SCREENSHOT-QUEUE.md` track the remaining image
  backlog.
- Screenshot capture helpers now exist for:
  - `make spec-screenshots-seed`
  - `make spec-screenshots-high-risk`
  - `make spec-screenshots-all`
  - `make showcase-capture SECTION=<section> OUT=<path> THEME=light|dark`
- Theme-forced local captures require Safari's
  `Allow JavaScript from Apple Events` setting.
- Current queue size: 0 missing screenshots, 40 captured-dated.
- The committed screenshots are first-pass references. Re-crop any spec
  that needs a tighter visual target during the parity pass.
- The queue remains priority-sorted into `seed`, `high-risk`, and
  `remaining`, but it is now a review list rather than an empty
  placeholder.

## Next stage

### Slice 1 — High-risk interaction parity

Walk the highest-risk components against the captured references:
- `checkbox`
- `switch`
- `textarea`
- `dark-mode-toggle`
- `badge`
- `nav-item`
- `sidebar`

For each:
1. open the captured spec screenshot
2. walk the matching local showcase state in light and dark mode
3. land any CSS/runtime fixes needed for parity
4. update the spec's "Deliberate divergences" section if the delta is
   intentional

### Slice 2 — Remaining screenshot-backed review

Work straight down `docs/component-specs/SCREENSHOT-QUEUE.md` until each
captured reference has been reviewed against the local showcase.

### Slice 3 — Parity follow-up

Any deltas found during the screenshot-backed review should land with:
- CSS/JS/R changes as needed
- spec-doc divergence updates where the delta is deliberate
- `NEWS.md`
- `make build-css`
- targeted tests
- showcase + docs preview checks

### Slice 4 — Gallery resumption

Still blocked on ADR 0013 / WASM. Do not start this until the webR path
is unblocked.

## Commands

- `make spec-screenshots`
- `make spec-screenshots-md`
- `make spec-screenshots-seed`
- `make spec-screenshots-high-risk`
- `make spec-screenshots-all`
- `make build-css`
- `Rscript -e "devtools::test(filter = 'doc-coverage|showcase|shell|smoke')"`
- `Rscript -e "lintr::lint_package()"`
- `Rscript tools/budget.R`

## Definition of done for the next stage

- the captured references are reviewed against the live showcase,
  starting with the high-risk set
- any parity fixes discovered by that comparison are landed and
  documented
- `docs/component-specs/SCREENSHOT-QUEUE.md` stays at zero missing via
  `make spec-screenshots-check`
