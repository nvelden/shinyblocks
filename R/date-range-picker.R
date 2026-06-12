# Internal delimiter for the hidden native input that ferries the ISO range to
# the runtime as a single string. ISO `yyyy-mm-dd` values never contain `/`, so
# the pair round-trips unambiguously. This is an R<->runtime implementation
# detail, distinct from the user-facing display `separator`.
DATE_RANGE_NATIVE_SEP <- "/"

# Build the hidden native input value for a (possibly empty) ISO range. Both
# endpoints must be present for a committed range; anything else is empty.
date_range_native_value <- function(start, end) {
  if (is.null(start) || is.null(end)) {
    return("")
  }
  paste0(start, DATE_RANGE_NATIVE_SEP, end)
}

# Order and bounds-check a (possibly partial) ISO range. Reversed `start`/`end`
# are silently swapped to match `dateRangeInput()`; an inverted `min`/`max` or an
# endpoint outside its bounds is an error. Any argument may be `NULL` (absent),
# so this serves both the constructor and the partial-update path. Returns the
# possibly-swapped `list(start, end)`.
validate_range_bounds <- function(start, end, min, max) {
  if (!is.null(start) && !is.null(end) && start > end) {
    swapped <- start
    start <- end
    end <- swapped
  }
  if (!is.null(min) && !is.null(max) && min > max) {
    stop("`min` must not be after `max`.", call. = FALSE)
  }
  for (endpoint in list(list("start", start), list("end", end))) {
    val <- endpoint[[2]]
    if (is.null(val)) next
    if (!is.null(min) && val < min) {
      stop(sprintf("`%s` must not be before `min`.", endpoint[[1]]), call. = FALSE)
    }
    if (!is.null(max) && val > max) {
      stop(sprintf("`%s` must not be after `max`.", endpoint[[1]]), call. = FALSE)
    }
  }
  list(start = start, end = end)
}

#' Create a shadcn-style date range picker
#'
#' A package-owned runtime input that renders a trigger button plus a popover
#' calendar for selecting a start/end date range, instead of wrapping Shiny's
#' native [shiny::dateRangeInput()]. The server value matches
#' `dateRangeInput()`: `input$<id>` is a length-2 `Date` `c(start, end)`. The
#' control transports a two-element ISO `yyyy-mm-dd` array over a
#' `shiny.date`-typed binding, so R deserializes it as a `Date` with no custom
#' handler. An empty or incomplete range reports `NULL`.
#'
#' Unlike `dateRangeInput()`, `start = NULL` and `end = NULL` keep the control
#' empty (placeholder first) rather than defaulting to today. This is
#' intentional and matches shadcn's Date Range Picker examples. Providing only
#' one of `start`/`end` is an error: there is no half-open initial state.
#'
#' @param input_id Input id.
#' @param start Initial range start. Accepts a `Date`, a POSIX time, or a
#'   `"yyyy-mm-dd"` string. `NULL` (the default) starts empty.
#' @param end Initial range end, in the same accepted forms as `start`. `NULL`
#'   (the default) starts empty.
#' @param min Earliest selectable date, in the same accepted forms as `start`.
#'   `NULL` for no lower bound.
#' @param max Latest selectable date, in the same accepted forms as `start`.
#'   `NULL` for no upper bound.
#' @param separator Text shown between the start and end dates on the trigger
#'   label. Defaults to an en dash, matching [shiny::dateRangeInput()].
#' @param placeholder Text shown on the trigger before a range is selected.
#' @param format Display format for the trigger label. Supports the
#'   [shiny::dateInput()] token set (`yyyy`/`yy`, `mm`/`m`, `MM`/`M`, `dd`/`d`,
#'   `DD`/`D`). The transported value is always ISO regardless of `format`.
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
block_date_range_picker <- function(
  input_id,
  start = NULL,
  end = NULL,
  min = NULL,
  max = NULL,
  # `\u2013` (en dash) as a locale-independent escape: a literal en-dash in the
  # source is mangled to "<U+2013>" when the package is parsed under a C locale.
  separator = " \u2013 ",
  placeholder = "Pick a date range",
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
  check_string(separator, "separator", null_ok = TRUE)
  check_string(placeholder, "placeholder", null_ok = TRUE)

  if (is.null(start) != is.null(end)) {
    stop(
      "Provide both `start` and `end`, or neither. ",
      "A half-open initial range is not supported.",
      call. = FALSE
    )
  }

  start <- normalize_iso_date(start, "start")
  end <- normalize_iso_date(end, "end")
  min <- normalize_iso_date(min, "min")
  max <- normalize_iso_date(max, "max")
  weekstart <- normalize_weekstart(weekstart)

  # Match `dateRangeInput()`, which silently orders a reversed selection, then
  # reject inverted bounds / out-of-range endpoints.
  bounds <- validate_range_bounds(start, end, min, max)
  start <- bounds$start
  end <- bounds$end

  hidden_native <- hidden_native_input(
    input_id,
    type = "text",
    class = "sb-date-range-picker-native",
    value = date_range_native_value(start, end)
  )

  wrapper_style <- normalize_width_style(width)

  runtime_component(
    component = "date-range-picker",
    props = list(
      separator = separator %||% "",
      placeholder = placeholder %||% "",
      format = format,
      weekstart = weekstart,
      min = min,
      max = max,
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      style = normalize_runtime_style(style),
      spriteHref = sprite_href()
    ),
    input_id = input_id,
    state = list(start = start %||% "", end = end %||% ""),
    binding = list(input = TRUE, type = "shinyblocks.date-range-picker"),
    class = class,
    style = wrapper_style,
    root_class = "sb-date-range-picker",
    children = list(hidden_native)
  )
}

#' Update a runtime date range picker
#'
#' Updates the range, bounds, and cosmetic props of a
#' [block_date_range_picker()]. Following [shiny::updateDateRangeInput()],
#' omitted arguments are left unchanged, and `start`/`end` can be updated
#' independently. Note that the control only reports a *complete* range: setting
#' a single endpoint when the other is empty leaves the value `NULL` (the
#' trigger keeps its placeholder) until both endpoints are present, so the input
#' event fires but `input$<id>` stays empty. To clear the selected range from
#' the server, pass `clear = TRUE` (a bare `start = NULL`/`end = NULL` is
#' ignored, matching Shiny's "missing args are ignored" rule).
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_date_range_picker()`.
#' @param start Optional replacement range start (`Date`, POSIX time, or
#'   `"yyyy-mm-dd"` string).
#' @param end Optional replacement range end.
#' @param min Optional replacement lower bound. Use `NULL` to clear the bound.
#' @param max Optional replacement upper bound. Use `NULL` to clear the bound.
#' @param separator Optional replacement separator text.
#' @param placeholder Optional replacement placeholder text.
#' @param disabled Optional disabled state.
#' @param invalid Optional invalid flag.
#' @param class Optional replacement classes for the wrapper.
#' @param style Optional replacement inline CSS styles for the trigger.
#' @param notify Whether Shiny should receive an input event when the range
#'   changes. Cosmetic-only updates never notify.
#' @param clear Whether to clear the selected range (sends an explicit empty
#'   range). Takes precedence over `start`/`end`.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_date_range_picker <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  start,
  end,
  min,
  max,
  separator,
  placeholder,
  disabled,
  invalid,
  class,
  style,
  notify = TRUE,
  clear = FALSE
) {
  payload <- list()

  if (!missing(separator)) check_string(separator, "separator", null_ok = TRUE)
  if (!missing(placeholder)) check_string(placeholder, "placeholder", null_ok = TRUE)

  norm_start <- if (!missing(start) && !isTRUE(clear)) normalize_iso_date(start, "start") else NULL
  norm_end <- if (!missing(end) && !isTRUE(clear)) normalize_iso_date(end, "end") else NULL
  norm_min <- if (!missing(min)) normalize_iso_date(min, "min") else NULL
  norm_max <- if (!missing(max)) normalize_iso_date(max, "max") else NULL

  # Validate the combination of values supplied in *this* update, mirroring the
  # constructor's consistency checks. The server cannot see the client's current
  # state, so this only reasons about fields present in the same call -- but that
  # is enough to reject the impossible combinations the runtime would otherwise
  # accept silently (e.g. `min` after `max`, or an endpoint outside its bounds).
  bounds <- validate_range_bounds(norm_start, norm_end, norm_min, norm_max)
  norm_start <- bounds$start
  norm_end <- bounds$end

  if (!missing(start) && !isTRUE(clear)) {
    payload$start <- norm_start %||% ""
  }
  if (!missing(end) && !isTRUE(clear)) {
    payload$end <- norm_end %||% ""
  }
  if (!missing(min)) {
    payload <- payload_set_clearable(payload, "min", norm_min)
  }
  if (!missing(max)) {
    payload <- payload_set_clearable(payload, "max", norm_max)
  }
  if (isTRUE(clear)) {
    payload$start <- ""
    payload$end <- ""
  }

  payload <- apply_update_fields(payload, list(
    field_clearable("separator"),
    field_clearable("placeholder"),
    field("disabled", transform = isTRUE),
    field("invalid", transform = isTRUE),
    field_style("style"),
    field_clearable("class")
  ))

  # The range carries two value fields, so notify keys off either endpoint
  # rather than the single-`value` convention used elsewhere.
  range_changed <- "start" %in% names(payload) || "end" %in% names(payload)
  payload$notify <- isTRUE(notify) && range_changed

  runtime_input_update(
    session, input_id, "date-range-picker", payload, notify_key = NULL
  )
}
