# Dialog

> Shinyblocks function: `block_dialog()` / `update_block_dialog()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/dialog>
> Status: Runtime overlay component; Phase 7 spec refreshed around the
> shipped API, state bridge, accessibility contract, and divergences.

## States

- **closed** — only the optional trigger button is visible.
- **open** — overlay and content render into
  `[data-shinyblocks-portal-root]`.
- **dismissed by interaction** — overlay click, close button, or
  `Escape` closes the dialog and notifies Shiny.
- **server-updated** — `update_block_dialog()` can open/close,
  replace title/description/footer content, and resize the content
  without remounting.
- **sized** — content width uses `"sm"`, `"default"`, `"lg"`, or
  `"xl"` via `data-size` and `sb-dialog-content-size-*`.
- **title-hidden** — `hide_title = TRUE` keeps the accessible name in
  the DOM while visually hiding it.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `id` | `input_id` / runtime mount id | Required; drives `input$<id>`. |
| `title` | `props$titleHtml` | Required accessible name. |
| `description` | `props$descriptionHtml` | Optional `aria-describedby` source. |
| `...` | `props$bodyHtml` | Dialog body HTML. |
| `footer` | `props$footerHtml` | Optional action/footer region. |
| `trigger` | `props$triggerLabel` | Optional local opener button. |
| `open` | `state$open`, `state$value` | Initial Shiny/open state. |
| `size` | `props$size` | `"sm"`, `"default"`, `"lg"`, `"xl"`. |
| `hide_title` | `props$hideTitle` | Applies `.sb-visually-hidden`. |
| `class` | `className` | Merged onto dialog content. |

## Shiny State And Update Contract

- `input$<id>` is `TRUE` when open and `FALSE` when closed.
- The runtime registers a dialog input binding and routes
  `sendInputMessage()` payloads to `el.__sbDialogReceive`.
- `update_block_dialog()` accepts `open`, `title`, `description`,
  `footer`, and `size`.
- Cosmetic updates do not notify. Open/close updates notify only when
  `notify = TRUE`.
- Passing `footer = NULL` clears an existing footer.

## Accessibility

- Content carries `role="dialog"` and `aria-modal="true"`.
- `aria-labelledby` points at the runtime title slot.
- `aria-describedby` points at the description slot when present.
- Opening moves focus into the dialog; closing returns focus to the
  previously focused element.
- `Tab` and `Shift+Tab` cycle inside the dialog.
- Body scroll is locked while the dialog is open and restored on close.
- Trigger button advertises `aria-haspopup="dialog"` and live
  `aria-expanded`.

## Token Contract

| Visual role | Token |
| --- | --- |
| Overlay | `rgb(0 0 0 / 0.5)` |
| Content surface | `--background` |
| Content foreground | `--foreground` |
| Border | `--border` |
| Description text | `--muted-foreground` |
| Close-button hover | `--accent`, `--accent-foreground` |

## Deliberate Divergences From Shadcn

- React runtime is package-local (`component = "dialog"`); shinyblocks
  does not ship `@radix-ui/react-dialog`.
- `block_dialog()` uses flat `title`, `description`, `footer`, and
  body arguments instead of exported dialog subcomponent helpers.
- Content is currently serialized HTML, not live Shiny-bound children.
- The overlay color is a fixed translucent black rather than a token.
- No animated open/close transition yet.

## Reference Screenshot

Pending — capture and add under `_screenshots/dialog.png` during the
Phase 7 screenshot refresh.
