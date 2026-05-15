# Textarea

> Shinyblocks function: `block_textarea()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/textarea>
> Status: **Phase 5.7 — runtime textarea migration**.

## States

- **default** — full-width multiline control with shadcn textarea
  spacing, radius, border, and text sizing.
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

- `input$<input_id>` reports the current textarea value through the
  `shinyblocks.textarea` input binding (debounced 250 ms).
- `update_block_textarea()` supports server-driven updates for
  `value`, `placeholder`, `rows`, `disabled`, `invalid`, `style`, and
  `class` with optional `notify` semantics.

## Deliberate divergences from shadcn

- React runtime is package-local (`component = "textarea"`); we do not
  ship Radix/shadcn primitives.
- A hidden native `<textarea>` remains in the mount so screen readers
  and form-submission flows still see a real textarea. Shiny input
  wiring is handled by a component-specific
  `ShinyblocksTextareaBinding` (`shinyblocks.textarea`) instead of
  Shiny's default textarea binding.

## Reference screenshot

Pending — capture and add under `_screenshots/textarea.png` during the
runtime parity-harness rewrite (Phase 7).
