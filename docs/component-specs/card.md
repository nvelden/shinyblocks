# Card

> Shinyblocks function: `block_card()` and the composition primitives
> `block_card_header()`, `block_card_title()`, `block_card_description()`,
> `block_card_content()`, `block_card_footer()`.
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>

## States

- **default** — `--card` fill, `--card-foreground` text, 1px
  `--border` border, `--radius-xl` radius, soft `shadow-sm`.
- **with header** — title is an `<h3>` with `--font-weight-semibold`
  and `tracking-tight`. Description is a `<p>` styled as muted text.
- **with content slot** — body content sits inside
  `<div class="sb-card-content">`, which inherits `text-sm` and uses
  `text-muted-foreground` as the default colour for prose.
- **with value slot** — flat-argument `value =` renders as a
  prominent number (`text-2xl`, semibold) above the body, sharing the
  card-content surface.
- **with footer** — footer sits flush to the bottom of the card,
  separated from content by the layout's `gap-4`.
- **as a grid** — multiple cards laid out in `auto-fit` grids inherit
  consistent radii and shadows; no special "selected" state at this
  layer.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--card` |
| Foreground | `--card-foreground` |
| Border | `--border` |
| Radius | `--radius-xl` |
| Body text | `--muted-foreground` |
| Title weight | `--font-weight-semibold` |

## Deliberate divergences from shadcn

- The flat-argument convenience (`title =`, `description =`,
  `value =`, `footer =` directly on `block_card()`) is shinyblocks-
  only. shadcn-react expects the composition primitives. Both shapes
  are accepted — pre-built region tags are reused via
  `data-sb-child` markers, bare strings get wrapped automatically.
- The `value =` slot has no shadcn equivalent. It exists for the
  dashboard-style "metric tile" use that maps to `block_value_box()`
  in shinyblocks, but reused inside cards because R/Shiny dashboards
  conflate the two patterns more often than React apps do.

## Reference screenshot

![Card](_screenshots/card.png)

Captured from <https://ui.shadcn.com/docs/components/card> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
