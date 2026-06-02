# Tab

> Shinyblocks function: `block_tab()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/tabs>
> Status: R-side source tag consumed by `block_tabs()`; Phase 7 spec
> refreshed around the shipped `.sb-tab-source` payload contract.

## States

- **default** — records a title, value, and content payload for the
  parent `block_tabs()` component.
- **selected** — delegated to the parent tabset; the matching trigger
  receives `data-state="active"` and `aria-selected="true"`.
- **content** — content is moved into a package-owned
  `.sb-tabs-panel` container at render time.

## R API

| Argument | Purpose |
| --- | --- |
| `title` | Tab label. Required, non-empty string. |
| `...` | Tab content. |
| `value` | Optional tab value. Defaults to `title`. Drives the value pushed to `input$<id>` on the parent tabset. |

## Rendered contract

`block_tab()` does **not** render the visible trigger or panel. It
emits a `<div class="sb-tab-source" data-title="..." data-value="...">`
carrying the children, and `block_tabs()` re-emits the trigger button
and `tabpanel` div using package-owned classes.

## Token contract

| Visual role | Token |
| --- | --- |
| Trigger/content styling | delegated to `block_tabs()` |
| Active state | delegated to `block_tabs()` |
| Focus ring | delegated to `block_tabs()` |

## Deliberate divergences from shadcn

- `block_tab()` is a lightweight source tag, not a standalone
  React/Radix primitive like shadcn's `TabsContent`. Mounting a
  `block_tab()` outside `block_tabs()` is a no-op visually.
- Selection and keyboard behavior are owned by the parent
  `block_tabs()` wrapper and the local `shinyblocks.js` bridge.

## Reference screenshot

![Tab](_screenshots/tab.png)

Captured from <https://ui.shadcn.com/docs/components/tabs> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
