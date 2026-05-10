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

Capture pending — use the project showcase as the local reference until
the screenshot pass defines a canonical external capture.
