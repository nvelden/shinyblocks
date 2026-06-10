# Toaster

> Shinyblocks functions: `block_toaster()`, `show_toast()`, `dismiss_toast()`,
> `update_block_toaster()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/sonner>
> Status: Runtime overlay; server-driven broadcast region (see
> `docs/agent-plans/2026-06-09-toast-notifications.md`). Toast surfaces reuse the
> `block_alert()` variant + icon contract.

## Concept

Unlike `block_alert()` (inline static content), a toaster is **not** placed
where a message should appear. Mount one `block_toaster(id)` per screen position,
then fire transient toasts from the server with `show_toast()`. This mirrors
shadcn's Sonner model: a single `<Toaster />` plus an imperative `toast()` call.

The mounted element carries a Shiny input binding, so `show_toast()` /
`dismiss_toast()` reach it through the same `sendInputMessage` bridge the dialog
and popover updaters use. React owns the stack, per-toast auto-dismiss timers,
and dismissal. `input$<id>` reports the most recent toast lifecycle event as a
list `{ action, id, seq }`: `action` is `"show"` or `"dismiss"`, `id` is the
toast id (`NULL` when all toasts are dismissed), and `seq` is a monotonic
counter so the value changes on every show/dismiss — including auto-dismiss, the
close button, and `Escape`.

## States

- **default** — bordered surface with optional leading icon, title, description.
- **destructive** — destructive-tinted border and foreground; announced
  assertively (`role="alert"`).
- **success / warning / info** — feedback-state surfaces using the matching
  semantic tokens, identical to `block_alert()`.
- **hover / focus** — auto-dismiss timer pauses while the toast is hovered or
  its close button is focused, and resumes on leave/blur.
- **dismissible** — shows a close button; `Escape` dismisses from the focused
  close button.
- **sticky** — `duration = 0` keeps the toast until dismissed.

## R API

### `block_toaster()`

| Argument | Purpose |
| --- | --- |
| `id` | Required input id. Targets the toaster from `show_toast()` / `dismiss_toast()` and reports lifecycle events `{ action, id, seq }` to `input$<id>`. |
| `position` | Screen anchor: `top-left`, `top-center`, `top-right`, `bottom-left`, `bottom-center`, `bottom-right`. Defaults to `bottom-right`. |
| `class` | Extra classes merged onto the toaster region. |
| `style` | Inline styles for the toaster region. |

### `show_toast()`

| Argument | Purpose |
| --- | --- |
| `session` | Shiny session. Defaults to the current reactive session. |
| `toaster_id` | Target `block_toaster()` id. |
| `title` | Toast title. Required. String, tag, or `block_alert_title()`. |
| `description` | Optional secondary text. |
| `variant` | One of `default`, `destructive`, `success`, `warning`, `info`. |
| `icon` | Icon tag or vendored name (forced `inline-start`). `NULL` omits it. |
| `duration` | Milliseconds before auto-dismiss. `0` keeps it until dismissed. |
| `dismissible` | Whether the toast shows a close button. |
| `id` | Optional stable toast id (auto-generated otherwise) for later dismissal. |

Returns the toast `id` invisibly.

### `dismiss_toast()`

| Argument | Purpose |
| --- | --- |
| `session` | Shiny session. |
| `toaster_id` | Target `block_toaster()` id. |
| `toast_id` | Toast to dismiss. `NULL` dismisses all visible toasts. |

### `update_block_toaster()`

| Argument | Purpose |
| --- | --- |
| `session` | Shiny session. |
| `toaster_id` | Target `block_toaster()` id. |
| `position` | New screen anchor; moves the region without re-mounting it. |

## Runtime mapping

| R input | Runtime payload |
| --- | --- |
| `block_toaster(position)` | `props$position` |
| `show_toast(...)` | `{ action: "add", toast: {...} }` |
| `dismiss_toast(toast_id)` | `{ action: "dismiss", toastId }` (`toastId` null = all) |
| `update_block_toaster(position)` | `{ action: "config", position }` |
| `title` | `toast.titleHtml` |
| `description` | `toast.descriptionHtml` |
| `icon` | `toast.iconHtml` |
| `variant` | `toast.variant` |
| `duration` | `toast.duration` |
| `dismissible` | `toast.dismissible` |

Title and description tags carrying `data-sb-child="alert-title"` /
`data-sb-child="alert-description"` are reused in place; bare strings are wrapped
with the alert title/description builders.

## Accessibility

- Each toast renders `role="alert"` (destructive) or `role="status"` (others)
  so assistive tech announces it; the destructive variant is assertive.
- Dismissible toasts expose a focusable close button; `Escape` dismisses from
  that focused control.
- The close button has an `aria-label="Dismiss"`.
- The toaster container ignores pointer events so it never blocks the app; each
  toast re-enables them.

## Token contract

Identical to `block_alert()`:

| Visual role | Token |
| --- | --- |
| Default surface | `--card` |
| Default text | `--card-foreground` |
| Default border | `--border` |
| Destructive foreground | `--destructive` |
| Destructive border | `--destructive-border` |
| Feedback surface | `--success` / `--warning` / `--info` |
| Feedback text / border | matching `-foreground` / `-border` token |
| Radius | `--sb-toast-radius` (profile token `toaster_radius`, defaults to `--radius`) |

## Deliberate divergences from shadcn

- shadcn's Sonner is a client-only imperative API; shinyblocks toasts are fired
  from the **server** so Shiny apps trigger them from observers.
- Toast surfaces reuse the `block_alert()` variant treatment rather than
  Sonner's neutral surface, giving variant parity with `block_alert()`.
- Rich/promise/action toasts are out of scope for the initial release.

## Reference screenshot

![Toaster](_screenshots/toaster.png)

Capture from <https://ui.shadcn.com/docs/components/sonner> and update the date
whenever shadcn updates the canonical look.
