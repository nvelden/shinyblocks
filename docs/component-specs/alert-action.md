# Alert Action Component Spec

> Shinyblocks function: `block_alert_action()`
> Parent component: `block_alert(action = ...)`

## Status

- **runtime slot wrapper** — `block_alert_action()` marks alert action
  content with `data-sb-child="alert-action"` and `.sb-alert-action`.
- **composition-only API** — the helper is exported so users can pass an
  explicit action slot to `block_alert(action = block_alert_action(...))`.
  It does not render as a standalone runtime component.
- **showcase coverage** — the Alert playground and parity fixtures
  demonstrate a `block_button()` composed through the action slot.

## R API

### `block_alert_action(..., class)`

| Argument | Purpose |
| --- | --- |
| `...` | Action content, usually a `block_button()` or link-like tag. |
| `class` | Optional additional classes merged onto `.sb-alert-action`. |

## Runtime mapping

`block_alert()` serializes the rendered action wrapper into
`props$actionHtml`. The React runtime places it in the Alert action
position and adds right-side padding to the alert container when an
action is present.

## Accessibility

The helper does not add roles or keyboard behavior. Interactive action
content must supply its own semantics, which is why examples compose
through `block_button()`.
