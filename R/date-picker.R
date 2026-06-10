# Normalize a single date-ish value to an ISO `yyyy-mm-dd` string. Accepts a
# `Date`, a POSIX time, or a `"yyyy-mm-dd"` string; `NULL` passes through so
# callers can represent "no value". Used at the R boundary so the runtime and
# the `shiny.date` binding only ever see ISO strings.
normalize_iso_date <- function(x, name) {
  if (is.null(x)) {
    return(NULL)
  }
  if (length(x) != 1L) {
    stop(sprintf("`%s` must be a single date.", name), call. = FALSE)
  }
  if (inherits(x, "Date")) {
    if (is.na(x)) {
      stop(sprintf("`%s` must not be `NA`.", name), call. = FALSE)
    }
    return(format(x, "%Y-%m-%d"))
  }
  if (inherits(x, "POSIXt")) {
    if (is.na(x)) {
      stop(sprintf("`%s` must not be `NA`.", name), call. = FALSE)
    }
    return(format(as.Date(x), "%Y-%m-%d"))
  }
  if (is.character(x)) {
    if (is.na(x)) {
      stop(sprintf("`%s` must not be `NA`.", name), call. = FALSE)
    }
    parsed <- as.Date(x, format = "%Y-%m-%d")
    if (is.na(parsed) || !identical(format(parsed, "%Y-%m-%d"), trimws(x))) {
      stop(
        sprintf("`%s` must be a valid `yyyy-mm-dd` date string.", name),
        call. = FALSE
      )
    }
    return(format(parsed, "%Y-%m-%d"))
  }
  stop(
    sprintf(
      "`%s` must be a `Date`, a POSIX time, or a `yyyy-mm-dd` string.",
      name
    ),
    call. = FALSE
  )
}

# Validate that `weekstart` is a single integer in 0-6 (Shiny convention:
# 0 = Sunday, 6 = Saturday). Returns the coerced integer.
normalize_weekstart <- function(weekstart) {
  if (!is.numeric(weekstart) || length(weekstart) != 1L || is.na(weekstart) ||
        weekstart != as.integer(weekstart) || weekstart < 0 || weekstart > 6) {
    stop(
      "`weekstart` must be a single integer between 0 (Sunday) and 6 (Saturday).",
      call. = FALSE
    )
  }
  as.integer(weekstart)
}

#' Create a shadcn-style date picker
#'
#' A package-owned runtime input that renders a trigger button plus a popover
#' calendar instead of wrapping Shiny's native [shiny::dateInput()]. The server
#' value matches `dateInput()`: `input$<id>` is a length-1 `Date`. The control
#' transports an ISO `yyyy-mm-dd` string over a `shiny.date`-typed binding, so R
#' deserializes it as a `Date` with no custom handler.
#'
#' Unlike `dateInput()`, `value = NULL` keeps the control empty (placeholder
#' first) rather than defaulting to today. This is intentional and matches
#' shadcn's Date Picker examples.
#'
#' @param input_id Input id.
#' @param value Initial date. Accepts a `Date`, a POSIX time, or a
#'   `"yyyy-mm-dd"` string. `NULL` (the default) starts empty.
#' @param min Earliest selectable date, in the same accepted forms as `value`.
#'   `NULL` for no lower bound.
#' @param max Latest selectable date, in the same accepted forms as `value`.
#'   `NULL` for no upper bound.
#' @param placeholder Text shown on the trigger before a date is selected.
#' @param format Display format for the trigger label. Supports the token set
#'   `yyyy`, `mm`, `dd`, `M`, `MM`, `D`, `DD` (Shiny's `dateInput()` tokens).
#'   The transported value is always ISO regardless of `format`.
#' @param weekstart First day of the week, integer 0-6 using Shiny's convention
#'   (0 = Sunday, 6 = Saturday).
#' @param disabled Whether the control is disabled.
#' @param invalid Whether the control should show invalid styling (sets
#'   `aria-invalid="true"`).
#' @param width Optional CSS width value (applied to the wrapper).
#' @param class Additional classes for the wrapper.
#' @param style Inline CSS styles for the trigger.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_date_picker <- function(
  input_id,
  value = NULL,
  min = NULL,
  max = NULL,
  placeholder = "Pick a date",
  format = "yyyy-mm-dd",
  weekstart = 0,
  disabled = FALSE,
  invalid = FALSE,
  width = NULL,
  class = NULL,
  style = NULL
) {
  validate_input_id(input_id)
  check_string(format, "format")

  value <- normalize_iso_date(value, "value")
  min <- normalize_iso_date(min, "min")
  max <- normalize_iso_date(max, "max")
  weekstart <- normalize_weekstart(weekstart)

  if (!is.null(min) && !is.null(max) && min > max) {
    stop("`min` must not be after `max`.", call. = FALSE)
  }
  if (!is.null(value)) {
    if (!is.null(min) && value < min) {
      stop("`value` must not be before `min`.", call. = FALSE)
    }
    if (!is.null(max) && value > max) {
      stop("`value` must not be after `max`.", call. = FALSE)
    }
  }

  hidden_native <- hidden_native_input(
    input_id,
    type = "text",
    class = "sb-date-picker-native",
    value = value %||% ""
  )

  wrapper_style <- normalize_width_style(width)

  runtime_component(
    component = "date-picker",
    props = list(
      placeholder = as.character(placeholder %||% ""),
      format = format,
      weekstart = weekstart,
      min = min,
      max = max,
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = value %||% ""),
    binding = list(input = TRUE, type = "shinyblocks.date-picker"),
    class = class,
    style = wrapper_style,
    root_class = "sb-date-picker",
    children = list(hidden_native)
  )
}

#' Update a runtime date picker
#'
#' Updates the value, bounds, and cosmetic props of a [block_date_picker()].
#' Following [shiny::updateDateInput()], omitted arguments are left unchanged.
#' To clear the selected date from the server, pass `clear = TRUE` (a bare
#' `value = NULL` is ignored, matching Shiny's "missing args are ignored" rule).
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_date_picker()`.
#' @param value Optional replacement date (`Date`, POSIX time, or
#'   `"yyyy-mm-dd"` string).
#' @param min Optional replacement lower bound. Use `NULL` to clear the bound.
#' @param max Optional replacement upper bound. Use `NULL` to clear the bound.
#' @param placeholder Optional replacement placeholder text.
#' @param disabled Optional disabled state.
#' @param invalid Optional invalid flag.
#' @param class Optional replacement classes for the wrapper.
#' @param style Optional replacement inline CSS styles for the trigger.
#' @param notify Whether Shiny should receive an input event when `value`
#'   changes. Cosmetic-only updates never notify.
#' @param clear Whether to clear the selected date (sends an explicit empty
#'   value). Takes precedence over `value`.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_date_picker <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  value,
  min,
  max,
  placeholder,
  disabled,
  invalid,
  class,
  style,
  notify = TRUE,
  clear = FALSE
) {
  payload <- list()

  if (!missing(value) && !isTRUE(clear)) {
    payload$value <- normalize_iso_date(value, "value") %||% ""
  }
  if (!missing(min)) {
    payload <- payload_set_clearable(
      payload, "min", normalize_iso_date(min, "min")
    )
  }
  if (!missing(max)) {
    payload <- payload_set_clearable(
      payload, "max", normalize_iso_date(max, "max")
    )
  }
  if (isTRUE(clear)) {
    payload$value <- ""
  }

  payload <- apply_update_fields(payload, list(
    field_clearable("placeholder"),
    field("disabled", transform = isTRUE),
    field("invalid", transform = isTRUE),
    field_style("style"),
    field_clearable("class")
  ))

  runtime_input_update(session, input_id, "date-picker", payload, notify = notify)
}
