# Sidebar

> Shinyblocks function: `block_sidebar()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/sidebar>

## States

- **default** — bordered sidebar shell with title and nav region.
- **collapsible** — exposes a desktop collapse toggle and
  `data-collapsible="true"`.
- **collapsed** — starts in the desktop-collapsed state when
  `data-collapsed="true"`.
- **mobile-open** — page-level runtime opens the sidebar as a sheet
  with backdrop handling.
- **nav-composed** — when passed a `block_nav()` container, reuses that
  nav landmark instead of wrapping it in a second nested nav region.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Foreground | `--foreground` |
| Border | `--border` |
| Focus ring | `--ring` |

## Stable shell hooks

`block_sidebar()` owns `.sb-sidebar`, `.sb-sidebar-title`,
`.sb-sidebar-nav`, `.sb-sidebar-toggle`, and the page-level sidebar
state attrs. These hooks are package shell contracts for layout,
navigation, and responsive sidebar behavior only.

## Deliberate divergences from shadcn

- shinyblocks keeps the sidebar runtime small and page-scoped instead of
  porting the full React/sidebar provider model.
- `block_sidebar()` normalizes either direct `block_nav_item()` children
  or a provided `block_nav()` container into one sidebar navigation
  landmark, avoiding nested nav semantics.

## Reference screenshot

![Sidebar](_screenshots/sidebar.png)

Captured from <https://ui.shadcn.com/docs/components/sidebar> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
