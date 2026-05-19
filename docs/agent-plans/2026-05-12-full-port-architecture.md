# Full shadcn Port Implementation Plan

Status: implementation-ready runtime plan adopted by ADR 0017 on 2026-05-12.

## Goal

Rewrite `shinyblocks` from a native Shiny/CSS translation of shadcn into an
R-facing adapter over a shipped shadcn/Radix runtime.

The R package remains the public authoring surface. The component
implementation, variants, state attributes, theming hooks, customization model,
and interactive behavior should come from upstream-compatible shadcn component
source, not package-owned `.sb-*` visual classes.

End users still install an R package. End users do **not** run Node, Tailwind,
Vite, or React build tooling.

## Implementation Decisions

These decisions make the plan executable. Re-open them only if the Phase 1 spike
proves one wrong.

1. **Full runtime, not hybrid.** All shadcn components move to a runtime-backed
   implementation. Native `.sb-*` visual classes are migration scaffolding only.
2. **Keep the R API names.** Rewrite `block_button()`, `block_badge()`,
   `block_select()`, etc. in place while preserving user-facing function names.
   Do not add parallel public names such as `block_select_runtime()`.
3. **Use a thin custom runtime adapter first.** The initial frontend runtime uses
   React + ReactDOM `createRoot()` plus a small Shiny input/message bridge. Do
   not introduce `reactR` or `shiny.react` unless the spike shows the custom
   bridge is worse.
4. **Frontend source is the visual source of truth.** R validates arguments,
   serializes props/slots, attaches dependencies, and defines Shiny updaters. R
   does not maintain visual variant class maps.
5. **Runtime bundle ships locally.** The package ships compiled CSS/JS under
   `inst/www/`. There is no CDN and no runtime package download.
6. **Theme customization is token-first.** `block_theme()` remains the R
   entrypoint, but it changes CSS custom properties consumed by the runtime
   components. Theme packs and presets must not fork component CSS.
7. **Obsolete code is removed immediately.** Every migration slice has a cleanup
   gate. The slice is not done while old R implementations, CSS rules, showcase
   examples, tests, parity baselines, or docs still assert the native contract.

## Target Architecture

### R package surface

Public helpers remain ordinary R functions:

- `block_button()`
- `block_badge()`
- `block_alert()`
- `block_card()`
- `block_select()`
- `block_dialog()`
- `block_popover()`
- `block_command()`
- `update_block_select()`
- other `update_block_*()` helpers only where Shiny value/open state requires
  them.

Each runtime-backed helper emits:

- a deterministic mount node;
- a component name;
- a versioned JSON payload with props, slots, children, and Shiny binding
  metadata;
- the shared `shinyblocks` html dependency.

### Frontend runtime

New tree:

```text
frontend/
  package.json
  vite.config.*
  src/
    index.*
    runtime/
      mount.*
      shiny-bridge.*
      payload-schema.*
      portal-root.*
    components/
      button.*
      badge.*
      select.*
      ...
    styles/
      globals.css
```

Compiled output:

```text
inst/www/
  shinyblocks-runtime.js
  shinyblocks-runtime.css
  shinyblocks.css          # temporary compatibility CSS, shrinks over time
  shinyblocks.js           # temporary compatibility JS, shrinks over time
```

The final state should have either:

- one dependency that loads runtime CSS/JS plus only non-visual compatibility
  helpers; or
- a renamed single asset pair after compatibility code is removed.

## CSS and Bundling Contract

The runtime rewrite must not turn shinyblocks into a global Tailwind stylesheet
that accidentally restyles the host Shiny app. CSS isolation and bundle size are
part of the architecture, not post-release optimization.

### CSS isolation rules

1. **No global Tailwind preflight.** Do not ship Tailwind's global reset into the
   host page. Shiny apps often include Bootstrap, bslib, htmlwidgets, DT, plotly,
   and user CSS. A global reset will create hard-to-debug regressions.
2. **Scope runtime CSS.** Runtime utility and component CSS must be scoped under
   a package-owned root such as `[data-shinyblocks-root]` and a matching portal
   root such as `[data-shinyblocks-portal-root]`.
3. **Portal content stays in scope.** Radix/shadcn portals must render into the
   shinyblocks portal root, not `document.body` by default, so popovers, menus,
   dialogs, sheets, and tooltips keep the same token and CSS scope.
4. **Tokens are scoped first, global only by opt-in.** Default tokens live on the
   shinyblocks root. `block_theme(scope = "page")` may set page-scoped tokens;
   global `:root` token writes require an explicit API and documentation.
5. **Package shell hooks may remain `.sb-*`; component styling may not.**
   `.sb-app`, `.sb-page`, and similar shell hooks are allowed for Shiny layout.
   Runtime component visuals come from shadcn component source and scoped runtime
   CSS.
6. **Avoid `!important`.** Use scoped selectors, layer order, and component
   source ownership instead. `!important` requires a documented exception.
7. **Do not style host Shiny widgets accidentally.** Runtime CSS selectors must
   not target generic Shiny/Bootstrap classes such as `.form-group`, `.control-label`,
   `.btn`, `.nav-link`, `.tab-pane`, `.selectize-*`, `.irs-*`, `.dataTables_*`, or
   htmlwidget containers.

### Tailwind build strategy

The frontend build should compile only the utilities used by the runtime source.

- The CSS input for the runtime lives under `frontend/src/styles/`.
- Tailwind scans only `frontend/src/**/*` and any explicitly listed runtime
  registry/generated files.
- Do not scan `R/`, `docs/`, `site/`, `inst/showcase/`, or arbitrary user
  examples for runtime CSS. That turns docs/examples into accidental production
  CSS dependencies.
- Safelists are allowed only when generated from a typed component registry and
  checked into source. Hand-written broad safelists are a bundle-size bug.
- Upstream shadcn class strings must stay mechanically traceable. If scoping or
  prefixing requires transforming class names, preserve the upstream source or
  sync diff separately from the transformed runtime source.

Preferred first implementation:

- keep shadcn component class strings in the frontend source;
- compile a runtime-only Tailwind CSS file from frontend source;
- post-process the generated CSS so selectors are scoped under
  `[data-shinyblocks-root]` and `[data-shinyblocks-portal-root]`;
- do not include Tailwind preflight;
- document any class-prefix or selector-scope transform in ADR 0017.

If selector scoping proves too leaky, the next option is a prefixed Tailwind
build with an automated class-name transform. Do not hand-prefix upstream
classes; that makes shadcn updates unmaintainable.

### Shiny asset packaging

Use `htmltools::htmlDependency()` with package-local assets only.

Rules:

- No CDN.
- No runtime network fetches for JS, CSS, fonts, or icons.
- Prefer a single IIFE/UMD-style runtime bundle at first because it works with
  ordinary Shiny/htmltools script tags without module attributes or import maps.
- Avoid dynamic imports and code-splitting until there is a tested
  `htmlDependency()` strategy for loading chunk files from `inst/www/`.
- If chunks are introduced later, every chunk must be deterministic, copied to
  `inst/www/`, included in package build checks, and tested from an installed
  package, not only from the source tree.
- `shinyblocks_dependency()` must be a function, not a top-level dependency
  object, so package asset paths resolve correctly after installation.

### Bundle-size policy

The existing `15 KB raw` JS budget is incompatible with a React/Radix runtime,
but the replacement budget still needs teeth.

Track at least:

- runtime JS raw size;
- runtime JS gzip size;
- runtime CSS raw size;
- runtime CSS gzip size;
- compatibility CSS/JS size while old assets remain;
- icon asset size;
- per-component size deltas during migration.

Initial budgets should be set in ADR 0017 after the Phase 1 foundation and Phase
2 Button/Badge/Select spike produce real numbers. Until then, every slice must
print a size report and explain increases.

Size-control rules:

- import only the Radix packages actually used by migrated components;
- import icons individually or keep the existing sprite strategy until a runtime
  icon plan proves smaller;
- do not bundle the parity app or dev-only shadcn reference code into
  `inst/www/`;
- keep source maps out of CRAN-shipped assets unless a release ADR allows them;
- fail CI if generated assets are missing, unexpectedly changed, or over the
  current budget.

### CSS maintenance rules

- Token definitions are the stable customization API.
- Component-specific CSS overrides are allowed only as temporary migration
  compatibility and must have a deletion phase.
- Theme presets modify token values, not component selectors.
- Any scoped CSS transform must be covered by a fixture test that proves:
  - Bootstrap `.btn`, `.nav-link`, and `.form-control` outside shinyblocks are
    unchanged;
  - htmlwidget/DT/plotly containers inside shinyblocks are not reset;
  - runtime portals receive the same tokens as inline runtime components.

### Runtime payload contract

Every runtime mount payload must include:

- `schemaVersion`;
- `component`;
- `id` when the component participates in Shiny input state;
- `props`;
- `slots`;
- `children`;
- `state`, for controlled values and open state;
- `binding`, for Shiny input/update behavior;
- `className`, passed through to the upstream component extension point where
  safe.

Do not serialize arbitrary executable JavaScript from R. Any dynamic behavior
must be represented as explicit props, slots, Shiny messages, or documented
runtime events.

## Reactive State Contract

Stateful components must behave like Shiny inputs first and React components
second. The runtime may use React internally, but users should be able to reason
about state with ordinary Shiny rules.

### State ownership

Every stateful prop must be classified in the component spec:

- **Input value state.** User-originated value changes are sent to Shiny and
  appear at `input$<id>`. Examples: select value, checkbox checked state, slider
  value, tabs selected value.
- **Server-controlled state.** Server updates may change the client state through
  `update_block_*()`. Examples: selected value, choices/items, disabled, invalid,
  open state when explicitly supported.
- **Client-only interaction state.** Internal UI state is not exposed to Shiny
  unless the component API opts in. Examples: transient hover/focus state,
  combobox search text unless explicitly exposed, menu highlight index.

Open state is opt-in. Dialogs, sheets, popovers, and menus should not create
noisy reactive dependencies by default. Expose `input$<id>_open` or equivalent
only when the R API explicitly says open state is observable.

### Input value semantics

For input-like components:

- initialize the Shiny value once the component mounts;
- send user-originated changes with event priority so server observers see them
  promptly;
- do not echo server-originated updates back as new user changes unless the
  updater explicitly requests notification;
- use `NULL` for no selected value in R;
- do not use empty string as a hidden sentinel unless the component spec
  documents it for backward compatibility;
- preserve value type: scalar, vector, logical, numeric range, date, etc.;
- include a component-level rule for what happens when choices/items change and
  the current value is no longer valid.

Recommended invalid-choice rule for `block_select()`:

- if `selected` is supplied in `update_block_select()`, use it after validating
  it against the new choices;
- if choices change and the current value still exists, preserve it;
- if choices change and the current value no longer exists, clear to `NULL`
  unless `selected` is explicitly supplied;
- clearing to `NULL` updates the visible UI and Shiny input value.

### Updater semantics

Every updater must use this shape unless a component-specific reason is recorded:

```r
update_block_<component> <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  ...,
  notify = FALSE
) {
  # validate session, namespace id, send explicit message
}
```

Rules:

- `session` defaults to `shiny::getDefaultReactiveDomain()`.
- `input_id` is always namespaced with `session$ns(input_id)` before sending the
  browser message.
- Omitted arguments mean "leave unchanged".
- Explicit `NULL` means "clear" only for arguments documented as clearable.
- `notify = FALSE` means server-originated updates should not fire as fresh
  user-originated input events.
- `notify = TRUE` is allowed only when the component spec says the echo is useful
  and safe.
- Update messages include a monotonically increasing revision or message id so
  stale updates can be ignored.

### Conflict and race handling

The runtime must guard against common Shiny races:

- user changes value while the server is updating choices;
- server disables a component while a menu/dialog is open;
- server removes a selected value from the choices;
- server sends an update after the component was removed;
- component is inserted, removed, then inserted again with the same id.

Each runtime input keeps a local revision counter. Server messages carry a
revision. The component applies only messages that are newer than the last
applied server revision. User-originated changes update Shiny immediately and do
not wait for server acknowledgement.

### Disabled state

Disabled state is server-updateable and must be consistent:

- user interaction is blocked;
- keyboard interaction is blocked;
- ARIA/native disabled attributes are set according to the upstream component
  contract;
- current value is preserved unless a separate value update changes it;
- disabled components can still receive server updates;
- if a component is disabled while open, close it unless upstream behavior
  explicitly keeps it open safely.

### Dynamic UI lifecycle

The runtime must support Shiny's dynamic UI model:

- mount components added by initial UI, `renderUI()`, and `insertUI()`;
- unmount React roots before Shiny removes DOM via `removeUI()` or output
  re-rendering;
- call Shiny unbinding/binding hooks around DOM that contains Shiny outputs or
  inputs;
- ignore in-flight update messages for unmounted roots;
- allow a component id to be reused after removal without leaking old state.

Implementation may use a Shiny input binding, a binding-compatible adapter, a
`MutationObserver`, or a combination. The chosen mechanism must be documented in
ADR 0017 and tested in Phase 1.

### Shiny children inside runtime components

Runtime components must support Shiny-owned children such as:

- `plotOutput()`;
- `uiOutput()`;
- `textOutput()`;
- `tableOutput()`;
- DT/plotly/htmlwidget outputs;
- nested Shiny inputs.

If React renders or moves a subtree containing Shiny bindings, the runtime must
call the appropriate Shiny unbind/bind lifecycle or avoid moving that DOM after
Shiny binds it. This must be proven before migrating containers such as Card,
Tabs, Dialog, Popover, Sheet, and Drawer.

## Mandatory Cleanup Gate

This gate runs after every implementation slice.

1. **R cleanup.** Remove or rewrite replaced native implementations. No migrated
   component should still call Shiny's old wrapper path, Selectize, ionRangeSlider,
   Bootstrap tab decoration, or local class-map helpers unless the slice explicitly
   keeps that compatibility.
2. **CSS cleanup.** Delete migrated component rules from
   `inst/www/src/shinyblocks.css`. Rebuild `inst/www/shinyblocks.css`. Keep only
   tokens, page shell rules, and non-visual compatibility selectors that are still
   required.
3. **JS cleanup.** Delete migrated behavior from `inst/www/shinyblocks.js` once
   the runtime owns it.
4. **Test cleanup.** Remove tests that assert `.sb-*` visual class strings,
   Selectize markup, Bootstrap tab markup, or old native implementation details.
   Replace them with payload, dependency, Shiny value, updater, and browser tests.
5. **Showcase update and cleanup.** Update the Shiny showcase in the same slice.
   Every migrated component must have its own showcase page/section before the
   slice is done. Remove old examples for migrated components and replace them
   with runtime-backed examples that mirror upstream shadcn docs.
6. **Spec/parity cleanup.** Update component specs from "native divergence from
   shadcn" to "R wrapper/runtime contract". Delete obsolete parity baselines when
   they only tested the old native CSS translation.
7. **Documentation cleanup.** Run `devtools::document()` after roxygen changes.
   Do not edit `man/` files by hand.
8. **Reference cleanup.** Update `_pkgdown.yml`, `NEWS.md`, roadmap, and any ADRs
   touched by the slice.
9. **Search audit.** Run targeted `rg` checks for deleted selectors, functions,
   and old implementation libraries. A slice cannot finish with unexpected hits.

Example search audit for the first spike:

```bash
rg -n "sb-button|sb-badge|sb-select|selectInput|selectize" R inst tests docs/component-specs inst/showcase
rg -n "sb-button|sb-badge|sb-select" inst/www/src inst/www
```

Expected remaining hits must be listed in the slice notes. Unlisted hits are
blockers.

## Mandatory Showcase Contract

The showcase app is part of the implementation, not a final documentation pass.
After every component migration, update `inst/showcase/` in the same commit.

Every component gets its own page or page-like section. If the current single-app
section router remains, each component must still have a unique route/section ID,
sidebar entry, title, lead, rendered examples, and visible source. If the
showcase is refactored into true pages later, this same content contract applies
per page.

Each component page must include, at minimum:

1. **Basic example.** The smallest normal usage.
2. **Variants.** Every supported `variant` option.
3. **Sizes/density.** Every supported `size`, density, orientation, or layout
   option.
4. **Slots/composition.** All supported slots and child helpers, such as title,
   description, trigger, content, item, group, footer, icon, prefix, suffix, or
   addon.
5. **State examples.** Disabled, invalid, loading, selected, open, checked,
   unchecked, empty, and error states where the component supports them.
6. **Customization examples.** All public customization options:
   - `class` / `className` pass-through;
   - theme token overrides via `block_theme()`;
   - dark mode;
   - icons;
   - labels and accessibility text;
   - width, alignment, orientation, or placement options;
   - component-specific options.
7. **Reactive examples for stateful components.** Inputs and overlay components
   must show:
   - how to read the current value/open state from `input$...`;
   - how to update value/state from the server with `update_block_*()`;
   - how to update choices/items/options from the server where supported;
   - how to enable/disable from the server where supported;
   - how invalid/error state is set and cleared;
   - how the component behaves inside a Shiny module if namespacing matters.
8. **Visible source.** The app must display source for each example group, not
   only one combined file if that hides the reactive server pattern.

The showcase tests must evolve with this contract:

- every exported `block_*()` appears on its own component page/section unless it
  is intentionally internal to another component page;
- every component page contains a basic example;
- every component page lists all documented variants/options;
- every reactive component page contains at least one server/update example;
- obsolete examples for the old native implementation are removed immediately.

## Phase 0 - Adopt the Pivot

Goal: make the architecture decision explicit before code starts.

Files:

- `docs/decisions/0017-full-runtime-port.md`
- `PLAN.md`
- `docs/ROADMAP.md`
- `DESCRIPTION`
- `NEWS.md`
- this plan

Tasks:

1. Write ADR 0017.
2. Supersede or amend:
   - ADR 0006 where it says utilities never appear in rendered markup;
   - ADR 0014 where it says form inputs wrap by default;
   - current roadmap language that describes a curated native port.
3. Replace the current JS budget with a React/Radix-aware budget. Record both
   raw and gzip sizes. Do not pretend the existing `15 KB raw` budget still
   applies.
4. Define the CSS isolation policy in ADR 0017:
   - no global Tailwind preflight;
   - scoped runtime CSS;
   - scoped portal root;
   - no broad safelists;
   - no CDN/runtime fetches.
5. Update `DESCRIPTION` from "End users do not need Node, Tailwind, or React" to
   language that distinguishes build tooling from shipped runtime assets.
6. Update `PLAN.md` and `docs/ROADMAP.md` so future agents do not continue the
   native parity path by accident.

Tests/checks:

- `Rscript -e "devtools::test(filter = 'doc-coverage|dependencies')"`
- `Rscript -e "pkgdown::check_pkgdown()"`

Cleanup gate:

- Remove roadmap instructions that tell agents to add new wrapped form controls
  under ADR 0014.
- Remove or mark obsolete any plan language that treats `.sb-*` visual classes
  as the destination architecture.

Exit criteria:

- ADR 0017 is accepted.
- The roadmap says the next implementation task is the runtime foundation, not
  another native CSS parity pass.

## Phase 1 - Runtime Foundation

Goal: establish the frontend build, runtime mount protocol, and R serialization
helpers before migrating components.

Files to add:

- `frontend/package.json`
- `frontend/vite.config.*`
- `frontend/src/index.*`
- `frontend/src/runtime/mount.*`
- `frontend/src/runtime/shiny-bridge.*`
- `frontend/src/runtime/payload-schema.*`
- `frontend/src/runtime/portal-root.*`
- `frontend/src/runtime/revisions.*`
- `frontend/src/runtime/shiny-bindings.*`
- `frontend/src/styles/runtime.css`
- CSS scoping/post-processing config or script
- `R/runtime.R`
- `R/runtime-payload.R`
- `R/runtime-update.R`
- `tests/testthat/test-runtime-payload.R`
- `tests/testthat/test-runtime-update.R`
- showcase page/section metadata helpers, if the current `sections` list is not
  enough for per-component pages and grouped examples
- browser/runtime test files under `tools/` or `frontend/`

Files to edit:

- `package.json`
- `package-lock.json`
- `Makefile`
- `.Rbuildignore` if present or needed
- `R/deps.R`
- `tests/testthat/test-dependencies.R`
- `inst/showcase/app.R`
- `inst/showcase/R/section.R`
- `tests/testthat/test-showcase.R`
- `tools/budget.R`
- CSS collision fixture/test files under `tools/`, `frontend/`, or
  `tests/testthat/`

Tasks:

1. Add frontend build scripts:
   - `runtime-install`
   - `runtime-build`
   - `runtime-build-css`
   - `runtime-test`
   - `runtime-watch` if useful.
2. Add runtime assets to `inst/www/`.
3. Build runtime CSS with the CSS isolation rules:
   - no Tailwind preflight;
   - scan only `frontend/src/**/*` and explicit generated registry files;
   - scope generated selectors under `[data-shinyblocks-root]` and
     `[data-shinyblocks-portal-root]`;
   - keep tokens scoped to the shinyblocks root by default;
   - keep source maps out of shipped assets unless ADR 0017 explicitly allows
     them.
4. Build runtime JS as one deterministic package-local bundle for the first
   implementation.
5. Update `shinyblocks_dependency()` to attach the runtime assets.
6. Create a generic R mount helper, for example internal
   `runtime_component(component, props, slots, input_id = NULL, class = NULL)`.
7. Ensure every runtime mount node includes `[data-shinyblocks-root]`.
8. Ensure portal content renders under `[data-shinyblocks-portal-root]`.
9. Serialize payloads as JSON in a script tag or data attribute. Pick one and
   document it in ADR 0017.
10. Mount and unmount React roots deterministically.
11. Implement the Shiny input/update bridge:
   - initialize input values on mount;
   - send user-originated value changes to Shiny;
   - receive server update messages;
   - distinguish user-originated events from server-originated updates;
   - support `notify = FALSE` and `notify = TRUE`;
   - ignore stale messages using revision/message ids.
12. Add a generic R update helper used by all `update_block_*()` functions:
   - validate that `session` is available;
   - namespace ids with `session$ns(input_id)`;
   - encode omitted vs explicit `NULL` arguments correctly;
   - attach a revision/message id.
13. Add a portal root strategy for popovers/dialogs/select menus.
14. Add dynamic UI lifecycle support:
    - initial mount;
    - `renderUI()` remount;
    - `insertUI()`;
    - `removeUI()`;
    - id reuse after removal.
15. Add Shiny child binding support:
    - prove a runtime container can hold `plotOutput()`, `uiOutput()`, and a
      nested Shiny input without breaking Shiny bindings.
16. Prepare the showcase structure for the full component-page contract:
   - each component can have a dedicated page/section;
   - each page can contain multiple named example groups;
   - each group can show its own source;
   - reactive examples can include both UI and server source.

Tests/checks:

- R payload unit tests.
- R updater payload tests, including omitted vs explicit `NULL`.
- Dependency tests assert runtime CSS/JS are attached once.
- CSS collision tests:
  - Bootstrap `.btn`, `.nav-link`, and `.form-control` outside shinyblocks are
    unchanged;
  - a page with bslib/Bootstrap still renders expected base styles;
  - runtime portals receive scoped tokens;
  - DT/plotly/htmlwidget containers inside shinyblocks are not reset by runtime
    CSS.
- Bundle tests:
  - runtime CSS and JS are built into `inst/www/`;
  - no source maps are shipped unless allowed;
  - no parity/dev-only frontend files are copied into `inst/www/`;
  - budget report includes runtime JS/CSS raw and gzip sizes.
- Showcase tests assert the page/section metadata required by the new contract.
- Browser smoke:
  - one dummy runtime input mounts and initializes `input$...`;
  - user change reaches Shiny;
  - server update changes the browser state;
  - `notify = FALSE` does not echo as a user event;
  - `notify = TRUE` echoes only when explicitly requested;
  - stale update messages are ignored;
  - disabled state blocks interaction but still accepts server updates;
  - dynamic insert/remove unmounts cleanly;
  - id reuse after removal starts from fresh state;
  - Shiny children inside a runtime container remain bound.
- Module smoke: a dummy runtime input works inside `moduleServer()`.
- `make runtime-build`
- `Rscript -e "devtools::test(filter = 'runtime|dependencies|showcase')"`
- `Rscript -e "devtools::document()"`

Cleanup gate:

- Remove any temporary proof-of-concept scripts that are not part of the runtime
  foundation.
- Remove duplicated dependency attachment code if the runtime dependency replaces
  old CSS/JS attachment paths.
- Search audit:

```bash
rg -n "runtime_component|shinyblocks-runtime" R tests inst/www frontend
rg -n "TODO|FIXME|proof|poc" R inst/www frontend tests tools inst/showcase
```

Exit criteria:

- A no-op runtime component can mount and unmount in a Shiny page.
- A dummy runtime input proves value sync, server update, disabled state,
  revision handling, modules, and dynamic UI lifecycle.
- A dummy runtime container proves Shiny outputs and nested inputs can live
  inside runtime-rendered children.
- Runtime CSS is scoped and does not alter host Bootstrap/Shiny/htmlwidget
  fixtures.
- Runtime JS/CSS sizes are reported, with provisional budgets recorded in ADR
  0017 or a Phase 1 note.
- Runtime assets build from `frontend/` and are shipped from `inst/www/`.
- No migrated user-facing component yet depends on incomplete runtime behavior.

## Phase 2 - Vertical Spike: Button, Badge, Select

Goal: prove primitives, variants, class customization, icons, theming, portals,
Shiny value sync, updater sync, and cleanup through one runtime path.

Components:

1. `block_button()`
2. `block_badge()`
3. `block_select()`

Frontend files:

- `frontend/src/components/button.*`
- `frontend/src/components/badge.*`
- `frontend/src/components/select.*`
- runtime registry/exports
- frontend/browser tests for button, badge, and select

R files:

- `R/components.R`
- `R/select.R`
- `R/runtime-payload.R`
- `R/icon.R` if icon payload format changes
- `R/field.R` if validation/description wiring changes

Showcase/spec/test files:

- `inst/showcase/R/examples/button.R`
- `inst/showcase/R/examples/badge.R`
- `inst/showcase/R/examples/field.R` or new select example file
- component page/section entries in `inst/showcase/app.R`
- `tests/testthat/test-runtime-payload.R`
- `tests/testthat/test-shell.R` or split into component-specific tests
- `tests/testthat/test-showcase.R`
- `docs/component-specs/button.md`
- `docs/component-specs/badge.md`
- `docs/component-specs/select.md`
- `_pkgdown.yml`
- `NEWS.md`

Tasks:

1. Implement runtime Button from upstream-compatible shadcn source.
2. Rewrite `block_button()` to emit a runtime payload:
   - `label`;
   - `variant`;
   - `size`;
   - `disabled`;
   - icon slot metadata;
   - pass-through `className`.
3. Implement runtime Badge.
4. Rewrite `block_badge()` to emit a runtime payload:
   - `label`;
   - `variant`;
   - pass-through `className`.
5. Implement runtime Select.
6. Rewrite `block_select()` in place:
   - no `shiny::selectInput()`;
   - no Selectize dependency;
   - value appears in `input$<id>`;
   - `NULL` represents no selected value;
   - choices updates preserve the current value if still valid;
   - choices updates clear to `NULL` if the current value is no longer valid and
     no explicit `selected` is supplied;
   - server updater can change value, choices, disabled state, invalid state, and
     placeholder;
   - server-originated updates do not echo to Shiny unless `notify = TRUE`;
   - keyboard behavior and open-state behavior come from Radix/shadcn runtime.
7. Add `update_block_select()`.
8. Ensure `block_field_invalid()` can decorate runtime controls through payload
   props instead of DOM mutation assumptions.
9. Update showcase examples to use upstream shadcn docs structure.
10. Give Button, Badge, and Select their own showcase pages/sections.
11. For Button and Badge pages, include:
    - basic example;
    - every variant;
    - every size where applicable;
    - icon/slot examples where applicable;
    - disabled/invalid/loading examples where supported;
    - `class` customization;
    - scoped `block_theme()` customization;
    - dark-mode visual check.
12. For Select, include:
    - basic example;
    - placeholder example;
    - disabled example;
    - invalid/error example;
    - grouped/item examples if supported;
    - value display from `input$...`;
    - server-side selected-value update;
    - server-side choices update;
    - server-side enable/disable update;
    - server-side invalid/error set and clear;
    - reset/clear-to-`NULL` example;
    - stale update/race behavior note if demonstrated in the app;
    - module namespacing example if supported in the spike.

Tests/checks:

- Button payload tests: variant, size, icon, disabled, className.
- Badge payload tests: variant and className.
- Select payload tests: choices, selected, placeholder, disabled, invalid.
- CSS/bundle tests:
  - Button/Badge/Select class strings are present in the runtime build input;
  - runtime CSS includes only classes used by migrated runtime components;
  - no broad safelist is added for variants;
  - size report shows the per-component JS/CSS delta for Button, Badge, and
    Select.
- `update_block_select()` tests:
  - namespaces ids through `session$ns()`;
  - preserves omitted values;
  - encodes explicit clear-to-`NULL`;
  - rejects invalid selected values when choices are provided;
  - supports `notify = FALSE` and `notify = TRUE`;
  - includes a revision/message id.
- Showcase tests:
  - Button, Badge, and Select each have their own page/section;
  - each page/section has a basic example;
  - all documented variants/options appear in the page metadata or example
    groups;
  - Select has reactive get/update/disable examples.
- Browser Select tests:
  - opens by click and keyboard;
  - arrow navigation works;
  - selection updates Shiny input value;
  - server update changes selected value;
  - server update changes choices;
  - choices update preserves valid current value;
  - choices update clears invalid current value to `NULL`;
  - server update with `notify = FALSE` does not echo as a user-originated event;
  - stale server update is ignored;
  - server disables select while open and the menu closes safely;
  - disabled select does not open;
  - invalid state sets ARIA/state attributes and can be cleared;
  - module namespacing works;
  - `insertUI()` and `removeUI()` do not leak roots;
  - unmount removes React root.
- Theme smoke: `block_theme()` changes Button, Badge, and Select tokens.
- `make runtime-build`
- targeted R tests.
- showcase manual review.

Cleanup gate:

- Delete Button/Badge visual rules from `inst/www/src/shinyblocks.css`.
- Delete Selectize-specific Select rules from `inst/www/src/shinyblocks.css`.
- Rebuild `inst/www/shinyblocks.css`.
- Delete or rewrite tests that assert:
  - `sb-button-*`;
  - `sb-badge-*`;
  - `sb-select-control`;
  - `shiny-input-select`;
  - Selectize dropdown markup.
- Delete old combined examples if they hide the per-component contract or omit
  customization/reactive state examples.
- Delete obsolete `docs/component-specs/_parity/button.json`,
  `badge.json`, and `select.json` if they only describe native CSS parity.
  Replace with runtime sync/browser coverage notes.
- Delete old select POCs once their assertions are covered:
  - `tools/parity/select-poc.mjs`, if fully superseded;
  - any select-only inspection script that only checks Selectize.
- Search audit:

```bash
rg -n "sb-button|sb-badge|sb-select|sb-select-control|selectInput|selectize" R inst/www/src inst/showcase tests docs/component-specs tools
```

Expected remaining hits:

- migration docs;
- non-visual mount/test hooks explicitly listed in the slice notes.

Exit criteria:

- Button, Badge, and Select are runtime-backed.
- No old visual CSS or tests remain for those three components.
- The runtime pattern is documented enough to migrate the next components.

## Phase 3 - Presentational Components

Goal: migrate low-risk visual components to the runtime and remove their native
CSS contracts.

Order:

1. `block_separator()`
2. `block_skeleton()`
3. `block_spinner()`
4. `block_alert()`, `block_alert_title()`, `block_alert_description()`
5. `block_card()` and card region helpers
6. `block_empty()`
7. `block_value_box()` if it remains part of the API

Per-component tasks:

1. Add the frontend component.
2. Rewrite the R helper to runtime payloads.
3. Update examples and specs.
4. Update the Shiny showcase page/section for that component:
   - basic example;
   - all variants/options;
   - all customization options;
   - all supported states;
   - visible source per example group.
5. Replace native class tests with payload/browser/showcase tests.
6. Remove obsolete CSS and parity baselines before moving to the next component.

Files commonly touched:

- `frontend/src/components/<component>.*`
- `R/components.R`
- component showcase file under `inst/showcase/R/examples/`
- component page/section metadata in `inst/showcase/app.R`
- `tests/testthat/test-runtime-payload.R` or component-specific test file
- `tests/testthat/test-showcase.R`
- `docs/component-specs/<component>.md`
- `inst/www/src/shinyblocks.css`
- `inst/www/shinyblocks.css`
- `tools/parity/registry.mjs`
- `docs/component-specs/_parity/<component>.json`
- `NEWS.md`

Tests/checks per component:

- R payload contract.
- Browser render smoke.
- Showcase page/section contract.
- Theme token smoke when the component consumes color/radius/border tokens.
- Showcase section renders.
- Manual visual review against upstream docs.

Cleanup gate per component:

```bash
rg -n "sb-<component>|sb-<component-part>" R inst/www/src inst/showcase tests docs/component-specs tools
```

Delete:

- old CSS selectors;
- old native class assertions;
- old component parity baseline when it checked translated CSS instead of
  runtime output;
- old screenshots if they no longer represent the shipped component.

Exit criteria:

- All presentational components render through the runtime.
- `inst/www/src/shinyblocks.css` no longer contains visual rules for migrated
  components.

## Phase 4 - Overlay and Menu Components

Goal: migrate components where Radix behavior matters most.

Order:

1. `block_dialog()`
2. `block_popover()`
3. `block_dropdown_menu()`
4. `block_sheet()`
5. `block_drawer()`
6. `block_tooltip()`
7. `block_hover_card()`

Tasks:

1. Add R APIs and docs for components that do not exist yet.
2. Use upstream composition rules: trigger, content, title, description, item,
   group, separator, etc.
3. Require accessible titles for dialog, sheet, and drawer. Allow visually hidden
   titles through an explicit argument.
4. Use the runtime portal strategy. Do not implement local positioning in
   `inst/www/shinyblocks.js`.
5. Add open-state Shiny bindings only where needed.
6. Add or update one showcase page/section per overlay/menu component. Each
   page must include:
   - basic open/close example;
   - trigger customization;
   - placement/alignment/side options where supported;
   - disabled trigger or disabled item states;
   - destructive/checked/selected item states where supported;
   - server-side open/close update where supported;
   - visible `input$...` open state where supported.

Tests/checks:

- R payload tests for composition and required title validation.
- Updater tests for open-state helpers where the component exposes open state.
- Showcase tests for basic, customization, state, and reactive/open-state
  examples.
- Browser tests for:
  - open/close;
  - Escape;
  - outside click;
  - focus return;
  - portal location;
  - Shiny open-state update where supported;
  - `notify = FALSE` open-state updates do not echo as user-originated events;
  - server closes an open overlay while focus is inside it;
  - removing an open overlay unmounts the portal and restores/clears focus safely.
- Accessibility smoke for roles and labels.

Cleanup gate:

- Remove any local JS behavior that duplicates migrated overlay/menu behavior.
- Remove obsolete CSS z-index, popper, focus-trap, or menu-positioning rules.
- Search audit:

```bash
rg -n "focus trap|popover|dialog|dropdown|sheet|drawer|tooltip|z-index|data-sb" inst/www R tests frontend
```

Exit criteria:

- Overlay behavior comes from the runtime, not local ad hoc JS.

## Phase 5 - Forms and Controls

Goal: remove the wrapped-Shiny-control strategy for shadcn controls.

Status as of 2026-05-18: checkbox, switch, textarea, input,
radio group, and slider render through the package runtime with Shiny
input bindings and updater helpers. The slider slice removed the
`shiny::sliderInput()` / ion.rangeSlider wrapper, added single/range
runtime value sync, pointer and keyboard interaction, invalid/style
state, and `update_block_slider()`. As of Phase 5.11,
`block_input_group()` and `block_input_group_addon()` are resolved as
R-side composition/layout primitives around runtime controls such as
`block_input()`, not standalone runtime bindings. The current remaining
Phase 5 work is deletion of residual wrapped-input CSS/tests and the
field-helper ownership decision. As of Phase 5.12, `block_tabs()` /
`block_tab()` emit package-owned R-side markup with a local Shiny value
bridge instead of wrapping `shiny::tabsetPanel()` or Bootstrap tab
internals.

Order:

1. `block_checkbox()`
2. `block_switch()`
3. `block_radio_group()`
4. `block_textarea()`
5. `block_slider()`
6. `block_input()`
7. `block_input_group()` and addons (R-side composition primitives)
8. `block_field_*()` helpers
9. `block_tabs()` and `block_tab()` (R-side package-owned markup)

Tasks:

1. Replace Shiny widget wrappers with runtime components.
2. Implement Shiny input bindings for controls with values.
3. Implement updater helpers where Shiny users expect server-side updates.
4. Make validation state payload-driven:
   - `data-invalid` on field-level components;
   - `aria-invalid` on controls;
   - error/description IDs wired by payload, not post-render DOM mutation.
5. Keep tabs independent of Bootstrap tabset assumptions; the local
   `shinyblocks.js` bridge owns selection, keyboard behavior, panel
   visibility, and Shiny value updates.
6. Add or update one showcase page/section per form/control component. Each
   input-like page must include:
   - a preview;
   - live `input$...` value display;
   - UI Definition and Server Action code blocks;
   - Content controls for every public constructor argument;
   - State controls for disabled/invalid/open/value-like state;
   - Actions (Server Update) buttons for every supported updater field;
   - Styling controls for `style` and `class`, applied to the owned control
     element rather than the whole playground block;
   - API Reference using the concise table pattern used by Input/Slider;
   - module namespacing example where the component owns an input id.

Tests/checks:

- Value round-trip tests for every input.
- Updater tests for every input with a server updater.
- Race tests for every input family:
  - user value change concurrent with server update;
  - disabled update while active/open/focused;
  - choices/items update that invalidates the current value;
  - stale update ignored after a newer value/update.
- Showcase tests for reactive get/update/disable examples on every stateful
  component.
- Browser keyboard tests for radio, checkbox, switch, slider, tabs.
- Module namespacing tests.
- Dynamic UI insert/remove tests.
- Shiny child-binding tests for containers that can hold Shiny outputs or nested
  inputs.

Cleanup gate:

- Delete wrapper calls to:
  - `shiny::selectInput()`;
  - `shiny::textAreaInput()`;
  - `shiny::checkboxInput()`;
  - `shiny::sliderInput()`;
  - `shiny::tabsetPanel()`.
- Delete Selectize, ionRangeSlider, Bootstrap tab, checkbox, switch, textarea,
  and field visual override CSS.
- Delete tests that assert Shiny-generated Bootstrap/Selectize/ionRangeSlider
  markup.
- Remove `bslib` dependency if it was only needed for tabs and runtime tabs no
  longer use Shiny tabsets.
- Search audit:

```bash
rg -n "selectInput|textAreaInput|checkboxInput|sliderInput|tabsetPanel|selectize|irs-|shiny-tab-input|nav-link|BootstrapTabInputBinding" R inst/www/src inst/www tests docs/component-specs inst/showcase
```

Exit criteria:

- Form controls use the runtime.
- Old wrapped-input CSS and tests are gone.

## Phase 6 - Layout, Navigation, Icons, and Theme

Goal: finish the package shell while keeping only package-specific layout glue
that has no upstream shadcn equivalent.

Components:

- `block_page()`
- `block_header()`
- `block_sidebar()`
- `block_nav()`
- `block_nav_item()`
- `block_icon()`
- `block_dark_mode_toggle()`
- `block_theme()`
- `update_block_theme()`

Tasks:

1. Decide which shell helpers remain R/htmltools-native because they are Shiny
   page infrastructure.
2. Move shadcn Sidebar/Nav behavior to runtime where practical.
3. Keep page/root classes only as shell hooks, not as component visual systems.
4. Decide whether icons remain sprite-based or move to the runtime icon library.
5. Ensure dark-mode and theme updates affect runtime components without local
   component CSS.
6. Add or update one showcase page/section for each shell/theme/icon component.
   Theme pages must show:
   - basic theme override;
   - full token override example;
   - dark mode;
   - server-side `update_block_theme()`;
   - how component pages react to scoped theme customization.

Tests/checks:

- Dependency tests.
- Theme update tests.
- Showcase tests for theme customization and server update examples.
- Browser tests for sidebar collapse/mobile behavior if still package-owned.
- Icon rendering tests for chosen icon strategy.
- Showcase smoke.

Cleanup gate:

- Remove old sidebar/nav JS if runtime owns the behavior.
- Remove old icon sprite code if runtime icons replace it.
- Remove obsolete icon manifest/tests if sprite icons are removed.
- Search audit:

```bash
rg -n "sb-sidebar|sb-nav|sb-icon|sprite.svg|data-sb-theme-toggle|sidebar" R inst/www/src inst/www tests tools docs/component-specs
```

Exit criteria:

- Remaining `.sb-*` selectors are shell hooks only and documented as such.
- No migrated component relies on package-owned visual CSS.

## Phase 7 - Parity, Specs, and Docs Reset

Goal: align verification and documentation with the runtime architecture.

Tasks:

1. Rewrite component specs around:
   - R API;
   - runtime component mapping;
   - props/slots;
   - Shiny value/update contract;
   - accessibility requirements;
   - deliberate divergences.
2. Convert the parity harness from "native CSS vs React reference" to:
   - upstream sync drift checks;
   - shipped runtime screenshot/browser checks;
   - token/theme regression checks.
3. Remove obsolete native parity baselines.
4. Update README, pkgdown reference, showcase, and vignettes.
5. Update `docs/upstream/sb-sync.md` with the pinned shadcn source/version.
6. Ensure the showcase app is complete:
   - one page/section per exported component or documented component family;
   - every page has basic, variants/options, customization, and state examples;
   - every reactive component has get value/open-state, server update,
     disable/enable, and reset/clear examples where supported;
   - visible source is present for UI and server examples.

Files:

- `docs/component-specs/*.md`
- `docs/component-specs/_parity/`
- `docs/component-specs/_screenshots/`
- `tools/parity/`
- `parity/`
- `README.md`
- `_pkgdown.yml`
- `NEWS.md`
- vignettes/gallery files when resumed

Tests/checks:

- `make runtime-build`
- `make build-css`
- `Rscript -e "devtools::test()"`
- `Rscript -e "devtools::document()"`
- `Rscript -e "pkgdown::build_site(preview = FALSE)"`
- runtime browser suite
- showcase contract tests
- updated budget check
- CSS collision fixture tests

Cleanup gate:

- Delete parity files that only exist to compare old native CSS with upstream
  React.
- Delete stale screenshots for removed native implementations.
- Delete docs that explain old Selectize/ionRangeSlider/Bootstrap divergences
  unless kept as historical notes in ADRs.
- Delete showcase examples that no longer match the runtime implementation or
  fail to document customization/reactive behavior.
- Search audit:

```bash
rg -n "Selectize|ionRangeSlider|Bootstrap tab|native CSS|wrap by default|\\.sb-.*visual|translated CSS" docs tools tests R inst
```

Exit criteria:

- Docs describe the shipped runtime architecture.
- Verification no longer rewards maintaining two implementations.

## Phase 8 - Final Package Gate

Goal: prove the rewrite is package-quality, not just visually convincing.

Required checks:

1. `make runtime-build`
2. `make build-css`
3. CSS collision fixture tests
4. budget report with runtime CSS/JS raw and gzip sizes
5. `Rscript -e "lintr::lint_package()"`
6. `Rscript -e "devtools::spell_check()"`
7. `Rscript -e "urlchecker::url_check()"`
8. `Rscript -e "devtools::test()"`
9. `Rscript -e "devtools::document()"`
10. `Rscript -e "devtools::check(remote = TRUE, manual = FALSE)"`
11. `Rscript -e "pkgdown::build_site(preview = FALSE)"`
12. runtime browser suite
13. showcase contract tests
14. showcase manual review of every component page
15. accessibility keyboard/screen-reader smoke
16. critical code review on the rewrite diff

Final cleanup audit:

```bash
rg -n "selectize|Selectize|ionRangeSlider|irs-|shiny-input-select|shiny-input-checkbox|shiny-tab-input|BootstrapTabInputBinding|sb-button-|sb-badge-|sb-select-control|sb-slider-control|sb-textarea-control" R inst tests docs tools
```

Any remaining hit must be either:

- a historical ADR note;
- an intentional shell/test hook documented in the final architecture;
- or removed before release.

## Slice Template

Use this template for every component slice.

~~~markdown
## Slice: <component>

Goal:

- <what this slice migrates>

Files to add:

- frontend/src/components/<component>.*
- tests/browser/<component>.*
- inst/showcase/R/examples/<component>.R, or the new page/example files if the
  showcase has been refactored

Files to edit:

- R/<file>.R
- inst/showcase/app.R
- inst/showcase/R/examples/<component>.R
- tests/testthat/<test-file>.R
- tests/testthat/test-showcase.R
- docs/component-specs/<component>.md
- NEWS.md

Files to delete or shrink:

- old CSS selectors in inst/www/src/shinyblocks.css
- old native tests
- old parity baseline/screenshot if superseded
- old local JS behavior if superseded

Tests:

- R payload test
- browser render test
- Shiny value/update test, if input-like
- updater namespace/`NULL`/`notify`/revision test, if stateful
- race and stale-message test, if stateful
- module namespacing test, if stateful
- dynamic UI insert/remove test, if runtime-mounted
- Shiny child-binding test, if the component accepts arbitrary children
- CSS scoping/collision test, if the component adds runtime classes or CSS
- bundle size delta report
- showcase page/section test
- theme smoke, if token-consuming
- showcase smoke

Cleanup audit:

```bash
rg -n "<old selectors/functions/libraries>" R inst tests docs tools
```

Done when:

- component renders through the runtime;
- component has its own showcase page/section;
- showcase has basic, all variants/options, all customization options, and all
  supported states;
- reactive components show get value/open-state, server update, disable/enable,
  and reset/clear examples where supported;
- stateful components define ownership, updater echo behavior, invalid-value
  behavior, disabled behavior, and stale-message behavior;
- runtime CSS remains scoped;
- bundle report records CSS/JS size delta;
- old native implementation is gone;
- old tests are gone or rewritten;
- old CSS is gone;
- docs/spec/showcase match the runtime;
- targeted tests and cleanup audit pass.
~~~

## Immediate Next Step

Start with Phase 0 and Phase 1 only. Do not migrate additional components until
the Button/Badge/Select vertical spike proves:

- payload serialization is stable;
- Shiny value sync works;
- updater messages work;
- portals work;
- dynamic UI cleanup works;
- theming works through tokens;
- obsolete native code can be removed cleanly at the end of a slice.
