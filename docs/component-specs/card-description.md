# Card Description

> Shinyblocks function: `block_card_description()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>
> Status: R-side composition primitive; Phase 7 spec refreshed around
> the `data-sb-child="card-description"` marker used for region
> detection.

## States

- **default** — muted supporting text rendered as
  `<p class="sb-card-description">` inside the card header.
- **composed** — used directly inside `block_card_header()`, or via
  the flat `description =` argument on `block_card()`.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Description content. |
| `class` | Extra classes merged onto the `.sb-card-description` element. |

## Composition contract

Stamps `data-sb-child="card-description"`. `block_card()` reuses any
existing description tag carrying this marker; bare strings passed via
`description =` are auto-wrapped.

## Token contract

| Visual role | Token |
| --- | --- |
| Text | `--muted-foreground` |

## Deliberate divergences from shadcn

- Always renders as `<p>`; for non-paragraph content prefer composing
  inside `block_card_header()` directly.

## Reference screenshot

![Card description](_screenshots/card-description.png)

Captured from <https://ui.shadcn.com/docs/components/card> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
