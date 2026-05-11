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

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Foreground | `--foreground` |
| Border | `--border` |
| Focus ring | `--ring` |

## Deliberate divergences from shadcn

- shinyblocks keeps the sidebar runtime small and page-scoped instead of
  porting the full React/sidebar provider model.

## Reference screenshot

![Sidebar](_screenshots/sidebar.png)

Captured from <https://ui.shadcn.com/docs/components/sidebar> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
