# Spinner

> Shinyblocks function: `block_spinner()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/skeleton>

## States

- **default** — compact animated loading indicator.
- **accessible** — exposes `role="status"` and an `aria-label`.

## Token contract

| Visual role | Token |
| --- | --- |
| Spinner stroke | `--muted-foreground` |

## Deliberate divergences from shadcn

- shadcn does not ship a dedicated spinner primitive; shinyblocks adds
  one for Shiny loading states while keeping the same token language.

## Reference screenshot

![Spinner](_screenshots/spinner.png)

Captured from <https://ui.shadcn.com/docs/components/skeleton> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
