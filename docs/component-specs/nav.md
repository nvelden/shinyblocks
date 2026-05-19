# Nav

> Shinyblocks function: `block_nav()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/sidebar>

## States

- **default** — validated container for one or more `block_nav_item()`
  children.
- **stacked** — renders a vertical navigation list with sidebar-safe
  spacing.
- **keyboard-enhanced** — sidebar runtime enables arrow/home/end
  traversal across child items.
- **sidebar-composed** — when used inside `block_sidebar()`, the nav
  container is promoted to the sidebar navigation region instead of
  being wrapped again.

## Token contract

| Visual role | Token |
| --- | --- |
| Layout spacing | none (layout only) |

## Deliberate divergences from shadcn

- `block_nav()` is an R-side validation wrapper; shadcn sidebar
  examples rely on composition inside React providers.

## Reference screenshot

![Nav](_screenshots/nav.png)

Captured from <https://ui.shadcn.com/docs/components/sidebar> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
