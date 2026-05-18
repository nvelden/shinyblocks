# Slider

> Shinyblocks function: `block_slider()` / `update_block_slider()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/slider>

## States

- **default** — muted rail (6px tall, fully rounded), primary-filled range, 16px white thumb with primary border and a soft shadow.
- **hover** (on thumb) — 4px ring at 50% `--ring` opacity around the thumb. Rail and range unchanged.
- **focus-visible** (on thumb) — same 4px `--ring/50` ring as hover, default browser outline suppressed.
- **range mode** — two thumbs; filled range sits between them.
- **disabled** — entire slider at 0.5 opacity, pointer-events disabled, thumb cursor `not-allowed`.
- **invalid** — thumb border/ring switches to destructive styling via `aria-invalid="true"`.
- **server update** — `update_block_slider()` can update value, min, max, step, disabled, invalid, style, and class.

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

## Deliberate divergences from shadcn

- The DOM is package-local React runtime markup, not `@radix-ui/react-slider`, but it uses the same slot names: `[data-slot="slider"]`, `[data-slot="slider-track"]`, `[data-slot="slider-range"]`, and `[data-slot="slider-thumb"]`.
- The runtime keeps a hidden native `<input>` only for Shiny/form synchronization. Shiny reads the dedicated `shinyblocks.slider` binding from the runtime root.
- `ticks` remains accepted for API compatibility with the old wrapper but the runtime slider does not render tick labels yet.
- Thumb surface is a literal `#ffffff` (matches shadcn's `bg-white`) rather than `--background`, so the thumb stays light in dark mode exactly as shadcn does it.
- No vertical orientation today. shadcn supports `data-orientation="vertical"`; shinyblocks only supports horizontal sliders for now.
- **Dark-mode colour refinement.** In dark mode, the default token mapping produces a near-invisible track (`--muted` = `oklch(0.269)` on `oklch(0.145)` background). shinyblocks overrides the slider track in dark mode to `--ring` and the handle border to `--border`. The range bar keeps `--primary`.

## Implementation Notes

- `block_slider()` now renders through `runtime_component(component = "slider")` and no longer wraps `shiny::sliderInput()` / ion.rangeSlider.
- Single-value sliders report a numeric scalar to Shiny; range sliders report a two-number array.
- Pointer dragging, click-to-position, Home/End, arrow keys, and PageUp/PageDown are handled by the runtime component.
- Server-driven value updates can notify Shiny (`notify = TRUE`) or remain cosmetic/state-only (`notify = FALSE`).

## Reference Screenshot

![Slider](_screenshots/slider.png)

Captured from <https://ui.shadcn.com/docs/components/slider> on 2026-05-11. Refresh and update the date whenever shadcn updates the canonical look.
