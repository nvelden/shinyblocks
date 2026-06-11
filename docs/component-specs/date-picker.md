# Date Picker

> Shinyblocks function: `block_date_picker()` / `update_block_date_picker()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/date-picker>
> Status: Slices 1-4 shipped — R API + runtime payload + `shiny.date` value
> contract, the runtime trigger/calendar component and binding, shadcn
> token/theme parity (theme-registry + style-registry coverage), and the
> showcase + docs-site playgrounds (Content/State/Actions/Styling controls,
> `input$` value display, API table). Follow-up: `block_date_range_picker()`
> (separate issue).

## Overview

A package-owned runtime input: a trigger button plus a popover calendar,
**not** a wrapper around Shiny's `dateInput()` (whose Bootstrap-era DOM breaks
shadcn parity — same de-wrapping precedent as `block_slider()`). The server
value matches `dateInput()`: `input$<id>` is a length-1 `Date`. The control
transports an ISO `yyyy-mm-dd` string over a `shiny.date`-typed binding, so R
deserializes it as a `Date` with no custom handler.

## States

Rendered (slice 2): default (placeholder-first trigger), hover, focus-visible
ring, open (portaled calendar), day hover / selected / today, out-of-bounds
disabled days, `disabled`, and `invalid` (destructive ring via
`aria-invalid="true"`). Token parity (slice 3): the trigger uses `--background`
surface / `--input` border / `--foreground` text (`--muted-foreground` while
placeholder); the calendar uses `--popover`; the selected day fills `--primary`,
while today and day hover use `--accent` (selected wins over hover). Focus rings
use `--ring`.

## R API

### `block_date_picker(input_id, value, min, max, placeholder, format, weekstart, disabled, invalid, width, class, style)`

| Argument | Purpose |
| --- | --- |
| `input_id` | Shiny input id used for `input$<id>` and update messages. |
| `value` | Initial date (`Date`, POSIX time, or `"yyyy-mm-dd"` string). `NULL` (default) starts empty — placeholder-first, unlike `dateInput()`'s "today" default. Intentional shadcn parity. |
| `min` / `max` | Selectable bounds in the same accepted forms. `min` must not be after `max`; a `value` outside the bounds is rejected. |
| `placeholder` | Trigger text shown before a date is selected. |
| `format` | Display format for the trigger label. Tokens: `yyyy`/`yy`, `mm`/`m`, `MM`/`M`, `dd`/`d`, `DD`/`D` (Shiny `dateInput()` tokens). Display-only — the transported value stays ISO. |
| `weekstart` | First day of week, integer 0-6 (Shiny convention: 0 = Sunday, 6 = Saturday). |
| `disabled` | Disables the trigger and hidden input. |
| `invalid` | Applies `aria-invalid` and destructive styling. |
| `width` | CSS width applied to the runtime wrapper. |
| `style` / `class` | Inline style on the trigger / extra class on the wrapper. |

### `update_block_date_picker(session, input_id, ...)`

Accepts `value`, `min`, `max`, `placeholder`, `disabled`, `invalid`, `class`,
`style`, plus `notify` and `clear`. Following `updateDateInput()`, omitted
arguments are left unchanged. Clearing the selected date from the server
requires `clear = TRUE` (a bare `value = NULL` is ignored). `min`/`max` are
clearable: passing `NULL` removes the bound. Cosmetic-only updates never
notify.

## Runtime mapping

| R input | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | mount id | Drives `input$<id>`. |
| `value` | `state$value` | ISO `yyyy-mm-dd` string, or `""` when empty. |
| `min` / `max` | `props$min` / `props$max` | ISO strings or absent. |
| `placeholder` | `props$placeholder` | |
| `format` | `props$format` | Display-only token string. |
| `weekstart` | `props$weekstart` | Integer 0-6. |
| `disabled` | `props$disabled` | |
| `invalid` | `props$invalid` | |
| `width` | mount `style.width` | |

A hidden native `<input type="text" class="sb-date-picker-native">` carries the
ISO value as a form-submission bridge; the dedicated `shiny.date`-typed binding
owns the `input$<id>` value. Following the single-writer runtime-input contract
(ADR 0019), the React mount writes the `__sbDatePickerValue` expando, the
`data-sb-date-picker-value` dataset attribute, and the native input together on
mount, on user selection, and in the `__sbDatePickerReceive` server handler,
dispatching `sb:date-picker-change` only on a notifying change. An empty
selection reports `null`, so `input$<id>` is `NULL`.

## Shiny state and update contract

- `input$<id>` is a length-1 `Date` (matches `dateInput()`).
- Empty control reports no selected date.
- Server-driven value updates can notify Shiny (`notify = TRUE`, default) or
  remain cosmetic/state-only (`notify = FALSE`).

## Deliberate divergences from shadcn

- shadcn's Date Picker is composition (`Button` + `Popover` + `Calendar` over
  `react-day-picker`). shinyblocks hand-rolls a no-dependency calendar grid to
  stay within the runtime asset budget (no `react-day-picker` / `date-fns`).
- `value = NULL` keeps the control empty rather than defaulting to today,
  matching shadcn's placeholder-first examples and diverging from `dateInput()`.
- Range selection is deliberately deferred to a separate
  `block_date_range_picker()` (follow-up issue), mirroring Shiny's split of
  `dateInput()` / `dateRangeInput()`.

## Reference screenshot

_Pending manual upstream capture._ Grab the canonical look from
<https://ui.shadcn.com/docs/components/date-picker>, save it as
`_screenshots/date-picker.png`, then replace this note with
`![Date Picker](_screenshots/date-picker.png)` and a "Captured from … on
<date>" caption (matching the other specs). Refresh whenever shadcn updates the
canonical design.
