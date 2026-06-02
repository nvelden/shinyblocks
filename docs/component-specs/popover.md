# Popover

> Shinyblocks function: `block_popover()` / `update_block_popover()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/popover>
> Status: Runtime overlay component; Phase 7 spec refreshed around the
> shipped API, state bridge, accessibility contract, and divergences.

## States

- **closed** — only the trigger button is rendered.
- **open** — content renders into `[data-shinyblocks-portal-root]` and
  is positioned relative to the trigger.
- **dismissed by interaction** — outside pointer down or `Escape`
  closes the popover and notifies Shiny when an `id` is present.
- **server-updated** — `update_block_popover()` can open/close,
  replace trigger/body content, reposition, and update style/class
  without remounting.
- **positioned** — `side` supports `"bottom"`, `"top"`, `"left"`, and
  `"right"`; `align` supports `"center"`, `"start"`, and `"end"`.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `id` | `input_id` / runtime mount id | Optional; enables Shiny state. |
| `trigger` | `props$triggerLabel` | Required trigger button label. |
| `...` | `props$bodyHtml` | Popover body HTML. |
| `side` | `props$side` | Fixed-position side. |
| `align` | `props$align` | Alignment along the side. |
| `open` | `state$open`, `state$value` | Initial open state. |
| `style` | `props$contentStyle` | Inline content style object. |
| `class` | `props$contentClass` | Extra class on content. |

## Shiny State And Update Contract

- Without `id`, the popover is client-only and registers no input
  binding.
- With `id`, `input$<id>` is `TRUE` when open and `FALSE` when closed.
- The runtime routes `sendInputMessage()` payloads to
  `el.__sbPopoverReceive`.
- `update_block_popover()` accepts `open`, `trigger`, `body`, `side`,
  `align`, `style`, and `class`.
- Cosmetic updates do not notify. Open/close updates notify only when
  `notify = TRUE`.
- Passing `body = NULL`, `style = NULL`, or `class = NULL` clears that
  field.

## Accessibility

- Trigger is a real `<button>` with `aria-haspopup="dialog"`,
  `aria-expanded`, and `aria-controls` when open.
- Open content carries `role="dialog"` and is focusable.
- Opening moves focus to the first focusable child or the content panel.
- Closing returns focus to the element that opened the popover.
- `Escape` closes the popover and stops propagation.

## Token Contract

| Visual role | Token |
| --- | --- |
| Surface | `--popover` |
| Foreground | `--popover-foreground` |
| Border | `--border` |

## Deliberate Divergences From Shadcn

- React runtime is package-local (`component = "popover"`); shinyblocks
  does not ship `@radix-ui/react-popover`.
- Positioning uses `getBoundingClientRect()` and fixed coordinates.
  Floating UI flip, shift, collision padding, and arrows are deferred.
- Content is currently serialized HTML, not live Shiny-bound children.
- No animated open/close transition yet.

## Reference Screenshot

Pending — capture and add under `_screenshots/popover.png` during the
Phase 7 screenshot refresh.
