# Input

> Shinyblocks function: `block_input()` / `update_block_input()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/input>
> Status: Runtime form control; Phase 7 spec refreshed around shipped
> API, Shiny state bridge, and update contract.

## States

- **default** — single-line text control with shadcn input height,
  padding, radius, border, and text sizing.
- **placeholder** — muted foreground placeholder text.
- **focus-visible** — 3px `--ring` shadow at 50% opacity with the
  border promoted to `--ring`.
- **disabled** — reduced opacity and no pointer interaction.
- **invalid** — destructive-tinted border/ring when `invalid = TRUE`
  or when a parent field marks the control invalid.
- **server-updated** — server can replace value, placeholder, type,
  disabled state, invalid state, style, and class without remounting.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | `input_id` / runtime mount id | Drives `input$<id>`. |
| `value` | `state$value` | Initial text value. |
| `placeholder` | `props$placeholder` | Optional prompt text. |
| `type` | `props$type` | `text`, `password`, `email`, `url`, `tel`, `search`, or `number`. |
| `width` | mount `style` | Wrapper width. |
| `disabled` | `props$disabled` | Disables rendered input. |
| `invalid` | `props$invalid` | Applies invalid state. |
| `style` | `props$style` | Inline style on visible input. |
| `class` | `className` | Extra class on wrapper. |

## Shiny State And Update Contract

- `input$<id>` reports the current value through the
  `shinyblocks.input` binding.
- User input is debounced by 250 ms before notifying Shiny.
- A hidden native `<input>` remains in the runtime mount as a form
  and accessibility bridge, but Shiny reads the package binding.
- `update_block_input()` accepts `value`, `placeholder`, `type`,
  `disabled`, `invalid`, `style`, and `class`.
- Cosmetic updates do not notify. Value updates notify only when
  `notify = TRUE`.
- Passing `value = NULL` clears to `""`; passing `style = NULL` or
  `class = NULL` clears that field.

## Token Contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Text | `--foreground` |
| Placeholder | `--muted-foreground` |
| Border | `--input` |
| Focus ring | `--ring` |
| Invalid border/ring | `--destructive` |

## Deliberate Divergences From Shadcn

- React runtime is package-local (`component = "input"`); shinyblocks
  does not ship a separate shadcn/Radix primitive.
- Hidden native input markup is retained for form submission and
  assistive technology compatibility, while the visible control is
  owned by the runtime.

## Reference Screenshot

Pending — capture and add under `_screenshots/input.png` during the
Phase 7 screenshot refresh.
