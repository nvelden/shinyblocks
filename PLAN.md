# shinyblocks Plan

A Shiny dashboard package with the authoring ergonomics of `shinydashboard`
and a full shadcn/Radix component runtime behind an R-first API. End
users install from CRAN; they never run Node, Tailwind, Vite, or a
frontend build.

The original native-CSS strategy in
[`docs/agent-plans/2026-05-08-port-strategy.md`](docs/agent-plans/2026-05-08-port-strategy.md)
is superseded by [ADR 0017](docs/decisions/0017-full-runtime-port.md)
and the implementation plan in
[`docs/agent-plans/2026-05-12-full-port-architecture.md`](docs/agent-plans/2026-05-12-full-port-architecture.md).
This document is the short product brief — read ADR 0017 and the
runtime plan for implementation details.

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
- Developers who want shadcn-style components, themes, variants, and
  customization from R without maintaining a frontend app.

## Core Principles

- R-first API: public helpers return `htmltools::tag` objects or
  `htmltools` dependency-bearing mount nodes.
- **No Node, Tailwind, Vite, or frontend build at user install time.**
  Runtime CSS/JS assets are built by maintainers, committed under
  `inst/www/`, and shipped on CRAN.
- No CDN at runtime. All assets are local.
- shadcn/Radix-compatible frontend source is the component source of
  truth; R validates arguments, serializes props/slots, attaches assets,
  and defines Shiny update helpers.
- Theming is token-based (CSS custom properties) and override-friendly.
- Runtime CSS is scoped so shinyblocks does not restyle host Shiny,
  Bootstrap, bslib, DT, plotly, or htmlwidget UI accidentally.
- Stateful components follow Shiny input/update semantics, including
  module namespacing and dynamic UI cleanup.
- Accessibility is part of the component contract, not an afterthought.
- Every showcase component page uses the same full interactive playground
  contract: preview, `input$` value, UI Definition, Server Action,
  Content controls, State controls, Actions (Server Update), Styling
  controls (`style` + `class`), and API Reference. For each component,
  the playground controls must cover all supported public constructor
  arguments; when an `update_block_*()` helper exists, include Actions
  buttons that exercise that updater contract.
- Every exported component has a **gallery page** with an embedded
  Shinylive demo and visible source, modelled on
  <https://shiny.posit.co/r/components/>. See
  [ADR 0013](docs/decisions/0013-component-gallery-quarto.md) and the
  [Components Gallery](docs/ROADMAP.md#components-gallery) section of
  the roadmap.

For the full runtime architecture, cleanup gates, Shiny state bridge,
scoped Tailwind/CSS contract, and component migration order, see the
[full port implementation plan](docs/agent-plans/2026-05-12-full-port-architecture.md).

## Milestones

1. ADR 0017 adopted, superseding the native-CSS/wrap-by-default path
   where it conflicts.
2. Runtime foundation: frontend build, scoped CSS, Shiny bridge,
   updater protocol, dynamic UI lifecycle, portal root, and Shiny child
   binding fixtures.
3. Vertical spike: `block_button()`, `block_badge()`, and
   `block_select()` rendered through the runtime, with old native
   CSS/tests removed.
4. Presentational component migration with one showcase page/section per
   component.
5. Overlay/menu migration with Radix portal/focus behavior.
6. Forms and controls migration with Shiny value/update/disable
   examples.
7. Layout, navigation, icons, and theme runtime cleanup.
8. Parity/spec/docs reset around shipped runtime behavior and upstream
   sync drift.
9. R CMD check clean. Tag v0.1.0.

Phase details live in [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Local Preview Before Going Public

The Quality Gate now includes runtime browser verification, scoped-CSS
collision fixtures, Shiny state/update tests, bundle-size reporting,
and any still-relevant parity or upstream-sync checks. Until each
legacy native component is migrated, `make parity-ci` remains useful
for the existing shared registry; runtime-migrated components are
verified against the shipped runtime behavior instead.

As of 2026-05-19, the shared registry slice covers `alert`, `badge`,
`button`, `checkbox`, `select`, `separator`, `slider`, `switch`, and
`textarea`, and `make parity-ci` is green for that slice. Runtime
browser and Shiny smoke tests are now the primary verifier for
runtime-migrated controls. Phase 5 cleanup has also resolved input
group ownership as an R-side composition primitive and removed
Bootstrap/Shiny tabset dependencies from the rendered tabs contract.
Field helpers likewise remain R-side composition primitives, and the
legacy raw-input styling under `.sb-field` has been removed in favor of
runtime controls inside fields.
Remaining component families still need to be migrated before parity
becomes the repo-wide primary verifier.

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
- Breaking-change rules for the runtime port are governed by ADR 0017
  and the phase-exit notes until the release policy is rewritten for
  `0.1.0`.
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
- `docs/upstream/sb-sync.md` records the pinned shadcn/Radix source
  used by the runtime and any deliberate local patches.
