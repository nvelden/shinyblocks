# Tooltip

> Shinyblocks function: `block_tooltip()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/tooltip>
> Status: Runtime overlay component; Phase 7 spec refreshed around the
> shipped API, accessibility contract, and divergences.

## States

- **closed** — only the trigger button is rendered.
- **opening** — hover or focus starts the `delay_duration` timer.
- **open** — content renders into `[data-shinyblocks-portal-root]` and
  is positioned relative to the trigger.
- **dismissed by interaction** — trigger leave/blur, tooltip
  leave/blur after the short grace period, or `Escape` closes the
  tooltip.
- **positioned** — `side` supports `"top"`, `"bottom"`, `"left"`, and
  `"right"`; `align` supports `"center"`, `"start"`, and `"end"`.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `trigger` | `props$triggerLabel` | Required trigger button label. |
| `...` | `props$bodyHtml` | Tooltip body HTML. |
| `side` | `props$side` | Fixed-position side. |
| `align` | `props$align` | Alignment along the side. |
| `delay_duration` | `props$delayDuration` | Milliseconds before open. |
| `style` | `props$contentStyle` | Inline content style object. |
| `class` | `props$contentClass` | Extra class on content. |

## Shiny State And Update Contract

- Tooltips are presentational and register no Shiny input binding.
- There is no `update_block_tooltip()` helper.
- Dynamic tooltip content should be emitted by `renderUI()` or by
  re-rendering the parent UI.

## Accessibility

- Trigger is a real `<button>` and opens on both pointer hover and
  keyboard focus.
- When open, the trigger advertises the panel with
  `aria-describedby`.
- Content carries `role="tooltip"`.
- `Escape` closes the tooltip.
- `delay_duration` defaults to 700 ms, matching the shadcn reference.

## Token Contract

| Visual role | Token |
| --- | --- |
| Surface | `--primary` |
| Foreground | `--primary-foreground` |

The shadcn tooltip uses a primary-toned bubble in both light and dark
modes; no `--border` ring is used on the content panel.

## Deliberate Divergences From Shadcn

- React runtime is package-local (`component = "tooltip"`); shinyblocks
  does not ship `@radix-ui/react-tooltip`.
- Positioning uses `getBoundingClientRect()` and fixed coordinates.
  Floating UI flip, shift, collision padding, and arrows are deferred.
- Content is currently serialized HTML, not live Shiny-bound children.
- No animated open/close transition yet.

## Reference Screenshot

Pending — capture and add under `_screenshots/tooltip.png` during the
Phase 7 screenshot refresh.
