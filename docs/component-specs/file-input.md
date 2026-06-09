# File Input

> Shinyblocks function: `block_file_input()`
> Shadcn reference: none; styled from shadcn input/button conventions.
> Status: Runtime form control that deliberately reuses Shiny's native
> `FileUploadBinding`.

## Variants

- **button** (default) — input-like control with a secondary picker button
  and filename text.
- **dropzone** — a focusable drag-and-drop surface (dashed border) that
  forwards clicks/Enter/Space to the native picker and accepts dropped files.
  Cosmetic chrome over the **same** native Shiny upload binding; `input$<id>`
  is identical to the button variant.

## States

- **default** — input-like border/surface (button) or dashed surface
  (dropzone) with filename text.
- **placeholder** — muted filename text before a file is selected.
- **focus-visible** — control shows the standard `--ring` focus treatment
  (button focus for `"button"`, the dropzone itself is a tab stop for
  `"dropzone"`).
- **dragover** — dropzone shows an active solid `--ring` border and accent
  surface while a drag is over it.
- **reject** — dropzone pulses a `--destructive` border/surface when every
  dropped file fails the `accept` filter; the prior selection is kept.
- **disabled** — visible picker/dropzone and native file input are disabled;
  drops are ignored.
- **invalid** — destructive border/ring when `invalid = TRUE` or a
  parent field marks the control invalid.
- **selected** — filename text mirrors the browser-selected file names.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | native input `id` | Drives Shiny's native upload binding. |
| `variant` | `props$variant` | `"button"` or `"dropzone"`. |
| `multiple` | `props$multiple` + native attr | Allows multiple files. |
| `accept` | `props$accept` + native attr | Character vector comma-joined; also gates dropped files. |
| `button_label` | `props$buttonLabel` | Visible trigger text (button variant). |
| `placeholder` | `props$placeholder` | Empty-state filename text. |
| `dropzone_label` | `props$dropzoneLabel` | Primary dropzone text (dropzone variant). |
| `dropzone_hint` | `props$dropzoneHint` | Secondary dropzone hint (dropzone variant). |
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
  `size`, `type`, and `datapath` — identical for both variants.
- `update_block_file_input()` ships
  (`R/form-controls.R`). It updates cosmetic/stateful props (`variant`,
  `button_label`, `placeholder`, `dropzone_label`, `dropzone_hint`,
  `accept`, `multiple`, `disabled`, `invalid`, `style`, `class`) and can
  clear the current selection with `reset = TRUE`. As with Shiny's lack of
  `updateFileInput()`, it cannot set the file value itself from the server.

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
- The `"dropzone"` variant adds no new transport: on drop the runtime builds
  a fresh `DataTransfer` from the accepted files (filtered by `accept`,
  trimmed to one when `multiple = FALSE`), assigns `native.files`, and
  dispatches a bubbling `change` so the unchanged native binding uploads.
  Disabled dropzones ignore drops; an all-rejected drop fires no event.

## Reference Screenshot

Pending — no canonical shadcn file input screenshot exists.
