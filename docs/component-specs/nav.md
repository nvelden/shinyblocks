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

## Token contract

| Visual role | Token |
| --- | --- |
| Layout spacing | none (layout only) |

## Deliberate divergences from shadcn

- `block_nav()` is an R-side validation wrapper; shadcn sidebar
  examples rely on composition inside React providers.

## Reference screenshot

![Nav](_screenshots/nav.png)

Capture pending — use the canonical shadcn sidebar navigation example
once screenshots are being captured.
