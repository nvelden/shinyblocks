# Roadmap

The canonical strategy lives in
[`agent-plans/2026-05-08-port-strategy.md`](agent-plans/2026-05-08-port-strategy.md).
This document is the implementation sequence. Each phase ends by
passing the **Quality Gate** below before the next phase begins.

## Current Status

> **Phase 0 complete** — ADRs `0006`–`0012` are accepted.
> Next: start Phase 1A, the asset dependency and static shell slice.

Update this line at every phase exit.

## Quality Gate (Every Phase)

No phase is complete until every step below passes, **in this order**.
Order matters: cheap automated checks run first. The gate is runnable
as `make gate`.

### A. Verify — automated

1. **Build pipeline.** `make build-css` clean; committed CSS matches
   source (CI drift check).
2. **Lint.** `lintr::lint_package()` clean.
3. **Spelling.** `devtools::spell_check()` clean. New jargon →
   `inst/WORDLIST`.
4. **URLs.** `urlchecker::url_check()` clean.
5. **Latest-version verification.** All versioned inputs touched in
   the phase checked against authoritative sources. Recorded in the
   relevant ADR, sync log, or phase-exit file.
6. **Tests.** `devtools::test()` clean. Every new exported function
   has tag-shape, validation, ARIA, and `merge_classes()` tests.
7. **Documentation.** `devtools::document()` no warnings. Generated
   `man/` committed.
8. **Package check.** `devtools::check(remote = TRUE, manual = FALSE)`
   clean. Full manual PDF checks are release-gate only.
9. **pkgdown.** `pkgdown::build_site()` succeeds. New components have
   reference pages.

### B. Verify — semi-automated

10. **Showcase smoke test.** `shinytest2` launches
    `inst/showcase/app.R`, navigates every section, and
    `expect_screenshot()`s each. From Phase 1C onward, also run
    Shinylive export smoke.
11. **Performance budget.** `tools/budget.R`: CSS ≤30 KB, JS ≤15 KB,
    sprite ≤25 KB gzipped. Over budget = blocking unless ADR'd.
12. **Accessibility sweep.** Manual keyboard/screen-reader smoke on
    the showcase. Findings → `docs/a11y/notes.md`.

### C. Review

13. **Roxygen audit.** `@param`, `@return`, `@export`, `@examples`,
    `@family` on every exported function. `@noRd` on internals.
14. **Utility audit.** No copy-pasted helpers across `R/*.R`.
15. **Critical code review.** `critical-code-reviewer` skill against
    the phase diff.

### D. Document

16. **NEWS.md.** User-visible changes under next dev-version heading.
17. **`docs/` updates.** Roadmap status, strategy/ADR amendments,
    sync-log entries, cross-link check.

### E. Version and tag

18. **Version bump.** `0.0.0.9000 → 9001 → 9002 → ...`; Phase 7 →
    `0.1.0`.
19. **Single tidy commit on main.**
20. **Git tag.** `git tag phase-N`.
21. **CI green on main.**

### F. Optional from Phase 5 onward

22. **Deployed showcase refresh.**

## Phase Exit Process

Each exit is recorded in `docs/phase-exits/phase-N.md` (copied from
`docs/phase-exits/TEMPLATE.md`). Commit when all green.

## When Things Go Wrong

Non-obvious problems → postmortem under
[`docs/dev-notes/`](dev-notes/README.md). User-facing fixes →
[`docs/troubleshooting.md`](troubleshooting.md).

## Continuous Tracks

Two artifacts grow with every phase. Details in the
[strategy doc](agent-plans/2026-05-08-port-strategy.md#shinylive-showcase):

- **pkgdown site** — category-grouped reference modeled on
  <https://shiny.posit.co/r/components/>. CI builds it; a failed
  build blocks the phase.
- **Showcase app** — `inst/showcase/`, launchable via
  `run_showcase()`. Dogfooded with shinyblocks. Hosted version
  exported via Shinylive to `site/showcase/`.

---

## Phase 0 — Decisions

ADRs `0006`–`0012` under [`docs/decisions/`](decisions/). Done.

## Phase 1A — Asset Dependency and Static Shell

Goal: minimal static dashboard shell, renders without JS.

- `R/deps.R`: `shinyblocks_dependency()`, `attach_shinyblocks_deps()`.
- `R/utils.R`: `merge_classes()`, `validate_children()`.
- `R/page.R`: `block_page()`, `block_body()`.
- `R/header.R`: `block_header()`.
- `R/sidebar.R`: `block_sidebar()` static layout (no collapse).
- Tests: tag shape, semantic landmarks, single dependency attachment.

Exit: shell renders with JS disabled; `devtools::test()` and check pass.

## Phase 1B — CSS Build Pipeline

Goal: dev-time Tailwind v4 build wired up, no public R API change.

- `inst/www/src/tokens.css` + `inst/www/src/shinyblocks.css` source.
- `Makefile` `build-css` and `package.json` `build:css` targets.
- CI drift check on committed `inst/www/shinyblocks.css`.

Exit: generated CSS is reproducible; no Node at install time.

## Phase 1C — Package Infrastructure

Goal: project infrastructure after the first working shell.

- **pkgdown:** `_pkgdown.yml` with seven reference categories.
- **CRAN CI:** `.github/workflows/R-CMD-check.yaml` (Ubuntu
  devel/release/oldrel-1, macOS release, Windows release).
- **CRAN release gate:** `.github/workflows/cran-release-check.yaml`.
- **Showcase:** scaffold `inst/showcase/app.R` + `render_example()`.
- **Shinylive export:** `tools/export-shinylive.R` staging flow.
- **Makefile targets:** inner loop (`setup`, `watch-css`, `dev`,
  `showcase`, `check-fast`) and phase exit (`gate`).
- **Gate tools:** `tools/budget.R`, `tools/check-doc-links.R`,
  `inst/WORDLIST`, `tests/testthat/setup.R`.
- `Suggests:` grows only as checks are wired in.

Exit: automated gate runs on CI, pkgdown builds, showcase runs
locally, Shinylive export succeeds.

## Phase 2 — Icons and Static Components

- `R/icon.R`: `block_icon()` + vendored Lucide sprite (~80 icons).
- `R/button.R`: variants and sizes per strategy doc.
- `R/badge.R`, `R/alert.R`: variants, composition slots.
- Tests: variant validation, ARIA, icon sprite reference.
- Showcase: gallery sections for icon, button, badge, alert.

## Phase 3 — Composite Components

- `R/card.R`: full composition primitives + flat-argument convenience.
- `R/value-box.R`, `R/separator.R`, `R/skeleton.R`, `R/spinner.R`,
  `R/empty.R`.
- Tests: composition validation, slot composition.
- **Third-party widget smoke test:** verify `plotOutput()`,
  `DT::dataTableOutput()`, `plotly::plotlyOutput()`, and
  `rhandsontable::rHandsontableOutput()` render inside
  `block_card_content()`. Manual visual check in showcase.
- Showcase: multi-card grid, empty state, third-party widgets section.

## Phase 4 — Navigation and Behavior

- `R/sidebar.R`: collapse/expand, mobile sheet, keyboard nav. JS
  module in `inst/www/shinyblocks.js`.
- `R/nav.R`: `block_nav()`, `block_nav_item()` with selected state.
- Showcase: convert sidebar to `block_nav()`, demonstrate collapse.

## Phase 5 — Tabs, Forms, and Theme Runtime

- `R/tabs.R`: wrap `shiny::tabsetPanel()`, additive decoration only.
  Add `bslib` to `Imports` if needed. See
  [ADR 0007](decisions/0007-tabs-and-bootstrap.md).
- `R/field.R`, `R/input-group.R`: wrap Shiny inputs in sb-styled
  field markup. See strategy doc
  [§Field layout](agent-plans/2026-05-08-port-strategy.md#field-layout-shiny-input-wrapping).
- `R/theme.R`, `R/dark-mode.R`: `block_theme()`,
  `block_dark_mode_toggle()`, `update_block_theme()`.
- Showcase: tabs, forms with validation states, live theme controls.

## Phase 6 — Documentation Polish

- `inst/templates/starter/`: minimal starter app.
- Vignettes finalized: `getting-started`, `theming`, `components`,
  `coexistence`, `accessibility`.
- `coexistence.Rmd` documents embedding third-party widgets (ggplot2,
  DT, plotly, leaflet, rhandsontable) inside shinyblocks containers.
- `docs/upstream/sb-sync.md` initial entry.
- README links to pkgdown, showcase, and `run_showcase()`.

## Local Preview Before Going Public

Before making the repository public, build and review locally:

1. **pkgdown site.** `make pkgdown` → browse `site/docs/index.html`.
2. **Shinylive showcase.** `make shinylive-export` → serve
   `site/showcase/` locally.
3. **Local showcase.** `shinyblocks::run_showcase()`.
4. **README & metadata.** No incomplete or internal references.

Only make the repo public once all four pass.

## Phase 7 — Hardening and Release

- Critical code review, a11y pass, cross-browser check.
- `R CMD check --as-cran` clean including manual/PDF.
- pkgdown + Shinylive deployed as one static site artifact.
- NEWS.md in user-facing voice. Tag `v0.1.0`.
- (Optional) CRAN submission.

## Post-v0.1 Candidates

Each requires its own ADR. See strategy doc
[§v0.1 Scope — out of scope](agent-plans/2026-05-08-port-strategy.md#v01-scope)
for the full list with rationale.
