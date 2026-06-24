# Grid

> Shinyblocks function: `block_grid()`
> Shadcn reference: <https://ui.shadcn.com/blocks>
> Status: R-side composition primitive.

## States

- **default** — responsive auto-fit columns with a 16rem preferred minimum.
- **narrow/wide** — caller-controlled validated `min_width`.
- **mobile** — columns shrink to 100% before the preferred minimum can overflow.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Ordered repeated content. |
| `min_width` | Valid CSS unit used as the preferred minimum column width. |
| `gap` | Semantic spacing: `"sm"`, `"md"`, or `"lg"`. |
| `align` | Grid item alignment. |
| `class` | Additional classes. |

## Accessibility

- Renders a plain `<div>` and adds no false role or list semantics.
- Visual reflow does not alter document or keyboard order.

## Token contract

| Visual role | Token |
| --- | --- |
| Column minimum | Private `--sb-grid-min` property |
| Small/medium/large gap | `--sb-layout-gap-*` fallback chain |

## Deliberate divergences from shadcn

- Shadcn blocks define responsive grid tracks with utilities. This helper uses
  auto-fit plus `min(100%, var(--sb-grid-min))` to provide the same composition
  pattern without requiring app-authored layout CSS.

## Reference screenshot

![Grid](_screenshots/grid.png)

Composed from <https://ui.shadcn.com/blocks> layout conventions on 2026-06-24.
