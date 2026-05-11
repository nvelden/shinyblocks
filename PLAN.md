# shinyblocks Plan

A Shiny dashboard package with the authoring ergonomics of `shinydashboard`
and the visual language of shadcn/ui. End users install from CRAN; they
never need Node, Tailwind, or React.

The canonical strategy, full API surface, component conventions, and
architectural decisions live in
[`docs/agent-plans/2026-05-08-port-strategy.md`](docs/agent-plans/2026-05-08-port-strategy.md).
This document is the short product brief — read the strategy doc for
implementation details.

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

- R-first API: every public function returns `htmltools::tag` objects.
- **No Node, no Tailwind, no React at user install time.** Compiled CSS
  is committed and shipped on CRAN (same model as `bslib` and `bs4Dash`).
- No CDN at runtime. All assets are local.
- shadcn/ui is treated as upstream design reference, not code to copy.
- Theming is token-based (CSS custom properties) and override-friendly.
- Components degrade to clean HTML/CSS when JavaScript is disabled.
- Accessibility is part of the component contract, not an afterthought.
- Every exported component has a **gallery page** with an embedded
  Shinylive demo and visible source, modelled on
  <https://shiny.posit.co/r/components/>. See
  [ADR 0013](docs/decisions/0013-component-gallery-quarto.md) and the
  [Components Gallery](docs/ROADMAP.md#components-gallery) section of
  the roadmap.

For the full v0.1 API surface, scope decisions, naming conventions,
component composition rules, and out-of-scope items, see the
[strategy doc §v0.1 Scope](docs/agent-plans/2026-05-08-port-strategy.md#v01-scope).

## Milestones

1. ADRs 0006–0012 written, formalizing the open decisions.
2. Asset dependency and static shell.
3. CSS build pipeline wired up (`Makefile`, `package.json`, CI drift
   check).
4. Package infrastructure, CRAN-readiness GitHub Actions, pkgdown,
   Shinylive showcase export, and CI.
5. Tokens, base styles, icons.
6. Core static components (button, badge, alert, card, value box).
7. Navigation and sidebar behavior.
8. Tabs wrapper and theme runtime.
9. **Local preview:** build pkgdown site and Shinylive showcase
   locally, review before making the repo public.
10. Example app and vignettes.
11. R CMD check clean. Tag v0.1.0.

Phase details live in [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Local Preview Before Going Public

The Quality Gate runs a `make parity-ci` checkpoint at every phase
exit — see [`docs/ROADMAP.md` §Local Preview Workflow](docs/ROADMAP.md#local-preview-workflow)
for the recurring flow and port assignments. Visual fidelity for
components already migrated into the shared registry is enforced
programmatically by the Playwright parity harness (`tools/parity/`);
the rest still rely on spec docs plus committed screenshots until
their registry entries land.

As of 2026-05-11, the shared registry slice covers `button`,
`checkbox`, `select`, `slider`, and `switch`. Remaining component
families still need to be migrated before parity becomes the
repo-wide primary verifier.

The list below is the final pre-public sweep on top of that:

1. **pkgdown site.** Run `pkgdown::build_site()` (or `make pkgdown`)
   and open `site/docs/index.html` in a browser. Walk through the
   reference index, every component page, and each article.
2. **Shinylive showcase.** Run `make shinylive-export` (or
   `tools/export-shinylive.R`) to produce the static export under
   `site/showcase/`. Serve it locally
   (`python3 -m http.server -d site/showcase`) and verify in a
   browser that the app loads, dark mode works, and every gallery
   section renders.
3. **Local showcase app.** Run `shinyblocks::run_showcase()` to
   launch the dogfooded gallery. Confirm every component section is
   present with both the live render and the source code.
4. **README & package metadata.** Review `README.md`, `DESCRIPTION`,
   and `NEWS.md` for anything that looks incomplete or references
   internal-only artifacts.

Only make the repo public once all four pass. This checkpoint is not
a formal phase exit; it does not require the full Quality Gate. It is
a final structural sanity check to ensure the first public impression is
polished.

## Quality Gate (Every Phase)

Every phase passes a single ordered ritual before the next begins —
runnable as `make gate`. The full checklist lives in
[`docs/ROADMAP.md`](docs/ROADMAP.md#quality-gate-every-phase).

## Versioning Policy

- Pre-release: `0.0.0.9000` → `0.0.0.9001` per phase exit, mirroring
  tidyverse convention.
- v0.1 release at end of Phase 7: bump to `0.1.0`.
- Breaking-change rules are defined in the
  [Release Policy](docs/agent-plans/2026-05-08-port-strategy.md#release-policy)
  section of the strategy doc.
- Every version bump pairs with a NEWS.md heading; entries are
  written for users, not committers.

## Definition of Done for v0.1

- Quality Gate passes for every phase.
- Every exported function has roxygen docs (with `@examples` and
  `@family`) and at least one unit test.
- `devtools::check()` is clean.
- Third-party widget compatibility verified: ggplot2 plots, DT tables,
  plotly charts, and rhandsontable outputs render correctly inside
  `block_card()` / `block_card_content()` without CSS collisions or
  layout breakage. Documented in `vignette("coexistence")`.
- pkgdown site deployed; every v0.1 component has a reference page.
- Showcase app deployed as a Shinylive static app and runnable
  locally via `run_showcase()`.
- Starter app under `inst/templates/starter/`.
- Vignettes: `getting-started`, `theming`, `components`,
  `coexistence`, `accessibility`.
- `docs/upstream/sb-sync.md` records the shadcn commit the v0.1
  tokens were copied from.
