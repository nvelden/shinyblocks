# Card Description

> Shinyblocks function: `block_card_description()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>

## States

- **default** — muted supporting text inside the card header.
- **composed** — may be used directly in `block_card_header()` or
  created from the flat `description =` argument on `block_card()`.

## Token contract

| Visual role | Token |
| --- | --- |
| Text | `--muted-foreground` |

## Deliberate divergences from shadcn

- shinyblocks auto-wraps flat description text into this primitive when
  `block_card(description = ...)` is used.

## Reference screenshot

![Card description](_screenshots/card-description.png)

Captured from <https://ui.shadcn.com/docs/components/card> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
