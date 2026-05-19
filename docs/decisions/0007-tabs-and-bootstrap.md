# ADR 0007: Tabs and Bootstrap Coexistence

## Status

Superseded by [ADR 0017](0017-full-runtime-port.md) and the Phase 5.12
tabs ownership cleanup (2026-05-19)

## Superseded Note

This ADR documents the original native/wrapper strategy where
`block_tabs()` decorated `shiny::tabsetPanel()` / Bootstrap tab markup.
That is no longer the shipped direction. Keep this file only as
historical context for why the wrapper existed and what constraints it
was designed around.

## Context

shinyblocks provides `block_tabs()` as a primary navigation primitive.
shadcn/ui's `Tabs` model uses the structure
`Tabs > TabsList > TabsTrigger`, with `data-state="active|inactive"`
on each trigger and Floating-UI-driven keyboard behavior via Radix.

Shiny's `tabsetPanel()` provides the input binding shinyblocks needs
for reactive tab switching (`input$tab_id`). Since Shiny 1.7,
`tabsetPanel()` delegates HTML construction to `bslib::buildTabset()`,
emitting Bootstrap-flavored markup:

```html
<div class="tabbable">
  <ul class="nav nav-tabs shiny-tab-input" data-tabsetid="...">
    <li class="nav-item">
      <a class="nav-link [active]" data-bs-toggle="tab" data-value="...">...</a>
    </li>
  </ul>
  <div class="tab-content" data-tabsetid="...">
    <div class="tab-pane [active]" data-value="...">...</div>
  </div>
</div>
```

Validated against `rstudio/shiny` `main` (see strategy doc, Shiny
Integration Notes). The `BootstrapTabInputBinding` in compiled
`inst/www/shared/shiny.js` keys on:

- `ul.nav.shiny-tab-input` (find selector)
- `.nav-link.active` (active value)
- `data-value` (value attribute)
- `shown.bs.tab` (Bootstrap event for change subscription)

Removing or renaming any of these breaks tab reactivity AND tab
switching itself, because Bootstrap's own JS drives the `.active`
toggle.

## Decision

`block_tabs()` wraps `shiny::tabsetPanel()`. The wrapper is
**additive decoration only** — it does not restructure the markup.

```r
block_tabs <- function(..., id = NULL, selected = NULL, class = NULL) {
  panels <- shiny::tabsetPanel(..., id = id, selected = selected)
  htmltools::tagQuery(panels)$
    addClass("sb-tabs")$
    find("ul.nav")$
      each(\(x, i) htmltools::tagAppendAttributes(
        x, role = "tablist", `aria-orientation` = "horizontal"
      ))$
    find("a.nav-link")$
      each(\(x, i) htmltools::tagAppendAttributes(x, role = "tab"))$
    allTags()
}
```

CSS targets the existing Bootstrap classes plus our decoration:

```css
.sb-tabs .nav-link        { /* default tab styling */ }
.sb-tabs .nav-link.active { /* selected tab styling */ }
.sb-tabs .tab-content     { /* content styling */ }
```

`block_tab(label, value, ...)` is sugar over `shiny::tabPanel()` —
no behavioral changes, just consistent naming with the rest of the
package.

### Acknowledged transitive dependency

`tabsetPanel()` calls `bslib::buildTabset()` internally. shinyblocks
therefore has a runtime dependency on `bslib` once `block_tabs()`
ships. bslib ships with modern Shiny anyway. Reimplementing the tab
input binding from scratch is not worth the maintenance cost.

`DESCRIPTION` should list `bslib` under `Imports:` in the same phase
that implements `block_tabs()`. It does not need to be imported before
tabs exist.

### What we explicitly do NOT do

- Strip `shiny-tab-input`, `nav-link`, or `data-bs-toggle` classes.
- Replace `<ul>` with `<div>` or `[role="tablist"]` siblings.
- Mirror `.active` to a `data-state` attribute via MutationObserver.
  CSS targeting `.nav-link.active` works directly; the extra
  `data-state` is Radix idiom, not a hard requirement.
- Re-implement the tab input binding to remove the bslib pull.

## Bootstrap Coexistence

Shiny ships Bootstrap 5 by default (loaded via `bootstrapPage()` /
`fluidPage()` etc., NOT by individual inputs). shinyblocks does not
load Bootstrap itself; users who call `block_page()` get a
Bootstrap-free shell.

Mixed apps that load both shinyblocks and `fluidPage()` are
explicitly unsupported but won't catastrophically break:

- shinyblocks's CSS is loaded after Bootstrap and uses
  `.sb-app`-scoped selectors with sufficient specificity to win
  conflicts on shinyblocks-rendered components.
- Bootstrap-styled inputs and components retain their Bootstrap
  appearance unless explicitly wrapped in `block_field()` or
  `block_input_group()`.
- Mixing bslib, shinydashboard, or bs4Dash with shinyblocks is
  documented as not supported in `vignette("coexistence")`.

For tabs specifically, the bslib pull means Bootstrap's tab JS is
present whether or not the user loaded `fluidPage()`. shinyblocks
relies on this for `block_tabs()` to work.

## Consequences

- `block_tabs()` works out-of-the-box with `input$tab_id` exactly
  like `tabsetPanel()` — no input binding to maintain.
- Users who depend on the underlying markup (CSS targeting, JS
  inspection) see Bootstrap-flavored classes plus our `sb-tabs`
  decoration. Document this in the tabs reference page.
- Bootstrap's tab JS is loaded transitively. If a future ADR moves
  tabs off Bootstrap, this dependency vanishes.
- The wrapper is small and easily testable: tag-shape tests confirm
  `ul.nav.shiny-tab-input` is present, `role="tablist"` is added,
  and `data-bs-toggle` is preserved.

## References

- [strategy: Shiny Integration Notes — Tab markup is structurally fixed](../agent-plans/2026-05-08-port-strategy.md#shiny-integration-notes-validated-2026-05-08)
- `rstudio/shiny` `R/bootstrap.R` (~lines 668–685): `tabsetPanel()`
  → `bslib::navs_tab` dispatch.
- `rstudio/shiny` compiled `inst/www/shared/shiny.js`:
  `BootstrapTabInputBinding`.
- `rstudio/bslib` `R/navs.R`: `buildTabset()`.
