# Checkbox

> Shinyblocks function: `block_checkbox()` / `update_block_checkbox()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/checkbox>
> Status: Runtime form control; Phase 7 spec refreshed around shipped
> API, Shiny state bridge, and update contract.

## States

- **unchecked** — square control with input-coloured border, subtle
  shadow, and inline label text.
- **checked** — primary-filled surface with a visible check mark.
- **focus-visible** — 3px `--ring` shadow at 50% opacity with the
  control border promoted to `--ring`.
- **disabled** — reduced opacity for both control and label.
- **invalid** — destructive-tinted border/ring when a parent field
  marks the control invalid.
- **server-updated** — server can replace checked state, disabled
  state, style, and class without remounting.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | `input_id` / runtime mount id | Drives `input$<id>`. |
| `label` | `props$labelHtml` | Inline label HTML. |
| `value` | `state$value` | Initial checked state. |
| `disabled` | `props$disabled` | Disables rendered checkbox. |
| `style` | `props$style` | Inline style on visible checkbox shell. |
| `class` | `className` | Extra class on wrapper. |

## Shiny State And Update Contract

- `input$<id>` reports `TRUE` when checked and `FALSE` when unchecked
  through the `shinyblocks.checkbox` binding.
- A hidden native `<input type="checkbox">` remains in the runtime
  mount as a form bridge, but Shiny reads the package binding.
- `update_block_checkbox()` accepts `checked`, `disabled`, `style`,
  and `class`.
- Cosmetic updates do not notify. Checked-state updates notify only
  when `notify = TRUE`.
- Passing `style = NULL` or `class = NULL` clears that field.

## Token Contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Text | `--foreground` |
| Border | `--input` |
| Checked fill | `--primary` |
| Check mark | `--primary-foreground` |
| Focus ring | `--ring` |
| Invalid border/ring | `--destructive`, `--border` |

## Deliberate Divergences From Shadcn

- React runtime is package-local (`component = "checkbox"`); shinyblocks
  does not ship `@radix-ui/react-checkbox`.
- Hidden native checkbox markup is retained for form submission and
  assistive technology compatibility, while the visible control is
  owned by the runtime.
- Invalid styling is field-driven today; `block_checkbox()` itself does
  not expose an `invalid` argument.

## Reference Screenshot

![Checkbox](_screenshots/checkbox.png)

Captured from <https://ui.shadcn.com/docs/components/checkbox> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
