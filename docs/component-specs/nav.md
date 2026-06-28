# Nav

> Shinyblocks function: `block_nav()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/sidebar>
> Status: R-side navigation container; Phase 7 spec refreshed around
> the shipped sidebar composition rule and runtime keyboard behavior.

## States

- **default** — `<nav class="sb-nav">` container for one or more
  `block_nav_item()`, `block_nav_group()`, or `block_nav_label()` children.
  Validated at construction.
- **stacked** — renders a vertical navigation list with sidebar-safe
  spacing.
- **keyboard-enhanced** — when inside a sidebar, the package runtime
  enables Up/Down/Home/End traversal across child items.
- **sidebar-composed** — when passed as the single child of
  `block_sidebar()`, the existing `<nav>` is promoted to the sidebar
  navigation region (gets `.sb-sidebar-nav` merged into its class)
  instead of being wrapped inside another `<nav>` landmark.
- **nav-input** — when constructed with `id`, the `<nav>` carries that
  `id` plus `data-sb-nav-input-id` and is registered as a real Shiny
  InputBinding (`shinyblocks.nav`). The runtime reports the selected
  leaf `block_nav_item()` `value` as `input[[id]]`, moves the `is-selected`
  highlight on click (a delegated handler that calls `preventDefault()`
  so the item selects a page instead of following its href), and re-binds
  inserted markup via `Shiny.bindAll`. `update_block_nav()` selects an
  item from the server through `sendInputMessage()` (routed by the
  element's DOM id), mirroring `block_tabs()` / `update_block_tabs()` and
  the runtime-component updaters.
- **grouped** — section labels and collapsible groups may structure the
  sidebar. Groups and labels never report input values; nested leaf item values
  must be non-empty and globally unique in an input nav.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | One or more `block_nav_item()`, `block_nav_group()`, or `block_nav_label()` children. Other children fail validation. |
| `id` | Optional Shiny input id. When set, the selected item's `value` is reported as `input[[id]]`; pair with `shiny::conditionalPanel()` / `renderUI()` to switch pages and `update_block_nav()` to select from the server. |
| `class` | Extra classes for the `.sb-nav` element. |

## Page navigation pattern

```r
ui <- block_page(
  sidebar = block_sidebar(
    block_nav(
      id = "page",
      block_nav_label("Workspace"),
      block_nav_item("Dashboard", value = "dashboard", selected = TRUE),
      block_nav_group(
        "Admin",
        block_nav_item("Users", value = "users")
      )
    )
  ),
  block_body(
    conditionalPanel("input.page == 'dashboard'", dashboard_ui),
    conditionalPanel("input.page == 'users'", users_ui)
  )
)
```

## Stable shell hooks

`block_nav()` owns `.sb-nav` and contributes `.sb-sidebar-nav` when composed
inside `block_sidebar()`. It accepts `data-sb-child` markers for `nav-item`,
`nav-group`, and `nav-label`. These hooks are R-side navigation contracts, not
runtime component styling targets.

## Accessibility

- Rendered as `<nav>`.
- The sidebar composition rule avoids nested `<nav>` landmarks.
- Child `block_nav_item()` elements carry `aria-current="page"` when selected.
- `block_nav_group()` triggers use disclosure button semantics and keep
  collapsed child regions hidden from the accessibility tree.

## Token contract

| Visual role | Token |
| --- | --- |
| Layout spacing | none (layout only; visual tokens are owned by `block_nav_item()`) |

## Deliberate divergences from shadcn

- `block_nav()` is an R-side validation wrapper; shadcn sidebar
  examples rely on composition inside React providers and menu primitives.

## Reference screenshot

![Nav](_screenshots/nav.png)

Captured from <https://ui.shadcn.com/docs/components/sidebar> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
