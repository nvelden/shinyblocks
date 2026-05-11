# Tabs

> Shinyblocks function: `block_tabs()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/tabs>

## States

- **default** — muted rounded list surface, inline triggers, and card
  content beneath.
- **line** — transparent list surface with an active underline
  indicator.
- **hover** — inactive triggers keep transparent background and lift
  label color from muted to foreground.
- **selected** — active trigger uses `--background` fill,
  `--foreground` text, and a light shadow inside the muted list for the
  default variant; line variant uses only the underline.
- **focus-visible** — trigger owns its own 3px `--ring` shadow at 50%
  opacity instead of relying on a global outline fallback.
- **orientation** — markup now carries `data-orientation` and supports
  both `horizontal` and `vertical`.
- **content** — tab content stays reactive through Shiny's tabset
  binding and renders inside `.tab-content.sb-tabs-content`.

## Token contract

| Visual role | Token |
| --- | --- |
| Tabs list surface | `--muted` |
| Inactive trigger text | `--muted-foreground` |
| Hover trigger text | `--foreground` |
| Active trigger surface | `--background` |
| Active trigger text | `--foreground` |
| Line indicator | `--foreground` |
| Focus ring | `--ring` |

## Deliberate divergences from shadcn

- `block_tabs()` still decorates `shiny::tabsetPanel()` markup instead
  of emitting a bespoke Radix-like DOM tree.
- Runtime selection is handled by the local `shinyblocks.js` tab
  behavior so the component does not depend on Bootstrap's tab plugin
  being present.

## Reference screenshot

![Tabs](_screenshots/tabs.png)

Captured from <https://ui.shadcn.com/docs/components/tabs> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
