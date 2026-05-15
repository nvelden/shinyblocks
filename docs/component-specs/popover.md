# Popover

> Shinyblocks function: `block_popover()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/popover>
> Status: **Phase 5.6 — popover/checkbox/switch parity + cleanup**.

## States

- **closed** — only the trigger button is rendered.
- **open** — content portal-rendered next to the trigger; updates on
  scroll/resize via fixed positioning.
- **dismissed by interaction** — Escape and outside click both
  transition to closed.
- **trigger focus-visible** — ring picked up from the shared
  `.sb-button` focus styles.
- **server-updated** — `update_block_popover()` updates body,
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

## Server contract

- When `id` is supplied, `input$<id>` reports `TRUE` when open and
  `FALSE` when closed through the `shinyblocks.popover` input binding.
- `update_block_popover()` supports server-driven updates for `open`,
  `trigger`, `body`, `side`, `align`, `style`, and `class` with optional
  `notify` semantics.

## Deliberate divergences from shadcn

- React runtime is package-local (`component = "popover"`); we do not
  ship `@radix-ui/react-popover`.
- Positioning uses naive `getBoundingClientRect()`-based fixed
  placement; Floating UI (flip / shift / arrow) is deferred.

## Reference screenshot

Pending — capture and add under `_screenshots/popover.png` during the
runtime parity-harness rewrite (Phase 7).
