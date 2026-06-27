# Nav

> Shinyblocks function: `block_nav()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/sidebar>
> Status: R-side navigation container; Phase 7 spec refreshed around
> the shipped sidebar composition rule and runtime keyboard behavior.

## States

- **default** — `<nav class="sb-nav">` container for one or more
  `block_nav_item()` children. Validated at construction.
- **stacked** — renders a vertical navigation list with sidebar-safe
  spacing.
- **keyboard-enhanced** — when inside a sidebar, the package runtime
  enables Up/Down/Home/End traversal across child items.
- **sidebar-composed** — when passed as the single child of
  `block_sidebar()`, the existing `<nav>` is promoted to the sidebar
  navigation region (gets `.sb-sidebar-nav` merged into its class)
  instead of being wrapped inside another `<nav>` landmark.
- **nav-input** — when constructed with `id`, the `<nav>` carries
  `data-sb-nav-input-id` and becomes a Shiny input. The package runtime
  reports the selected `block_nav_item()` `value` as `input[[id]]`,
  moves the `is-selected` highlight on click, and calls
  `preventDefault()` so the item selects a page instead of following its
  href. `update_block_nav()` selects an item from the server (the
  `sb:nav` custom message), mirroring `block_tabs()` / `update_block_tabs()`.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | One or more `block_nav_item()` children. Other children fail validation. |
| `id` | Optional Shiny input id. When set, the selected item's `value` is reported as `input[[id]]`; pair with `shiny::conditionalPanel()` / `renderUI()` to switch pages and `update_block_nav()` to select from the server. |
| `class` | Extra classes for the `.sb-nav` element. |

## Page navigation pattern

```r
ui <- block_page(
  sidebar = block_sidebar(
    block_nav(
      id = "page",
      block_nav_item("Dashboard", value = "dashboard", selected = TRUE),
      block_nav_item("Users", value = "users")
    )
  ),
  block_body(
    conditionalPanel("input.page == 'dashboard'", dashboard_ui),
    conditionalPanel("input.page == 'users'", users_ui)
  )
)
```

## Stable shell hooks

`block_nav()` owns `.sb-nav` and contributes `.sb-sidebar-nav` when
composed inside `block_sidebar()`. These hooks are R-side navigation
contracts, not runtime component styling targets.

## Accessibility

- Rendered as `<nav>`.
- The sidebar composition rule avoids nested `<nav>` landmarks.
- Child `block_nav_item()` elements carry `aria-current="page"` when
  selected.

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
