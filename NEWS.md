# shinyblocks (development version)

## Internal

* Tidied the listener lifecycle in `inst/www/shinyblocks.js` (issue #29). The `window.shinyblocksTheme.apply` assignment moved out of `applyTheme()` (which reassigned it on every theme toggle) into a one-shot `exposeThemeApi()` called from `init()`. The global Escape + outside-click handlers that closed open mobile sidebars moved out of `wirePage()` (which attached fresh closures per page mount, stacking listeners on every dynamic re-render) into a `wireGlobalSidebarHandlers()` wired once behind a `shinyblocksSidebarGlobalWired` guard.
* Hardened the runtime input contract (issue #30): R-side `runtime_component()` now validates the component name against a `RUNTIME_COMPONENT_NAMES` allowlist so a typo errors immediately instead of silently producing a no-op mount, and every JS-side `getValue()` reads the DOM expando first and falls back to the payload's `state.value` via a shared `initialValue(el)` helper. The previous native-input fallback paths (`nativeCheckbox(el)?.checked`, etc.) are gone — the single-writer contract from #24 already guarantees the expando is set synchronously on mount.
* Removed the unused `runtime_update()` / `sb:update` custom-message channel and the React `applyUpdate` handler that consumed it (issue #23). All shipped components use the standard `update_block_*()` -> `sendInputMessage()` -> binding `receiveMessage` path; the parallel channel only existed to be exercised by the smoke-test fixture's synthetic `component = "fixture"`. The fixture's `runtime_update` observers and the corresponding smoke assertions are gone with it. `validate_input_id()` moved from `runtime-update.R` into `runtime.R`.
* Eliminated the `requestAnimationFrame` value-deferral pattern across `Checkbox`, `Switch`, `Textarea`, `Input`, `RadioGroup`, `Dialog`, and `Popover` runtime components (issue #24). The DOM expandos (`root.__sbXxxValue`), dataset attributes, and hidden native inputs are now written synchronously from a single set of paths — the mount effect, the user-action setter, and the `__sbXxxReceive` handler — so the Shiny binding's `getValue(el)` returns the new value immediately when the `sb:<component>-change` event fires. See [ADR 0019](docs/decisions/0019-single-writer-runtime-inputs.md).
* Fold the JSON-serialisability check into `runtime_payload_json()` so every runtime component render runs `jsonlite::toJSON()` once instead of three times (issue #28). `validate_runtime_json()` is removed.
* Collapsed the ten copy-pasted Shiny input bindings in `frontend/src/runtime/bindings.js` into a single `makeRuntimeBinding()` factory driven by a config array (issue #26). Adding a new runtime input component is now a config entry rather than ~70 lines of boilerplate; the per-component `register*Binding`, `bind*Root`, and `unbind*Root` helpers are gone, and the dispatcher if-ladders collapse to a single `Shiny.bindAll` / `unbindAll` call.
* Extracted the session validation, `runtime_mount_id()` lookup, and `sendInputMessage()` boilerplate from every `update_block_*()` into a shared `runtime_input_update()` helper (issue #27). Each updater now only assembles its own payload fields.

## Other changes

* Added `block_alert_action()` and an `action` slot to `block_alert()`, matching the current shadcn Alert composition pattern for top-right actions while keeping the built-in variant set limited to upstream `default` / `destructive`.
* Replaced `block_slider()`'s in-component `requestAnimationFrame` notification coalescing with a Shiny binding rate policy (`throttle`, 100ms) (issue #25). Per-pointer-move drags arrive at `input$<id>` at most every 100ms without holding back server-driven `update_block_slider()` echoes. Standalone sliders also keep a usable minimum width in shrink-wrapped preview/layout contexts.
* Added `variant = c("default", "accent", "destructive")` support to `block_value_box()`, with matching docs/showcase controls for token-backed metric emphasis.
* Added `size = c("default", "sm", "lg")` support to `block_switch()` and `update_block_switch()`, and aligned the Switch docs/showcase playgrounds with the real component API.
* Added an interactive Shinylive playground to the docs site for the Tabs component page (issue #21), and aligned the local Tabs showcase tab with the same unboxed controls and preview layout.
* Added an interactive Shinylive playground to the docs site for the Slider component page (issue #21), and aligned the local Slider showcase tab with the same unboxed controls and preview layout.
* Added an interactive Shinylive playground to the docs site for the Input Group component page (issue #21), and aligned the local Input Group showcase tab with the same unboxed controls and preview layout.
* Added an interactive Shinylive playground to the docs site for the Radio Group component page (issue #21), and aligned the local Radio Group showcase tab with the same unboxed controls and preview layout.
* Added an interactive Shinylive playground to the docs site for the Switch component page (issue #21), and aligned the local Switch showcase tab with the same unboxed controls and preview layout.
* Added an interactive Shinylive playground to the docs site for the Empty component page (issue #21), and aligned the local Empty showcase tab with the same unboxed controls and preview layout.
* Fixed `block_select()` dropdown positioning in short embedded viewports. Select popovers now flip upward when there is not enough room below the trigger, preventing docs/playground iframes from clipping controls near the bottom edge.
* Added an interactive Shinylive playground to the docs site for the Value Box component page (issue #21), and aligned the local Value Box showcase tab with the same controls, preview canvas, and generated UI definition.
* Added an interactive Shinylive playground to the docs site for the Card component page (issue #21), and aligned the local Card showcase tab with the current unboxed playground layout.
* Added interactive Shinylive playgrounds to the docs site for the Skeleton, Spinner, Code, and Alert component pages (issue #21). Each playground mirrors its showcase example/server pair behind the established bundled-WASM mount + `do.call(library, ...)` pattern so Shinylive's static dependency scanner does not request a non-existent `shinyblocks` webR binary.
* Phase 8 final-gate dry run cleared. `devtools::check(remote = TRUE)` now reports 0 errors / 0 warnings / 2 benign notes (new-submission CRAN feasibility + "unable to verify current time"). `lintr::lint_package()` reports 0 lints. `devtools::spell_check()`, `devtools::test()`, the runtime/Shiny/showcase browser suites, and `make parity-ci` are all green.
* Fixed alignment of the light/dark mode icon inside `block_dark_mode_toggle()` under light and dark mode: enforced inline-flex display, row layout, a 0.5rem gap, and `white-space: nowrap` on the inner span wrapper to prevent the icon and text from wrapping and stacking vertically under narrow parent containers.
* Fixed a parity regression in `block_button()`: restored the `shadow-sm` box-shadow that was dropped during the Phase 6 legacy `.sb-button*` CSS cleanup, and confirmed it does not leak into the `ghost` / `link` variants.
* Tightened the slider thumb transform normaliser in `tools/parity/normalise.mjs`: scoped to the slider/thumb context only (a `context` parameter is now threaded through `normaliseValue` / `normaliseStyles` / `captureRoles`) so a future component using `translateX` as a visual primitive is not silently masked, and the `ty` offset is rounded to handle Chromium float drift.
* Removed `vignettes/articles/*.Rmd`. These were leftover pkgdown article copies, superseded first by the `gallery/` move and then by the custom docs site (ADR 0018). R CMD check no longer WARNs on `vignettes/` without a registered builder.
* Guarded `tests/testthat/test-runtime-css.R` and `tests/testthat/test-runtime-js.R` so the helpers that read repo-only source files now `skip()` under R CMD check (where the package tarball does not contain those paths), matching the existing pattern in `test-doc-coverage.R`.
* Expanded `inst/WORDLIST` with 76 legitimate runtime-migration / code-review / British-spelling terms so `devtools::spell_check()` is clean.
* Bumped `.lintr` line-length limit from 80 to 120 chars (modern R-package convention) and excluded `inst/showcase/` from lintr, since it is presentation/demo code rather than installed package source. Added two narrow `# nolint: line_length_linter` markers in test files that assert exact long string literals.
* GitHub Actions docs deploy now passes `enablement: true` to `actions/configure-pages@v5`, so the workflow can enable Pages on first run instead of 404-ing on a fresh repo. The free-private-repo Pro/Team/Enterprise requirement still applies until the repo is public.
* Docs site landing-page hero badge no longer claims a fictional `v0.4.0`; it now reads "Runtime preview · shadcn-inspired Shiny components" to match the actual pre-release state (DESCRIPTION is at 0.0.0.9000).
* Refreshed the Page, Body, Header, Sidebar, Nav, and Nav Item component specs around their shipped R-side composition contracts, page-scoped sidebar runtime behavior, stable shell hooks, and accessibility wiring.
* Refreshed the Theme, Icon, and Dark Mode Toggle component specs around the shipped token override / runtime mode-driver split, the manifest-as-source-of-truth icon contract, and the `block_button()`-delegated dark-mode toggle.
* Refreshed the Button, Badge, and Select component specs around the shipped runtime variant/size contract, receive-only button binding, full updater surfaces, hidden-native-select bridge, and portal-rendered select popup.
* Refreshed the Separator, Spinner, Skeleton, Empty, and Value Box specs around their shipped runtime payload shapes (orientation, accessible label, attrs passthrough, and title/value/description/icon/content/action slots).
* Refreshed the Card family specs (`block_card()` plus the five composition primitives) around the shipped flat-argument convenience, `data-sb-child` region markers, runtime child binding through `[data-shinyblocks-children]`, and the dashboard-specific `value =` metric slot.
* Refreshed the Alert family specs (`block_alert()`, `block_alert_title()`, `block_alert_description()`) around the shipped runtime variant + slot contract and `data-sb-child` composition markers.
* Refreshed the Tabs and Tab specs around the shipped package-owned tablist/tabpanel markup, local `shinyblocks.js` selection/keyboard/ARIA runtime, and the `shiny::tabPanel()` compatibility input boundary.
* Refreshed the Slider spec around the shipped runtime payload, hidden native-input bridge, single/range modes, pointer/keyboard behavior, and `update_block_slider()` notify semantics.
* Refreshed the Code and Field Description specs around their shipped runtime payload + composition contracts.
* Added `block_code()`, a shadcn-docs-style code block with line numbers, copy-to-clipboard interactions, and an optional editor-style header.
* Refreshed the Dialog, Popover, and Tooltip component specs around their shipped runtime API, Shiny state/update contracts, accessibility behavior, and known divergences.
* Refreshed the Input, Textarea, Checkbox, Switch, and Radio Group component specs around their shipped runtime API, Shiny state/update contracts, keyboard behavior, and known divergences.
* Cleaned up `block_tabs()` / `block_tab()` ownership for Phase 5. Tabs no longer wrap `shiny::tabsetPanel()` or decorate Bootstrap tab markup; `block_tabs()` now emits package-owned triggers and panels, local `shinyblocks.js` handles click/keyboard selection and panel visibility, and selected values are pushed to Shiny via `input$<id>` without `nav-link`, `tab-pane`, or `shiny-tab-input` dependencies in the rendered contract.
* Cleaned up `block_theme()` / `update_block_theme()` ownership for Phase 6. `block_page()` now emits only the initial theme-mode configuration, while the package `shinyblocks.js` runtime owns theme application, dark-mode toggle delegation, and Shiny `sb:theme` messages through one path.
* Documented the remaining `.sb-*` shell selectors as package-owned layout/navigation hooks, keeping them separate from runtime-rendered component styling.
* Added a package stylesheet guardrail so future runtime-rendered components cannot quietly reintroduce visual CSS into the shell/composition stylesheet.
* Resolved `block_input_group()` ownership for Phase 5 cleanup. Input groups and addons remain R-side composition/layout primitives rather than standalone runtime input bindings; the showcase and shell tests now compose them with runtime `block_input()`, and the source stylesheet includes group-specific merge rules so runtime inputs visually share the group shell.
* Phase 5.10 slider runtime migration: `block_slider()` now renders through the package React runtime instead of `shiny::sliderInput()` / ion.rangeSlider. It ships a hidden native input for synchronization, a dedicated `shinyblocks.slider` binding, single-value and range support, pointer and keyboard interaction, new `invalid` / `style` arguments, and `update_block_slider()` for value/min/max/step/disabled/invalid/style/class server updates. The Slider showcase tab now uses the full playground contract with Content, State, Actions (Server Update), Styling, API Reference, and parity fixtures; the API Reference table now matches the concise Input table format. Legacy ion.rangeSlider CSS was removed from the package stylesheet.
* Local package asset dependencies now include built asset mtimes in their version strings, so restarting the showcase after runtime CSS/JS edits reliably serves fresh `shinyblocks-runtime.css` and `shinyblocks-runtime.js` paths instead of browser-cached stale assets.
* Added `block_tooltip()`. Hover- and focus-triggered text overlay rendered through the runtime React layer with side/align placement (`side` defaults to `"top"`), configurable open delay (`delay_duration`, default 700 ms), `Escape`-to-close, scoped `--primary` / `--primary-foreground` styling, and portal rendering via `[data-shinyblocks-portal-root]` to avoid `overflow`/`transform` clipping. The Tooltip tab in the showcase demonstrates side variants, alignment, custom delays, and rich-HTML content.
* Showcase reorganization: split the umbrella **Field** tab into dedicated component tabs. **Switch** gets a full interactive playground with `update_block_switch()` Actions (turn on/off, disable/enable, rename). **Input group** gets its own tab demonstrating leading/trailing/both addons and invalid composition. Parity fixtures relocated to their owning component tabs (`.sb-parity-{select,checkbox,switch,textarea}-*` now live under `#select`, `#checkbox`, `#switch`, `#textarea`), and the parity registry was updated to match.
* Removed dead post-migration legacy CSS. Alert, value-box, separator, skeleton, spinner, empty, checkbox-indicator, switch-track, Selectize, and legacy `.sb-button*` selectors have been deleted from `inst/www/src/shinyblocks.css` since their components are runtime-rendered. Showcase-only server-update buttons now use local `.showcase-action-button-*` classes instead of keeping package-level button CSS alive. Surfaced a missing `position: relative` on the runtime `.sb-alert` rule that the legacy CSS had been silently providing.
* Fixed badge dark-mode parity (issue #2): `[data-theme="dark"] .sb-badge-destructive` now matches the shadcn `dark:bg-destructive/60` tint via `color-mix(in oklch, var(--destructive) 60%, transparent)`. The parity normaliser also collapses Tailwind v4's two-value `display: inline flex` and `border-radius: calc(infinity * 1px)` idioms to canonical forms so visually identical badges no longer report 17 spurious drifts. `make parity-ci` now passes for badge.
* Fixed button parity capture (issue #3): the button showcase now ships stable `.sb-parity-button-default` / `.sb-parity-button-disabled` fixtures in a small "Parity fixtures" block alongside the interactive playground, and the parity registry targets the rendered `button[data-slot="button"]` rather than the runtime mount wrapper. The parity diff baseline is now passed through `normaliseStyles`, and zero-width border sides skip their (visually irrelevant) `borderXColor` comparison.
* `block_textarea()` and `block_input()` runtime bindings now report the payload's initial `state.value` from `getValue()` when React has not yet mounted, so Shiny's first read no longer reports an empty string for inputs whose initial value was set on the server.
* Added `update_block_button()`. `block_button()` accepts `id = "..."` (via `...`) to register a receive-only `shinyblocks.button` runtime binding; the new updater can change `label`, `variant`, `size`, `icon`, `icon_position`, `disabled`, `style`, and `class` from the server, with `icon = NULL` / `style = NULL` clearing those props. The button showcase now exposes a full Actions (Server Update) panel exercising every field.
* Unblocked the select parity selectors (issue #5): the field showcase now ships a stable `.sb-parity-select-default` fixture, the parity registry targets `button[data-slot="select-trigger"]`, and `prepareSelectOpenState` waits on the runtime portal (`[data-slot="select-content"][data-state="open"]`) instead of the removed Selectize dropdown. Underlying runtime-CSS drift on the select trigger surfaces separately and is tracked in #5.
* Unblocked the switch parity selectors (issue #7): the registry's `track` role now targets `button[data-slot="switch-control"]` inside each `.sb-parity-switch-*` fixture, matching the runtime Switch markup. Underlying runtime-CSS drift on the switch track (height/width/inset-shadow) surfaces separately and is tracked in #7.

## 0.0.0.9000

* Architecture pivot: ADR 0017 adopts the full runtime shadcn port. Future component work moves to an R-facing adapter over package-local shadcn/Radix runtime assets, with scoped CSS, Shiny input/update semantics, per-component showcase pages, cleanup gates, and bundle-size reporting. The earlier native-CSS and wrap-by-default input decisions remain historical migration scaffolding.
* Added the first runtime foundation slice: package-local runtime CSS/JS assets, internal R payload and update-message helpers, scoped mount markup, runtime build targets, a browser smoke-test scaffold, and tests for dependency attachment and Shiny updater semantics.
* Added Phase 1 runtime asset guardrails: runtime CSS isolation tests block unscoped selectors and host-framework selectors, and `tools/budget.R` now reports runtime JS/CSS raw and gzip sizes separately from legacy compatibility assets.
* Added Phase 1 runtime lifecycle guardrails: `block_page()` now includes a package-owned portal root, runtime mounts without Shiny input ids receive unique ids, and static runtime JS tests cover the Shiny bridge, dynamic UI hooks, child binding hooks, and portal setup.
* Added a Shiny-backed runtime browser smoke fixture that verifies runtime input initialization, server updates, disabled state, dynamic `renderUI()` removal/reinsertion, and Shiny children inside runtime mounts.
* Expanded the Shiny-backed runtime browser smoke fixture to cover explicit `insertUI()` / `removeUI()` and id reuse.
* Expanded the runtime input-update browser fixture to cover clear/reset updates, enable-after-disable, stale update rejection, and Shiny module namespacing.
* Added browser-backed runtime collision coverage for host Bootstrap-style selectors, Selectize-style selectors, bslib card markup, DT tables, plotly-style htmlwidget hosts, htmlwidget children inside runtime mounts, and pre-existing portal-root content.
* Switched the runtime JavaScript foundation from concatenated vanilla browser scripts to a Vite-built React/ReactDOM bundle, with React-owned mount slots kept separate from Shiny child slots so Shiny outputs and htmlwidgets continue to bind inside runtime components.
* Added scoped runtime token defaults on `[data-shinyblocks-root]` and `[data-shinyblocks-portal-root]`, plus static checks that the runtime asset does not write theme tokens to `:root`.
* Added hard Phase 1 runtime asset budgets for the Vite-built runtime bundle and scoped runtime CSS, recorded in ADR 0017 and enforced by `tools/budget.R`.
* `block_badge()` and `block_button()` now render through the package-local React runtime while preserving their R-facing variant, size, icon, custom class, disabled, and passthrough-attribute contracts. Native badge CSS was removed from the legacy stylesheet; native button CSS remains temporarily for `block_dark_mode_toggle()`.
* `block_select()` now renders a package-local shadcn-style overlay backed by a hidden native `<select>` and a component-specific Shiny input binding. `update_block_select()` now routes through `sendInputMessage()` and can update value, choices, placeholder, disabled state, styling metadata, and optional Shiny notification.
* `block_separator()` now renders through the package-local runtime while preserving horizontal/vertical orientation and decorative/semantic ARIA behavior.
* `block_spinner()` now renders through the package-local runtime while preserving the `role="status"` and accessible label contract.
* `block_skeleton()` now renders through the package-local runtime while preserving passthrough attributes and normalized runtime inline-style handling.
* `block_empty()` now renders through the package-local runtime while preserving icon, description, extra content, and action composition.
* `block_value_box()` now renders through the package-local runtime while preserving title, value, description, icon, and extra-content composition.
* `block_alert()` now renders through the package-local runtime while preserving role, variant, icon, title, description, and extra-content composition.
* `block_card()` now renders through the package-local runtime. Card body flows through `[data-shinyblocks-children]` so nested Shiny outputs, htmlwidgets, and inputs bind without a serialized HTML slot. Legacy `.sb-card*` Tailwind rules have been removed from `inst/www/src/shinyblocks.css`; runtime CSS now owns card styling under `[data-shinyblocks-root]`.
* Phase 4.1 skeleton: introduced `block_dialog()`. A modal portal-rendered through `[data-shinyblocks-portal-root]` with title, description, and serialized body. Initial open state only — no Shiny input binding, no trigger, no escape/outside-click, no focus management.
* Phase 4.2: `block_dialog()` becomes a Shiny input. `input$<id>` reports the open/closed state as a boolean and updates when the user clicks the trigger, overlay, or close button. New `update_block_dialog()` updater changes open state, title, and description from the server with explicit `notify` semantics. The dialog ships its own `Shiny.InputBinding` (`shinyblocks.dialog`) and uses the same mount-id-based message routing as `block_select()`.
* Phase 5.1 skeleton: introduced `block_popover()`. A non-modal, portal-rendered popover anchored to a trigger button via fixed positioning against the trigger's `getBoundingClientRect()`. Configurable `side` (`bottom` / `top` / `left` / `right`) and `align` (`center` / `start` / `end`). Initial open state only — no Shiny input binding, no outside-click, no escape, no focus management. These arrive in later sub-phases.
* Phase 5.4 checkbox runtime migration: `block_checkbox()` now renders through the package runtime (`component = "checkbox"`) with a hidden native checkbox input, a dedicated `shinyblocks.checkbox` input binding, and browser smoke coverage for user toggles and native-input synchronization.
* Phase 5.4 checkbox parity hardening: runtime checkbox markup and scoped CSS now align with the current shadcn checkbox visual contract (single indicator box, compact control geometry, and state styling), while explicitly neutralizing legacy checkbox pseudo-element styles inside runtime mounts.
* Phase 5.5 switch runtime migration: `block_switch()` now renders through the package runtime (`component = "switch"`) with a hidden native checkbox input, a dedicated `shinyblocks.switch` input binding, and a new `update_block_switch()` helper for checked/disabled/style/class server updates with optional notify semantics.
* Phase 5.9 radio group: introduced `block_radio_group()` and `update_block_radio_group()`. Shadcn-style radio group rendered through the package runtime (`component = "radio-group"`) with a hidden native `<input type="hidden">` for form-submission, a dedicated `shinyblocks.radio-group` input binding, full arrow-key navigation (Up/Down/Left/Right), `orientation` arg (`"vertical"` / `"horizontal"`), `invalid` flag, and a server updater covering selected/choices/disabled/invalid/orientation/style/class with optional notify semantics. Scoped `.sb-radio-group-control` styles under `[data-shinyblocks-root]` follow the shadcn radio contract.
* Phase 5.8 text input: introduced `block_input()` and `update_block_input()`. Single-line text input rendered through the package runtime (`component = "input"`) with a hidden native `<input>`, a dedicated `shinyblocks.input` binding (debounced 250 ms), `type` argument supporting `text` / `password` / `email` / `url` / `tel` / `search` / `number`, `invalid` flag, and full server updater for value/placeholder/type/disabled/invalid/style/class with optional notify semantics. Scoped `.sb-input-control` styles under `[data-shinyblocks-root]` mirror the shadcn input contract. Showcase ships a full Content/State/Actions/Styling playground.
* Phase 5.7 textarea runtime migration: `block_textarea()` now renders through the package runtime (`component = "textarea"`) with a hidden native `<textarea>`, a dedicated `shinyblocks.textarea` input binding (debounced 250 ms), a new `invalid` argument that sets `aria-invalid="true"`, and a new `update_block_textarea()` helper for value/placeholder/rows/disabled/invalid/style/class server updates with optional notify semantics. Legacy `.sb-textarea` rules removed from `inst/www/src/shinyblocks.css`; runtime CSS owns textarea styling under `[data-shinyblocks-root]`. Server-driven `value` / `rows` updates clear any drag-resized inline `style.height` so server changes are visually authoritative; the showcase Clear button snaps the preview back to whatever the controls panel currently states.
* Phase 5.6 popover/checkbox/switch cleanup: removed the dead pre-runtime `boolean_control_input()` helper and the legacy `.sb-checkbox-shell`/`.sb-checkbox-control`/`.sb-checkbox-indicator`/`.sb-switch-shell`/`.sb-switch-control`/`.sb-switch-track` rules from `inst/www/src/shinyblocks.css` now that all three controls render through the scoped runtime under `[data-shinyblocks-root]`. Component specs harmonized to the same status header.
* Phase 4.4: `block_dialog()` gains a `size` argument (`"sm"`, `"default"`, `"lg"`, `"xl"`) that adjusts the content max-width, plus a `footer` slot that renders below the body in a right-aligned, wrapping flex row. `update_block_dialog()` learns matching `size` and `footer` arguments so server code can resize the dialog or swap action rows without a re-render. Passing `footer = NULL` to the updater clears an existing footer.
* Phase 4.3: `block_dialog()` is now keyboard- and screen-reader-ready. Escape closes the dialog, Tab/Shift+Tab cycle focus inside the content, focus is moved to the first focusable element on open and returned to whichever element held it before open. Body scroll locks while open with scrollbar-width padding compensation to avoid layout shift. The content carries `role="dialog"`, `aria-modal="true"`, and `aria-labelledby` / `aria-describedby` wired to the title and description slots. New `hide_title = TRUE` argument hides the title visually while keeping it as the accessible name, and the trigger button advertises `aria-haspopup="dialog"` plus a live `aria-expanded`.
* Added the initial ADR 0016 visual-parity harness scaffold: a
  dev-only `parity/` React reference app, shared Playwright
  capture/diff scripts, parity make targets, and the first committed
  computed-style baseline for `button`.
* Internal: `make parity` now accepts `COMPONENT=<name>`, and
  `make parity-ci` iterates over every component currently registered
  in `tools/parity/registry.mjs` instead of pretending the button-only
  baseline covers the whole package. Phase-exit docs and the
  `shinyblocks-component` skill now describe the actual shared-harness
  workflow (`parity/src/main.js`, registered components, manual spec +
  screenshot backstop for everything not yet migrated).
* `block_select()` is now migrated into the shared ADR 0016 parity
  registry. The dev-only React reference app exposes a local select
  trigger in closed and open states, `docs/component-specs/_parity/select.json`
  is committed as the baseline, and `make parity-ci` now verifies both
  `button` and `select`. The selectize wrapper CSS was tightened at the
  same time so the visible trigger now matches the shadcn contract more
  closely: `shadow-xs` at rest, `justify-between` + `gap-2`, zero
  vertical padding inside the fixed 32px shell, and a token-driven open
  ring that suppresses Selectize's default blue focus shadow.
* `block_slider()` is now migrated into the shared ADR 0016 parity
  registry as the first multi-role component. The shared harness now
  captures and diffs `root`, `rail`, `range`, and `thumb` roles across
  light/dark, default/hover/disabled states, with extra live checks for
  thumb-vs-rail centering and hidden ion.rangeSlider labels. The local
  baseline lives at `docs/component-specs/_parity/slider.json`, and the
  disabled thumb cursor is now forced to `not-allowed` with
  `!important` so the live widget matches the parity contract.
* `block_checkbox()` is now migrated into the shared ADR 0016 parity
  registry. The shared harness captures unchecked, checked, and
  disabled states across light/dark mode using the visible checkbox
  shell plus label-text opacity, with a new disabled checkbox fixture in
  the field showcase to anchor the live comparison. The baseline lives
  at `docs/component-specs/_parity/checkbox.json`.
* `block_switch()` is now migrated into the shared ADR 0016 parity
  registry. The shared harness captures off, on, and disabled states
  across light/dark mode using the visible switch track plus label-text
  opacity, with a new disabled switch fixture in the field showcase to
  anchor the live comparison. The baseline lives at
  `docs/component-specs/_parity/switch.json`.
* `block_textarea()` is now migrated into the shared ADR 0016 parity
  registry. The shared harness captures default, focus-visible,
  disabled, and invalid textarea states across light/dark mode, with
  stable field-showcase fixtures and a new baseline at
  `docs/component-specs/_parity/textarea.json`. The shared text-control
  CSS was tightened at the same time so text inputs keep `shadow-xs`
  under focus/invalid rings, disabled controls get the shadcn
  `not-allowed` + `opacity-50` contract, and `block_textarea()`
  defaults to the 2-row shadcn baseline instead of a taller native
  shell.
* New agent skill `shinyblocks-component` lands at
  [`docs/skills/shinyblocks-component.md`](docs/skills/shinyblocks-component.md)
  (the tracked canonical copy), with a `make skills-install` target
  that mirrors it into `.claude/skills/shinyblocks-component/SKILL.md`
  and `.agents/skills/shinyblocks-component/SKILL.md` so Claude Code
  and Codex pick it up locally. End-to-end recipe for adding (or
  refactoring) a `block_*()` component: per-gate sync rule (R + CSS
  + showcase + tests + spec + pkgdown + NEWS), shadcn-fidelity
  workflow against the `apps/v4/registry/new-york-v4` source, the
  parity-harness template (including the positioning + cross-element
  bounding-rect checks the 2026-05-11 slider POC surfaced as
  necessary), common-pitfall list, and pre-commit checklist.
  Triggered by user prompts like "add a component", "port shadcn X
  to shinyblocks", or "wrap shiny::Y as a block". `docs/ROADMAP.md`
  Current Status and the Phase 5 hand-off doc both point at the
  skill as the canonical workflow. `make setup` now runs
  `skills-install` automatically so a fresh checkout has the skill
  registered after one command.
* `tools/parity/slider-poc.mjs` grew positioning properties
  (`position`, `top`, `marginTop`, `transform`), a
  `getBoundingClientRect()` cross-check asserting the slider thumb
  is vertically centred on the rail (delta ≤ 1.5px), and a dark/
  light theme toggle that captures all three roles (rail, range,
  thumb) in both modes. The original property-only diff had missed
  an off-centre thumb that visibly floated above the rail; the
  geometry assertion now catches it.
* `block_slider()` CSS hardened to match shadcn's contract under
  any container height: `.sb-slider .irs--shiny { height: 1.5rem
  !important; }`, inner `.irs` wrapper expanded to fill via
  `height: 100% !important`, and every role centred with
  `top: 50% !important; transform: translateY(-50%) !important;`
  so ion.rangeSlider's inline `top` rewrites cannot offset them
  again.
* Visual-parity harness adopted per
  [ADR 0016](docs/decisions/0016-visual-parity-harness.md). Mechanical
  computed-style + DOM diff against a pinned shadcn-react reference
  replaces reviewer-only parity for the bulk of drift. An initial
  proof of concept validated the approach against `block_select()` —
  caught
  18 trigger drifts and a double-hover dropdown bug that the
  spec-doc review missed. A follow-up CSS fix on the same select
  reduced trigger drift from 18 to 7 properties (the remaining ones
  are colour-space normalisation, expected state mismatches, and
  structural divergences by design), and eliminated the double-hover
  (dropdown now lights exactly one row on mouse hover instead of
  two). The full harness is Slice 6 in
  [`docs/agent-plans/2026-05-09-phase-5-handoff.md`](docs/agent-plans/2026-05-09-phase-5-handoff.md).
* `block_select()` trigger and dropdown now match shadcn more
  closely: `rounded-lg` (was `rounded-md` — 10px vs 4px), transparent
  background (was solid), 32px height (was 34px), absolutely-
  positioned 16px chevron with the Lucide `chevron-down` mask, and a
  selected option that uses `font-weight: 500` instead of a fill so
  it no longer competes with the keyboard-cursor / pointer-hover
  state.
* Phase 5 hand-off plan landed at
  [`docs/agent-plans/2026-05-09-phase-5-handoff.md`](docs/agent-plans/2026-05-09-phase-5-handoff.md):
  six slice-sized implementation steps (focus-visible redesign,
  `aria-invalid` cross-cut, tabs refactor, reference screenshots,
  spec backfill, gallery resumption) with files to edit, concrete
  CSS patterns, tests to update, and definition-of-done per slice.
  The next implementer can pick up Phase 5 finish from there without
  rereading the conversation history.
* First shadcn-fidelity audit pass per
  [`docs/agent-plans/2026-05-09-shadcn-fidelity-audit.md`](docs/agent-plans/2026-05-09-shadcn-fidelity-audit.md).
  Compared against the canonical
  `apps/v4/registry/new-york-v4` source, three classes of drift were
  fixed in `inst/www/src/shinyblocks.css`: badges now use
  `rounded-full` + `text-xs` (the current shadcn pill shape, not the
  earlier rounded-rectangle), `block_button(variant = "link")` picks
  up `text-primary`, `block_button(variant = "outline")` carries
  `shadow-xs`, and destructive button + badge variants use
  `text-white` with a `[data-theme="dark"]` 60%-opacity dim that
  matches shadcn's dark-mode treatment. Three cross-cutting drifts
  (focus-ring redesign to the shadcn 3px ring, `aria-invalid`
  styling, tabs data-attribute refactor) are queued as the next
  Phase 5 slices.
* Visual-parity contract per [ADR 0015](docs/decisions/0015-component-specs.md):
  every exported `block_*()` ships with a short
  `docs/component-specs/<name>.md` capturing the shadcn reference
  link, visual states, token contract, deliberate divergences, and a
  reference screenshot. `tests/testthat/test-doc-coverage.R` enforces
  the rule; existing components are backfilled incrementally via a
  shrinking `backfill_pending_specs` allowlist. Quality Gate item 15
  walks every state listed in the spec against the live showcase
  during phase exit. Seed specs land for `block_button()` and
  `block_card()`; the template lives at
  `docs/component-specs/_template.md`.
* Initial R package scaffold with exported Shiny/htmltools helpers for
  pages, sidebars, headers, navigation items, cards, and buttons.
* `block_card()` now ships with styling for its title, value, and body
  slots so it renders as a tokenised surface instead of an unstyled
  `<article>`.
* `block_nav_item()` advertises itself as a `nav-item` child via
  `data-sb-child`, so a future `block_nav()` parent can validate its
  contents.
* Documentation gains a Quarto + Shinylive component gallery
  (`gallery/components/`) modelled on
  <https://shiny.posit.co/r/components/>. Each exported component has
  a page with an embedded live demo and visible source. See
  `docs/decisions/0013-component-gallery-quarto.md`.
* The dogfooded showcase under `inst/showcase/` is now a proper
  component gallery — its own UI is built entirely with shinyblocks
  primitives, the sidebar filters one component at a time, and every
  section is deep-linkable via the URL hash. `test-showcase.R`
  enforces an authoring contract: any new exported `block_*()` must
  land with a matching example file under `inst/showcase/R/examples/`
  and a row in the showcase's sections list, or the test suite fails.
* `block_card()` gains composition primitives — `block_card_header()`,
  `block_card_title()`, `block_card_description()`,
  `block_card_content()`, `block_card_footer()` — alongside the
  flat-argument convenience form. Pre-built region tags are reused
  via `data-sb-child` markers; bare strings/tags are wrapped
  automatically.
* `block_field()`, `block_field_group()`, `block_field_invalid()`,
  `block_field_label()`, `block_field_description()`,
  `block_field_set()`, `block_field_legend()`,
  `block_input_group()`, and `block_input_group_addon()` add
  Phase 5 form wrappers around standard Shiny inputs, including
  helper text, addons, fieldset composition, and invalid-state
  markup.
* `block_select()` now follows the new wrap-by-default input policy:
  it is a thin wrapper around Shiny's select/selectize path with
  token-driven Selectize styling, instead of a package-owned select
  runtime.
* `block_tab()` and `block_tabs()` add shadcn-style tab triggers and
  content styling on top of Shiny's existing tabset binding, preserving
  reactive tab switching without a custom input runtime.
* `block_theme()`, `block_dark_mode_toggle()`, and
  `update_block_theme()` add page-scoped token overrides, a persistent
  dark-mode toggle, and a server-side theme mode updater.
* `block_tabs()` now ships local tab activation behavior and hides
  inactive panels without relying on Bootstrap tab runtime.
* Tabs trigger sizing, spacing, and showcase content now track the
  shadcn tabs contract more closely.
* `block_textarea()`, `block_checkbox()`, and `block_switch()` add
  first-class wrapped Shiny form controls to the forms layer.
* Focus-visible styling now lives on the component bases themselves
  instead of a global `.sb-app *:focus-visible` outline fallback.
* Interactive controls now honour `aria-invalid="true"` with a
  destructive ring on the visible shell, including wrapped select,
  textarea, checkbox, and switch inputs.
* Tabs now use a shadcn-style data-attribute contract
  (`data-state`, `data-orientation`, `data-variant`) and include the
  line variant in the showcase.
* Component spec backfill now covers alert, alert-title,
  alert-description, input-group, input-group-addon, and select.
* The showcase theme example is now locally scoped and no longer
  changes the global primary button colour; `block_select()` also gets
  a stronger native-select fallback shell for dark mode.
* `block_select()` now applies stronger dark-mode styling to the
  Selectize-enhanced trigger itself, and hides the fallback chevron
  once Selectize has taken over the control.
* Component spec backfill now covers the field family:
  `block_field_group()`, `block_field()`, `block_field_label()`,
  `block_field_description()`, `block_field_set()`,
  `block_field_legend()`, and `block_field_invalid()`.
* Component spec backfill now also covers the layout shell:
  `block_page()`, `block_body()`, `block_header()`, and
  `block_sidebar()`.
* Component spec backfill now also covers navigation and utility
  primitives: `block_icon()`, `block_nav()`, `block_nav_item()`,
  `block_separator()`, `block_skeleton()`, `block_spinner()`,
  `block_empty()`, and `block_value_box()`.
* Component spec backfill is now complete for every exported
  `block_*()`; `test-doc-coverage.R` enforces the spec-doc contract
  without a temporary allowlist.
* Internal: the asset budget gate now enforces CSS on gzipped delivery
  size (`≤10 KB`) instead of a stale raw/minified threshold.
* Internal: added `tools/spec-screenshots.R` and `make spec-screenshots`
  to report which component-spec screenshots are still missing.
* Internal: added `make spec-screenshots-md` to generate a committed
  screenshot queue under `docs/component-specs/`.
* Internal: added `make spec-screenshots-check` so stale screenshot
  queue docs fail fast.
* Internal: `make gate` and the phase-exit checklist now include the
  screenshot-queue freshness check.
* Internal: added `make spec-screenshots-seed`, a macOS/Safari helper
  for first-pass capture of the seed screenshot set (`button`, `card`,
  `select`, `tabs`).
* Internal: the component-spec screenshot queue is now fully populated
  (`40` captured-dated references), and the Safari helper has been
  generalized to `make spec-screenshots-high-risk` and
  `make spec-screenshots-all` for repeatable refreshes.
* Internal: added `make showcase-capture` / `tools/capture-showcase-parity.sh`
  so local light/dark showcase sections can be captured reproducibly
  during the parity pass.
* New components round out Phase 3: `block_value_box()` for
  high-signal metrics, `block_separator()` (horizontal + vertical,
  ARIA-aware), `block_skeleton()` for loading placeholders,
  `block_spinner()` with `role="status"`, and `block_empty()` with
  optional icon, description, and action slots.
* Internal: deduplicated `as_alert_child()` and `as_component_child()`
  into a single helper; both call sites now share the same code path.
* `tests/testthat/test-doc-coverage.R` enforces a per-gate sync rule:
  every exported `block_*()` must appear in `_pkgdown.yml`'s
  `reference:` section (active) and have a gallery `.qmd` page under
  `gallery/components/` (currently `skip()`'d pending the
  WASM resolution per ADR 0013). The ROADMAP grows a §Per-gate
  component-sync rule section spelling out which artifacts must land
  in the same commit as a new component.
* The component gallery moves from `vignettes/articles/` to top-level
  `gallery/`. pkgdown 2.x requires Quarto 1.5+ to render `.qmd` files
  inside `vignettes/`, and the project pins Quarto 1.4 today —
  relocating sidesteps the version requirement until the gallery's
  WASM blocker (ADR 0013) is resolved. `make gallery` and the
  shinylive Quarto extension move with the directory.
* New `make verify` and `make verify-stop` targets. `verify` builds
  pkgdown, launches the showcase on `:4321` and the pkgdown site on
  `:4322` in the background, HTTP-checks both for `200`, and leaves
  them running so the maintainer can eyeball them. `make gate` now
  ends with `verify`, so a phase exit cannot tag without both servers
  responding. Quality Gate item 14 documents this rule.
* Added an interactive Shinylive playground to the docs site for the Theme component page (issue #21), and aligned the local Theme showcase tab with the same unboxed controls and preview layout.
* Added an interactive Shinylive playground to the docs site for the Nav Item component page (issue #21), and aligned the local Nav Item showcase tab with the same unboxed controls and preview layout.
* Added an interactive Shinylive playground to the docs site for the Layout component page (issue #21), and aligned the local Layout showcase tab with the same unboxed controls and preview layout.
* Added an interactive Shinylive playground to the docs site for the Tooltip component page (issue #21), and aligned the local Tooltip showcase tab with the same unboxed controls and preview layout.
* Added an interactive Shinylive playground to the docs site for the Popover component page (issue #21), and aligned the local Popover showcase tab with the same unboxed controls and preview layout.
* Added an interactive Shinylive playground to the docs site for the Dialog component page (issue #21), and aligned the local Dialog showcase tab with the same unboxed controls and preview layout.
* Replaced the docs home page's static Gallery preview with a live Shinylive dashboard playground composed from shinyblocks inputs, cards, tabs, alerts, and reactive server actions (issue #21).
