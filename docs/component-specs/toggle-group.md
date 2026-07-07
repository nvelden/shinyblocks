# Toggle Group

> Shinyblocks function: `block_toggle_group()` /
> `update_block_toggle_group()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/toggle-group>
> Status: Runtime form control (issue #93). Joined (spacing-0)
> segmented control; single and multiple pressed modes.

## States

- **off** — transparent item on the group surface (`default` variant)
  or input-bordered segment (`outline` variant).
- **on / pressed** — `--accent` background with `--accent-foreground`
  text (`data-state="on"`).
- **hover** — `--muted` background (`default`) or `--accent`
  (`outline`).
- **focus-visible** — `--ring` shadow ring; the focused segment lifts
  above its joined neighbours (`z-index`).
- **disabled** — reduced opacity and no pointer interaction; group-wide
  (`disabled = TRUE`) or per item (`disabled = c("value")`).
- **server-updated** — selection, choices (with icons), disabled state,
  variant, size, style, and class update without remounting.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | `input_id` / runtime mount id | Drives `input$<id>`. |
| `choices` | `props$choices` | Label/value records, plus per-choice `icon` / `iconHtml`. |
| `selected` | `state$value` | String or `null` (single); string array (multiple). |
| `type` | `props$type` | `"single"` or `"multiple"`. Create-only: it fixes the binding's value shape. |
| `variant` | `props$variant` | `"default"` or `"outline"`. |
| `size` | `props$size` | `"default"`, `"sm"`, `"lg"`. |
| `icons` | `props$choices[].icon` / `.iconHtml` | Vendored icon name or rendered tag fragment. |
| `icon_only` | `props$iconOnly` | Create-only. Labels become `aria-label`. |
| `disabled` | `props$disabled` / `props$disabledValues` | Boolean group flag or per-item value list. |
| `style` | `props$style` | Inline style on the group wrapper. |
| `class` | `className` | Extra class on the wrapper. |

## Shiny State And Update Contract

- `input$<id>` reports through the `shinyblocks.toggle-group` binding:
  a string (or `NULL` when nothing is pressed) in single mode, a
  character vector in multiple mode (`NULL` when empty, like
  `selectInput(multiple = TRUE)`).
- A hidden native `<input type="hidden">` mirrors the value
  (comma-joined in multiple mode) as a form bridge; Shiny reads the
  package binding.
- `update_block_toggle_group()` accepts `selected`, `choices`, `icons`
  (requires `choices`), `disabled`, `variant`, `size`, `style`, and
  `class`. `selected = NULL` releases everything. A character-vector
  `disabled` re-enables the group and disables only the named items.
- Cosmetic updates never notify; selection updates notify when
  `notify = TRUE`.

## Keyboard / A11y Contract

- Root is `role="group"`; items are native `<button>`s.
- Single mode uses radio semantics per Radix: items carry
  `role="radio"` + `aria-checked`. Pressing the active item releases it
  (selection can be empty, unlike `block_radio_group()`).
- Multiple mode items carry `aria-pressed`.
- Roving tabindex: one tab stop (last focused, else first pressed, else
  first enabled item). Arrow keys and `Home`/`End` move focus without
  changing selection; `Space`/`Enter` toggle the focused item.
- Disabled items leave the roving order; `icon_only = TRUE` moves the
  label to `aria-label`.

## Token Contract

- Pressed surface: `--accent` / `--accent-foreground`.
- Hover: `--muted` / `--muted-foreground` (default variant).
- Outline borders: `--input`; focus ring: `--ring`; text:
  `--foreground`.
- Radius follows `--sb-button-radius` (outer corners only; inner edges
  stay square and outline inner borders collapse).
- Theme registry: `toggle-group` entry binds the
  `.sb-parity-toggle-group-on` showcase fixture.

## Divergences From shadcn

- shadcn's `spacing` prop is not exposed; only the joined
  (`spacing = 0`) presentation ships.
- A standalone `block_toggle()` is not exported; a one-item
  `type = "multiple"` group covers the lone pressed/unpressed button.
