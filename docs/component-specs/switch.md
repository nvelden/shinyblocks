# Switch

> Shinyblocks function: `block_switch()` / `update_block_switch()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/switch>
> Status: Runtime form control; Phase 7 spec refreshed around shipped
> API, Shiny state bridge, and update contract.

## States

- **off** — rounded input-coloured track with the thumb at the leading
  edge and inline label text.
- **on** — primary-filled track with the thumb translated to the
  trailing edge.
- **focus-visible** — 3px `--ring` shadow at 50% opacity around the
  track.
- **disabled** — reduced opacity for both track and label.
- **invalid** — destructive-tinted border/ring when a parent field
  marks the control invalid.
- **size** — `sm`, `default`, and `lg` sizes keep the same horizontal
  switch pattern with scaled track, thumb, gap, and label text.
- **server-updated** — server can replace checked state, disabled
  state, size, style, and class without remounting.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | `input_id` / runtime mount id | Drives `input$<id>`. |
| `label` | `props$labelHtml` | Inline label HTML. |
| `value` | `state$value` | Initial on/off state. |
| `disabled` | `props$disabled` | Disables rendered switch. |
| `size` | `props$size` | One of `default`, `sm`, or `lg`. |
| `style` | `props$style` | Inline style on visible switch shell. |
| `class` | `className` | Extra class on wrapper. |

## Shiny State And Update Contract

- `input$<id>` reports `TRUE` when on and `FALSE` when off through the
  `shinyblocks.switch` binding.
- A hidden native `<input type="checkbox">` remains in the runtime
  mount as a form bridge, but Shiny reads the package binding.
- `update_block_switch()` accepts `checked`, `disabled`, `size`,
  `style`, and `class`.
- Cosmetic updates do not notify. Checked-state updates notify only
  when `notify = TRUE`.
- Passing `style = NULL` or `class = NULL` clears that field.

## Token Contract

| Visual role | Token |
| --- | --- |
| Track off | `--input` |
| Track on | `--primary` |
| Thumb | `--background` |
| Text | `--foreground` |
| Focus ring | `--ring` |
| Invalid border/ring | `--destructive`, `--border` |

## Deliberate Divergences From Shadcn

- React runtime is package-local (`component = "switch"`); shinyblocks
  does not ship `@radix-ui/react-switch`.
- Hidden native checkbox markup is retained for form submission and
  assistive technology compatibility, while the visible control is
  owned by the runtime.
- Shadcn's canonical Switch does not provide a vertical switch API.
  `shinyblocks` follows that horizontal contract and adds only package
  size presets for dashboard density.
- Invalid styling is field-driven today; `block_switch()` itself does
  not expose an `invalid` argument.

## Reference Screenshot

![Switch](_screenshots/switch.png)

Captured from <https://ui.shadcn.com/docs/components/switch> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
