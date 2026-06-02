# Card Content

> Shinyblocks function: `block_card_content()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>
> Status: R-side composition primitive; Phase 7 spec refreshed around
> the `data-sb-child="card-content"` marker and the optional
> `sb-card-value` metric slot emitted by `block_card()`.

## States

- **default** — main card body region rendered as
  `<div class="sb-card-content">`.
- **with-value-slot** — may contain the shinyblocks-only
  `<div class="sb-card-value">` metric treatment emitted by
  `block_card(value = ...)` above the rest of the body.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Card body content. Shiny outputs and htmlwidgets bind here through the runtime child slot. |
| `class` | Extra classes merged onto the `.sb-card-content` element. |

## Composition contract

Stamps `data-sb-child="card-content"`. `block_card()` always
materialises a content region (passing `...` and any `value =` content
through it), so most callers do not call `block_card_content()`
directly unless they want to opt out of the flat-argument convenience.

## Token contract

| Visual role | Token |
| --- | --- |
| Text | inherited `--card-foreground` |
| Prose/default body text | `--muted-foreground` |

## Deliberate divergences from shadcn

- The `.sb-card-value` slot has no shadcn equivalent — see the Card
  spec for the dashboard-tile motivation.

## Reference screenshot

![Card content](_screenshots/card-content.png)

Captured from <https://ui.shadcn.com/docs/components/card> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
