# Roadmap

The canonical strategy is now [ADR 0017: Full Runtime shadcn Port](decisions/0017-full-runtime-port.md),
implemented through
[`agent-plans/2026-05-12-full-port-architecture.md`](agent-plans/2026-05-12-full-port-architecture.md).
The earlier native-CSS strategy is retained as historical context only.
Each phase ends by passing the **Quality Gate** below before the next
phase begins.

## Current Status

> **In progress: migration cleanup for shipped components (status as of 2026-05-19).**
>
> Landed and verified locally:
> - **Legacy native phases 0–5** — ADRs `0006`–`0016`, package shell,
>   native component helpers, showcase scaffold, Tailwind v4 source,
>   parity harness, and current wrapped/input components. These remain
>   as migration scaffolding.
> - **Phase 0 runtime pivot** — [ADR 0017](decisions/0017-full-runtime-port.md)
>   accepted. Future implementation follows the full runtime plan in
>   [`docs/agent-plans/2026-05-12-full-port-architecture.md`](agent-plans/2026-05-12-full-port-architecture.md).
> - **Phase 1 foundation slice 1** — internal R runtime payload and
>   update-message helpers, package-local `shinyblocks-runtime.css/js`,
>   root dependency attachment, frontend source scaffold, runtime build
>   targets, scoped mount markup, browser smoke-test scaffold, and
>   focused runtime/dependency tests.
> - **Phase 1 foundation slice 2** — runtime CSS static isolation
>   tests, forbidden host-selector checks, runtime asset existence
>   checks, and runtime JS/CSS raw+gzip reporting in `tools/budget.R`.
> - **Phase 1 foundation slice 3** — `block_page()` emits the
>   package-owned portal root, runtime mounts without Shiny input ids
>   get unique ids, and static runtime JS tests cover Shiny bridge,
>   dynamic UI, Shiny child binding, and portal setup hooks.
> - **Phase 1 browser smoke** — `npm run test:runtime` passes when
>   Playwright can launch Chrome outside the Codex command sandbox.
> - **Phase 1 Shiny browser fixture** — `npm run test:runtime-shiny`
>   launches a Shiny app and verifies runtime input initialization,
>   server updates, disabled state, dynamic `renderUI()` removal and
>   reinsertion, and Shiny children inside runtime mounts.
> - **Phase 1 insert/remove fixture** — the Shiny browser fixture also
>   verifies explicit `insertUI()` / `removeUI()` and id reuse.
> - **Phase 1 input-update fixture** — the Shiny browser fixture now
>   verifies clear/reset updates, enable-after-disable, stale update
>   rejection, and Shiny module namespacing.
> - **Phase 1 collision/widget fixture** — the Shiny browser fixture
>   verifies host Bootstrap-style selectors, Selectize-style selectors,
>   bslib card markup, DT tables, plotly-style htmlwidget hosts,
>   htmlwidget children inside runtime mounts, and pre-existing portal
>   content are not reset by runtime CSS.
> - **Phase 1 React bundle foundation** — runtime JavaScript now builds
>   through Vite with React/ReactDOM `createRoot()`. Runtime mounts keep
>   a dedicated React slot separate from `data-shinyblocks-children`
>   so Shiny outputs and htmlwidgets remain under Shiny's binding
>   lifecycle.
> - **Phase 1 scoped tokens** — default runtime token values are scoped
>   to `[data-shinyblocks-root]` and `[data-shinyblocks-portal-root]`,
>   with static checks blocking accidental `:root` token writes and a
>   browser fixture proving host-page tokens remain untouched.
> - **Phase 1 runtime budgets** — ADR 0017 records measured runtime
>   JS/CSS baselines and `tools/budget.R` now enforces Phase 1 ceilings
>   for raw and gzipped runtime assets.
> - **Phase 2 presentational spike** — `block_button()` and
>   `block_badge()` emit runtime payloads and render in React.
>   Button keeps variant, size, icon, custom class, disabled, and
>   passthrough-attribute contracts; Badge keeps variant and custom
>   class contracts. Native Badge CSS has been removed from the legacy
>   stylesheet.
> - **Phase 2 stateful spike** — `block_select()` emits a runtime
>   payload instead of Shiny/selectize markup, and
>   `update_block_select()` covers value, choices, placeholder,
>   disabled state, clear, and `notify` semantics. Obsolete
>   `.sb-select` / Selectize compatibility CSS has been removed from
>   the legacy stylesheet.
> - **Phase 3 presentational slice 1** — `block_separator()` now
>   renders through the package-local runtime with scoped separator
>   styles and updated shell/runtime smoke coverage.
> - **Phase 3 presentational slice 2** — `block_spinner()` now renders
>   through the package-local runtime with scoped spinner animation and
>   updated shell/runtime smoke coverage.
> - **Phase 3 presentational slice 3** — `block_skeleton()` now renders
>   through the package-local runtime while preserving passthrough
>   attributes and scoped skeleton animation.
> - **Phase 3 presentational slice 4** — `block_empty()` now renders
>   through the package-local runtime while preserving icon/content/
>   action composition and scoped empty-state styles.
> - **Phase 3 presentational slice 5** — `block_value_box()` now renders
>   through the package-local runtime while preserving title/value/
>   description/icon/content composition and scoped metric-tile styles.
> - **Phase 3 presentational slice 6** — `block_alert()` now renders
>   through the package-local runtime while preserving role/variant/
>   icon/title/description/content composition and scoped alert styles.
> - **Phase 3 presentational slice 7** — `block_card()` now renders
>   through the package-local runtime. Card body flows through
>   `[data-shinyblocks-children]`, preserving Shiny binding lifecycles
>   for nested outputs/widgets/inputs. Legacy `.sb-card*` Tailwind rules
>   removed; runtime CSS owns card styling under `[data-shinyblocks-root]`.
> - **Phase 4.1 dialog skeleton** — `block_dialog()` lands as a modal
>   portal-rendered through `[data-shinyblocks-portal-root]`, with title,
>   description, and a serialized body. Initial open state only.
> - **Phase 4.2 dialog Shiny integration** — `block_dialog()` reports its
>   open/closed state to `input$<id>` through the `shinyblocks.dialog`
>   input binding. New `update_block_dialog()` updater changes open state,
>   title, and description from the server with explicit `notify`
>   semantics. A trigger button label argument auto-renders a default
>   `sb-button` that opens the dialog locally.
> - **Phase 4.3 dialog accessibility** — `block_dialog()` now traps focus
>   inside the modal, closes on Escape, returns focus to the previously
>   active element on close, locks body scroll with scrollbar-width
>   compensation, and exposes proper ARIA wiring
>   (`role="dialog"`, `aria-modal`, `aria-labelledby`, `aria-describedby`).
>   New `hide_title = TRUE` hides the title visually while keeping it as
>   the accessible name; the trigger advertises `aria-haspopup` and
>   `aria-expanded`.
> - **Phase 4.4 dialog variants + slots** — `block_dialog()` gains a `size`
>   argument (`"sm"` / `"default"` / `"lg"` / `"xl"`) mapping to content
>   max-width presets and a `footer` slot rendering action buttons in a
>   right-aligned wrapping flex row. `update_block_dialog()` learns
>   matching `size` and `footer` arguments (with `footer = NULL` clearing
>   an existing footer). The dialog showcase is rewritten as the canonical
>   interactive playground (preview + UI Definition + Server Action
>   panels + Content/State/Styling/Actions controls + API Reference).
> - **Phase 5.2 popover binding + updater** — `block_popover()` now
>   supports optional Shiny input binding when `id` is supplied, and
>   `update_block_popover()` can update `open`, `trigger`, `body`,
>   `side`, `align`, `style`, and `class` via runtime input messages.
>   The showcase and runtime Shiny fixture both exercise server-driven
>   popover updates.
> - **Phase 5.3 popover interactions** — popover now closes on Escape
>   and pointer-down outside, returns focus to the trigger on close, and
>   is covered by runtime Shiny smoke checks for dismiss and server
>   update flows.
> - **Phase 5.4 checkbox runtime migration** — `block_checkbox()` now
>   renders through the package runtime with a hidden native checkbox,
>   a dedicated `shinyblocks.checkbox` input binding, and runtime Shiny
>   smoke coverage for value toggling and native-input sync.
> - **Phase 5.4 checkbox parity hardening** — checkbox runtime structure
>   and scoped CSS now align with current shadcn visual contract (single
>   control box, compact indicator, checked/focus/invalid states, and
>   label click behavior) without leaking legacy checkbox pseudo-element
>   styling into runtime mounts.
> - **Phase 5.5 switch runtime migration** — `block_switch()` now
>   renders through the package runtime with a hidden native checkbox,
>   a dedicated `shinyblocks.switch` input binding, and
>   `update_block_switch()` for checked/disabled/style/class updates
>   with optional Shiny notify semantics.
> - **Phase 5.6 popover/checkbox/switch cleanup** — removed the dead
>   pre-runtime `boolean_control_input()` helper and the legacy
>   `.sb-checkbox-*`/`.sb-switch-*` rules from
>   `inst/www/src/shinyblocks.css` now that all three controls render
>   through scoped runtime CSS under `[data-shinyblocks-root]`.
>   Component specs aligned to a common status header.
> - **Phase 5.7 textarea runtime migration** — `block_textarea()` now
>   renders through the package runtime with a hidden native
>   `<textarea>`, a dedicated `shinyblocks.textarea` input binding
>   (debounced 250 ms), a new `invalid` argument, and
>   `update_block_textarea()` for value/placeholder/rows/disabled/
>   invalid/style/class updates with optional Shiny notify semantics.
>   Legacy `.sb-textarea` rules removed from
>   `inst/www/src/shinyblocks.css`.
> - **Phase 5.8 text input** — introduced `block_input()` and
>   `update_block_input()`. Single-line runtime input with hidden
>   native `<input>`, `shinyblocks.input` binding (debounced 250 ms),
>   `type` (text/password/email/url/tel/search/number), `invalid`
>   flag, and full server updater for
>   value/placeholder/type/disabled/invalid/style/class.
> - **Phase 5.9 radio group** — introduced `block_radio_group()` and
>   `update_block_radio_group()`. Runtime radio group with hidden
>   native `<input type="hidden">`, `shinyblocks.radio-group`
>   binding, arrow-key navigation, `orientation` (vertical/
>   horizontal), `invalid` flag, and a server updater covering
>   selected/choices/disabled/invalid/orientation/style/class.
> - **Phase 5.10 slider runtime migration** — `block_slider()` now
>   renders through the package runtime instead of
>   `shiny::sliderInput()` / ion.rangeSlider, with a hidden native
>   `<input>`, dedicated `shinyblocks.slider` binding, single-value and
>   range support, pointer/keyboard interaction, `invalid` and `style`
>   args, and `update_block_slider()` for value/min/max/step/disabled/
>   invalid/style/class server updates. Follow-up fixes aligned the
>   Slider API Reference table with the Input table pattern and changed
>   package-local asset dependency versions to include file mtimes so a
>   restarted showcase app does not keep stale runtime CSS/JS paths.
> - **Phase 5.11 input group ownership cleanup** —
>   `block_input_group()` and `block_input_group_addon()` are explicitly
>   classified as R-side composition/layout primitives, not standalone
>   runtime input bindings. The showcase and shell tests now compose the
>   group with runtime `block_input()`, and the source stylesheet includes
>   group-specific runtime input merge rules while keeping raw Shiny input
>   compatibility as migration scaffolding.
> - **Phase 5.12 tabs ownership cleanup** — `block_tabs()` no longer
>   wraps `shiny::tabsetPanel()` or decorates Bootstrap tab markup. It now
>   emits package-owned triggers and panels, keeps local keyboard/selection
>   behavior in `shinyblocks.js`, and pushes selected values to Shiny via
>   `input$<id>` without `nav-link`, `tab-pane`, or `shiny-tab-input`
>   dependencies in the rendered contract.
> - **Phase 5.13 field ownership cleanup** — `block_field_*()` remains
>   package-owned R-side composition for labels, descriptions, fieldsets,
>   and invalid messaging. The last live examples/tests using raw Shiny
>   text inputs inside fields were migrated to runtime controls, and the
>   legacy raw-input styling under `.sb-field` was removed from the source
>   stylesheet.
> - **Phase 6 helper cleanup — dark mode toggle** —
>   `block_dark_mode_toggle()` now delegates to the shipped runtime
>   `block_button()` contract and keeps only theme-toggle-specific icon
>   swap behavior. It is no longer a reason to retain legacy
>   `.sb-button*` CSS outside the runtime.
> - **Phase 6 helper cleanup — page/theme portal scope** —
>   `block_page()` now keeps the owned runtime portal root inside the
>   `.sb-app` shell so `block_theme()` page-scoped token overrides also
>   reach overlay/select portal content.
> - **Phase 6 helper cleanup — sidebar/nav composition** —
>   `block_sidebar()` now reuses a provided `block_nav()` container
>   instead of nesting a second nav landmark around it, while still
>   wrapping direct `block_nav_item()` children into one sidebar nav
>   region.
> - **Phase 6 helper cleanup — icon manifest contract** —
>   `block_icon()` now reads the curated icon list from
>   `inst/www/icons/MANIFEST.json` directly instead of scraping the
>   generated sprite for names; the manifest is the R-side source of
>   truth and the sprite remains the build artifact.
> - **Phase 5.12 verification** — latest checks passed:
>   `make build-css`, `Rscript -e "devtools::document()"`,
>   `Rscript -e "devtools::test(filter = 'tabs|shell|runtime|showcase|doc-coverage')"`,
>   `npm run test:runtime`, `npm run test:runtime-shiny`,
>   `npm run test:showcase`, and `make legacy-audit`. The local
>   showcase was fully restarted after JS/CSS/showcase edits.
> - **Parity gate cleared (2026-05-18)** — `make parity-ci` is fully
>   green across all nine registered components (alert, badge, button,
>   checkbox, select, separator, slider, switch, textarea). Issues
>   #2–#8 closed. Resolution touched runtime CSS (select trigger
>   bg/padding/focus-shadow, textarea shadow/line-height, separator
>   vertical-mount flex stretch), parity references aligned to current
>   shadcn New York v4 source (select / switch / checkbox / textarea),
>   the parity normaliser (collapse `display: flex|inline-flex`,
>   `border-radius: pill`, `min-height: 0|auto`), and a harness bug
>   where `page.goto` to the same URL with same hash was doing
>   SPA-style hash navigation instead of a full reload (fixed with
>   `about:blank` between captures).
> - **Phase 3 cleanup gate (post-migration)** — removed ~110 lines of
>   dead legacy CSS from `inst/www/src/shinyblocks.css` for the six
>   fully-migrated presentational components (alert, value-box,
>   separator, skeleton, spinner, empty) plus the stale
>   `.sb-checkbox-indicator`/`.sb-switch-track`/`.selectize-*`
>   invalid-state selectors. `.sb-button*` legacy CSS is no longer kept
>   alive by `block_dark_mode_toggle()`; remaining retention should be
>   treated as shell/showcase cleanup debt only.
> - **Showcase reorganization (2026-05-18)** — split the umbrella
>   **Field** tab. **Switch** gets its own full interactive playground
>   with `update_block_switch()` Actions. **Input group** gets its own
>   variant-style tab. The seven `block_field*()` helpers continue to
>   appear transitively through every form tab (textarea, switch,
>   input, radio_group, etc.). Parity fixtures relocated from the
>   defunct field section into the owning component tabs
>   (`#select`, `#checkbox`, `#switch`, `#textarea`) and the parity
>   registry was updated accordingly.
> - **Phase 4 overlay slice — `block_tooltip()` (2026-05-18)** —
>   hover- and focus-triggered text overlay rendered through the
>   runtime React layer. `side` (default `"top"`), `align`,
>   `delay_duration` (default 700 ms), `Escape` close, portal
>   rendering via `[data-shinyblocks-portal-root]`, primary-toned
>   styling per shadcn. No Shiny input binding (purely presentational).
>
> Historical native work already landed:
> - **Phase 1** — package shell, Tailwind v4 source, committed compiled
>   CSS, dependency plumbing, showcase scaffold, and core package
>   infrastructure.
> - **Phase 2** — `block_icon()`, `block_button()`, `block_badge()`,
>   `block_alert()`, `block_alert_title()`, `block_alert_description()`,
>   plus showcase/docs/test coverage.
> - **Phase 3** — `block_card()` composition primitives,
>   `block_value_box()`, `block_separator()`, `block_skeleton()`,
>   `block_spinner()`, and `block_empty()`.
> - **Phase 4** — `block_nav()`, `block_nav_item()`, collapsible
>   `block_sidebar()`, page-level sidebar state, and
>   `inst/www/shinyblocks.js` for desktop collapse, mobile open/close,
>   backdrop click, outside click, `Escape`, and nav keyboard movement.
> - **Phase 5 legacy slice** — `block_field_group()`, `block_field()`,
>   `block_field_label()`, `block_field_description()`,
>   `block_field_set()`, `block_field_legend()`,
>   `block_field_invalid()`, `block_input_group()`,
>   `block_input_group_addon()`, `block_select()`, `block_textarea()`,
>   `block_checkbox()`, `block_switch()`, `block_tab()`, `block_tabs()`,
>   `block_theme()`, `block_dark_mode_toggle()`, and
>   `update_block_theme()`.
>
> Current natural-next work (migration scope only):
> - Phase 5 remaining cleanup — audit stale wrapped-input and
>   Bootstrap-tab assumptions out of the docs/decision stack, and
>   remove any now-dead notes/tests/scaffolding that audit reveals.
> - Phase 6 shipped-helper cleanup — finish runtime/shell cleanup for
>   already-exported helpers such as `block_page()`, `block_sidebar()`,
>   `block_nav()`, `block_icon()`, `block_dark_mode_toggle()`, and
>   `block_theme()` / `update_block_theme()`.
> - Remaining overlay additions are explicitly deferred until the
>   migration/cleanup of shipped components is complete.
>
> **Component-by-component hand-off:** after button and select are
> accepted, proceed one component at a time. Each slice should
>
> 1. Read [ADR 0017](decisions/0017-full-runtime-port.md).
> 2. Read the runtime plan:
>    [`docs/agent-plans/2026-05-12-full-port-architecture.md`](agent-plans/2026-05-12-full-port-architecture.md).
> 3. Choose exactly one component and keep the write set vertical:
>    R API/runtime payload, CSS/runtime source if needed, showcase
>    documentation, component spec/docs, NEWS/pkgdown reference when
>    public behavior changes, and focused tests.
> 4. Prefer direct failures over compatibility fallbacks. Normalize data
>    at the R boundary, keep runtime payload shapes strict, and avoid
>    duplicate parsing in JavaScript unless the component genuinely needs
>    browser-only state.
> 5. Run the targeted checks for that component, start the local showcase,
>    and stop for manual approval before beginning the next component.
>
> Slices, in order:
>
> 1. **Runtime foundation** — no user-facing component migration yet.
> 2. **Vertical runtime spike** — `block_button()`, `block_badge()`,
>    and `block_select()`, including showcase pages, Shiny update
>    examples, scoped CSS, bundle-size reporting, and native cleanup.
> 3. **Presentational components** — migrate low-risk visual
>    components and remove their native CSS/tests.
> 4. **Overlay/menu cleanup for shipped helpers** — finish portal/focus
>    cleanup on existing overlay components.
> 5. **Forms and controls** — finish migration cleanup of shipped
>    stateful controls and their updater examples.
> 6. **Layout, navigation, icons, theme** — finish shell decisions and
>    remove obsolete compatibility assets for already-exported helpers.
> 7. **Parity/spec/docs reset** — verification targets shipped runtime
>    behavior and upstream sync drift, not native CSS translation.

Update this line at every phase exit.

## Quality Gate (Every Phase)

No phase is complete until every step below passes, **in this order**.
Order matters: cheap automated checks run first. The gate is runnable
as `make gate`.

### A. Verify — automated

1. **Build pipeline.** `make build-css` clean; committed CSS matches
   source (CI drift check).
2. **Lint.** `lintr::lint_package()` clean.
3. **Spelling.** `devtools::spell_check()` clean. New jargon →
   `inst/WORDLIST`.
4. **URLs.** `urlchecker::url_check()` clean.
5. **Latest-version verification.** All versioned inputs touched in
   the phase checked against authoritative sources. Recorded in the
   relevant ADR, sync log, or phase-exit file.
6. **Tests.** `devtools::test()` clean. Every migrated component has
   payload, validation, ARIA/state, updater/lifecycle tests where
   applicable, plus a component page/section in `inst/showcase/`
   enforced by `test-showcase.R` (see [§Showcase App](#showcase-app)).
7. **Documentation.** `devtools::document()` no warnings. Generated
   `man/` committed.
8. **Package check.** `devtools::check(remote = TRUE, manual = FALSE)`
   clean. Full manual PDF checks are release-gate only.
9. **pkgdown.** `pkgdown::build_site()` succeeds. New components have
   both an auto-generated reference page **and** a gallery page under
   `gallery/components/` per [ADR 0013](decisions/0013-component-gallery-quarto.md).
10. **Multi-artifact coverage.** `test-doc-coverage.R` is green —
    every exported `block_*()` is referenced in `_pkgdown.yml`'s
    `reference:` section, and once WASM is unblocked, also has a
    matching gallery `.qmd` page. See
    [§Per-gate component-sync rule](#per-gate-component-sync-rule).
11. **Runtime verification.** Runtime browser tests, scoped-CSS
    collision fixtures, and any still-relevant parity/upstream-sync
    checks pass. Native CSS parity baselines are removed as their
    components migrate to the runtime.

### B. Verify — semi-automated

12. **Showcase smoke test.** `shinytest2` launches
    `inst/showcase/app.R`, navigates every section, and
    `expect_screenshot()`s each. From Phase 1C onward, also run
    Shinylive export smoke.
13. **Performance budget.** `tools/budget.R` reports runtime JS/CSS
    raw and gzip size, compatibility CSS/JS while they remain, icon
    assets, and per-slice deltas. Budgets are set by ADR 0017 and the
    Phase 1/2 size baselines. Over budget = blocking unless ADR'd.
14. **Accessibility sweep.** Manual keyboard/screen-reader smoke on
    the showcase. Findings → `docs/a11y/notes.md`.


### C. Review

17. **Roxygen audit.** `@param`, `@return`, `@export`, `@examples`,
    `@family` on every exported function. `@noRd` on internals.
18. **Utility audit.** No copy-pasted helpers across `R/*.R`.
19. **Critical code review.** `critical-code-reviewer` skill against
    the phase diff.

### D. Document

20. **NEWS.md.** User-visible changes under next dev-version heading.
21. **`docs/` updates.** Roadmap status, strategy/ADR amendments,
    sync-log entries, cross-link check.

### E. Version and tag

22. **Version bump.** `0.0.0.9000 → 9001 → 9002 → ...`; Phase 7 →
    `0.1.0`.
23. **Single tidy commit on main.**
24. **Git tag.** `git tag phase-N`.
25. **CI green on main.**

### F. Optional from Phase 5 onward

26. **Deployed showcase refresh.**

## Local Preview Workflow

Run this any time you want to *see* the work — not just at phase exit.
After every component slice is a good cadence; before opening a PR is
the minimum.
Always fully restart the showcase app after editing runtime JS/CSS,
showcase server wiring, or component update handlers; do not rely on a
previous in-memory Shiny process to pick up those changes correctly.
During active development, prefer `make showcase` (which uses
`devtools::load_all(".")`) so the app reflects the current checkout.
`shinyblocks::run_showcase()` launches the installed package copy and
requires reinstalling to pick up local file edits.
In Codex-style sandboxed sessions, the app may print `Listening on
http://127.0.0.1:4321` and then fail with `createTcpServer: operation
not permitted`. Treat that as a sandbox port-bind limitation, not an app
bug: rerun the restart outside the sandbox / with escalation, then
verify the port with `curl -sSI http://127.0.0.1:4321/`.

| Command | Serves | Port | When to run |
| --- | --- | --- | --- |
| `make showcase` | Live showcase app | 4321 | After any new `block_*()` to eyeball it. |
| `make preview-pkgdown` | Built pkgdown site | 4322 | After `devtools::document()` — confirms reference pages render. |
| `make gallery` | Quarto-rendered component gallery | 4324 | After editing any `gallery/components/*.qmd`. |
| `make preview-shinylive` | Static Shinylive export | 4323 | From Phase 1C onward, once `tools/export-shinylive.R` lands. |
| `make preview` | Showcase + pkgdown together | 4321 + 4322 | Foreground; Ctrl+C to stop. |

What to actually look at:

1. **Showcase (`http://127.0.0.1:4321`)** — every component section
   renders, light/dark mode toggle works, no console errors, no
   broken icons, no layout shift on hover/focus.
2. **pkgdown (`http://127.0.0.1:4322`)** — reference index lists
   every exported function, each page has examples that render,
   the category grouping in `_pkgdown.yml` matches the strategy
   doc.
3. **Shinylive (`http://127.0.0.1:4323`)** — static export loads in
   a fresh tab, dark mode works, no asset 404s in the network tab.

If any of those fail the eyeball check, fix before opening a PR or tagging a phase exit.

## Phase Exit Process

Each exit is recorded in `docs/phase-exits/phase-N.md` (copied from
`docs/phase-exits/TEMPLATE.md`). Commit when all green.

## When Things Go Wrong

Non-obvious problems → postmortem under
[`docs/dev-notes/`](dev-notes/README.md). User-facing fixes →
[`docs/troubleshooting.md`](troubleshooting.md).

## Continuous Tracks

Four artifacts grow with every phase. Details live in
[ADR 0017](decisions/0017-full-runtime-port.md), the
[runtime plan](agent-plans/2026-05-12-full-port-architecture.md), and
[ADR 0013](decisions/0013-component-gallery-quarto.md):

- **pkgdown site** — category-grouped reference. Auto-generated from
  roxygen. CI builds it; a failed build blocks the phase.
- **Component gallery** — Quarto `.qmd` pages under
  `gallery/components/`, modelled on
  <https://shiny.posit.co/r/components/>. One page per exported
  component, embedded Shinylive demo + visible source. See
  [§Components Gallery](#components-gallery).
- **Showcase app** — `inst/showcase/`, launchable via
  `run_showcase()`. Dogfooded — its own UI is built with shinyblocks
  primitives. Sidebar filters one component at a time. Authoring
  contract enforced by `test-showcase.R`. See
  [§Showcase App](#showcase-app). Hosted version exported via
  Shinylive to `site/showcase/`.
- **Runtime verification** — browser tests, scoped-CSS collision
  fixtures, Shiny state/update tests, bundle-size reports, and any
  still-relevant upstream-sync/parity checks. ADR 0016 remains useful
  for historical native parity and upstream drift ideas, but migrated
  runtime components are verified against shipped runtime behavior.

## Components Gallery

The gallery is the visual spine of the docs. Every exported `block_*()`
gets one `.qmd` page with this fixed shape (the same shape
shiny.posit.co/r/components uses):

1. YAML front matter (`title`, optional `description`).
2. Lead paragraph (1–2 sentences).
3. `{shinylive-r}` fence with `#| standalone: true`,
   `#| components: [viewer]`, `#| viewerHeight:` (component-specific),
   body via `{{< include _examples/<component>.R >}}`.
4. Plain `r` fence showing the same code (same include — single
   source).
5. **Relevant Functions** — bulleted list of signature lines linking
   to the auto-generated reference page.
6. **Details** — short prose, optionally a numbered list.
7. **See also** — sibling components and any related vignettes.

### Layout

```
gallery/
├── components.qmd                    # gallery landing
└── components/
    ├── _examples/<component>.R       # canonical Shiny app per component
    └── <component>.qmd               # one per exported block_*()
```

Each `_examples/*.R` is a complete runnable Shiny app with
`library(shiny)`, `library(shinyblocks)`, `ui <-`, `server <-`,
`shinyApp(...)`. It is the single source of truth — included twice in
the `.qmd` (live demo + visible code).

### Build

- `make quarto-setup` — one-shot install of Quarto +
  `quarto add quarto-ext/shinylive`. Run once per machine.
- `make gallery` — render `gallery/` and serve the result.
- `make pkgdown` — full pkgdown site, which renders the gallery as
  part of the articles section when Quarto is installed.

### Adding a component to the gallery

When a new `block_*()` is exported, the same commit must add:

1. `gallery/components/_examples/<component>.R` — runnable
   Shiny app demonstrating the default and one or two interesting
   variants.
2. `gallery/components/<component>.qmd` — using the
   template above.
3. An entry in `gallery/components.qmd` (the gallery index
   landing page).
4. The category mapping in `_pkgdown.yml` `articles:` for navbar
   grouping.

Pages that ship without a gallery entry block the Quality Gate.

## Showcase App

The dogfooded showcase under `inst/showcase/` is the second consumer
of every component. It is a single-page Shiny app whose own UI is
built entirely with `shinyblocks` — `block_page()`, `block_sidebar()`,
`block_header()`, `block_body()`, `block_nav_item()`. Clicking a
sidebar item filters the body to that one section so each component
renders in isolation; the URL hash deep-links the active section.

It exists for two reasons: (1) the package documents itself by *being*
a shinyblocks dashboard; (2) it is a fast verification surface for the
maintainer — far cheaper than rebuilding the Quarto gallery to confirm
a CSS change.

### Layout

```
inst/showcase/
├── app.R                            # block_page shell + sections list
└── R/
    ├── render_example.R             # eval an example file -> tag + code
    ├── section.R                    # sb_section() helper, hides non-active
    └── examples/<component>.R       # tag/tagList per component
```

The `sections` list at the top of `app.R` drives both the sidebar nav
and the body — one row per component, each pointing at its example
file under `R/examples/`.

### Authoring contract

When a new `block_*()` is exported, the same commit must add:

1. `inst/showcase/R/examples/<component>.R` — an **interactive
   playground** following the standard layout (preview at top;
   two-column split below with `input$` value + UI Definition + Server
   Action code blocks on the left and Content / State / Actions /
   Styling controls on the right; API Reference table at the bottom).
   See `select.R` and `dialog.R` as canonical references, and the
   `shinyblocks-component` skill's "Showcase playground layout" step
   for the full template. This full layout is mandatory for every
   component section; do not ship minimal/static demos.
2. `inst/showcase/R/server_<component>.R` — a
   `register_<component>_showcase(input, output, session)` function
   wiring the five standard outputs (`*_preview_ui`, `*_preview_value`,
   `*_preview_code`, `*_reactive_code`, `*_api_table`) plus an
   observer per action button that drives the visible preview, calls
   `update_block_<name>()`, and updates the `reactive_code`
   `reactiveVal`. Source it and call the register function from
   `inst/showcase/app.R`. Every section must expose the same control
   families: Content, State, Actions (Server Update), and Styling
   (`style` and `class`). Controls must cover the component's full
   public constructor surface (all user-facing args). If an
   `update_block_*()` helper exists, the Actions panel is mandatory and
   should demonstrate the updater contract (for example set/clear,
   disable/enable, plus one structural/content mutation where relevant).
3. A row in the `sections` list in `inst/showcase/app.R` (id, label,
   icon, title, lead, file). The `lead` is a one-sentence current-state
   description — no phase numbers, no "skeleton — to be expanded
   later" placeholders.
4. Update `inst/showcase/www/showcase.css`: add
   `#showcase_<component>_api_table` to the three rule blocks that
   style the API tables (monospace first three columns, muted header,
   border-bottom rows), and add any `.showcase-<component>-preview-custom`
   demo class referenced by the playground's `class` checkbox.
5. Run `make showcase` and eyeball it. The new section should appear
   in the sidebar, render correctly when selected, and deep-link via
   `#<id>`. The API table should match the other components visually.

`tests/testthat/test-showcase.R` enforces this contract end-to-end —
exporting a new `block_*()` without referencing it from the showcase
fails the test suite. Specifically the suite asserts:

- Every file under `inst/showcase/R/examples/` evaluates to a
  `shiny.tag` or `shiny.tag.list`.
- Every section in the `sections` list has a matching
  `data-sb-section` element and a matching `href="#..."` sidebar link
  in the rendered UI.
- Every exported `block_*()` has a page/section marker unless it is
  intentionally internal to another documented component family.
- Reactive component pages include server/update examples.
- The first section is rendered visible; all others render with the
  `hidden` attribute so the JS filter has a stable starting state.

Components that are emitted transitively (e.g. `block_body` via
`block_page`) still appear in the rendered HTML through their parent
and need no separate section. The showcase coverage test should use
component metadata/page markers rather than `.sb-*` visual classes as
components migrate to the runtime.

## Per-gate component-sync rule

When a phase-exit slice adds, renames, or removes any exported
`block_*()`, the following five artifacts must be in sync **in the
same commit** that lands the API change:

| Artifact | What goes in | Enforced by |
| --- | --- | --- |
| `inst/showcase/` | Full interactive playground per component: preview, input value, UI Definition, Server Action, Content/State/Actions/Styling controls, API Reference | `test-showcase.R` |
| `_pkgdown.yml` `reference:` | Function under the matching category | `test-doc-coverage.R` |
| `gallery/components/*.qmd` | Page following the [§Components Gallery](#components-gallery) template | `test-doc-coverage.R` (currently `skip()`'d — see below) |
| `docs/component-specs/<name>.md` | Runtime mapping, props/slots, Shiny state/update contract, accessibility requirements, scoped-CSS notes, and deliberate divergences | `test-doc-coverage.R` |
| `NEWS.md` | One bullet under the dev-version heading | Quality Gate item 19 |

A drifted artifact fails the Quality Gate. The first four are
mechanically checked; `NEWS.md` is reviewer-checked at gate exit.

The component spec is the anchor for runtime verification: the reviewer
walks every state listed in the spec against the live showcase, and
automated checks cover runtime behavior, scoped CSS, upstream sync drift,
and bundle-size changes.

### Gallery exception during the WASM hold

[ADR 0013](decisions/0013-component-gallery-quarto.md) requires a
gallery `.qmd` per component, but live demos depend on a webR-loadable
shinyblocks binary at `repo.r-wasm.org`. The path-B WASM build was
deferred — the gallery currently has only `button.qmd`. The matching
test in `test-doc-coverage.R` is `skip()`'d with a pointer to ADR 0013.

When WASM lands:

1. Drop the `skip()` call in `test-doc-coverage.R`.
2. Author one `.qmd` page (and matching `_examples/<component>.R`)
   per exported `block_*()` so the test passes.
3. Update `_pkgdown.yml` `articles:` to list every page.

Until then, the showcase is the visual verification surface.

---

## Runtime Phase 0 — Decisions

Done: [ADR 0017](decisions/0017-full-runtime-port.md) adopts the full
runtime port and supersedes the earlier native-CSS/wrap-by-default path
where it conflicts.

## Runtime Phase 1 — Foundation

Goal: prove the runtime substrate before any user-facing component is
migrated.

- `frontend/` build scaffold.
- Scoped runtime CSS without Tailwind preflight.
- Package-local runtime JS/CSS under `inst/www/`.
- `shinyblocks_dependency()` attaches runtime assets once.
- Runtime mount protocol and versioned payload schema.
- Shiny input/update bridge with `notify`, revision ids, namespacing,
  and stale-message handling.
- Dynamic UI lifecycle for initial UI, `renderUI()`, `insertUI()`,
  `removeUI()`, and id reuse.
- Portal root under `[data-shinyblocks-portal-root]`.
- Shiny child-binding fixture for outputs, htmlwidgets, and nested
  inputs inside runtime-rendered containers.
- CSS collision fixtures for Bootstrap, bslib, DT/plotly/htmlwidgets,
  scoped tokens, and portals.
- Runtime size report for raw/gzipped JS and CSS.

Exit: the dummy runtime input/container proves scoped CSS, value sync,
server updates, disabled state, modules, dynamic UI, portals, and
Shiny children. Do not migrate real components before this exits.

## Runtime Phase 2 — Vertical Spike

Goal: migrate the smallest useful slice through one runtime path.

- `block_button()`
- `block_badge()`
- `block_select()`
- `update_block_select()`

Each gets a per-component showcase page/section. `block_select()` must
show read value, server update, choices update, disable/enable,
invalid/error set and clear, reset to `NULL`, and module namespacing.

Exit: native Button/Badge/Select CSS, tests, examples, and obsolete
parity baselines are removed or rewritten.

## Runtime Phase 3 — Presentational Components

Goal: move low-risk visual components to the runtime and remove their
native CSS contracts.

- `block_separator()`
- `block_skeleton()`
- `block_spinner()`
- `block_alert()` and alert slots
- `block_card()` and card slots
- `block_empty()`
- `block_value_box()` if retained

Exit: migrated components render through the runtime, have showcase
pages/sections with full customization examples, and no longer rely on
package-owned visual CSS.

## Runtime Phase 4 — Overlays and Menus

Goal: finish migration cleanup for the behavior-heavy overlay components
that already shipped. New overlay additions stay deferred until the
current exported surface is fully cleaned up.

- `block_dialog()` ✅ shipped (4.1 – 4.4)
- `block_popover()` ✅ shipped (5.1 – 5.3, naming legacy)
- `block_tooltip()` ✅ shipped (2026-05-18)
- Deferred: `block_dropdown_menu()`, `block_sheet()`,
  `block_drawer()`, `block_hover_card()`

Exit: portal, focus, Escape, outside-click, open-state, and removal
behavior come from the runtime and are covered by browser tests.

## Runtime Phase 5 — Forms and Controls

Goal: remove the wrapped-Shiny-control strategy for shadcn controls.

- `block_checkbox()`
- `block_switch()`
- `block_radio_group()`
- `block_textarea()`
- `block_slider()`
- `block_input()`
- `block_input_group()` and addons (R-side composition primitives around
  runtime controls, not standalone runtime bindings)
- `block_field_*()` (R-side composition primitives for labels, helper
  text, fieldsets, and invalid messaging)
- `block_tabs()` and `block_tab()` (package-owned R-side markup with a
  local Shiny value bridge)

Exit: controls use runtime input bindings and updater helpers. Old
Selectize, ion.rangeSlider, Bootstrap-tab, checkbox, switch, textarea,
and field visual override CSS/tests are gone. `block_input_group()` and
addons remain as R-side layout primitives where they compose migrated
runtime controls. `block_tabs()` remains R-side markup, but no longer
wraps Shiny/Bootstrap tabset output. `block_field_*()` remains R-side
composition instead of moving into the runtime.

## Runtime Phase 6 — Shell, Icons, and Theme

Goal: finish package-specific shell decisions and theme runtime.

- Decide which page/shell helpers remain R/htmltools-native.
- Move Sidebar/Nav behavior to runtime where practical.
- Decide sprite icons versus runtime icon library.
- Ensure `block_theme()` and `update_block_theme()` affect runtime
  components through scoped tokens.
- Keep remaining `.sb-*` selectors as shell hooks only.

Exit: no migrated component relies on package-owned visual CSS.

## Runtime Phase 7 — Parity, Specs, Docs, and Release

- Rewrite specs around R API, runtime mapping, props/slots, Shiny
  state/update contract, accessibility, and deliberate divergences.
- Convert parity checks to shipped runtime behavior, upstream sync
  drift, theme, scoped CSS, and browser behavior.
- Remove obsolete native parity baselines/screenshots.
- Finish README, pkgdown, vignettes, showcase, and gallery pages.
- Run the final package gate and tag `v0.1.0`.

## Local Preview Before Going Public

Before making the repository public, build and review locally:

1. **pkgdown site.** `make pkgdown` → browse `site/docs/index.html`.
2. **Shinylive showcase.** `make shinylive-export` → serve
   `site/showcase/` locally.
3. **Local showcase.** `shinyblocks::run_showcase()`.
4. **README & metadata.** No incomplete or internal references.

Only make the repo public once all four pass.

## Phase 7 — Hardening and Release

- Critical code review, a11y pass, cross-browser check.
- `R CMD check --as-cran` clean including manual/PDF.
- pkgdown + Shinylive deployed as one static site artifact.
- NEWS.md in user-facing voice. Tag `v0.1.0`.
- (Optional) CRAN submission.

## Post-v0.1 Candidates

Each requires its own ADR after the runtime port is stable.
