# Slider

> Shinyblocks function: `block_slider()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/slider>

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
- **min / max / current-value labels** — hidden in shinyblocks (the
  shadcn slider has none). An opt-in `show_value` variant can re-
  enable later if needed.

## Token contract

| Visual role | Token |
| --- | --- |
| Rail (track) fill | `--muted` |
| Range fill | `--primary` |
| Thumb surface | `#ffffff` (literal white, matches shadcn) |
| Thumb border | `--primary` |
| Thumb shadow | `--foreground` at 5% / 10% (shadow-sm) |
| Hover / focus ring | `--ring` at 50% opacity, 4px wide |
| Disabled opacity | `0.5` |
| Rail / range / thumb radius | `9999px` (fully rounded) |
| Rail / range height | `0.375rem` (6px) |
| Thumb size | `1rem` (16px) |

## Deliberate divergences from shadcn

- `block_slider()` wraps `shiny::sliderInput()`, which renders an
  `ion.rangeSlider` widget at runtime. shadcn's slider uses
  `@radix-ui/react-slider`. The DOM is different (Radix:
  `[data-slot="slider-track"]` / `[data-slot="slider-range"]` /
  `[data-slot="slider-thumb"]`; ion.rangeSlider: `.irs-line` /
  `.irs-bar` / `.irs-handle`). The visual contract matches; the DOM
  shape does not.
- ion.rangeSlider's edge labels (`.irs-min`, `.irs-max`) and
  current-value bubbles (`.irs-single`, `.irs-from`, `.irs-to`) are
  hidden. shadcn shows neither.
- Thumb surface is a literal `#ffffff` (matches shadcn's `bg-white`)
  rather than `--background`, so the thumb stays light in dark mode
  exactly as shadcn does it.
- No vertical orientation today. shadcn supports
  `data-orientation="vertical"`; Shiny's slider doesn't surface a
  vertical mode. Future work; track as a separate slice.
- **Source-spec vs docs-render mismatches.** `tools/parity/slider-poc.mjs`
  diffs `getComputedStyle()` against
  <https://ui.shadcn.com/docs/components/slider> and reports a few
  drifts that are *the docs page* deviating from shadcn's published
  registry rather than shinyblocks deviating from shadcn:
  - Rail and range height: docs renders **4px**, source registry
    says `h-1.5` (**6px**). shinyblocks matches the source (6px).
  - Thumb width / height: docs renders **12px**, source registry
    says `size-4` (**16px**). shinyblocks matches the source (16px).
  - Thumb shadow: docs renders `none`, source registry says
    `shadow-sm`. shinyblocks matches the source (shadow-sm).
  - Thumb border colour: docs renders the local theme's
    `--primary` (medium gray); shinyblocks renders the default
    shadcn `--primary` (very dark). Theme difference, not a
    slider-style bug.

  These will resolve when the harness pins against a local
  shadcn-react reference app per ADR 0016 §Architecture instead of
  reading from the live docs page. Tracked there.

## Reference screenshot

![Slider](_screenshots/slider.png)

Captured from <https://ui.shadcn.com/docs/components/slider> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
