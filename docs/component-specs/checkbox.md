# Checkbox

> Shinyblocks function: `block_checkbox()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/checkbox>
> Status: **Phase 5.6 — popover/checkbox/switch parity + cleanup**.

## States

- **default** — square control with border, subtle shadow, and inline
  label text.
- **checked** — primary-filled surface with a visible check mark.
- **focus-visible** — 3px `--ring` shadow at 50% opacity with the
  indicator border promoted to `--ring`.
- **disabled** — reduced opacity for both indicator and label.
- **invalid** — destructive-tinted border when wrapped in
  `block_field_invalid()`.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Text | `--foreground` |
| Border | `--input` |
| Checked fill | `--primary` |
| Check mark | `--primary-foreground` |
| Focus ring | `--ring` |
| Invalid border | `--destructive`, `--border` |

## Deliberate divergences from shadcn

- React runtime is package-local (`component = "checkbox"`); we do not
  ship Radix checkbox primitives.
- A hidden native `<input type="checkbox">` remains in the mount so the
  Shiny-side value source stays native while the visible shell matches
  shadcn styling.
- Shiny input wiring is handled by a component-specific
  `ShinyblocksCheckboxBinding` (`shinyblocks.checkbox`) instead of
  relying on Shiny's default checkbox binding.

## Reference screenshot

![Checkbox](_screenshots/checkbox.png)

Captured from <https://ui.shadcn.com/docs/components/checkbox> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
