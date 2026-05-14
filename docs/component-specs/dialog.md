# Dialog

> Shinyblocks function: `block_dialog()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/dialog>
> Status: **Phase 4.1 skeleton** — see GitHub issue #1 for the
> sub-phase breakdown (Shiny binding, trigger, a11y behaviors,
> variants/slots, and parity arrive in 4.2–4.5).

## Phase 4.1 contract

- Modal dialog rendered into the runtime portal root
  (`[data-shinyblocks-portal-root]`).
- Initial open state only — controlled by the `open` argument.
- Required `title`. Optional `description` and body (`...`).
- Static close button (`×`) and overlay click both toggle local
  visibility; there is no `input$<id>` binding yet.
- No focus management, no escape/outside-click outside of the local
  close handlers, no scroll lock.

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
