# Roadmap

The canonical strategy lives in
[`agent-plans/2026-05-08-port-strategy.md`](agent-plans/2026-05-08-port-strategy.md).
This document is the implementation sequence. Each phase ends by
passing the **Quality Gate** below before the next phase begins.

## Current Status

> **In progress: Phase 2 — icons and static components.**
>
> Landed (not yet through a formal phase-exit gate):
> - **Phase 0** — ADRs `0006`–`0012` accepted.
> - **Phase 1A** — `block_page()`, `block_body()`, `block_header()`,
>   `block_sidebar()`, `attach_shinyblocks_deps()`, plus shell tests.
> - **Phase 1B** — Tailwind v4 source under `inst/www/src/`,
>   committed compiled `inst/www/shinyblocks.css`, `make build-css`.
> - **Phase 1C** — `_pkgdown.yml`, `inst/showcase/app.R` scaffold,
>   `Makefile` inner-loop and gate targets, `tools/budget.R`,
>   `tools/check-doc-links.R`, `inst/WORDLIST`, `tests/testthat/setup.R`.
>   Still owed: split CRAN CI matrix into `R-CMD-check.yaml` +
>   `cran-release-check.yaml`, add `tools/export-shinylive.R`.
> - **Phase 2** — `block_icon()` with vendored Lucide sprite,
>   `block_button()` with variants and sizes, `block_badge()` with
>   four variants, `block_alert()` + `block_alert_title()` +
>   `block_alert_description()` with composable slots and ARIA
>   `role="alert"`. Still owed: showcase examples for badge and
>   alert so the Local Preview can eyeball them.
> - **Phase 3 (early)** — `block_card()` flat-argument convenience
>   shape with CSS. Composition primitives, `block_value_box()`,
>   `block_separator()`, `block_skeleton()`, `block_spinner()`, and
>   `block_empty()` still owed.
> - **Phase 4 (early)** — `block_nav_item()` with `data-sb-child`
>   marker. `block_nav()`, sidebar collapse, mobile sheet, and the
>   `inst/www/shinyblocks.js` module still owed.
>
> **Recently decided:** [ADR 0013](decisions/0013-component-gallery-quarto.md)
> commits the package to a Quarto + shinylive component gallery under
> `vignettes/articles/components/`, modelled on
> <https://shiny.posit.co/r/components/>. This adds Quarto + the
> `quarto-ext/shinylive` extension as a dev/CI dependency. See the
> [Components Gallery](#components-gallery) section below for the build
> and authoring contract.
>
> Next concrete slice (Phase 2 finish + gallery proof of concept):
>
> 1. Run `make quarto-setup` once locally to install Quarto and the
>    shinylive extension.
> 2. Render the scaffolded `vignettes/articles/components/button.qmd`
>    via `make gallery` — confirm the live demo and code listing both
>    show up.
> 3. Add `inst/showcase/R/examples/badge.R` and `alert.R`, wire them
>    into `inst/showcase/app.R`, run `make preview` to eyeball.
> 4. Author `badge.qmd`, `alert.qmd`, `card.qmd`, `icon.qmd`, plus the
>    layout/navigation pages (`page.qmd`, `header.qmd`, `sidebar.qmd`,
>    `nav-item.qmd`) and the gallery index `components.qmd`.
> 5. Run the Quality Gate to formally exit Phases 1A → 2 in one
>    bundled phase-exit file.

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
   has tag-shape, validation, ARIA, and `merge_classes()` tests, plus
   a section in `inst/showcase/` enforced by `test-showcase.R` (see
   [§Showcase App](#showcase-app)).
7. **Documentation.** `devtools::document()` no warnings. Generated
   `man/` committed.
8. **Package check.** `devtools::check(remote = TRUE, manual = FALSE)`
   clean. Full manual PDF checks are release-gate only.
9. **pkgdown.** `pkgdown::build_site()` succeeds. New components have
   both an auto-generated reference page **and** a gallery page under
   `vignettes/articles/components/` per [ADR 0013](decisions/0013-component-gallery-quarto.md).

### B. Verify — semi-automated

10. **Showcase smoke test.** `shinytest2` launches
    `inst/showcase/app.R`, navigates every section, and
    `expect_screenshot()`s each. From Phase 1C onward, also run
    Shinylive export smoke.
11. **Performance budget.** `tools/budget.R`: CSS ≤30 KB, JS ≤15 KB,
    sprite ≤25 KB gzipped. Over budget = blocking unless ADR'd.
12. **Accessibility sweep.** Manual keyboard/screen-reader smoke on
    the showcase. Findings → `docs/a11y/notes.md`.
13. **Local preview — visual sanity check.** Run `make preview` to
    launch the local showcase and pkgdown site side by side. Walk
    through every component added or touched in this phase, in both
    light and dark mode. From Phase 1C onward, also run
    `make preview-shinylive` to confirm the export still renders.
    See [§Local Preview Workflow](#local-preview-workflow). This is
    an *eyes-on-pixels* check — automated tests do not replace it.

### C. Review

14. **Roxygen audit.** `@param`, `@return`, `@export`, `@examples`,
    `@family` on every exported function. `@noRd` on internals.
15. **Utility audit.** No copy-pasted helpers across `R/*.R`.
16. **Critical code review.** `critical-code-reviewer` skill against
    the phase diff.

### D. Document

17. **NEWS.md.** User-visible changes under next dev-version heading.
18. **`docs/` updates.** Roadmap status, strategy/ADR amendments,
    sync-log entries, cross-link check.

### E. Version and tag

19. **Version bump.** `0.0.0.9000 → 9001 → 9002 → ...`; Phase 7 →
    `0.1.0`.
20. **Single tidy commit on main.**
21. **Git tag.** `git tag phase-N`.
22. **CI green on main.**

### F. Optional from Phase 5 onward

23. **Deployed showcase refresh.**

## Local Preview Workflow

Run this any time you want to *see* the work — not just at phase exit.
After every component slice is a good cadence; before opening a PR is
the minimum.

| Command | Serves | Port | When to run |
| --- | --- | --- | --- |
| `make showcase` | Live showcase app | 4321 | After any new `block_*()` to eyeball it. |
| `make preview-pkgdown` | Built pkgdown site | 4322 | After `devtools::document()` — confirms reference pages render. |
| `make gallery` | Quarto-rendered component gallery | 4324 | After editing any `vignettes/articles/components/*.qmd`. |
| `make preview-shinylive` | Static Shinylive export | 4323 | From Phase 1C onward, once `tools/export-shinylive.R` lands. |
| `make preview` | Showcase + pkgdown together | 4321 + 4322 | Phase exit. Flip between live components and their docs. |

What to actually look at:

1. **Showcase (`http://127.0.0.1:4321`)** — every component section
   renders, light/dark mode toggle works, no console errors, no
   broken icons, no layout shift on hover/focus.
2. **pkgdown (`http://127.0.0.1:4322`)** — reference index lists
   every exported function, each page has examples that render,
   the category grouping in `_pkgdown.yml` matches the strategy
   doc.
3. **Shinylive (`http://127.0.0.1:4323`)** — static export loads in
   a fresh tab, dark mode works, no asset 404s in the network tab.

If any of those fail the eyeball check, fix before tagging the phase
exit. This step is also called out as Quality Gate item 13.

## Phase Exit Process

Each exit is recorded in `docs/phase-exits/phase-N.md` (copied from
`docs/phase-exits/TEMPLATE.md`). Commit when all green.

## When Things Go Wrong

Non-obvious problems → postmortem under
[`docs/dev-notes/`](dev-notes/README.md). User-facing fixes →
[`docs/troubleshooting.md`](troubleshooting.md).

## Continuous Tracks

Three artifacts grow with every phase. Details in the
[strategy doc](agent-plans/2026-05-08-port-strategy.md#shinylive-showcase)
and [ADR 0013](decisions/0013-component-gallery-quarto.md):

- **pkgdown site** — category-grouped reference. Auto-generated from
  roxygen. CI builds it; a failed build blocks the phase.
- **Component gallery** — Quarto `.qmd` pages under
  `vignettes/articles/components/`, modelled on
  <https://shiny.posit.co/r/components/>. One page per exported
  component, embedded Shinylive demo + visible source. See
  [§Components Gallery](#components-gallery).
- **Showcase app** — `inst/showcase/`, launchable via
  `run_showcase()`. Dogfooded — its own UI is built with shinyblocks
  primitives. Sidebar filters one component at a time. Authoring
  contract enforced by `test-showcase.R`. See
  [§Showcase App](#showcase-app). Hosted version exported via
  Shinylive to `site/showcase/`.

## Components Gallery

The gallery is the visual spine of the docs. Every exported `block_*()`
gets one `.qmd` page with this fixed shape (the same shape
shiny.posit.co/r/components uses):

1. YAML front matter (`title`, optional `description`).
2. Lead paragraph (1–2 sentences).
3. `{shinylive-r}` fence with `#| standalone: true`,
   `#| components: [viewer]`, `#| viewerHeight:` (component-specific),
   body via `{{< include _examples/<component>.R >}}`.
4. Plain `r` fence showing the same code (same include — single
   source).
5. **Relevant Functions** — bulleted list of signature lines linking
   to the auto-generated reference page.
6. **Details** — short prose, optionally a numbered list.
7. **See also** — sibling components and any related vignettes.

### Layout

```
vignettes/articles/
├── components.qmd                    # gallery landing
└── components/
    ├── _examples/<component>.R       # canonical Shiny app per component
    └── <component>.qmd               # one per exported block_*()
```

Each `_examples/*.R` is a complete runnable Shiny app with
`library(shiny)`, `library(shinyblocks)`, `ui <-`, `server <-`,
`shinyApp(...)`. It is the single source of truth — included twice in
the `.qmd` (live demo + visible code).

### Build

- `make quarto-setup` — one-shot install of Quarto +
  `quarto add quarto-ext/shinylive`. Run once per machine.
- `make gallery` — render `vignettes/articles/` and serve the result.
- `make pkgdown` — full pkgdown site, which renders the gallery as
  part of the articles section when Quarto is installed.

### Adding a component to the gallery

When a new `block_*()` is exported, the same commit must add:

1. `vignettes/articles/components/_examples/<component>.R` — runnable
   Shiny app demonstrating the default and one or two interesting
   variants.
2. `vignettes/articles/components/<component>.qmd` — using the
   template above.
3. An entry in `vignettes/articles/components.qmd` (the gallery index
   landing page).
4. The category mapping in `_pkgdown.yml` `articles:` for navbar
   grouping.

Pages that ship without a gallery entry block the Quality Gate.

## Showcase App

The dogfooded showcase under `inst/showcase/` is the second consumer
of every component. It is a single-page Shiny app whose own UI is
built entirely with `shinyblocks` — `block_page()`, `block_sidebar()`,
`block_header()`, `block_body()`, `block_nav_item()`. Clicking a
sidebar item filters the body to that one section so each component
renders in isolation; the URL hash deep-links the active section.

It exists for two reasons: (1) the package documents itself by *being*
a shinyblocks dashboard; (2) it is a fast verification surface for the
maintainer — far cheaper than rebuilding the Quarto gallery to confirm
a CSS change.

### Layout

```
inst/showcase/
├── app.R                            # block_page shell + sections list
└── R/
    ├── render_example.R             # eval an example file -> tag + code
    ├── section.R                    # sb_section() helper, hides non-active
    └── examples/<component>.R       # tag/tagList per component
```

The `sections` list at the top of `app.R` drives both the sidebar nav
and the body — one row per component, each pointing at its example
file under `R/examples/`.

### Authoring contract

When a new `block_*()` is exported, the same commit must add:

1. `inst/showcase/R/examples/<component>.R` — a `htmltools::tagList`
   showing the default plus interesting variants, evaluable in a
   fresh environment with shinyblocks loaded.
2. A row in the `sections` list in `inst/showcase/app.R` (id, label,
   icon, title, lead, file).
3. Run `make showcase` and eyeball it. The new section should appear
   in the sidebar, render correctly when selected, and deep-link via
   `#<id>`.

`tests/testthat/test-showcase.R` enforces this contract end-to-end —
exporting a new `block_*()` without referencing it from the showcase
fails the test suite. Specifically the suite asserts:

- Every file under `inst/showcase/R/examples/` evaluates to a
  `shiny.tag` or `shiny.tag.list`.
- Every section in the `sections` list has a matching
  `data-sb-section` element and a matching `href="#..."` sidebar link
  in the rendered UI.
- Every exported `block_*()` puts its conventional class
  (`sb-<name>`) somewhere in the rendered showcase UI.
- The first section is rendered visible; all others render with the
  `hidden` attribute so the JS filter has a stable starting state.

Components that are emitted transitively (e.g. `block_body` via
`block_page`) still appear in the rendered HTML through their parent
and need no separate section. The class-coverage test catches the
case where they are removed entirely.

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
