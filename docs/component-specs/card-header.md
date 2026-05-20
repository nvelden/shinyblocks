# Card Header

> Shinyblocks function: `block_card_header()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>
> Status: R-side composition primitive; Phase 7 spec refreshed around
> the `data-sb-child="card-header"` marker used by `block_card()` for
> region detection.

## States

- **default** — top region wrapper for title and description rendered
  as `<div class="sb-card-header">`.
- **stacked** — lays out title/description vertically with card-header
  spacing.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Header content (typically a `block_card_title()` and/or `block_card_description()`). |
| `class` | Extra classes merged onto the `.sb-card-header` element. |

## Composition contract

`block_card_header()` stamps `data-sb-child="card-header"` on the
emitted element. `block_card()` looks for that marker when it
materialises a header from its flat `title =`/`description =` shortcut
so prebuilt headers are reused in place instead of being re-wrapped.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | inherited `--card` |
| Foreground | inherited `--card-foreground` |

## Deliberate divergences from shadcn

- shinyblocks exports the card regions individually so R callers can
  compose them incrementally without JSX nesting ergonomics.

## Reference screenshot

![Card header](_screenshots/card-header.png)

Captured from <https://ui.shadcn.com/docs/components/card> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
