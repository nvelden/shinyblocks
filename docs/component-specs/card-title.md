# Card Title

> Shinyblocks function: `block_card_title()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>

## States

- **default** — semibold heading inside a card header.
- **composed** — may be used directly in `block_card_header()` or passed
  as the flat `title =` argument to `block_card()`.

## Token contract

| Visual role | Token |
| --- | --- |
| Text | inherited `--card-foreground` |
| Weight | `--font-weight-semibold` |

## Deliberate divergences from shadcn

- shinyblocks wraps flat `title =` values into this primitive
  automatically.

## Reference screenshot

![Card title](_screenshots/card-title.png)

Capture pending — use the canonical shadcn card docs page once the
reference screenshot pass resumes.
