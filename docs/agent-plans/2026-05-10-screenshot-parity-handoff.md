# Screenshot + Parity Handoff (2026-05-10)

Goal: finish the remaining Phase 5 work now that the written
component-spec backfill is complete.

## Current state

- Every exported `block_*()` now has a written spec doc under
  `docs/component-specs/`.
- `tests/testthat/test-doc-coverage.R` enforces spec presence for all
  exports.
- Screenshot capture is still manual.
- `tools/spec-screenshots.R` and
  `docs/component-specs/SCREENSHOT-QUEUE.md` track the remaining image
  backlog.
- Current queue size: 40 missing screenshots.

## Next stage

### Slice 1 — Seed captures

Capture the anchor images first:
- `button`
- `card`
- `select`
- `tabs`

For each:
1. open the shadcn docs page from the matching spec
2. capture the canonical light-mode example tightly cropped
3. save to `docs/component-specs/_screenshots/<slug>.png`
4. replace "Capture pending" in the spec with the actual capture date

### Slice 2 — High-risk interaction components

Capture the components where the parity review is most likely to force
CSS changes:
- `checkbox`
- `switch`
- `textarea`
- `dark-mode-toggle`
- `badge`
- `nav-item`
- `sidebar`

Then walk those same components in the local showcase, light and dark,
against the captured references.

### Slice 3 — Remaining spec screenshots

Work straight down `docs/component-specs/SCREENSHOT-QUEUE.md` until the
queue is empty.

### Slice 4 — Parity follow-up

Any deltas found during the screenshot-backed review should land with:
- CSS/JS/R changes as needed
- spec-doc divergence updates where the delta is deliberate
- `NEWS.md`
- `make build-css`
- targeted tests
- showcase + docs preview checks

### Slice 5 — Gallery resumption

Still blocked on ADR 0013 / WASM. Do not start this until the webR path
is unblocked.

## Commands

- `make spec-screenshots`
- `make spec-screenshots-md`
- `make build-css`
- `Rscript -e "devtools::test(filter = 'doc-coverage|showcase|shell|smoke')"`
- `Rscript -e "lintr::lint_package()"`
- `Rscript tools/budget.R`

## Definition of done for the next stage

- `docs/component-specs/SCREENSHOT-QUEUE.md` is either empty or
  materially smaller with committed screenshots
- seed specs (`button`, `card`, `select`, `tabs`) have real screenshots
- the showcase has been visually checked against those references
- any parity fixes discovered by that comparison are landed and
  documented
