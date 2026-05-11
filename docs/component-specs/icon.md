# Icon

> Shinyblocks function: `block_icon()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/button>

## States

- **default** — inline Lucide SVG symbol referenced from the vendored
  sprite.
- **custom-tag** — passes through a supplied `htmltools` tag while
  merging extra classes and attrs.
- **decorative** — defaults to `aria-hidden="true"` and
  `focusable="false"`.

## Token contract

| Visual role | Token |
| --- | --- |
| Icon color | `currentColor` |

## Deliberate divergences from shadcn

- shinyblocks serves icons from a local SVG sprite instead of importing
  Lucide React components.

## Reference screenshot

![Icon](_screenshots/icon.png)

Captured from <https://ui.shadcn.com/docs/components/button> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
