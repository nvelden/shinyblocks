# Roadmap

The canonical strategy lives in
[`agent-plans/2026-05-08-port-strategy.md`](agent-plans/2026-05-08-port-strategy.md).
This document is the implementation sequence. Each phase ends by
passing the **Quality Gate** below before the next phase begins.

## Current Status

> **In progress: Phase 5 — tabs, forms, and theme runtime.**
>
> Landed and verified locally:
> - **Phase 0** — ADRs `0006`–`0015` accepted.
> - **Phase 1** — package shell, Tailwind v4 source, committed compiled
>   CSS, dependency plumbing, showcase scaffold, and core package
>   infrastructure.
> - **Phase 2** — `block_icon()`, `block_button()`, `block_badge()`,
>   `block_alert()`, `block_alert_title()`, `block_alert_description()`,
>   plus showcase/docs/test coverage.
> - **Phase 3** — `block_card()` composition primitives,
>   `block_value_box()`, `block_separator()`, `block_skeleton()`,
>   `block_spinner()`, and `block_empty()`.
> - **Phase 4** — `block_nav()`, `block_nav_item()`, collapsible
>   `block_sidebar()`, page-level sidebar state, and
>   `inst/www/shinyblocks.js` for desktop collapse, mobile open/close,
>   backdrop click, outside click, `Escape`, and nav keyboard movement.
> - **Phase 5 (current slice)** — `block_field_group()`, `block_field()`,
>   `block_field_label()`, `block_field_description()`,
>   `block_field_set()`, `block_field_legend()`,
>   `block_field_invalid()`, `block_input_group()`,
>   `block_input_group_addon()`, `block_select()`, `block_textarea()`,
>   `block_checkbox()`, `block_switch()`, `block_tab()`, `block_tabs()`,
>   `block_theme()`, `block_dark_mode_toggle()`, and
>   `update_block_theme()`.
>
> Still owed in Phase 5:
> - gallery `.qmd` pages once the WASM/gallery track resumes
> - component-spec backfill per [ADR 0015](decisions/0015-component-specs.md):
>   31 components are in `backfill_pending_specs` in
>   `tests/testthat/test-doc-coverage.R`; each one needs a
>   `docs/component-specs/<name>.md` and a captured reference
>   screenshot. The rule applies to new components today; the
>   backfill happens incrementally.
> - **shadcn fidelity audit** per
>   [`docs/agent-plans/2026-05-09-shadcn-fidelity-audit.md`](agent-plans/2026-05-09-shadcn-fidelity-audit.md):
>   token + class drift surfaced against the canonical
>   `apps/v4/registry/new-york-v4` source. Button + badge safe
>   drifts already fixed (rounded-full + text-xs on badge,
>   `text-white` on destructive variants, `text-primary` on link,
>   `shadow-xs` on outline, dark-mode destructive dim). Three cross-
>   cutting slices still owed:
>   1. Focus-visible redesign — drop the global
>      `.sb-app *:focus-visible` outline, add per-component
>      `border-ring + ring-[3px] + ring-ring/50` to button, badge,
>      nav-item, tabs trigger, select trigger, checkbox, switch.
>   2. `aria-invalid` styling on every interactive base, wired to
>      `block_field_invalid()`.
>   3. Tabs refactor to shadcn's `data-state` / `data-orientation` /
>      `data-variant` attribute model (replaces the current Bootstrap-
>      class-leaning markup).
>
> Next concrete slice:
>
> 1. Land the focus-visible + aria-invalid cross-cut as one commit
>    so every interactive component picks up the new ring + invalid
>    treatment together.
> 2. Refactor tabs to the shadcn data-attribute model; add the line
>    variant.
> 3. Capture reference screenshots for the seed specs (button, card)
>    so the §Per-gate component-sync rule has anchored examples.
> 4. Resume gallery page authoring once the WASM/gallery track is
>    back in active implementation.

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
   `gallery/components/` per [ADR 0013](decisions/0013-component-gallery-quarto.md).
10. **Multi-artifact coverage.** `test-doc-coverage.R` is green —
    every exported `block_*()` is referenced in `_pkgdown.yml`'s
    `reference:` section, and once WASM is unblocked, also has a
    matching gallery `.qmd` page. See
    [§Per-gate component-sync rule](#per-gate-component-sync-rule).

### B. Verify — semi-automated

11. **Showcase smoke test.** `shinytest2` launches
    `inst/showcase/app.R`, navigates every section, and
    `expect_screenshot()`s each. From Phase 1C onward, also run
    Shinylive export smoke.
12. **Performance budget.** `tools/budget.R`: CSS ≤30 KB, JS ≤15 KB,
    sprite ≤25 KB gzipped. Over budget = blocking unless ADR'd.
13. **Accessibility sweep.** Manual keyboard/screen-reader smoke on
    the showcase. Findings → `docs/a11y/notes.md`.
14. **Live preview — both servers running.** `make verify` (also
    invoked as the last step of `make gate`) builds pkgdown,
    launches the showcase on `:4321` and the pkgdown site on `:4322`
    in the background, HTTP-checks both for `200`, and leaves them
    running. The phase exit cannot tag until *both* respond. Walk
    through every component touched in this phase in both light and
    dark mode. From Phase 1C onward, `make preview-shinylive` is the
    third leg. Stop with `make verify-stop`.
    See [§Local Preview Workflow](#local-preview-workflow).
15. **Interaction-style parity.** For every component touched in the
    phase, walk every state listed in
    `docs/component-specs/<name>.md` against the live showcase. The
    spec's reference screenshot from
    <https://ui.shadcn.com/docs/components/...> is the shadcn ground
    truth — divergences are only acceptable if explicitly listed in
    the spec's "Deliberate divergences" section. Per
    [ADR 0015](decisions/0015-component-specs.md).

### C. Review

16. **Roxygen audit.** `@param`, `@return`, `@export`, `@examples`,
    `@family` on every exported function. `@noRd` on internals.
17. **Utility audit.** No copy-pasted helpers across `R/*.R`.
18. **Critical code review.** `critical-code-reviewer` skill against
    the phase diff.

### D. Document

19. **NEWS.md.** User-visible changes under next dev-version heading.
20. **`docs/` updates.** Roadmap status, strategy/ADR amendments,
    sync-log entries, cross-link check.

### E. Version and tag

21. **Version bump.** `0.0.0.9000 → 9001 → 9002 → ...`; Phase 7 →
    `0.1.0`.
22. **Single tidy commit on main.**
23. **Git tag.** `git tag phase-N`.
24. **CI green on main.**

### F. Optional from Phase 5 onward

25. **Deployed showcase refresh.**

## Local Preview Workflow

Run this any time you want to *see* the work — not just at phase exit.
After every component slice is a good cadence; before opening a PR is
the minimum.

| Command | Serves | Port | When to run |
| --- | --- | --- | --- |
| `make showcase` | Live showcase app | 4321 | After any new `block_*()` to eyeball it. |
| `make preview-pkgdown` | Built pkgdown site | 4322 | After `devtools::document()` — confirms reference pages render. |
| `make gallery` | Quarto-rendered component gallery | 4324 | After editing any `gallery/components/*.qmd`. |
| `make preview-shinylive` | Static Shinylive export | 4323 | From Phase 1C onward, once `tools/export-shinylive.R` lands. |
| `make preview` | Showcase + pkgdown together | 4321 + 4322 | Foreground; Ctrl+C to stop. |
| `make verify` | Same as preview but background + HTTP-checked | 4321 + 4322 | **Phase exit.** Last step of `make gate`. Stop with `make verify-stop`. |

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
  `gallery/components/`, modelled on
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
gallery/
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
- `make gallery` — render `gallery/` and serve the result.
- `make pkgdown` — full pkgdown site, which renders the gallery as
  part of the articles section when Quarto is installed.

### Adding a component to the gallery

When a new `block_*()` is exported, the same commit must add:

1. `gallery/components/_examples/<component>.R` — runnable
   Shiny app demonstrating the default and one or two interesting
   variants.
2. `gallery/components/<component>.qmd` — using the
   template above.
3. An entry in `gallery/components.qmd` (the gallery index
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

## Per-gate component-sync rule

When a phase-exit slice adds, renames, or removes any exported
`block_*()`, the following five artifacts must be in sync **in the
same commit** that lands the API change:

| Artifact | What goes in | Enforced by |
| --- | --- | --- |
| `inst/showcase/` | Example file + sections-list row | `test-showcase.R` |
| `_pkgdown.yml` `reference:` | Function under the matching category | `test-doc-coverage.R` |
| `gallery/components/*.qmd` | Page following the [§Components Gallery](#components-gallery) template | `test-doc-coverage.R` (currently `skip()`'d — see below) |
| `docs/component-specs/<name>.md` | Visual-parity spec per [ADR 0015](decisions/0015-component-specs.md) — shadcn link, states, token contract, divergences, reference screenshot | `test-doc-coverage.R` (active for new components; existing components in a `backfill_pending_specs` allowlist) |
| `NEWS.md` | One bullet under the dev-version heading | Quality Gate item 19 |

A drifted artifact fails the Quality Gate. The first four are
mechanically checked; `NEWS.md` is reviewer-checked at gate exit.

The component spec is the anchor for Quality Gate item 15 (interaction-
style parity) — the reviewer walks every state listed in the spec
against the live showcase, with the spec's reference screenshot as the
shadcn ground truth.

### Gallery exception during the WASM hold

[ADR 0013](decisions/0013-component-gallery-quarto.md) requires a
gallery `.qmd` per component, but live demos depend on a webR-loadable
shinyblocks binary at `repo.r-wasm.org`. The path-B WASM build was
deferred — the gallery currently has only `button.qmd`. The matching
test in `test-doc-coverage.R` is `skip()`'d with a pointer to ADR 0013.

When WASM lands:

1. Drop the `skip()` call in `test-doc-coverage.R`.
2. Author one `.qmd` page (and matching `_examples/<component>.R`)
   per exported `block_*()` so the test passes.
3. Update `_pkgdown.yml` `articles:` to list every page.

Until then, the showcase is the visual verification surface.

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
