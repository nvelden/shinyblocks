# Card

> Shinyblocks functions: `block_card()` + the composition primitives
> `block_card_header()`, `block_card_title()`, `block_card_description()`,
> `block_card_content()`, `block_card_footer()`.
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>
> Status: Runtime composition primitive that hosts Shiny outputs and
> htmlwidgets through the runtime child slot; Phase 7 spec refreshed
> around shipped flat-argument convenience and child binding lifecycle.

## States

- **default** — `--card` fill, `--card-foreground` text, 1px
  `--border` border, `--radius-xl` radius, soft `shadow-sm`.
- **with header** — title is an `<h3>` with `--font-weight-semibold`
  and `tracking-tight`. Description is a `<p>` styled as muted text.
- **with content slot** — body content sits inside `<div class="sb-card-content">`,
  which inherits `text-sm` and uses `--muted-foreground` as the default
  prose colour.
- **with value slot** — flat-argument `value =` renders as a prominent
  number (`text-2xl`, semibold) above the body, sharing the
  card-content surface.
- **with footer** — footer sits flush to the bottom of the card,
  separated from content by the layout's `gap-4`.
- **as a grid** — multiple cards laid out in `auto-fit` grids inherit
  consistent radii and shadows; no special "selected" state at this
  layer.

## R API

### `block_card(..., title, description, value, footer, class)`

| Argument | Purpose |
| --- | --- |
| `...` | Card body content. Rendered inside `block_card_content()`. Shiny outputs and htmlwidgets bind here through the runtime child slot. |
| `title` | Optional title. String, tag, or `block_card_title()` — bare strings are auto-wrapped. |
| `description` | Optional description. Same auto-wrap behaviour. |
| `value` | Optional prominent metric value rendered above the body inside `sb-card-value`. |
| `footer` | Optional footer. String, tag, or `block_card_footer()`. |
| `class` | Extra classes merged onto the runtime wrapper. |

### Composition primitives

`block_card_header()`, `block_card_title()`, `block_card_description()`,
`block_card_content()`, and `block_card_footer()` are R-side helpers
that emit tagged elements (`data-sb-child="card-<part>"`) so
`block_card()` can detect prebuilt regions and reuse them in place
instead of re-wrapping them.

## Runtime mapping

- The card itself is rendered as a React runtime component
  (`component = "card"`).
- `header`, `content`, and `footer` regions are serialized as
  `children` so their nested Shiny outputs and htmlwidgets bind under
  the runtime mount through `[data-shinyblocks-children]`.
- The hidden `data-sb-child` markers let `block_card()` distinguish
  prebuilt region tags from bare content.

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
  `value =`, `footer =` directly on `block_card()`) is shinyblocks-only.
  shadcn-react expects the composition primitives. Both shapes are
  accepted — prebuilt region tags are reused via `data-sb-child`
  markers, bare strings get wrapped automatically.
- The `value =` slot has no shadcn equivalent. It exists for the
  dashboard-style metric-tile pattern that maps to `block_value_box()`
  in shinyblocks, but reused inside cards because R/Shiny dashboards
  conflate the two patterns more often than React apps do.

## Reference screenshot

![Card](_screenshots/card.png)

Captured from <https://ui.shadcn.com/docs/components/card> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
