# Empty

> Shinyblocks function: `block_empty()`
> Shadcn reference: <https://ui.shadcn.com/blocks>

## States

- **default** — centered empty-state composition with title and optional
  description.
- **with-icon** — optional leading icon in a dedicated empty-state slot.
- **with-action** — action area below the message for recovery CTA.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Title text | `--foreground` |
| Description text | `--muted-foreground` |

## Deliberate divergences from shadcn

- `block_empty()` packages a common app pattern; shadcn presents empty
  states as block examples rather than one primitive.

## Reference screenshot

![Empty](_screenshots/empty.png)

Captured from <https://ui.shadcn.com/blocks> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
