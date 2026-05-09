# Tabs

> Shinyblocks function: `block_tabs()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/tabs>

## States

- **default** — muted rounded list surface, inline triggers, no bottom
  border, content stacked beneath with `gap-4`.
- **hover** — inactive triggers keep transparent background and lift
  label color from muted to foreground.
- **selected** — active trigger uses `--background` fill,
  `--foreground` text, and a light shadow inside the muted list.
- **focus-visible** — relies on the global 2px `--ring` outline from
  the base layer on the underlying anchor trigger.
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
| Focus ring | `--ring` |

## Deliberate divergences from shadcn

- `block_tabs()` still decorates `shiny::tabsetPanel()` markup instead
  of emitting a bespoke Radix-like DOM tree.
- Active state is keyed off `.nav-link.active` rather than a Radix-style
  `data-state="active"` attribute.
- Runtime selection is handled by the local `shinyblocks.js` tab
  behavior so the component does not depend on Bootstrap's tab plugin
  being present.

## Reference screenshot

![Tabs](_screenshots/tabs.png)

Capture pending — pull the canonical screenshot from
<https://ui.shadcn.com/docs/components/tabs> showing the default tab
set. Refresh and update the date whenever shadcn updates the canonical
look.
