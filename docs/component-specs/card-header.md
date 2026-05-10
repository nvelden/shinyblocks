# Card Header

> Shinyblocks function: `block_card_header()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/card>

## States

- **default** — top region wrapper for title and description.
- **stacked** — lays out title/description vertically with card-header
  spacing.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | inherited `--card` |
| Foreground | inherited `--card-foreground` |

## Deliberate divergences from shadcn

- shinyblocks exports the card regions individually so R callers can
  compose them without JSX-style nesting ergonomics.

## Reference screenshot

![Card header](_screenshots/card-header.png)

Capture pending — use the canonical shadcn card docs page once the
reference screenshot pass resumes.
