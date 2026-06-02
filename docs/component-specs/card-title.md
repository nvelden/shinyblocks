# Card Title

> Shinyblocks function: `block_card_title()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>
> Status: R-side composition primitive; Phase 7 spec refreshed around
> the `data-sb-child="card-title"` marker used for region detection.

## States

- **default** — semibold heading rendered as `<h3 class="sb-card-title">`.
- **composed** — used directly inside `block_card_header()`, or via
  the flat `title =` argument on `block_card()` which auto-wraps bare
  strings.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Title content. |
| `class` | Extra classes merged onto the `.sb-card-title` element. |

## Composition contract

Stamps `data-sb-child="card-title"` on the emitted `<h3>`. When
`block_card(title = ...)` receives a tag that already carries this
marker, it is reused in place; bare strings get wrapped into a fresh
`block_card_title()` automatically.

## Token contract

| Visual role | Token |
| --- | --- |
| Text | inherited `--card-foreground` |
| Weight | `--font-weight-semibold` |

## Deliberate divergences from shadcn

- Always renders as `<h3>`. Callers that need a different heading level
  should compose markup directly inside `block_card_header()` rather
  than reaching for a level prop.

## Reference screenshot

![Card title](_screenshots/card-title.png)

Captured from <https://ui.shadcn.com/docs/components/card> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
