# Card Content

> Shinyblocks function: `block_card_content()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>

## States

- **default** — main card body region for arbitrary content.
- **with-value-slot** — may contain the shinyblocks-only `sb-card-value`
  metric treatment emitted by `block_card(value = ...)`.

## Token contract

| Visual role | Token |
| --- | --- |
| Text | inherited `--card-foreground` |
| Prose/default body text | `--muted-foreground` |

## Deliberate divergences from shadcn

- `block_card_content()` may host the shinyblocks-only `value =` metric
  slot emitted by `block_card()`.

## Reference screenshot

![Card content](_screenshots/card-content.png)

Capture pending — use the canonical shadcn card docs page once the
reference screenshot pass resumes.
