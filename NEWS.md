# shinyblocks (development version)

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
  replaces reviewer-only parity for the bulk of drift. A proof of
  concept at [`tools/parity/select-poc.mjs`](tools/parity/select-poc.mjs)
  validated the approach against `block_select()` — caught
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
