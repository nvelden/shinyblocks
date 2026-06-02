# Slider

> Shinyblocks function: `block_slider()` / `update_block_slider()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/slider>
> Status: Runtime form control with a hidden native input bridge;
> Phase 7 spec refreshed around shipped pointer/keyboard runtime,
> range/single modes, and updater contract.

## States

- **default** — muted rail (6px tall, fully rounded), primary-filled
  range, 16px white thumb with primary border and a soft shadow.
- **hover** (on thumb) — 4px ring at 50% `--ring` opacity around the
  thumb. Rail and range unchanged.
- **focus-visible** (on thumb) — same 4px `--ring/50` ring as hover,
  default browser outline suppressed.
- **range mode** — two thumbs; filled range sits between them.
- **disabled** — entire slider at 0.5 opacity, pointer-events
  disabled, thumb cursor `not-allowed`.
- **invalid** — thumb border/ring switches to destructive styling via
  `aria-invalid="true"`.
- **server update** — `update_block_slider()` can update value, min,
  max, step, disabled, invalid, style, and class.
- **standalone width** — sliders keep a small runtime minimum width in
  shrink-wrapped containers while explicit `width` / parent constraints
  can still size the control.
- **change-event throttling** — the `shinyblocks.slider` Shiny binding
  declares `{ policy: "throttle", delay: 100 }`, so per-pointer-move
  drags arrive at `input$<id>` at most every 100ms. The component
  dispatches `sb:slider-change` synchronously; throttling lives in
  Shiny's binding contract, not in the component.

## R API

### `block_slider(input_id, value, min, max, step, ticks, orientation, show_value, min_label, max_label, width, disabled, invalid, style, class)`

| Argument | Purpose |
| --- | --- |
| `input_id` | Shiny input id used for `input$<id>` and update messages. |
| `value` | One or two numeric values. Two values activates range mode. |
| `min` / `max` | Numeric bounds. `min` must be strictly less than `max`. |
| `step` | Optional positive numeric step. |
| `ticks` | Accepted for API compatibility — tick labels are not currently rendered. |
| `orientation` | `"horizontal"` or `"vertical"` rail orientation. |
| `show_value` | Shows the current scalar value or range near the rail. |
| `min_label` / `max_label` | Optional labels rendered at the rail bounds. |
| `width` | CSS width applied to the runtime wrapper for horizontal sliders. Vertical sliders shrink-wrap the rail/label group; use `style` for custom vertical sizing. |
| `disabled` | Disables pointer/keyboard interaction. |
| `invalid` | Applies `aria-invalid` and destructive border/ring. |
| `style` / `class` | Inline style / extra class on the wrapper. |

### `update_block_slider(session, input_id, ...)`

Accepts `value`, `min`, `max`, `step`, `orientation`, `show_value`,
`min_label`, `max_label`, `disabled`, `invalid`, `style`, `class`, with
optional `notify` semantics. `value` accepts one or two numerics
matching single vs range mode.

## Runtime mapping

| R input | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | mount id | Drives `input$<id>`. |
| `value` | `state$value` | Numeric scalar or two-number array. |
| `min`/`max`/`step` | `props$min` / `props$max` / `props$step` | |
| `ticks` | (ignored) | Accepted for API compatibility; the runtime does not render tick labels yet. |
| `orientation` | `props$orientation` | Horizontal by default; vertical uses the same Shiny value contract. |
| `show_value` | `props$showValue` | Renders the current scalar/range text in the runtime. |
| `min_label` / `max_label` | `props$minLabel` / `props$maxLabel` | Display-only bound labels. |
| `disabled` | `props$disabled` | |
| `invalid` | `props$invalid` | |
| `width` | mount `style.width` | Horizontal only. |

A hidden native `<input>` lives in the runtime mount as a
form-submission bridge, but Shiny reads the dedicated
`shinyblocks.slider` binding from the runtime root.

## Shiny state and update contract

- Single-value sliders report a numeric scalar to Shiny; range sliders
  report a two-number array.
- Pointer dragging, click-to-position, Home/End, ArrowLeft/Right,
  ArrowUp/Down, and PageUp/PageDown are handled by the runtime in both
  orientations.
- Server-driven value updates can notify Shiny (`notify = TRUE`,
  default) or remain cosmetic/state-only (`notify = FALSE`).

## Token contract

| Visual role | Token (light) | Token (dark override) |
| --- | --- | --- |
| Rail (track) fill | `--muted` | `--ring` |
| Range fill | `--primary` | same |
| Thumb surface | `#ffffff` (literal white, matches shadcn) | same |
| Thumb border | `--primary` | `--border` |
| Thumb shadow | `--foreground` at 5% / 10% (shadow-sm) | same |
| Hover / focus ring | `--ring` at 50% opacity, 4px wide | same |
| Invalid ring | `--destructive` at 20% opacity | same |
| Disabled opacity | `0.5` | same |
| Rail / range / thumb radius | `9999px` (fully rounded) | same |
| Rail / range height | `0.375rem` (6px) | same |
| Thumb size | `1rem` (16px) | same |
| Standalone minimum width | `min(12rem, 100%)` for horizontal; vertical uses a narrow rail with an 8rem default height | same |

## Deliberate divergences from shadcn

- The DOM is package-local React runtime markup, not
  `@radix-ui/react-slider`, but it uses the same slot names:
  `[data-slot="slider"]`, `[data-slot="slider-track"]`,
  `[data-slot="slider-range"]`, and `[data-slot="slider-thumb"]`.
- `block_slider()` no longer wraps `shiny::sliderInput()` /
  ion.rangeSlider — the runtime owns the visible control end-to-end.
- `ticks` remains accepted for API compatibility but the runtime does
  not render tick labels yet.
- Thumb surface is a literal `#ffffff` (matches shadcn's `bg-white`)
  rather than `--background`, so the thumb stays light in dark mode
  exactly as shadcn does it.
- Radix supports more than two thumbs and `minStepsBetweenThumbs`.
  shinyblocks intentionally keeps the public Shiny value contract to one
  scalar or a two-value range for now. A stricter minimum-distance API can
  be added later without changing the current value shape.
- **Dark-mode colour refinement.** In dark mode, the default token
  mapping produces a near-invisible track (`--muted` = `oklch(0.269)`
  on `oklch(0.145)` background). shinyblocks overrides the slider track
  in dark mode to `--ring` and the handle border to `--border`. The
  range bar keeps `--primary`.

## Reference screenshot

![Slider](_screenshots/slider.png)

Captured from <https://ui.shadcn.com/docs/components/slider> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
