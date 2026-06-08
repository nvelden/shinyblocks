# File Input

> Shinyblocks function: `block_file_input()`
> Shadcn reference: none; styled from shadcn input/button conventions.
> Status: Runtime form control that deliberately reuses Shiny's native
> `FileUploadBinding`.

## States

- **default** — input-like border/surface with a secondary picker button
  and filename text.
- **placeholder** — muted filename text before a file is selected.
- **focus-visible** — parent control shows the standard `--ring` focus
  treatment when the button receives focus.
- **disabled** — visible button and native file input are disabled.
- **invalid** — destructive border/ring when `invalid = TRUE` or a
  parent field marks the control invalid.
- **selected** — filename text mirrors the browser-selected file names.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | native input `id` | Drives Shiny's native upload binding. |
| `multiple` | `props$multiple` + native attr | Allows multiple files. |
| `accept` | `props$accept` + native attr | Character vector comma-joined. |
| `button_label` | `props$buttonLabel` | Visible trigger text. |
| `placeholder` | `props$placeholder` | Empty-state filename text. |
| `width` | mount `style` | Wrapper width. |
| `disabled` | `props$disabled` + native attr | Disables both picker surfaces. |
| `invalid` | `props$invalid` | Applies invalid state. |
| `style` | `props$style` | Inline style on visible control. |
| `class` | `className` | Extra class on visible control. |

## Shiny State And Update Contract

- R emits a real `<input type="file" class="shiny-input-file">` and
  Shiny progress markup into `[data-shinyblocks-children]`.
- React renders only the styled picker under `[data-shinyblocks-react]`
  and forwards button clicks to the native input.
- `input$<id>` is Shiny's standard upload data frame with `name`,
  `size`, `type`, and `datapath`.
- No `update_block_file_input()` ships in v1, matching Shiny's lack of
  `updateFileInput()`.

## Token Contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Text | `--foreground` |
| Placeholder | `--muted-foreground` |
| Border | `--input` |
| Button surface/text | `--secondary` / `--secondary-foreground` |
| Focus ring | `--ring` |
| Invalid border/ring | `--destructive` |

## Deliberate Divergences From Shadcn

- There is no shadcn file input primitive to port directly.
- Upload transport and progress intentionally stay with Shiny's native
  file upload binding instead of a shinyblocks custom binding.
- The native file input is visually hidden but bindable; it must not use
  `data-shiny-no-bind-input`.

## Reference Screenshot

Pending — no canonical shadcn file input screenshot exists.
