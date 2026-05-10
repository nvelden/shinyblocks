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

Capture pending — use a representative icon-in-button example from the
shadcn docs once the screenshot pass resumes.
