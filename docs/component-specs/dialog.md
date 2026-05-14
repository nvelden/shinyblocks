# Dialog

> Shinyblocks function: `block_dialog()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/dialog>
> Status: **Phase 4.3 — accessibility hardening**. Variants and parity
> arrive in 4.4–4.5. See GitHub issue #1 for the full sub-phase
> breakdown.

## Phase 4.3 accessibility contract

- `Escape` closes the dialog (notifies the binding) and re-stops
  propagation so host hash listeners do not also fire.
- Focus is moved to the first focusable element inside the dialog
  on open; if none exist, the content container itself receives
  focus.
- `Tab` and `Shift+Tab` cycle within the dialog's focusable
  children, never escaping the modal.
- Closing the dialog returns focus to whichever element held it
  before open (typically the trigger button), preserving keyboard
  context.
- `document.body` overflow is locked while open and the previously
  used `padding-right` value is restored on close; scrollbar-width
  padding is applied to prevent layout shift.
- ARIA wiring: `role="dialog"`, `aria-modal="true"`,
  `aria-labelledby="<id>-title"`, and `aria-describedby="<id>-description"`
  when a description is present.
- `hide_title = TRUE` keeps the title in the DOM (and as the
  accessible name) but renders it inside `.sb-visually-hidden` so it
  is announced by screen readers without occupying visible space.
- Trigger button advertises `aria-haspopup="dialog"` and
  `aria-expanded` that tracks the current open state.

## Phase 4.2 contract

- Modal dialog rendered into the runtime portal root
  (`[data-shinyblocks-portal-root]`).
- Required `id`. `input$<id>` is `TRUE` when open, `FALSE` when closed.
- Required `title`. Optional `description`, body (`...`), and
  `trigger` label.
- Trigger label renders an `sb-button` next to the mount node that
  opens the dialog locally. Pass `NULL` (default) to drive open
  state purely from the server.
- Close button (`×`) and overlay click set `open = FALSE` and notify
  the binding.
- Server can call `update_block_dialog(session, id, open, title,
  description, notify)` to drive open state, update slot content, or
  silently apply cosmetic changes (`notify` defaults to `TRUE` only
  when `open` is included).
- Message routing follows the `block_select()` pattern:
  `sendInputMessage(mount_id, payload)` with the dialog binding's
  `receiveMessage` forwarding to a component-installed
  `el.__sbDialogReceive`.
- No focus management, scroll lock, escape key, or focus trap yet
  (arrives in 4.3).

## Token contract

| Visual role | Token |
| --- | --- |
| Overlay | `rgb(0 0 0 / 0.5)` (hardcoded; tokenized in 4.3) |
| Content surface | `--background` |
| Content foreground | `--foreground` |
| Border | `--border` |
| Description text | `--muted-foreground` |
| Close-button hover | `--accent` / `--accent-foreground` |

## Slots (4.1)

| Slot | Source | Notes |
| --- | --- | --- |
| `titleHtml` | `title` arg | Required. Serialized via `html_fragment()`. |
| `descriptionHtml` | `description` arg | Optional. |
| `bodyHtml` | `...` | Serialized in 4.1; will become Shiny-bound children in 4.2+. |

## Planned divergences from shadcn

- React component is package-local; we do not ship `@radix-ui/react-dialog`.
- The close button is a `<button>` with `aria-label="Close"` rather
  than a `DialogPrimitive.Close` slot.

## Reference screenshot

Pending — capture and add under `_screenshots/dialog.png` during 4.5.
