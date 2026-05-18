# Tooltip

> Shinyblocks function: `block_tooltip()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/tooltip>
> Status: **Phase 4 — overlay/menu components**.

## States

- **closed** — only the trigger button is rendered.
- **opening** — `delay_duration` ms after a `mouseenter` or `focus`; the
  open timer can still be cancelled by a `mouseleave` / `blur` before
  the panel renders.
- **open** — content portal-rendered through
  `[data-shinyblocks-portal-root]`; updates on scroll/resize via fixed
  positioning.
- **dismissed by interaction** — `mouseleave` or `blur` of the trigger
  (with a short close grace period so users can move the cursor onto
  the tooltip itself) and the `Escape` key both transition to closed.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--primary` |
| Foreground | `--primary-foreground` |

The shadcn tooltip uses a primary-toned bubble in both light and dark
modes; no `--border` ring on the content panel.

## Slots

| Slot | Source | Notes |
| --- | --- | --- |
| `triggerLabel` | `trigger` arg | Required string rendered on the anchor button. |
| `bodyHtml` | `...` | Optional. Serialized via `html_fragment()`. |
| `contentStyle` | `style` arg | Optional inline style object/string. |
| `contentClass` | `class` arg | Optional extra class on content. |

## Server contract

Tooltips have no Shiny input binding and no `update_block_tooltip()`
helper; treat them as purely presentational. Dynamic content should be
emitted by `renderUI()`.

## Accessibility

- Trigger is a real `<button>` so it picks up the platform focus ring
  and keyboard activation behavior.
- When open, the trigger advertises the content via
  `aria-describedby`, and the content has `role="tooltip"`.
- Open delay (`delay_duration`, default 700 ms) matches the shadcn
  reference; pointer and keyboard both honor it.

## Deliberate divergences from shadcn

- React runtime is package-local (`component = "tooltip"`); we do not
  ship `@radix-ui/react-tooltip`.
- Positioning uses naive `getBoundingClientRect()`-based fixed
  placement; Floating UI (flip / shift / arrow) is deferred.
- No animated open/close transition yet.

## Reference screenshot

Pending — capture and add under `_screenshots/tooltip.png` during the
runtime parity-harness rewrite (Phase 7).
