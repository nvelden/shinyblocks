# shinyshadcn Plan

A Shiny dashboard package with the authoring ergonomics of `shinydashboard`
and the visual language of shadcn/ui. End users install from CRAN; they
never need Node, Tailwind, or React.

The canonical strategy lives in
[`docs/agent-plans/2026-05-08-port-strategy.md`](docs/agent-plans/2026-05-08-port-strategy.md).
This document is the short product brief.

## Repository Policy

The public GitHub repository is package-facing. It should contain the
installable R package, package assets, tests, README, NEWS, and
contributor guidance. Agent instructions, scratch plans, and long-form
implementation planning can stay in the maintainer workspace until a
specific artifact is ready to become part of the public workflow.

## Audience

- R/Shiny developers building modern dashboards without a frontend build
  pipeline.
- Scientific, data, and operational dashboards that need dense, accessible
  interfaces.
- Developers who want themeable primitives, not a fixed template.

## Core Principles

- R-first API: every public function returns `htmltools::tag` or
  `shiny.tag` objects.
- **No Node, no Tailwind, no React at user install time.** Tailwind v4
  is used by maintainers to compile `inst/www/shinyshadcn.css`; the
  compiled file is committed and shipped on CRAN. Same model as
  `bslib` (Sass → compiled Bootstrap) and `bs4Dash` (vendored
  AdminLTE).
- No CDN at runtime. All assets are local.
- shadcn/ui is treated as upstream design reference, not as code to copy.
- Any versioned dependency, library, package, tool, documentation source,
  API contract, or upstream reference must be verified against the latest
  available version before planning or implementation decisions are made.
  Do not rely on remembered versions or stale examples.
- Theming is token-based (CSS custom properties) and override-friendly.
- Components degrade to clean HTML/CSS when JavaScript is disabled.
- JavaScript handles behavior, never rendering.
- Accessibility is part of the component contract, not an afterthought.

## v0.1 API Surface

Shell:
- `shadcn_page()`, `shadcn_header()`, `shadcn_sidebar()`, `shadcn_body()`

Navigation:
- `shadcn_nav()`, `shadcn_nav_item()`
- `shadcn_tabs()`, `shadcn_tab()` (wraps `shiny::tabsetPanel`)

Card composition:
- `shadcn_card()`, `shadcn_card_header()`, `shadcn_card_title()`,
  `shadcn_card_description()`, `shadcn_card_content()`,
  `shadcn_card_footer()`

Alert composition:
- `shadcn_alert()`, `shadcn_alert_title()`, `shadcn_alert_description()`

Content:
- `shadcn_value_box()`, `shadcn_badge()`, `shadcn_separator()`,
  `shadcn_skeleton()`, `shadcn_spinner()`, `shadcn_empty()`

Action:
- `shadcn_button()` with `data-icon` integration

Form layout (wraps Shiny inputs, does not replace them):
- `shadcn_field()`, `shadcn_field_group()`, `shadcn_field_label()`,
  `shadcn_field_description()`, `shadcn_field_set()`,
  `shadcn_field_legend()`, `shadcn_field_invalid()`
- `shadcn_input_group()`, `shadcn_input_group_addon()`

Theme:
- `shadcn_theme()`, `shadcn_dark_mode_toggle()`, `update_shadcn_theme()`

Icon:
- `shadcn_icon()` backed by a vendored Lucide sprite

Showcase:
- `run_showcase()` launches the dogfooded gallery app locally; the
  public showcase is exported with Shinylive as a static site

Internal utilities (not exported, but central to the API contract):
- `merge_classes()` — R equivalent of shadcn's `cn()`; deduplicates
  and joins package classes with user `class =`.
- `validate_children()` — fast-fails when a Group/Item composition
  contract is violated (e.g. `shadcn_nav_item` outside `shadcn_nav`).

## Out of Scope for v0.1

Stated explicitly to prevent scope creep: combobox, command palette,
calendar, date picker, data table, toast, dialog, sheet, drawer, popover,
tooltip, dropdown menu, form validation primitives, charts, drag-and-drop,
animations beyond CSS transitions, and any interop with bslib /
shinydashboard / bs4Dash.

These are v0.2+ candidates and several need their own ADRs first.

## Decision Summary

- **Approach:** htmltools R helpers + dev-time Tailwind v4 build +
  small ES modules. Compiled CSS is committed and shipped; users never
  run Node. Same precedent as `bslib` and `bs4Dash`.
- **Naming:** `shadcn_*` for exported functions; `ssc-` for CSS classes;
  Radix-style `data-state` attributes where useful.
- **Tokens:** vendor shadcn's oklch CSS custom properties verbatim into
  `inst/www/src/tokens.css`; surface them through Tailwind's `@theme`
  block.
- **Build:** `make build-css` (or `npm run build:css`) invokes
  `@tailwindcss/cli`. CI verifies the committed output matches.
- **CRAN CI:** GitHub Actions are part of the package from the first
  infrastructure phase. Routine CI runs cross-platform R CMD checks
  with latest verified workflow action majors; release CI runs the
  stricter CRAN-style gate, including manual/PDF checks.
- **Version verification:** before adding or changing any dependency,
  build tool, upstream token set, documentation reference, or compatibility
  assumption, check the current upstream version and record what was checked
  in the relevant ADR, roadmap entry, sync log, or phase-exit notes.
- **Dark mode:** inline `<head>` script sets
  `document.documentElement.dataset.theme` from `localStorage` (or
  `prefers-color-scheme` fallback) before stylesheets load. CSS
  selectors target `[data-theme="dark"]` at the `<html>` level, no
  flash of wrong theme. (Shiny's page template doesn't expose
  arbitrary `<html>` attributes server-side, so the JS approach is
  the standard pattern.)
- **Icons:** ~80-icon Lucide subset bundled as one SVG sprite.
- **Showcase deployment:** Shinylive static export from a clean
  staged app. The hosted showcase does not require a Shiny server and
  is published as generated `site/showcase/` output composed with the
  pkgdown site.
- **Tabs:** wrap `shiny::tabsetPanel()` rather than reimplement input
  binding. Decoration only — Bootstrap-flavored classes are
  retained because the input binding keys off them. Brings a
  transitive bslib runtime dependency (acceptable; bslib ships with
  modern Shiny).
- **Bootstrap:** coexists but is not styled; users mix at their own risk.
- **Composition:** components with internal regions expose every
  region as its own primitive (Card, Alert, Field). Flat-argument
  forms are sugar over the same primitives.
- **Validation:** Group/Item contracts are enforced at call time via
  `validate_children()`. Required accessibility arguments
  (e.g. `title`) error if omitted.
- **Class merging:** every component accepts `class = NULL`; package
  classes are appended via `merge_classes()`, never overwritten.
- **Icons:** integrated via `data-icon` attributes; CSS handles
  sizing per component. Icon helpers never emit `size-*` classes.

## Milestones

1. ADRs 0006–0011 written, formalizing the open decisions.
2. Asset dependency and static shell.
3. CSS build pipeline wired up (`Makefile`, `package.json`, CI drift
   check).
4. Package infrastructure, CRAN-readiness GitHub Actions, pkgdown,
   Shinylive showcase export, and CI.
5. Tokens, base styles, icons.
6. Core static components (button, badge, alert, card, value box).
7. Navigation and sidebar behavior.
8. Tabs wrapper and theme runtime.
9. Example app and vignettes.
10. R CMD check clean. Tag v0.1.0.

## Quality Gate (Every Phase)

Every phase passes a single ordered ritual before the next begins —
runnable as `make gate`. The full checklist lives in
[`docs/ROADMAP.md`](docs/ROADMAP.md#quality-gate-every-phase). At a
glance:

1. **Verify (automated):** build CSS (no drift), lint, spell check,
   URL check, latest-version verification, tests, document,
   cross-platform R CMD check, release-gate `R CMD check --as-cran`,
   pkgdown.
2. **Verify (semi-automated):** `shinytest2` local showcase smoke
   with screenshots, Shinylive export/browser smoke, performance
   budget, manual a11y sweep.
3. **Review:** roxygen audit, utility audit, critical code review.
4. **Document:** NEWS.md, ROADMAP/strategy/ADR/sync-log updates,
   cross-link check across `docs/`.
5. **Version + tag:** bump `DESCRIPTION` dev counter
   (`0.0.0.9000 → 9001 → ...`), single commit, `git tag phase-N`,
   CI green.

## Versioning Policy

- Pre-release: `0.0.0.9000` → `0.0.0.9001` per phase exit, mirroring
  tidyverse convention.
- v0.1 release at end of Phase 7: bump to `0.1.0`.
- Patch releases bump the third digit; minor releases bump the
  second; major releases bump the first. Breaking-change rules are
  defined in the Release Policy section of the strategy doc.
- Every version bump pairs with a NEWS.md heading; entries are
  written for users, not committers.

## Documentation and Showcase

Four artifacts grow continuously alongside the code, not at the end:

- **pkgdown site** modeled on
  <https://shiny.posit.co/r/components/>: category-grouped reference
  with a live example on every page, plus articles for getting
  started, theming, components, coexistence, accessibility, and
  troubleshooting.
- **Showcase app** under `inst/showcase/`, launchable via
  `shinyshadcn::run_showcase()`. Built with shinyshadcn itself
  (dogfooding). Each component has a gallery card with a live render
  and the source code beside it. Light/dark toggle in the header.
  The hosted version is exported with Shinylive from a clean staging
  directory to `site/showcase/`, then served by the same static site
  deployment as pkgdown. Until `shinyshadcn` has a webR/WASM binary,
  the staged app copies the needed package R helpers and assets
  rather than calling `library(shinyshadcn)`.
- **`docs/troubleshooting.md`** — user-facing common-problem catalog.
  Updated whenever a recurring user issue is fixed.
- **`docs/dev-notes/`** — internal postmortems. Updated whenever a
  non-obvious problem is hit during development.

## Definition of Done for v0.1

- Quality Gate passes for every phase.
- GitHub Actions include a routine cross-platform R CMD check workflow
  and a strict manual CRAN release workflow using latest verified
  action majors.
- Every exported function has roxygen docs (with `@examples` and
  `@family`) and at least one unit test.
- `devtools::check()` is clean.
- pkgdown site deployed; every v0.1 component has a reference page.
- Showcase app deployed as a Shinylive static app and runnable
  locally via `run_showcase()`. Public docs warn that first visit can
  take 1-2 minutes while webR assets download and cache.
- A minimal starter app under `inst/templates/starter/` (separate
  from the showcase).
- `getting-started`, `theming`, `components`, `coexistence`, and
  `accessibility` vignettes ship.
- `docs/upstream/shadcn-sync.md` records the shadcn commit the v0.1
  tokens were copied from.
