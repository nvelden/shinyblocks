# Radio Group

> Shinyblocks function: `block_radio_group()` /
> `update_block_radio_group()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/radio-group>
> Status: Runtime form control; Phase 7 spec refreshed around shipped
> API, Shiny state bridge, and update contract.

## States

- **default** — circular control with input-coloured border per item
  and a label rendered to the right.
- **checked** — primary-coloured border with a primary-filled inner
  dot.
- **focus-visible** — 3px `--ring` shadow at 50% opacity on the
  focused control.
- **disabled** — reduced opacity and no pointer interaction; keyboard
  navigation is suppressed.
- **invalid** — destructive-tinted control border when `invalid = TRUE`.
- **horizontal / vertical** — orientation controls item layout and
  keyboard navigation direction.
- **server-updated** — server can replace selection, choices,
  disabled state, invalid state, orientation, style, and class without
  remounting.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | `input_id` / runtime mount id | Drives `input$<id>`. |
| `choices` | `props$choices` | Normalized label/value records. |
| `selected` | `state$value` | Initial selected value. |
| `disabled` | `props$disabled` | Disables the group. |
| `invalid` | `props$invalid` | Applies invalid state. |
| `orientation` | `props$orientation` | `"vertical"` or `"horizontal"`. |
| `style` | `props$style` | Inline style on group wrapper. |
| `class` | `className` | Extra class on wrapper. |

## Shiny State And Update Contract

- `input$<id>` reports the selected value through the
  `shinyblocks.radio-group` binding.
- A hidden native `<input type="hidden">` remains in the runtime mount
  as a form bridge, but Shiny reads the package binding.
- `update_block_radio_group()` accepts `selected`, `choices`,
  `disabled`, `invalid`, `orientation`, `style`, and `class`.
- Cosmetic updates do not notify. Selection updates notify only when
  `notify = TRUE`.
- Passing `selected = NULL` clears the selected value when allowed by
  the runtime update path.
- Passing `style = NULL` or `class = NULL` clears that field.

## Keyboard Contract

- Arrow keys move selection between enabled choices.
- `Home` and `End` jump to the first and last choices.
- Space and Enter re-fire the current selection.
- Disabled groups suppress pointer and keyboard selection changes.

## Token Contract

| Visual role | Token |
| --- | --- |
| Control border unchecked | `--input` |
| Control border checked | `--primary` |
| Indicator | `--primary` |
| Text | `--foreground` |
| Focus ring | `--ring` |
| Invalid border | `--destructive` |

## Deliberate Divergences From Shadcn

- React runtime is package-local (`component = "radio-group"`);
  shinyblocks does not ship `@radix-ui/react-radio-group`.
- Hidden native input markup is retained for form submission and
  assistive technology compatibility, while the visible control is
  owned by the runtime.

## Reference Screenshot

Pending — capture and add under `_screenshots/radio-group.png` during
the Phase 7 screenshot refresh.
