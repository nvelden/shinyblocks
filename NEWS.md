# shinyblocks (development version)

## 0.0.0.9002

## New features

* Added a shared semantic foreground color API for icons and spinners.
  `block_icon()` now accepts `color = c("default", "muted", "primary",
  "destructive", "success", "warning", "info")`, and `block_spinner()` accepts
  the same color set instead of only `default`, `muted`, and `destructive`.
  The local showcase and docs-site playgrounds now expose those color choices
  and generate `color = ...` examples instead of inline `style = "color: ..."`
  snippets.

* Aligned built-in `block_style()` profiles with the official shadcn/ui v4
  style registry (issue #48). `block_style_profiles()` now returns only
  `default`, `luma`, `lyra`, `maia`, `mira`, `nova`, `rhea`, `sera`, and `vega`;
  shinyblocks-owned `mono`, `soft`, `brutal`, and `glass` are no longer shipped
  as built-in profile names. The internal translucency hooks added during the
  `glass` exploration remain as future custom-style infrastructure, but no
  built-in `glass` profile ships because there is no official upstream
  `style-glass.css`.

## Internal

* Factored the shared flat/translucent-surface recipe duplicated by the `luma` and `rhea` style profiles into two internal helpers in `R/style-profiles.R` (issue #47): `style_translucent_surface_tokens()` (borderless controls on a color-mixed `--input` surface) and `style_foreground_ring_tokens()` (transparent borders plus the 1px foreground-ring elevation). Both profiles now compose them via `c(list(...), helper(), helper())` instead of copy-pasting the recipe a second time; the per-profile `value_box_shadow` (Luma's explicit drop shadow vs Rhea's var-based recipe) is a required argument of `style_foreground_ring_tokens()`, so a profile that composes the recipe cannot forget to set it. The emitted `--sb-*` token set for both profiles is unchanged. Taught the style-registry parser (`tools/theme/style-registry.mjs`) to resolve these spliced helper calls so the profile-parity sweep still sees every token, and added browser-free unit tests for the parser (`tools/theme/style-registry.test.mjs`, `npm run test:style-registry`, wired into `make check-slice`) so a parser regression is caught without the showcase browser gate. A future translucent profile reuses the helpers rather than copy-pasting a third time.
* Began issue #41's refactor slice by adding shared `local_input_message_session()` and `local_custom_message_session()` test helpers, then converting `test-utils.R` updater tests away from repeated fake Shiny session capture blocks. This keeps updater assertions focused on the message target and payload while preserving the existing public API behavior.
* Continued issue #41 by extracting small internal R helpers for repeated runtime updater and hidden native-input patterns: payload setters, clearable payload fields, normalized style payloads, width style generation, and hidden native input/textarea construction. The form controls, select, radio group, and button/dialog/popover updaters now use the helpers while keeping their public APIs and message payload keys unchanged.
* CSS isolation / embeddability (issue #40, ADR 0022). shinyblocks no longer assumes it owns the whole page, so it can be embedded inside an existing Shiny/bslib app without clobbering host styles. Three changes: (1) the Tailwind Preflight reset is now scoped under `.sb-app` instead of shipping globally — `inst/www/src/shinyblocks.css` uses granular Tailwind imports (`theme.css` + a generated `preflight.scoped.css` + `utilities.css`) instead of `@import "tailwindcss"`, and a new reproducible generator `tools/build-preflight.mjs` (chained into `make build-css` / `npm run build:css`) rewrites the installed Tailwind's Preflight selectors under `.sb-app`, re-run on every Tailwind upgrade. (2) The shadcn design tokens move from global `:root` / `[data-theme="dark"]` to `.sb-app` / `[data-theme="dark"] .sb-app` in `inst/www/src/tokens.css`, so they no longer collide with another shadcn-token library on the page (identical specificity keeps the `block_theme()` override cascade unchanged; runtime/portal mounts keep their tokens from the already-scoped `frontend/src/styles/runtime.css`). (3) Removed the bare `localStorage["theme"]` read in `inst/www/shinyblocks.js` (the toggle writes the prefixed `sb-theme` key, but the reader still honored an unprefixed `theme` key a host app might own); the reader now reads only `sb-theme`. The Tailwind-internal `@layer properties` `--tw-*` defaults stay global (inert) and the docs site keeps `:root` tokens since it owns its page.
* Fixed the runtime `block_select()` dropdown clipping its last option under non-default style profiles (e.g. `block_style("luma")`, visible in the docs gallery theme dropdown). The popover sized itself from a fixed 32px-per-item estimate, so a profile's roomier item spacing overflowed the box and `.sb-select-content { overflow: hidden }` hid the final option with no way to scroll to it. The popover now measures its real content height after paint to place and clamp itself, the content box is a flex column whose viewport scrolls within the available space, and `.sb-select-content` is `box-sizing: border-box` so the max-height math accounts for its own padding/border. Added `tools/select-overflow-smoke.mjs` (`npm run test:select-overflow`, chained into `npm run test:runtime`) as a Playwright regression guard that opens the dropdown in a short embedded viewport under both the default and `luma` profiles and asserts the last option scrolls into the clip box.
* Made style profiles lean and scalable (issue #34, ADR 0021). A `block_style()` profile is now **data, not CSS**: the default runtime CSS owns each repeated recipe once and reads it from a per-component `--sb-*` token with a fallback, so a profile is a list of token values in `R/style-profiles.R` plus only a few genuinely-structural rules. Introduced a two-tier token model — the small curated public allowlist (`style_token_map()`, accepted via `block_style(...)`) versus internal per-component geometry tokens (`style_internal_token_map()`: `--sb-<component>-radius`/`-surface`/`-border`/`-shadow`) that profiles set as data but callers cannot pass via `...`. Re-expressed Luma's radii and translucent/ring surfaces as these tokens and deleted the corresponding `[data-sb-style="luma"]` rules; only geometry a single static token cannot express (per-mode card ring, switch/slider metrics, the alternative radio fill, the blurred dialog scrim) remains as scoped CSS. Default visuals are unchanged (defaults equal the historical values). Generalized the profile-parity harness (`tools/theme/check-style-parity.mjs`) and the showcase style switcher to sweep every `style_profile_names()` rather than hardcoding `"luma"`, so a future profile is auto-checked with no harness edits. Added a static leanness gate (`tools/theme/check-style-leanness.mjs`, `npm run test:style-leanness`, `make style-leanness`) that fails when a `[data-sb-style]` rule hardcodes a recipe property (radius / translucent surface / foreground ring) instead of a token, with a justified-exception allowlist. Replaced the parity registry's incorrect overlay "covered by the static CSS scan" claim with a real presence assertion (the profile sets `<component>_*` tokens and/or a `[data-sb-style]` rule). Wired the palette sweep + style-profile parity (`theme-test`) and the leanness gate into `make gate`, and recalibrated the runtime-CSS raw budget (the 36 KB cap predated the Luma port and was already exceeded; gzipped stays the meaningful transfer budget). Clarified that `block_style(scope = )` applies all token-driven profile differences within the scope, while the residual structural CSS still keys off a page-level `data-sb-style`.
* Fixed the Theme showcase's live preview showing a dark blue `--accent` (and rounded radius) in its default no-override state. The page's "Parity fixtures" block ran `block_theme(accent = "oklch(0.3 0.03 260)")` with no explicit scope; the section-wide auto-scope (`scope_showcase_theme()` -> `[data-sb-preview="theme"]`) then applied it to the whole Theme section, including the live demo above it, so a token the demo intentionally left at its adaptive default inherited the fixture's value. The fixture now scopes its override to its own `.sb-parity-theme-baseline` wrapper.
* Fixed the Theme playground (Shiny showcase and docs-site Shinylive) leaking the literal text "luma" above the preview when the Luma style profile was selected. The playgrounds inserted the whole `block_style()` object into the preview `tagList`; htmltools rendered its `$profile` field ("luma") as a text node. They now insert only the object's `$style` tag (the profile name still drives `data-sb-style` on the preview wrapper).
* Repaired the showcase smoke test (`tools/showcase-smoke.mjs`, `npm run test:showcase`), which still drove a removed `#showcase_tabs` instance with `usage`/`settings` tabs after the Tabs showcase was refactored to a `showcase_tabs_preview_ui` playground plus stable parity fixtures. It now exercises the `#showcase_tabs_parity_default` fixture (`overview`/`usage`), including click activation and roving-focus wrap on `ArrowRight`.
* Removed the dev-only Quarto component gallery (`gallery/`, ADR 0013) and its `make gallery` / `make quarto-setup` targets and `gallery/components/*.qmd` doc-coverage test. It was superseded by the custom docs site (`docs-site/`, ADR 0018), which is the published documentation and component gallery.
* Added a reproducible theme-conformance framework (issue #32, ADR 0020) that guarantees current and future components honor theme settings (dark mode and `block_theme()` token overrides). Layer 1 (`tools/theme/check-token-usage.mjs`, `npm run test:themes-static`, `make theme-static`) statically fails when component CSS hardcodes a color instead of a `var(--token)`, with justified exceptions in `tools/theme/color-allowlist.mjs`. Layer 2 (`tools/theme/check-theme-response.mjs`, `npm run test:themes-runtime`) drives the showcase with Playwright and asserts each component's rendered color follows a sentinel token override in light and dark. Layer 3 is a completeness gate that reads `RUNTIME_COMPONENT_NAMES` from `R/runtime.R` plus the R-side primitives and fails when any component is missing from `tools/theme/theme-registry.mjs`. The static layer is wired into the Quality Gate. First catches: the slider thumb hardcoded `#ffffff` (now `var(--background)`, fixing dark mode) and the Theme showcase demo leaking its `--primary` app-wide (now scoped). Added `.sb-parity-input-default` and `.sb-parity-radio-group-checked` showcase fixtures so input and radio-group are covered.
* Added a `scope` argument to `block_theme()` so token overrides can be confined to a subtree (`<scope>` and the runtime roots inside it) instead of the whole page. Default behavior is unchanged (page-wide). The Shiny showcase Theme demo and its parity fixture now pass `scope` so they no longer leak token colors into the rest of the gallery.
* Added a `dark` argument to `block_theme()` for shadcn-style light/dark token pairs (issue #32). The `...` overrides apply in both modes; `dark = list(...)` sets values that apply only when `[data-theme="dark"]` is active (emitted as `[data-theme="dark"]`-scoped rules), overriding the base value or package default in dark mode. The Theme showcase playground gained dark-mode override controls and now defaults each token to "inherit" so untouched tokens keep their adaptive light/dark defaults (fixing an unreadable muted surface / invisible primary button in dark mode when the demo forced light values).

* Aligned playground controls panel height and scroll behavior (issue #32) across the local Shiny showcase and the docs site interactive Shinylive playgrounds. Added `showcase-playground`, `showcase-playground__controls`, and `showcase-playground__main` classes to `showcase_playground_layout()`. Refactored the controls sidebar to natively use the token-driven `block_card()` component, completely removing customized background, border, and padding CSS overrides. Implemented a stable fixed-height playground layout (`680px` on desktop) with dual-column independent scrollbars and custom high-fidelity thin scrollbars to deliver a premium, visual-parity dashboard experience. Appended showcase custom playground styles to `shinyblocks-runtime-override.css` during the docs playgrounds prebuild step so that all 27 embedded Shinylive playgrounds automatically gain identical height-alignment and scroll behavior. Also adjusted the embedded iframe sizes on the docs website to a uniform `720px` height across all 26 component pages (leaving the main live gallery at `980px`) to align perfectly with the fixed playground canvas and eliminate unnecessary outer scrollbars or clipping. Also aligned global playground and theme colors with standard shadcn tokens (issue #32, comment ID: `4574796543`) by applying scoped resets to shield controls and outlines from default/Bootstrap blue outlines and checked states under light and dark modes, setting primary OKLCH accent-colors on form elements, enforcing `!important` display rules on native input helper classes, and refining active/selected sidebar navigation items to be font-semibold for maximum readability.
* Tidied the listener lifecycle in `inst/www/shinyblocks.js` (issue #29). The `window.shinyblocksTheme.apply` assignment moved out of `applyTheme()` (which reassigned it on every theme toggle) into a one-shot `exposeThemeApi()` called from `init()`. The global Escape + outside-click handlers that closed open mobile sidebars moved out of `wirePage()` (which attached fresh closures per page mount, stacking listeners on every dynamic re-render) into a `wireGlobalSidebarHandlers()` wired once behind a `shinyblocksSidebarGlobalWired` guard.
* Hardened the runtime input contract (issue #30): R-side `runtime_component()` now validates the component name against a `RUNTIME_COMPONENT_NAMES` allowlist so a typo errors immediately instead of silently producing a no-op mount, and every JS-side `getValue()` reads the DOM expando first and falls back to the payload's `state.value` via a shared `initialValue(el)` helper. The previous native-input fallback paths (`nativeCheckbox(el)?.checked`, etc.) are gone — the single-writer contract from #24 already guarantees the expando is set synchronously on mount.
* Removed the unused `runtime_update()` / `sb:update` custom-message channel and the React `applyUpdate` handler that consumed it (issue #23). All shipped components use the standard `update_block_*()` -> `sendInputMessage()` -> binding `receiveMessage` path; the parallel channel only existed to be exercised by the smoke-test fixture's synthetic `component = "fixture"`. The fixture's `runtime_update` observers and the corresponding smoke assertions are gone with it. `validate_input_id()` moved from `runtime-update.R` into `runtime.R`.
* Eliminated the `requestAnimationFrame` value-deferral pattern across `Checkbox`, `Switch`, `Textarea`, `Input`, `RadioGroup`, `Dialog`, and `Popover` runtime components (issue #24). The DOM expandos (`root.__sbXxxValue`), dataset attributes, and hidden native inputs are now written synchronously from a single set of paths — the mount effect, the user-action setter, and the `__sbXxxReceive` handler — so the Shiny binding's `getValue(el)` returns the new value immediately when the `sb:<component>-change` event fires. See ADR 0019.
* Fold the JSON-serialisability check into `runtime_payload_json()` so every runtime component render runs `jsonlite::toJSON()` once instead of three times (issue #28). `validate_runtime_json()` is removed.
* Collapsed the ten copy-pasted Shiny input bindings in `frontend/src/runtime/bindings.js` into a single `makeRuntimeBinding()` factory driven by a config array (issue #26). Adding a new runtime input component is now a config entry rather than ~70 lines of boilerplate; the per-component `register*Binding`, `bind*Root`, and `unbind*Root` helpers are gone, and the dispatcher if-ladders collapse to a single `Shiny.bindAll` / `unbindAll` call.
* Extracted the session validation, `runtime_mount_id()` lookup, and `sendInputMessage()` boilerplate from every `update_block_*()` into a shared `runtime_input_update()` helper (issue #27). Each updater now only assembles its own payload fields.

## Other changes

* Added `update_block_tabs()` so Shiny servers can select the active `block_tabs()` value, and exposed the new server-update flow in the Tabs showcase.
* Added Rhea and feedback-state theme extensions (issue #36). `block_style("rhea")` ports the official compact-Luma Radix profile through the lean profile-data model, with scoped CSS limited to structural geometry. `block_alert()` and `block_badge()` now accept `success`, `warning`, and `info` variants backed by additive shinyblocks surface/foreground/border tokens; `block_theme()` accepts those tokens plus `destructive-border`. Synced the vendored neutral dark scaffold to the official shadcn theming docs as of 2026-06-02, completed chart/radius Tailwind mappings, and added a deterministic shell/runtime token-drift audit.
* Added `block_style()` and a `style` argument to `block_page()`, the foundation of the layered theming contract from ADR 0021 (issue #33, Slice 3). A *style profile* owns visual feel (control sizing, spacing, surface/overlay metrics, elevation, focus/disabled treatment, motion) through a curated, stable public `--sb-*` token layer, separate from `block_theme()`'s semantic colours. The runtime stylesheet now consumes those tokens, and the `default` profile preserves the current visuals exactly. `block_page(style = block_style("default", control_height = "2.5rem"))` places `data-sb-style` on `.sb-app` and injects scoped overrides; profile tokens inherit into portal overlays. Overrides use a fixed snake-case allowlist (e.g. `control_height`, `surface_padding`, `focus_ring_width`); raw `--sb-*` names are rejected. Also added the discovery helpers `block_theme_presets()` and `block_style_profiles()`. This slice ships the style foundation only — the Luma profile, profile-scoped component CSS, showcase/playground style controls, and the profile-parity matrix remain deferred to later slices.
* Added **Luma** as the first non-default visual style profile (issue #33, Slice 4): `block_page(style = block_style("luma"), theme = block_theme(preset = "olive"))`. Luma's shared differences (tighter control padding/gap, flat controls, heavier card elevation, wider dialog gap, lighter overlay shadow, softer 30% focus ring) are emitted as `--sb-*` token overrides from the `luma` profile in `R/style-profiles.R`; its component-specific differences (larger radii, pill/translucent surfaces, slider/switch geometry, dashed empty state, blurred dialog scrim) ship as `[data-sb-style="luma"]`-scoped CSS in the runtime stylesheet. Token values mirror official upstream Radix Luma (`apps/v4/registry/styles/style-luma.css`). Explicit `block_style()` overrides still win over profile values. The Theme showcase and docs-site playground gained a style-profile selector that layers token controls over the chosen profile and shows the `block_page(style = )` authoring form. Reviewed runtime families: card, value box, button, badge, input, textarea, select (trigger/menu/item), checkbox, switch, slider, radio group, dialog, popover, tooltip, alert, empty, skeleton, code. Shell families (input group, field, tabs, sidebar, nav) and the palette/profile conformance matrix remain deferred to Slice 5; the Tailwind shell CSS was not regenerated in this slice.
* Added the palette/style-profile conformance and parity layer (issue #33, Slice 5), kept deliberately separate from colour-token conformance so a failure names the right layer. The theme-response harness (`tools/theme/check-theme-response.mjs`, `npm run test:themes-runtime`) gained a **palette sweep** that drives every shipped `block_theme(preset = ...)` palette through the live showcase in light *and* dark mode (R emits each preset's overrides as the single source of truth) and asserts a representative primary-bound element adopts the palette's `--primary`, that palettes are mutually distinct, and that light differs from dark. A new **style-profile parity** check (`tools/theme/check-style-parity.mjs`, `npm run test:style-parity`, `make style-parity`) toggles the page into Luma exactly as `block_page(style = block_style("luma"))` would and asserts each component's profile-sensitive computed property (radius, padding, gap, height, border width) actually changes. Its registry (`tools/theme/style-registry.mjs`) requires every component in `RUNTIME_COMPONENT_NAMES` plus the R-side primitives to declare profile coverage — `profile` (measured), `overlay` (portal surface, CSS present), or `profile-neutral` (with a reason) — or the completeness gate fails. Shell families (input group, field, tabs, sidebar, nav) are registered `profile-neutral` because the Luma shell CSS port is still deferred. Added R tests for the palette token-set matrix and the luma profile's use of curated public tokens.
* Ported the **Luma** style profile to the five R-side shell families (issue #33), closing the gap that Slices 4 and 5 deferred. `[data-sb-style="luma"]`-scoped rules in the package shell stylesheet (`inst/www/src/shinyblocks.css`, compiled to `inst/www/shinyblocks.css` by `make build-css`) now give tabs rounded-full pill lists/triggers, nav menu items a larger radius and taller hit target, sidebar/nav menus a wider item gap, fields wider field/group gaps and a softer fieldset, and input groups a `rounded-4xl` translucent surface with a transparent border. Values mirror official upstream Radix Luma (`apps/v4/registry/styles/style-luma.css` + `radix-luma/ui`). All five families are promoted in `tools/theme/style-registry.mjs` from `profile-neutral` to measured `mode: "profile"` bindings, so `npm run test:style-parity` now asserts each one's profile-sensitive computed property changes under Luma (20 measured, 0 failed). Colour-token conformance stays a separate harness pass; no new colour tokens were added.
* Added seven built-in semantic color presets to `block_theme(preset = ...)`: `neutral`, `stone`, `zinc`, `mauve`, `olive`, `mist`, and `taupe`. Each preset emits official shadcn-derived light/dark token packs while existing explicit `...`, `dark`, and `scope` overrides continue to work.
* Fixed docs-site playgrounds not following the website's light/dark toggle. Shinylive runs each Shiny app in a nested (same-origin) frame, so the host setting `data-theme` on the outer iframe never reached the app. The docs `PlaygroundFrame` now walks every reachable frame on load and on each toggle and applies the theme through the package's own `window.shinyblocksTheme.apply()` API (and sets `data-theme` as a fallback), retrying until the WASM app has booted. This drives the already-shipped runtime theming directly, so it works without any in-app change.
* Added a real `size` argument to `block_icon()` (issue #32): `"default"` (1rem, unchanged), `"sm"` (0.875rem), `"lg"` (1.5rem), `"xl"` (2.25rem), mapped to component-owned `sb-icon-size-*` classes instead of ad-hoc inline `width`/`height`. The Icon playgrounds (showcase + docs) now expose the real `size` values and generate the matching `block_icon(size = ...)` call. Sizing audit for the remaining issue #32 size items: `block_button` (`default`/`sm`/`lg`/`icon`) matches shadcn; `block_badge`, `block_switch`, and `block_value_box` carry token-backed shinyblocks size extensions; `block_checkbox`, `block_radio_group`, `block_input`, `block_textarea`, `block_select`, and `block_slider` intentionally have **no** `size` argument because shadcn renders them at a single fixed size — sizing there is a deliberate non-feature, not a gap.
* Extended the built-in `block_code()` syntax highlighter (issue #32) so the language-aware tokenizer now covers `html`/`xml`/`svg`, `css`/`scss`/`less`, `json`, `sql`, and `bash`/`sh`/`zsh` in addition to the existing R, Python, and JavaScript/TypeScript support. Highlighting applies to any user-supplied `code`, not a single demo string. The Code playgrounds (local Shiny showcase and docs Shinylive) no longer expose an editable `code` textarea; the sample snippet now updates to a representative example for the selected `language`, demonstrating the component-owned highlighting for each supported language.
* Added `block_alert_action()` and an `action` slot to `block_alert()`, matching the current shadcn Alert composition pattern for top-right actions while keeping the built-in variant set limited to upstream `default` / `destructive`.
* Added vertical orientation plus optional current-value and min/max bound labels to `block_slider()` and `update_block_slider()`, and exposed the same controls in the docs and Shiny showcase playgrounds (issue #22).
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
  trigger in closed and open states, the select parity baseline
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
  baseline lives at the slider parity baseline, and the
  disabled thumb cursor is now forced to `not-allowed` with
  `!important` so the live widget matches the parity contract.
* `block_checkbox()` is now migrated into the shared ADR 0016 parity
  registry. The shared harness captures unchecked, checked, and
  disabled states across light/dark mode using the visible checkbox
  shell plus label-text opacity, with a new disabled checkbox fixture in
  the field showcase to anchor the live comparison. The baseline lives
  at the checkbox parity baseline.
* `block_switch()` is now migrated into the shared ADR 0016 parity
  registry. The shared harness captures off, on, and disabled states
  across light/dark mode using the visible switch track plus label-text
  opacity, with a new disabled switch fixture in the field showcase to
  anchor the live comparison. The baseline lives at
  the switch parity baseline.
* `block_textarea()` is now migrated into the shared ADR 0016 parity
  registry. The shared harness captures default, focus-visible,
  disabled, and invalid textarea states across light/dark mode, with
  stable field-showcase fixtures and a new baseline at
  the textarea parity baseline. The shared text-control
  CSS was tightened at the same time so text inputs keep `shadow-xs`
  under focus/invalid rings, disabled controls get the shadcn
  `not-allowed` + `opacity-50` contract, and `block_textarea()`
  defaults to the 2-row shadcn baseline instead of a taller native
  shell.
* New agent skill `shinyblocks-component` lands at
  the local shinyblocks-component agent skill
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
  to shinyblocks", or "wrap shiny::Y as a block". the internal roadmap
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
  ADR 0016. Mechanical
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
  the internal Phase 5 hand-off plan.
* `block_select()` trigger and dropdown now match shadcn more
  closely: `rounded-lg` (was `rounded-md` — 10px vs 4px), transparent
  background (was solid), 32px height (was 34px), absolutely-
  positioned 16px chevron with the Lucide `chevron-down` mask, and a
  selected option that uses `font-weight: 500` instead of a fill so
  it no longer competes with the keyboard-cursor / pointer-hover
  state.
* Phase 5 hand-off plan landed at
  the internal Phase 5 hand-off plan:
  six slice-sized implementation steps (focus-visible redesign,
  `aria-invalid` cross-cut, tabs refactor, reference screenshots,
  spec backfill, gallery resumption) with files to edit, concrete
  CSS patterns, tests to update, and definition-of-done per slice.
  The next implementer can pick up Phase 5 finish from there without
  rereading the conversation history.
* First shadcn-fidelity audit pass per
  the internal shadcn-fidelity audit plan.
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
* Visual-parity contract per ADR 0015:
  every exported `block_*()` ships with a short
  component spec docs capturing the shadcn reference
  link, visual states, token contract, deliberate divergences, and a
  reference screenshot. `tests/testthat/test-doc-coverage.R` enforces
  the rule; existing components are backfilled incrementally via a
  shrinking `backfill_pending_specs` allowlist. Quality Gate item 15
  walks every state listed in the spec against the live showcase
  during phase exit. Seed specs land for `block_button()` and
  `block_card()`; the template lives at
  the component spec template.
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
  ADR 0013.
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
  screenshot queue.
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
