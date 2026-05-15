# Radio group

> Shinyblocks function: `block_radio_group()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/radio-group>
> Status: **Phase 5.9 — runtime radio group**.

## States

- **default** — circular control with input-coloured border per item
  and a label rendered to the right.
- **checked** — primary-coloured border with a primary-filled inner
  dot.
- **focus-visible** — 3px `--ring` shadow at 50% opacity.
- **disabled** — reduced opacity, no pointer interaction; arrow-key
  navigation is suppressed.
- **invalid** — destructive-tinted control border on every item when
  the wrapper is `aria-invalid`.

## Token contract

| Visual role | Token |
| --- | --- |
| Control border (unchecked) | `--input` |
| Control border (checked) | `--primary` |
| Indicator | `--primary` |
| Text | `--foreground` |
| Focus ring | `--ring` |
| Invalid border | `--destructive` |

## Server contract

- `input$<input_id>` reports the currently selected value through the
  `shinyblocks.radio-group` input binding.
- `update_block_radio_group()` supports server-driven updates for
  `selected`, `choices`, `disabled`, `invalid`, `orientation`,
  `style`, and `class` with optional `notify` semantics.
- Arrow keys (Up / Down / Left / Right) move the selected option;
  Space and Enter re-fire the current selection.

## Deliberate divergences from shadcn

- React runtime is package-local (`component = "radio-group"`); we do
  not ship `@radix-ui/react-radio-group`.
- A hidden native `<input type="hidden">` carries the selected value
  for form submission flows; Shiny input wiring is handled by a
  component-specific `ShinyblocksRadioGroupBinding` instead of
  Shiny's default radio binding.

## Reference screenshot

Pending — capture and add under `_screenshots/radio-group.png` during
the runtime parity-harness rewrite (Phase 7).
