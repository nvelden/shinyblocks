# Shadcn Fidelity Audit

## Goal

Tighten `shinyblocks` so exported components are driven by semantic
tokens, visually track shadcn/ui more closely, and avoid styling
dependencies on Bootstrap or Selectize defaults.

## Assumptions

- Runtime remains R + Shiny + `htmltools`, with local CSS/JS assets.
- Theming must flow through CSS custom properties, not hard-coded
  light/dark overrides.
- Exact parity for interaction-heavy controls requires dedicated
  wrappers instead of styling raw Shiny widgets.

## Proposed API

- Add `block_select()` as the first dedicated form control wrapper.
- Keep `block_field_*()` and `block_input_group_*()` as composition
  primitives around form controls.
- Audit existing components against the shadcn contracts for:
  buttons, badges, alerts, cards, value boxes, nav/sidebar, empty
  states, separators, skeletons, spinners, and fields.

## Files To Edit

- `R/select.R`
- `R/utils.R`
- `R/field.R`
- `R/package.R`
- `DESCRIPTION`
- `_pkgdown.yml`
- `NEWS.md`
- `inst/www/src/shinyblocks.css`
- `inst/www/shinyblocks.js`
- `inst/showcase/app.R`
- `inst/showcase/R/examples/field.R`
- `tests/testthat/test-shell.R`
- `tests/testthat/test-showcase.R`
- `tests/testthat/test-utils.R`

## Tests / Checks

- `devtools::document()`
- `make build-css`
- `devtools::test()`
- `lintr::lint_package()`
- `pkgdown::check_pkgdown()`
- `devtools::check()`
- restart showcase and verify `http://127.0.0.1:4321`

## Open Questions

- How far should `block_select()` go in v0.1 on grouped choices and
  multi-select?
- Whether `block_checkbox()`, `block_switch()`, and `block_textarea()`
  should follow immediately after `block_select()` or wait for a second
  Phase 5 pass.

## Current Findings

- Implemented primitives already use semantic tokens instead of raw
  palette values: shell, nav, button, badge, alert, card, value box,
  separator, skeleton, spinner, empty, fields, and input groups.
- The main fidelity gap found in the shipped UI was select handling:
  the field wrapper was inheriting Selectize styling rather than
  rendering a first-class shadcn-like control.
- `block_select()` is the first dedicated form control added to close
  that gap while preserving Shiny reactivity through a real `<select>`.
- Remaining high-value parity work is in not-yet-built form controls
  and tabs rather than the already-landed static primitives.
