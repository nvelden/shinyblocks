# Input

> Shinyblocks function: `block_input()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/input>
> Status: **Phase 5.8 — runtime text input**.

## States

- **default** — single-line text control with shadcn input height,
  padding, radius, border, and text sizing.
- **placeholder** — muted foreground placeholder text inside the
  control.
- **focus-visible** — 3px `--ring` shadow at 50% opacity with the
  border promoted to `--ring`.
- **disabled** — reduced opacity and no pointer interaction.
- **invalid** — destructive-tinted border when `invalid = TRUE` (or
  when wrapped in `block_field_invalid()`).

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Text | `--foreground` |
| Placeholder | `--muted-foreground` |
| Border | `--input` |
| Focus ring | `--ring` |
| Invalid border | `--destructive` |

## Server contract

- `input$<input_id>` reports the current input value through the
  `shinyblocks.input` input binding (debounced 250 ms).
- `update_block_input()` supports server-driven updates for
  `value`, `placeholder`, `type`, `disabled`, `invalid`, `style`, and
  `class` with optional `notify` semantics.

## Deliberate divergences from shadcn

- React runtime is package-local (`component = "input"`); we do not
  ship Radix/shadcn primitives.
- A hidden native `<input>` remains in the mount so screen readers
  and form-submission flows still see a real input. Shiny input
  wiring is handled by a component-specific
  `ShinyblocksInputBinding` (`shinyblocks.input`) instead of
  Shiny's default text-input binding.

## Reference screenshot

Pending — capture and add under `_screenshots/input.png` during the
runtime parity-harness rewrite (Phase 7).
