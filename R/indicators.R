#' Create a value box
#'
#' @param title Value box title.
#' @param value Primary value.
#' @param ... Additional value box body content.
#' @param description Optional value box description.
#' @param icon Optional icon tag or vendored icon name.
#' @param variant Visual variant.
#' @param class Additional classes.
#' @param style Optional inline custom styles.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_value_box <- function(
  title,
  value,
  ...,
  description = NULL,
  icon = NULL,
  variant = c("default", "accent", "destructive"),
  class = NULL,
  style = NULL
) {
  variant <- match_arg(variant, c("default", "accent", "destructive"))
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "value-box",
    props = list(
      titleHtml = html_fragment(title),
      valueHtml = html_fragment(value),
      descriptionHtml = if (!is.null(description)) html_fragment(description) else NULL,
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL,
      variant = variant
    ),
    class = class,
    style = style
  )
}

#' Create a separator
#'
#' @param orientation Separator orientation.
#' @param decorative Whether the separator is decorative only.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_separator <- function(
  orientation = c("horizontal", "vertical"),
  decorative = TRUE,
  class = NULL
) {
  orientation <- match_arg(
    orientation,
    c("horizontal", "vertical"),
    "orientation"
  )

  runtime_component(
    component = "separator",
    props = list(
      orientation = orientation,
      decorative = isTRUE(decorative)
    ),
    class = class
  )
}

#' Create a skeleton placeholder
#'
#' @param class Additional classes.
#' @param ... Additional attributes passed to `htmltools::tags$div`.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_skeleton <- function(class = NULL, ...) {
  attrs <- named_attrs(list(...))
  if (!is.null(attrs$style)) {
    attrs$style <- normalize_runtime_style(attrs$style)
  }
  extra_class <- attrs[["class"]]
  class <- if (is.null(class) && is.null(extra_class)) {
    NULL
  } else {
    merge_classes(class, extra_class)
  }
  attrs[["class"]] <- NULL

  runtime_component(
    component = "skeleton",
    props = list(
      attrs = attrs
    ),
    class = class
  )
}

#' Create a spinner
#'
#' @param label Accessible `aria-label` announced by assistive technology.
#' @param size Visual size.
#' @param color Semantic color.
#' @param class Additional classes.
#' @param style Optional inline custom styles.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_spinner <- function(
  label = "Loading",
  size = c("default", "sm", "lg"),
  color = c("default", "muted", "primary", "destructive", "success", "warning", "info"),
  class = NULL,
  style = NULL
) {
  size <- match_arg(size, c("default", "sm", "lg"))
  color <- match_arg(color, semantic_color_choices())

  runtime_component(
    component = "spinner",
    props = list(
      label = label,
      size = size,
      color = color
    ),
    class = class,
    style = style
  )
}

semantic_color_choices <- function() {
  c("default", "muted", "primary", "destructive", "success", "warning", "info")
}

PROGRESS_VARIANTS <- c("default", "success", "warning", "info", "destructive")

# Finite scalar numeric. Unlike `check_number()`, this also rejects `Inf`/`-Inf`,
# which the progress arithmetic (clamp, percent) cannot represent.
check_finite_number <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1 || !is.finite(x)) {
    stop(sprintf("`%s` must be a finite scalar number.", name), call. = FALSE)
  }
  invisible(x)
}

# Length-1 logical, not NA.
check_flag <- function(x, name) {
  if (!is.logical(x) || length(x) != 1 || is.na(x)) {
    stop(sprintf("`%s` must be a single TRUE or FALSE.", name), call. = FALSE)
  }
  invisible(x)
}

clamp <- function(x, lo, hi) max(lo, min(hi, x))

#' Create a progress bar
#'
#' An embedded, shadcn-style progress indicator. Unlike Shiny's native
#' [shiny::Progress] notification panel, this renders inline exactly where it is
#' placed in the UI. It is display-only: it exposes no meaningful `input$<id>`
#' value, but the server can drive it with [update_block_progress()] and
#' [inc_block_progress()].
#'
#' @param id Component id, used to address the bar from the server. Not a form
#'   control: there is no `input$<id>` value.
#' @param value Current progress value. Clamped into `[min, max]`.
#' @param min Lower bound. Must be finite and less than `max`.
#' @param max Upper bound. Must be finite and greater than `min`.
#' @param message Dynamic status line (e.g. `"Importing rows..."`). Renders at
#'   header-left, or as a muted second line when `label` is also set.
#' @param detail Secondary muted text below the track.
#' @param label Static description of what is progressing (e.g. `"Upload"`).
#'   Takes header-left when set.
#' @param show_value Whether to render the clamped percent at header-right.
#'   Suppressed in indeterminate mode.
#' @param indeterminate Whether the bar shows an unknown-progress sweep instead
#'   of a determinate fill.
#' @param variant Indicator color: one of `"default"`, `"success"`,
#'   `"warning"`, `"info"`, `"destructive"`.
#' @param width Optional CSS width for the component (`NULL` fills the
#'   container). Sizes the mount wrapper only.
#' @param class Additional classes applied to the bar element
#'   (`.sb-progress-body`), not the mount wrapper.
#' @param style Optional inline styles (CSS string or named list) applied to the
#'   bar element. Targets the same node as `update_block_progress(style = )`; use
#'   `width` to size the component.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_progress <- function(
  id,
  value = 0,
  min = 0,
  max = 1,
  message = NULL,
  detail = NULL,
  label = NULL,
  show_value = FALSE,
  indeterminate = FALSE,
  variant = c("default", "success", "warning", "info", "destructive"),
  width = NULL,
  class = NULL,
  style = NULL
) {
  validate_input_id(id)
  check_finite_number(min, "min")
  check_finite_number(max, "max")
  check_finite_number(value, "value")
  if (min >= max) {
    stop("`min` must be less than `max`.", call. = FALSE)
  }
  check_string(message, "message", null_ok = TRUE)
  check_string(detail, "detail", null_ok = TRUE)
  check_string(label, "label", null_ok = TRUE)
  check_flag(show_value, "show_value")
  check_flag(indeterminate, "indeterminate")
  variant <- match_arg(variant, PROGRESS_VARIANTS)

  value <- clamp(value, min, max)

  runtime_component(
    component = "progress",
    props = list(
      message = message,
      detail = detail,
      label = label,
      showValue = isTRUE(show_value),
      variant = variant,
      # User `style` targets the inner `.sb-progress-body` (matching the textarea
      # / select convention: width sizes the mount wrapper, `style` styles the
      # component element). `update_block_progress(style=)` reaches the same node
      # via the runtime payload, so constructor and update style the same DOM
      # node with the same (normalized React object) grammar.
      style = normalize_runtime_style(style)
    ),
    input_id = id,
    state = list(
      value = value,
      min = min,
      max = max,
      indeterminate = isTRUE(indeterminate)
    ),
    binding = list(input = TRUE, type = "shinyblocks.progress"),
    class = class,
    # The mount wrapper only carries `width`; user `style` lives in `props`.
    style = normalize_width_style(width),
    root_class = "sb-progress"
  )
}

#' Update a runtime progress bar
#'
#' Sets fields on a [block_progress()] from the server. Following Shiny's
#' `setProgress()`, omitted arguments are left unchanged on the client. Text
#' fields (`message`, `detail`, `label`) clear when passed an explicit `NULL`;
#' numeric fields error on `NULL` (omit them to preserve the current value).
#'
#' Because a partial update cannot see the client's current state, `min < max`
#' is validated here only when both are supplied in the same call, and `value`
#' is not clamped server-side. The runtime is the single source of truth: it
#' clamps `value` into the merged `[min, max]` and reconciles range validity
#' (see [block_progress()]). Supplying `min`/`max` that invert the client's
#' current bounds is therefore the caller's responsibility.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param id Component id passed to [block_progress()].
#' @param value Replacement progress value (clamped client-side).
#' @param min Replacement lower bound.
#' @param max Replacement upper bound.
#' @param message Replacement status line; `NULL` clears it.
#' @param detail Replacement detail text; `NULL` clears it.
#' @param label Replacement label; `NULL` clears it.
#' @param show_value Whether to render the percent.
#' @param indeterminate Whether to show the unknown-progress sweep.
#' @param variant Replacement indicator color.
#' @param class Replacement classes; `NULL` clears them.
#' @param style Replacement inline styles; `NULL` clears them.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @export
update_block_progress <- function(
  session = shiny::getDefaultReactiveDomain(),
  id,
  value,
  min,
  max,
  message,
  detail,
  label,
  show_value,
  indeterminate,
  variant,
  class,
  style
) {
  payload <- list()

  payload <- progress_numeric_field(payload, "value", value, missing(value))
  payload <- progress_numeric_field(payload, "min", min, missing(min))
  payload <- progress_numeric_field(payload, "max", max, missing(max))

  if (!missing(min) && !missing(max) && min >= max) {
    stop("`min` must be less than `max`.", call. = FALSE)
  }

  if (!missing(message)) check_string(message, "message", null_ok = TRUE)
  if (!missing(detail)) check_string(detail, "detail", null_ok = TRUE)
  if (!missing(label)) check_string(label, "label", null_ok = TRUE)
  if (!missing(show_value)) {
    check_flag(show_value, "show_value")
    payload$showValue <- isTRUE(show_value)
  }
  if (!missing(indeterminate)) {
    check_flag(indeterminate, "indeterminate")
    payload$indeterminate <- isTRUE(indeterminate)
  }
  if (!missing(variant)) {
    payload$variant <- match_arg(variant, PROGRESS_VARIANTS)
  }

  payload <- apply_update_fields(payload, list(
    field_clearable("message"),
    field_clearable("detail"),
    field_clearable("label"),
    field_style("style"),
    field_clearable("class")
  ))

  runtime_input_update(session, id, "progress", payload, notify_key = NULL)
}

# Numeric updater field: omitted preserves (skip), explicit NULL errors,
# otherwise validate finite and set.
progress_numeric_field <- function(payload, name, value, is_missing) {
  if (is_missing) {
    return(payload)
  }
  if (is.null(value)) {
    stop(
      sprintf("`%s` cannot be NULL; omit it to preserve the current value.", name),
      call. = FALSE
    )
  }
  check_finite_number(value, name)
  payload[[name]] <- value
  payload
}

#' Increment a runtime progress bar
#'
#' Adds `amount` to a [block_progress()]'s current value, clamped client-side
#' into `[min, max]`. `amount` may be negative (decrement). Reaching `max` is a
#' stable no-op state: the bar never auto-hides, auto-resets, or fires a
#' completion event. Reset with `update_block_progress(value = min)`.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param id Component id passed to [block_progress()].
#' @param amount Signed amount to add to the current value.
#' @param message Optional status line to set in the same update; `NULL` clears.
#' @param detail Optional detail text to set in the same update; `NULL` clears.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @export
inc_block_progress <- function(
  session = shiny::getDefaultReactiveDomain(),
  id,
  amount = 0.1,
  message,
  detail
) {
  check_finite_number(amount, "amount")
  if (!missing(message)) check_string(message, "message", null_ok = TRUE)
  if (!missing(detail)) check_string(detail, "detail", null_ok = TRUE)

  payload <- list(action = "increment", amount = amount)
  payload <- apply_update_fields(payload, list(
    field_clearable("message"),
    field_clearable("detail")
  ))

  runtime_input_update(session, id, "progress", payload, notify_key = NULL)
}

#' Create an empty state
#'
#' @param title Empty-state title.
#' @param ... Additional empty-state body content.
#' @param description Optional description.
#' @param icon Optional icon tag or vendored icon name.
#' @param action Optional action content.
#' @param class Additional classes.
#' @param style Optional inline custom styles.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_empty <- function(
  title,
  ...,
  description = NULL,
  icon = NULL,
  action = NULL,
  class = NULL,
  style = NULL
) {
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "empty",
    props = list(
      titleHtml = html_fragment(title),
      descriptionHtml = if (!is.null(description)) html_fragment(description) else NULL,
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL,
      actionHtml = if (!is.null(action)) html_fragment(action) else NULL
    ),
    class = class,
    style = style
  )
}
