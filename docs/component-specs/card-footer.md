# Card Footer

> Shinyblocks function: `block_card_footer()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>
> Status: R-side composition primitive; Phase 7 spec refreshed around
> the `data-sb-child="card-footer"` marker used for region detection.

## States

- **default** — bottom region rendered as `<div class="sb-card-footer">`
  for actions or summary text.
- **action-row** — typically hosts `block_button()` actions aligned
  with the card layout spacing.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Footer content. |
| `class` | Extra classes merged onto the `.sb-card-footer` element. |

## Composition contract

Stamps `data-sb-child="card-footer"`. `block_card(footer = ...)`
reuses any existing tag carrying this marker; bare strings or tags
passed via `footer =` are auto-wrapped.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | inherited `--card` |
| Foreground | inherited `--card-foreground` |

## Deliberate divergences from shadcn

- shinyblocks exports the footer as a standalone helper so R callers
  can build card compositions incrementally.

## Reference screenshot

![Card footer](_screenshots/card-footer.png)

Captured from <https://ui.shadcn.com/docs/components/card> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
