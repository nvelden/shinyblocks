# ADR 0017: Full Runtime shadcn Port

## Status

Accepted (2026-05-12)

## Context

`shinyblocks` began as a native Shiny/CSS translation of shadcn's
visual language. That path kept the package lightweight and avoided a
frontend runtime, but it also created a second component system:
package-owned `.sb-*` classes, Shiny wrapper markup, Selectize and
ion.rangeSlider overrides, Bootstrap tab assumptions, and a growing
parity harness to catch drift from upstream shadcn.

That architecture does not scale to a broad shadcn port with serious
theme customization. Every new variant, density option, theme preset,
overlay behavior, form state, and Radix interaction would need to be
translated and maintained twice: once upstream and once in shinyblocks.

The product direction is now a full component/runtime port. R remains
the public authoring surface, but shadcn/Radix-compatible frontend
source becomes the visual and behavioral source of truth.

## Decision

Adopt a shipped, package-local shadcn/Radix runtime.

- Public R helpers keep the `block_*()` API names.
- R helpers emit deterministic mount nodes and versioned runtime
  payloads with props, slots, children, and Shiny binding metadata.
- A maintainer-only frontend build compiles the runtime to assets under
  `inst/www/`.
- End users install an R package and do not run Node, Tailwind, Vite,
  or React build tooling.
- Runtime assets are attached with `htmltools::htmlDependency()`.
- No CDN or runtime network fetch is allowed.

The initial implementation uses a thin custom React/ReactDOM adapter
with a small Shiny input/message bridge. `reactR` or `shiny.react` may
be reconsidered only if the Phase 1 runtime foundation proves the
custom bridge is worse.

## Superseded Decisions

This ADR supersedes earlier decisions where they conflict:

- ADR 0006's rule that Tailwind utilities are never present in rendered
  markup. Runtime-rendered shadcn markup may use upstream class
  contracts, but generated CSS must be scoped to shinyblocks roots.
- ADR 0014's wrap-by-default rule for form inputs. Shiny wrappers are no
  longer the destination architecture for shadcn controls.
- ADR 0016's parity target for migrated components. As components move
  into the runtime, verification shifts from "native CSS versus React
  reference" to shipped runtime behavior, upstream sync drift, scoped
  CSS, theme, accessibility, and Shiny reactivity checks.

Historical native implementations remain valid only as migration
scaffolding until each component is rewritten.

## CSS and Asset Rules

The runtime must not ship a global Tailwind stylesheet.

- No global Tailwind preflight/reset.
- Runtime CSS is scoped under `[data-shinyblocks-root]`.
- Portal content renders under `[data-shinyblocks-portal-root]`, not
  `document.body` by default.
- Tokens are scoped by default. Global `:root` token writes require an
  explicit API.
- Runtime CSS must not target generic Shiny, Bootstrap, Selectize,
  ion.rangeSlider, DT, plotly, or htmlwidget selectors.
- Tailwind scans only frontend runtime source and explicit generated
  registry files.
- Broad handwritten safelists are not allowed.
- Source maps are not shipped unless a release ADR allows them.

The first runtime bundle should be a deterministic package-local
IIFE/UMD-style asset. Dynamic imports and code splitting are deferred
until chunk loading through `htmlDependency()` is tested from an
installed package.

### Phase 1 Runtime Budgets

The Phase 1 React/ReactDOM foundation establishes the first hard runtime
asset ceilings. These are intentionally wider than the measured baseline
so minor build-tool output changes do not fail CI, but narrow enough to
catch accidental dev bundles, source maps, duplicate React copies, or
global CSS regressions.

| Asset | Metric | Measured on 2026-05-12 | Phase 1 ceiling |
| --- | --- | ---: | ---: |
| `inst/www/shinyblocks-runtime.js` | raw | 191.3 KB | 225 KB |
| `inst/www/shinyblocks-runtime.js` | gzip | 59.9 KB | 75 KB |
| `inst/www/shinyblocks-runtime.css` | raw | 1.4 KB | 5 KB |
| `inst/www/shinyblocks-runtime.css` | gzip | 0.3 KB | 2 KB |

Phase 2 may raise these ceilings only with a recorded before/after size
delta for the migrated Button, Badge, and Select runtime components.

## Shiny Runtime Rules

Stateful runtime components must behave like Shiny inputs.

- User-originated value changes are sent to `input$<id>`.
- `update_block_*()` helpers namespace ids with `session$ns(input_id)`.
- Omitted updater arguments mean unchanged.
- Explicit `NULL` means clear only where the component documents a
  clearable value.
- Server-originated updates do not echo as user events unless
  `notify = TRUE`.
- Update messages carry revision/message ids so stale messages can be
  ignored.
- Disabled state blocks user and keyboard interaction, preserves the
  current value unless separately updated, and remains server-updateable.
- Dynamic UI insertion/removal must mount and unmount React roots
  cleanly.
- Components that accept arbitrary children must support Shiny outputs,
  htmlwidgets, and nested Shiny inputs without breaking Shiny binding
  lifecycles.

## Migration Plan

The detailed implementation plan lives in
[`docs/agent-plans/2026-05-12-full-port-architecture.md`](../agent-plans/2026-05-12-full-port-architecture.md).

Implementation proceeds in hard gates:

1. Runtime foundation: build pipeline, scoped CSS, dependency
   attachment, Shiny bridge, dynamic UI lifecycle, portals, and Shiny
   child binding fixtures.
2. Vertical spike: `block_button()`, `block_badge()`, and
   `block_select()` through the same runtime.
3. Component-family migrations with cleanup gates after each slice.

No component migration should start until the runtime foundation proves
scoped CSS, Shiny state sync, updater semantics, modules, dynamic UI,
portal scoping, and Shiny child binding.

## Consequences

**Positive:**

- One visual and behavioral source of truth.
- Theme presets and customization flow through upstream-shaped tokens,
  variants, and class extension points.
- Complex Radix behavior no longer needs to be reconstructed with
  ad hoc Shiny wrappers and CSS overrides.
- Component drift becomes an upstream sync problem instead of a manual
  visual re-port for every slice.

**Negative / accepted costs:**

- The shipped JavaScript runtime is meaningfully larger than the native
  CSS/JS approach.
- Maintainers now own a frontend build pipeline.
- R wrappers need an explicit payload, slot, input binding, updater, and
  lifecycle contract.
- CSS scoping and asset-size checks become release-critical.

## Verification

Each slice must update or add:

- R payload and updater tests;
- browser/Shiny runtime tests;
- CSS collision fixtures;
- bundle-size reporting;
- per-component showcase page/section;
- component specs;
- cleanup audits that remove obsolete native CSS, JS, tests, parity
  baselines, screenshots, and docs.
