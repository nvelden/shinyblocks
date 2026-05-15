# Popover

> Shinyblocks function: `block_popover()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/popover>
> Status: **Phase 5.3 - binding/updater + interaction behaviors**.

## Phase 5.3 contract

- Non-modal content rendered into the runtime portal root
  (`[data-shinyblocks-portal-root]`), anchored to a trigger button by
  fixed positioning against `getBoundingClientRect()`.
- Required `trigger` label renders an `sb-button` that toggles the
  popover locally.
- `side` (`"bottom"` default, plus `"top"`, `"left"`, `"right"`) and
  `align` (`"center"` default, plus `"start"`, `"end"`) choose the
  anchor edge and alignment.
- Initial `open` arg renders the popover open on first paint.
- When `id` is supplied, `input$<id>` reports `TRUE` when open and
  `FALSE` when closed through the `shinyblocks.popover` input binding.
- `update_block_popover()` supports server-driven updates for open
  state and cosmetic slots: `trigger`, `body`, `side`, `align`,
  `style`, and `class`.
- Escape closes when open.
- Pointer down outside the trigger/content closes when open.
- Closing returns focus to the previous trigger element.

## States

- **closed** - only the trigger button is rendered.
- **open** - content portal-rendered next to the trigger; updates on
  scroll/resize via fixed positioning.
- **dismissed by interaction** - Escape and outside click both
  transition to closed.
- **trigger focus-visible** - ring picked up from the shared
  `.sb-button` focus styles.
- **server-updated** - `update_block_popover()` updates body,
  position, and class/style without remounting.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--popover` |
| Foreground | `--popover-foreground` |
| Border | `--border` |

## Slots

| Slot | Source | Notes |
| --- | --- | --- |
| `triggerLabel` | `trigger` arg | Required string. |
| `bodyHtml` | `...` | Optional. Serialized via `html_fragment()`. |
| `contentStyle` | `style` arg | Optional inline style object/string. |
| `contentClass` | `class` arg | Optional extra class on content. |

## Planned divergences from shadcn

- React component is package-local; we do not ship `@radix-ui/react-popover`.
- Positioning uses naive `getBoundingClientRect()`-based fixed
  placement; Floating UI (flip / shift / arrow) is deferred.

## Reference screenshot

Pending - capture and add under `_screenshots/popover.png` during the
Phase 5.x cleanup gate.
