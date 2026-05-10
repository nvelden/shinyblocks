# Alert Title

> Shinyblocks function: `block_alert_title()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/alert>

## States

- **default** — medium-weight compact title text inside an alert.
- **composed** — intended to be rendered inside `block_alert()`.

## Token contract

| Visual role | Token |
| --- | --- |
| Title text | inherits alert foreground |

## Deliberate divergences from shadcn

- shadcn does not expose a standalone AlertTitle page; this is a
  composition helper around the alert content contract.

## Reference screenshot

![Alert title](_screenshots/alert-title.png)

Capture pending — use the canonical alert screenshot and crop the title
region if a standalone example is needed.
