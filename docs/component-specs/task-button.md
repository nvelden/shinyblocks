# Task Button

> Shinyblocks function: `block_task_button()` / `update_block_task_button()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/button> (visuals)
> Behavioral reference: bslib `input_task_button()`
> Status: Runtime input component; Slice 2 (full API + lifecycle hardening).

A task button is an action button that locks itself the instant it is
clicked, shows a busy label and spinner while work runs, and reports a
`shinyActionButtonValue`. By default it returns to ready after the reactive
flush the click triggered; with `auto_reset = FALSE` it stays busy until the
server releases it via `update_block_task_button(state = "ready")`.

There is no canonical shadcn task-button. The visuals reuse the shadcn Button
contract (`block_button()`); the behavior follows bslib's `input_task_button()`.

## States

- **ready** — renders exactly like `block_button()` for the chosen variant /
  size; reports the click count and accepts clicks.
- **busy** — `disabled`, `data-state="busy"`, `aria-busy="true"`. Shows a
  decorative spinner (or `icon_busy`) and the `label_busy` text. The accessible
  name becomes `label_busy`.
- **disabled** — author-disabled (`disabled = TRUE` or
  `update_block_task_button(disabled = TRUE)`). Returning to ready never
  re-enables a button the author disabled: ready-state disabled is
  `authorDisabled || state == "busy"`.
- **focus-visible / invalid** — inherited from the shared `.sb-button` styles.

## Behavior

- **Synchronous click lock.** React `setState` is async, so the click binding
  mutates the real button (`disabled`, `data-state`, `aria-busy`) in the same
  tick as the click, then schedules React reconciliation. A rapid second click
  is rejected before it can reach the server, so the server observer fires once.
- **Automatic reset.** When `auto_reset = TRUE` (default), the typed input
  handler schedules a single `session$onFlush()` callback that sends
  `state = "ready"` — unless that input is under manual control.
- **Manual control.** `update_block_task_button(state = "busy")` records the
  input in a session-local manual-reset map (keyed by the namespaced input id),
  so the automatic reset leaves it busy. `state = "ready"` clears the entry and
  releases the button. Two sessions using the same local id stay independent.
- **Instance churn.** Each client mount reports a unique mount id with its
  value. When a new instance binds to a reused input id (renderUI / removeUI /
  insertUI), the handler sees the changed mount id and clears any manual state
  the removed instance left behind — so a fresh button is never stuck busy by a
  predecessor's stale flag. (The mount id changes even when the click count is
  unchanged, so it survives Shiny's value deduplication.)

## Accessibility

- The button carries `aria-busy` while busy; the spinner is decorative
  (`aria-hidden`, no status role).
- One persistent, visually-hidden `role="status"` / `aria-live="polite"` region
  sits next to the button. It is empty while ready and announces `label_busy`
  while busy.
- The visible busy label is `aria-hidden` to avoid a duplicate announcement.
- While busy the button's accessible name is the validated `label_busy`;
  author labeling is restored when ready.

## R API

### `block_task_button(input_id, label, label_busy, variant, size, icon, icon_busy, icon_position, auto_reset, ..., class)`

| Argument | Purpose |
| --- | --- |
| `input_id` | **Required.** Read the click count with `input[[input_id]]`. The busy/ready behavior depends on a Shiny input binding. |
| `label` | Ready-state label (string or tag). |
| `label_busy` | Accessible + visible label shown while busy. Length-1 string, default `"Processing…"`. |
| `variant` | One of `default`, `secondary`, `outline`, `ghost`, `destructive`, `link`. |
| `size` | One of `default`, `sm`, `lg`. (No `icon` size — a task button always carries a text label; use `block_button()` for an icon-only trigger.) |
| `icon` | Optional ready-state vendored icon name or `htmltools` tag. |
| `icon_busy` | Optional busy-state icon name or tag. Defaults to a spinner. |
| `icon_position` | `inline-start` (default) or `inline-end`. |
| `auto_reset` | Length-1 logical, default `TRUE`. |
| `...` | Additional HTML attributes (e.g. `disabled = TRUE`). Passing `id` here is an error — use `input_id`. |
| `class` | Extra classes merged onto the runtime button element. |

### `update_block_task_button(session, input_id, state, label, label_busy, variant, size, icon, icon_busy, icon_position, disabled, style, class)`

Emits only the fields supplied. `state` is `"ready"` or `"busy"`; setting a
non-ready state takes manual control. Passing `icon`, `icon_busy`, `style`, or
`class` as `NULL` clears them.

## Runtime mapping

| R input | Runtime payload | Notes |
| --- | --- | --- |
| `label` | `props$labelHtml` | Serialized HTML fragment. |
| `label_busy` | `props$labelBusy` | Plain string. |
| `variant` / `size` | `props$variant` / `props$size` | Shared with `block_button()`. |
| `icon` / `icon_busy` | `props$iconName`/`iconHtml`, `props$iconBusyName`/`iconBusyHtml` | Name resolves to the Lucide sprite; a tag embeds inline. |
| `auto_reset` | `props$autoReset` | Read by the binding and reported with the value. |
| `input_id` | mount id + `shinyblocks.task_button` binding | Required. |
| initial `state` | `state$state` (`"ready"`) | Starting busy/ready state. |

## Shiny state and update contract

- The browser binding reports `{ value: <clickCount>, autoReset: <bool> }`.
- The `shinyblocks.task_button` input handler exposes the numeric click count
  classed `shinyActionButtonValue` / `shiny.actionButton` (reads like
  `actionButton()`) and, when `autoReset` is true, schedules the post-flush
  ready reset.
- `update_block_task_button()` routes through `sendInputMessage()` and only
  notifies on supplied fields.

## Visual parity

The ready state has no distinct shadcn upstream, so it is **not** registered in
`tools/parity/registry.mjs`; visual parity delegates to the existing Button
fixture. The ready-state button reuses the same `.sb-button` /
`.sb-button-<variant>` / `.sb-button-size-<size>` classes as `block_button()`,
so its computed appearance is identical by construction. The shared geometry and
color are pinned by the theme/style harness against the
`.sb-parity-task-button-default` fixture:

- `tools/theme/theme-registry.mjs` asserts `background-color == --primary` and
  `color == --primary-foreground` (the Button default contract) across the
  palette sweep and every shipped style profile.
- `tools/theme/style-registry.mjs` asserts the trigger `border-radius` matches
  the shared base button radius.

## Deliberate divergences from shadcn

- shadcn has no task button; this composes the shadcn Button visuals with
  bslib `input_task_button()` behavior.
- The lock is enforced synchronously in the DOM (not via React state) so a
  same-tick double click cannot reach the server.

## Reference screenshot

![Task Button](_screenshots/task-button.png)

Captured from the shinyblocks showcase on 2026-06-23.
