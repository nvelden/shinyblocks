# shinyblocks (development version)

## 0.0.0.9000

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
