---
name: shinyblocks-component
description: End-to-end recipe for adding or refactoring a `block_*()` component in the shinyblocks R package. Covers runtime-first component ports, R payload/update helpers, scoped runtime CSS, showcase playgrounds, tests, component specs, pkgdown/docs sync, and verification.
metadata:
  version: "2.0"
---

# Adding a shinyblocks component

A new exported `block_*()` is not a single-file change. Runtime-facing
components must land with the R API, frontend runtime, showcase,
tests, docs/spec, and NEWS/pkgdown sync that prove the component works
as shipped.

## Required reading

Read these before implementing:

1. `docs/decisions/0017-full-runtime-port.md` — current strategy. This
   supersedes the old native CSS and historical wrapper input path.
2. `docs/agent-plans/2026-05-12-full-port-architecture.md` — runtime
   payload, Shiny bridge, scoped CSS, and cleanup plan.
3. `docs/decisions/0015-component-specs.md` — every component has a
   spec doc and reference screenshot.
4. `docs/decisions/0016-visual-parity-harness.md` — parity and
   computed-style drift checks.
5. `docs/ROADMAP.md` — current slice, quality gate, and showcase
   authoring contract.
6. The canonical shadcn source:
   `https://raw.githubusercontent.com/shadcn-ui/ui/main/apps/v4/registry/new-york-v4/ui/<name>.tsx`.

## Step 0 - Decide ownership

Default to package-owned runtime components. Do not reintroduce
retired host-widget libraries, tab framework internals, or raw Shiny
widget wrappers for shadcn components unless a new ADR explicitly
approves the exception.

| Component kind | shinyblocks treatment | Examples |
| --- | --- | --- |
| Presentational/component UI | R emits a strict runtime payload; React renders under `[data-shinyblocks-root]`. | `block_button`, `block_card`, `block_alert` |
| Stateful input/control | R validates and serializes props/state; React renders the control; hidden native input plus a component-specific Shiny binding preserves `input$` semantics. | `block_select`, `block_slider`, `block_checkbox`, `block_input` |
| Overlay/menu | React runtime owns portal/focus/dismiss behavior through `[data-shinyblocks-portal-root]`; R controls payload and server updater. | `block_dialog`, `block_popover`, `block_tooltip` |
| R-side composition primitive | Build with `htmltools` and package classes when there is no standalone shadcn runtime behavior. | `block_field_*`, `block_input_group*`, `block_nav*` |

Historical ADRs may explain why wrappers existed. They are not current
implementation guidance.

## Step 1 - Implement the R API

Use the existing file boundaries:

| Component kind | File |
| --- | --- |
| Layout/page shell | `R/layout.R` or `R/page.R` |
| Content/action/overlay | `R/components.R` or the existing component file |
| Forms and controls | `R/form-controls.R`, `R/select.R`, or a focused component file |
| Composition primitive | `R/field.R`, `R/input-group.R`, `R/tabs.R`, or the matching shell file |

Required exported function shape:

```r
#' One-line title
#'
#' Short behavior description.
#'
#' @param ... Document every public argument.
#' @return An `htmltools` tag.
#' @family <category>
#' @export
block_<name> <- function(...) {
  # Validate at the R boundary.
  # Normalize values into a strict payload shape.
  # Use runtime_component() for runtime-rendered components.
  # Use attach_shinyblocks_deps() for R-side composition primitives.
}
```

For stateful runtime controls, also add `update_block_<name>()` using
the package runtime update helpers and Shiny `sendInputMessage()`
contract already used by neighboring controls.

## Step 2 - Runtime implementation

For runtime components, edit `frontend/src/index.jsx` and any focused
runtime helpers under `frontend/src/runtime/`:

- Keep payload parsing strict and boring. Normalize at the R boundary
  when practical.
- Keep React-owned DOM under `[data-shinyblocks-react]`; Shiny children
  stay under `[data-shinyblocks-children]`.
- For inputs, provide a hidden native input and a dedicated
  `shinyblocks.<component>` binding in `frontend/src/runtime/bindings.js`.
- For overlays, use the package portal root and implement focus return,
  Escape, outside-click/pointer-dismiss, and ARIA wiring.
- For pointer-heavy controls, add browser smoke coverage for the real
  interaction path, not just server updates.

## Step 3 - CSS

Runtime component styling belongs in `frontend/src/styles/runtime.css`
under `[data-shinyblocks-root]` or `[data-shinyblocks-portal-root]`.
Package shell CSS in `inst/www/src/shinyblocks.css` is for layout,
navigation, and explicitly owned R-side composition primitives only.

Rules:

- Use token variables such as `var(--primary)`, `var(--muted)`,
  `var(--ring)`, `var(--border)`, and `var(--destructive)`.
- Do not target host framework selectors in runtime CSS: no external UI
  framework, third-party widget, DT, plotly, htmlwidget, `body`, or
  `:root` selectors.
- Do not add legacy shell button, host widget, or tab-framework class
  dependencies.
- Rebuild committed assets after runtime/source CSS changes:
  `npm run build:runtime` for runtime CSS/JS and `make build-css` for
  shell CSS.

## Step 4 - Showcase sync

Every component section uses the full interactive playground contract:

- `inst/showcase/R/examples/<name>.R`
- `inst/showcase/R/server_<name>.R`
- source and registration in `inst/showcase/app.R`
- API table styling/custom preview classes in
  `inst/showcase/www/showcase.css`

The playground must include:

- Preview.
- `input$` value display where the component has Shiny state.
- UI Definition.
- Server Action panel when an updater exists.
- Content, State, Actions, and Styling controls covering every public
  constructor argument.
- API Reference table.

Use `showcase_action_button()` for native Shiny action buttons in
server-update demos; do not emit runtime button classes manually.

After runtime JS/CSS, showcase server wiring, or updater changes, fully
restart `make showcase` and verify `curl -sSI http://127.0.0.1:4321/`.
In Codex sessions, check for stale listeners with
`lsof -nP -iTCP:4321 -sTCP:LISTEN` before retrying outside the
sandbox.

## Step 5 - Docs/spec sync

The same slice must update:

- roxygen docs and `NAMESPACE` via `Rscript -e "devtools::document()"`
  when R docs change;
- `_pkgdown.yml` reference entry when the exported surface changes;
- `docs/component-specs/<slug>.md`;
- gallery files when adding a new exported component;
- `NEWS.md` for user-visible behavior.

Specs should state current runtime behavior, not old wrapper behavior.
If a component deliberately differs from shadcn, document the
divergence and why.

## Step 6 - Tests and verification

Add focused coverage proportional to risk:

- R tag/payload/validation tests in `tests/testthat/`.
- Runtime JS static tests when a binding/protocol changes.
- `tools/runtime-shiny-smoke.mjs` browser coverage for Shiny
  initialization, user interaction, server updates, disabled state,
  dynamic UI, and module namespacing where applicable.
- Parity registry updates when the component participates in the
  computed-style harness.

Useful targeted checks:

```bash
npm run build:runtime
make build-css
Rscript -e "devtools::test(filter = 'shell|runtime|showcase|doc-coverage')"
npm run test:runtime
npm run test:runtime-shiny
npm run test:showcase
make legacy-audit
```

Playwright and Shiny port-binding checks may need to run outside the
Codex command sandbox.

## Step 7 - Interactive Shinylive Playground Integration

Every component page in the documentation site (`docs-site`) features an **Interactive Shinylive Playground** rendered directly inside a clean `<iframe>` that matches the showcase app's behavior. 

Follow these conventions for rendering and deploying playgrounds:

### 1. Iframe Embed Pattern
The detail page `docs-site/app/components/[slug]/page.tsx` embeds the playground dynamically when `hasPlayground` is enabled in `preview-manifest.json`:
```tsx
<div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
  <iframe
    src={`/shinyblocks/playgrounds/${slug}/`}
    title={`${component.name} playground`}
    loading="lazy"
    className="w-full block bg-background"
    style={{ height: `${component.playgroundHeight ?? 720}px`, border: 0 }}
  />
</div>
```

### 2. Premium UI/UX for Embeds (scroll-free & unboxed)
To keep the embedded app looking native to the documentation site, follow these layout rules in `docs-site/playgrounds/<slug>/app.R`:
- **No nested borders**: Never use `block_field_set` or `block_field_legend` double boxes. The playground should blend seamlessly with the parent iframe card.
- **2-Column Responsive Layout**: Layout using standard flexboxes:
  - **Left Panel (`flex: 1.2; min-width: 320px;`)**: Displays the live **Preview Canvas** and code snippets directly stacked. Place the preview inside a dashed border (`border: 1px dashed var(--border)`) and subtle background canvas (`bg-muted/10` or similar).
  - **Right Panel (`flex: 1; min-width: 300px; max-width: 480px;`)**: Houses the configuration controls (Content, State, Styling, Actions) within a standard card background (`bg-card`).
- **Compact Densities**: Use `size = "sm"` on select dropdowns, checkboxes, and textareas inside the controls panel to fit within the `720px` height and prevent vertical scrollbars.
- **Scrollbar-free execution**: Set specific column dimensions and margins to eliminate horizontal scrollbars on desktop viewports.

### 3. Static WASM Asset Compilation & Mounting (webR Integration)
Because `shinyblocks` is not on the default webR repository (`repo.r-wasm.org`), the package must be precompiled for WebAssembly in CI and hosted alongside the playgrounds:
1. **CI pre-compilation**: A GitHub Action compiles the R package for WebAssembly, attaching `library.data.gz` and `library.js.metadata` filesystem images to release tags (e.g., `v0.0.0.9000`).
2. **Static Asset Hosting**: The build script `generate-playgrounds.R` runs `shinylive::export()` and **explicitly copies** `library.data.gz` and `library.js.metadata` into the static export folder `docs-site/public/playgrounds/<slug>/` where they are served statically by Next.js.
3. **Relative Worker Mounting in `app.R`**: Inside each playground's `app.R`, before loading `library(shinyblocks)`, we mount the packages relative to the **webR WebWorker script context** (`shinylive/webr/webr-worker.js`), which is two levels deep. Use the relative path `../../library.data.gz`:
   ```r
   if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
     dir.create("/packages", recursive = TRUE, showWarnings = FALSE)
     webr::mount("/packages", "../../library.data.gz")
     .libPaths(c("/packages", .libPaths()))
   }
   library(shiny)
   library(shinyblocks)
   ```
   *Warning*: Never use root-relative paths like `/wasm_binaries/...` or hardcoded URLs, as they will break when hosted under custom subpaths on GitHub Pages or during local Next.js development.

## Commit shape

One vertical commit per component or cleanup slice. Suggested message:

```text
feat: add runtime block_<name>()
fix: harden block_<name>() runtime interaction
chore: remove legacy <area> cleanup debt
```

The commit should explain the runtime/R/showcase/test/docs pieces in
the body when the diff is non-trivial.

## Pitfalls

- Drag and pointer interactions must keep updating after the pointer
  leaves a small visual target. Use pointer capture on the element that
  starts the drag and cover it in browser smoke tests.
- Runtime CSS must stay scoped. If a selector could affect host Shiny,
  bslib, external UI frameworks, third-party widgets, DT, plotly, or
  htmlwidgets, it belongs somewhere else.
- Do not keep old shell CSS alive for showcase-only controls. Move
  showcase-only styles into `inst/showcase/www/showcase.css`.
- R-side composition primitives are not a reason to add standalone
  runtime bindings.
