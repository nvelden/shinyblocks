# Tab

> Shinyblocks function: `block_tab()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/tabs>

## States

- **default** — records a title, value, and content payload for the
  parent `block_tabs()` component.
- **selected** — delegated to the parent tabset; the matching trigger
  receives `data-state="active"` and `aria-selected="true"`.
- **content** — content is rendered inside a package-owned
  `.sb-tabs-panel` container.

## Token contract

| Visual role | Token |
| --- | --- |
| Trigger/content styling | delegated to `block_tabs()` |
| Active state | delegated to `block_tabs()` |
| Focus ring | delegated to `block_tabs()` |

## Deliberate divergences from shadcn

- `block_tab()` is a lightweight R-side source tag, not a standalone
  React/Radix primitive like shadcn's `TabsContent`.
- Selection and keyboard behavior are owned by the parent
  `block_tabs()` wrapper and local `shinyblocks.js` bridge.

## Reference screenshot

![Tab](_screenshots/tab.png)

Captured from <https://ui.shadcn.com/docs/components/tabs> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
