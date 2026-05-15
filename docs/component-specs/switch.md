# Switch

> Shinyblocks function: `block_switch()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/switch>
> Status: **Phase 5.5 - runtime switch migration**.

## States

- **default** — rounded track with a thumb at the leading edge and
  inline label text.
- **checked** — primary-filled track with the thumb translated to the
  trailing edge.
- **focus-visible** — 3px `--ring` shadow at 50% opacity around the
  track.
- **disabled** — reduced opacity for both track and label.
- **invalid** — destructive-tinted border when wrapped in
  `block_field_invalid()`.

## Token contract

| Visual role | Token |
| --- | --- |
| Track off | `--input` |
| Track on | `--primary` |
| Thumb | `--background` |
| Text | `--foreground` |
| Focus ring | `--ring` |
| Invalid border | `--destructive`, `--border` |

## Deliberate divergences from shadcn

- React runtime is package-local (`component = "switch"`); we do not
  ship Radix switch primitives.
- A hidden native `<input type="checkbox">` remains in the mount so the
  Shiny-side value source stays native while the visible shell matches
  shadcn styling.
- Shiny input wiring is handled by a component-specific
  `ShinyblocksSwitchBinding` (`shinyblocks.switch`) instead of relying on
  Shiny's default checkbox binding.

## Reference screenshot

![Switch](_screenshots/switch.png)

Captured from <https://ui.shadcn.com/docs/components/switch> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
