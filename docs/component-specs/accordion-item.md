# Accordion Item

> Shinyblocks function: `block_accordion_item()`
> Parent: `block_accordion()` (see `accordion.md`)
> Shadcn reference: <https://ui.shadcn.com/docs/components/accordion>
> Status: R-side composition primitive part (issue #91).

## Purpose

`block_accordion_item()` builds a single collapsible section for
`block_accordion()`: a trigger `title` that expands or collapses its body
content. Body content is arbitrary `htmltools`/Shiny markup and stays live
in the DOM, so reactive outputs inside a closed panel keep working.

## R API

| Argument | Purpose |
| --- | --- |
| `value` | Unique item id within the accordion. Reported to `input$<id>` and targeted by `update_block_accordion()`. |
| `title` | Trigger label. A string or an `htmltools` tag. |
| `...` | Panel body content. |
| `icon` | Optional leading icon shown before the title (vendored icon name or tag). |
| `disabled` | Whether the item is non-interactive (cannot be toggled). |
| `class` | Extra classes on the `.sb-accordion-item` wrapper. |

## Rendered contract

Emits `.sb-accordion-item[data-sb-child="accordion-item"]` carrying
`data-value` and `data-state` (`closed` by default; `block_accordion()`
stamps the resolved open state, `aria-controls`/`aria-labelledby` ids, and
`inert` on closed panels). Inside:

- `.sb-accordion-header` `<h3>` → `.sb-accordion-trigger` `<button>` with
  a `.sb-accordion-title` (icon + title) and a trailing chevron icon.
- `.sb-accordion-content` `<div role="region">` →
  `.sb-accordion-content-inner` holding `...`.

## States

See `accordion.md` — closed, open, hover, focus-visible, and disabled are
owned by the parent accordion's styles and runtime.

## Reference screenshot

![Accordion Item](_screenshots/accordion-item.png)

Captured from <https://ui.shadcn.com/docs/components/accordion>.
