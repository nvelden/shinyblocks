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
- **content** — tab content renders inside package-owned
  `.sb-tabs-content` / `.sb-tabs-panel` containers.

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

- `block_tabs()` is still an R-side component, not a React/Radix runtime
  component, but it now emits package-owned tab markup instead of
  decorating Shiny/Bootstrap tabset output.
- Selection, keyboard behavior, `aria-selected`, panel visibility, and
  Shiny `input$<id>` updates are handled by the local
  `shinyblocks.js` tab behavior.
- `shiny::tabPanel()` inputs remain accepted as a compatibility source,
  but the rendered DOM no longer keeps Bootstrap tab classes.

## Reference screenshot

![Tabs](_screenshots/tabs.png)

Captured from <https://ui.shadcn.com/docs/components/tabs> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
