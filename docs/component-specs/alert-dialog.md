# Alert dialog

> Shinyblocks function: `block_alert_dialog()` / `update_block_alert_dialog()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/alert-dialog>

## States

- **closed** — optional trigger remains in flow; content is not mounted.
- **open** — modal scrim, title, optional description/body, cancel, and confirm.
- **destructive** — confirmation action uses the destructive button variant.
- **resolved** — `input$<id>` emits `"confirm"` or `"cancel"`; Escape cancels.

## Runtime mapping

| R argument | Runtime prop | Behavior |
| --- | --- | --- |
| `title`, `description`, `...` | HTML props | Accessible heading, copy, and optional body. |
| `confirm_label`, `cancel_label` | label props | Explicit resolution actions. |
| `confirm_variant` | `confirmVariant` | Default or destructive button styling. |
| `trigger`, `open`, `size` | trigger/state/size | Local or server-controlled opening and width. |

## Accessibility

- Content uses `role="alertdialog"`, `aria-modal`, labelled title, and description.
- Focus starts on Cancel, is trapped while open, and returns to the opener.
- Escape reports cancel. Pointer interaction with the backdrop is ignored.

## Token contract

- Surface/border/text reuse dialog tokens and semantic background/foreground.
- Actions reuse outline/default/destructive button tokens; no literal colors.

## Divergences

- One opinionated R constructor replaces shadcn's composable React parts.
- Outcome events are the public Shiny value; open state is updater-controlled.

## Reference screenshot

Pending — capture under `_screenshots/alert-dialog.png` on the next visual audit.
