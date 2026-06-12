# Date Range Picker

> Shinyblocks function: `block_date_range_picker()` / `update_block_date_range_picker()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/date-picker> (Calendar `mode="range"`)
> Status: Shipped — R API + runtime payload + `shiny.date` value contract
> (length-2 `Date`), the shared `Calendar` core (extracted from the single-date
> picker), the runtime trigger/range-calendar component + binding, theme parity
> fixtures + registry entry, and the full showcase + docs-site interactive
> playgrounds (Content/State/Actions/Styling controls, live `input$` value, API
> table).

## Overview

A package-owned runtime input: a trigger button plus a popover calendar for
selecting a start/end **range**, **not** a wrapper around Shiny's
`dateRangeInput()`. Separate from `block_date_picker()` because the server value
shape differs — `input$<id>` is a length-2 `Date` `c(start, end)`, matching
`dateRangeInput()`. Overloading the single-date constructor with a `mode` flag
would silently change `input$<id>`'s type, so the two are split exactly as Shiny
splits `dateInput()` / `dateRangeInput()`.

The control transports a two-element ISO `yyyy-mm-dd` array over a
`shiny.date`-typed binding (`as.Date(unlist(val))` on the server yields the
length-2 `Date`), so no custom message handler is needed. An empty or
incomplete range reports `null`.

## States

Rendered: default (placeholder-first trigger), hover, focus-visible ring, open
(portaled calendar), and the range day roles — range start / range end (primary
endpoints), in-range middle (accent band, square corners), today, day hover,
out-of-bounds disabled days, plus `disabled` and `invalid`
(`aria-invalid="true"` destructive ring). During selection a hover/keyboard
preview band tracks the candidate second endpoint. Token parity and theme
fixtures land in the styling slice.

## Selection model

- **Click 1** anchors the range start (the committed/reported value is
  unchanged — a half-open selection never reaches the server).
- **Hover / arrow keys** preview the in-range band up to the candidate endpoint.
- **Click 2** commits the ordered pair (reversed clicks are swapped), notifies
  Shiny, and closes the popover.
- **Escape** cancels an in-progress selection (reverting to the last committed
  range) and closes.
- Disabled days (outside `min`/`max`) are not selectable.

## R API

### `block_date_range_picker(input_id, start, end, min, max, separator, placeholder, format, weekstart, disabled, invalid, width, class, style)`

| Argument | Purpose |
| --- | --- |
| `input_id` | Shiny input id used for `input$<id>` and update messages. |
| `start` / `end` | Initial range endpoints (`Date`, POSIX, or `"yyyy-mm-dd"`). Both `NULL` (default) starts empty — placeholder-first. Providing only one is an error (no half-open initial state). A reversed pair is silently ordered, matching `dateRangeInput()`. |
| `min` / `max` | Selectable bounds in the same accepted forms. `min` must not be after `max`; endpoints outside the bounds are rejected. |
| `separator` | Text shown between the two dates on the trigger label (default en dash, matching `dateRangeInput()`). |
| `placeholder` | Trigger text shown before a range is selected. |
| `format` | Display format for the trigger label (Shiny `dateInput()` tokens). Display-only — the transported value stays ISO. |
| `weekstart` | First day of week, integer 0-6 (0 = Sunday, 6 = Saturday). |
| `disabled` | Disables the trigger and hidden input. |
| `invalid` | Applies `aria-invalid` and destructive styling. |
| `width` | CSS width applied to the runtime wrapper. |
| `style` / `class` | Inline style on the trigger / extra class on the wrapper. |

### `update_block_date_range_picker(session, input_id, ...)`

Accepts `start`, `end`, `min`, `max`, `separator`, `placeholder`, `disabled`,
`invalid`, `class`, `style`, plus `notify` and `clear`. Following
`updateDateRangeInput()`, omitted arguments are left unchanged and `start`/`end`
can be updated independently. Clearing the selected range from the server
requires `clear = TRUE` (a bare `start = NULL`/`end = NULL` is ignored).
`min`/`max` are clearable: passing `NULL` removes the bound. Cosmetic-only
updates never notify.

## Runtime mapping

| R input | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | mount id | Drives `input$<id>`. |
| `start` / `end` | `state$start` / `state$end` | ISO `yyyy-mm-dd` strings, or `""` when empty. |
| `min` / `max` | `props$min` / `props$max` | ISO strings or absent. |
| `separator` | `props$separator` | Display-only trigger separator. |
| `placeholder` | `props$placeholder` | |
| `format` | `props$format` | Display-only token string. |
| `weekstart` | `props$weekstart` | Integer 0-6. |
| `disabled` / `invalid` | `props$disabled` / `props$invalid` | |
| `width` | mount `style.width` | |

A hidden native `<input type="text" class="sb-date-range-picker-native">`
carries the committed range as `"<startIso>/<endIso>"` (empty when incomplete);
the dedicated `shiny.date`-typed binding owns the `input$<id>` value. Following
the single-writer runtime-input contract, the React mount writes the
`__sbDateRangePickerValue` expando (`{ start, end }`), the
`data-sb-date-range-picker-start` / `-end` dataset attributes, and the native
input together on mount, on commit, and in the `__sbDateRangePickerReceive`
server handler, dispatching `sb:date-range-picker-change` only on a notifying
change. The binding's `getValue` returns `[startIso, endIso]` for a committed
range, else `null`.

## Shared calendar core

The grid, month math, weekday headers, and arrow-key navigation live in
`frontend/src/components/calendar.jsx` (`Calendar`), parameterized by
`classPrefix` / `slotPrefix` and a `getDayProps(iso)` day-decoration callback.
`block_date_picker()` and `block_date_range_picker()` both consume it, so the
~250 lines of grid logic are not forked; the single-date picker's DOM stays
byte-identical (same `sb-date-picker-*` hooks).

## Shiny state and update contract

- `input$<id>` is a length-2 `Date` `c(start, end)` (matches `dateRangeInput()`).
- An empty or incomplete range reports `NULL`.
- Server-driven updates can notify Shiny (`notify = TRUE`, default) or remain
  cosmetic/state-only (`notify = FALSE`).

## Deliberate divergences from shadcn

- shadcn's range picker is composition (`Button` + `Popover` + `Calendar` over
  `react-day-picker`). shinyblocks hand-rolls a no-dependency calendar grid to
  stay within the runtime asset budget (no `react-day-picker` / `date-fns`).
- Both `start`/`end` `NULL` keeps the control empty rather than defaulting to a
  range around today, matching shadcn's placeholder-first examples.
- Single-month view first; the dual-month range layout shadcn often shows is
  deferred to a later enhancement.

## Reference screenshot

_Intentionally deferred._ A reference capture is not a ship gate for this
component — the runtime parity is enforced by the theme/style-parity fixtures and
browser tests, not by a static image. When capturing one is worthwhile, grab the
canonical look from <https://ui.shadcn.com/docs/components/date-picker> (the
range example), save it as `_screenshots/date-range-picker.png`, then replace
this note with `![Date Range Picker](_screenshots/date-range-picker.png)` and a
"Captured from … on <date>" caption.
