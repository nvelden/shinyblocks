#' Create a styled textarea input
#'
#' @param input_id Input id.
#' @param value Initial value.
#' @param placeholder Optional placeholder text.
#' @param rows Number of visible rows.
#' @param width Optional CSS width value (applied to the wrapper).
#' @param disabled Whether the control is disabled.
#' @param invalid Whether the control should show invalid styling
#'   (sets `aria-invalid="true"`).
#' @param style Inline CSS styles for the textarea element.
#' @param class Additional classes for the wrapper.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_textarea <- function(
  input_id,
  value = "",
  placeholder = NULL,
  rows = 3,
  width = NULL,
  disabled = FALSE,
  invalid = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  if (!is.numeric(rows) || length(rows) != 1 || is.na(rows) || rows < 1) {
    stop("`rows` must be a positive number.", call. = FALSE)
  }

  hidden_native <- htmltools::tags$textarea(
    id = input_id,
    class = "sb-textarea-native",
    tabindex = "-1",
    `aria-hidden` = "true",
    `data-shiny-no-bind-input` = "",
    style = "display:none",
    if (is.null(value)) "" else as.character(value)
  )

  wrapper_class <- merge_classes("sb-textarea", class)
  wrapper_style <- if (!is.null(width)) paste0("width:", htmltools::validateCssUnit(width), ";") else NULL

  runtime_component(
    component = "textarea",
    props = list(
      placeholder = placeholder,
      rows = as.integer(rows),
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = if (is.null(value)) "" else as.character(value)),
    binding = list(input = TRUE, type = "shinyblocks.textarea"),
    class = wrapper_class,
    style = wrapper_style,
    children = list(hidden_native)
  )
}

#' Update a runtime textarea input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_textarea()`.
#' @param value Optional replacement value.
#' @param placeholder Optional replacement placeholder text.
#' @param rows Optional number of visible rows.
#' @param disabled Optional disabled state.
#' @param invalid Optional invalid flag.
#' @param style Optional replacement inline CSS styles for the textarea.
#' @param class Optional replacement classes for the wrapper.
#' @param notify Whether Shiny should receive an input event when `value`
#'   changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_textarea <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  value,
  placeholder,
  rows,
  disabled,
  invalid,
  style,
  class,
  notify = TRUE
) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$ns)) {
    stop("`session` must provide an `ns()` method.", call. = FALSE)
  }
  if (!is.function(session$sendInputMessage)) {
    stop("`session` must provide a `sendInputMessage()` method.", call. = FALSE)
  }

  validate_input_id(input_id)
  payload <- list()

  if (!missing(value)) {
    payload$value <- if (is.null(value)) "" else as.character(value)
  }
  if (!missing(placeholder)) {
    payload["placeholder"] <- list(placeholder)
  }
  if (!missing(rows)) {
    if (!is.numeric(rows) || length(rows) != 1 || is.na(rows) || rows < 1) {
      stop("`rows` must be a positive number.", call. = FALSE)
    }
    payload$rows <- as.integer(rows)
  }
  if (!missing(disabled)) {
    payload$disabled <- isTRUE(disabled)
  }
  if (!missing(invalid)) {
    payload$invalid <- isTRUE(invalid)
  }
  if (!missing(style)) {
    payload["style"] <- list(if (is.null(style)) NULL else normalize_runtime_style(style))
  }
  if (!missing(class)) {
    payload["class"] <- list(class)
  }

  payload$notify <- isTRUE(notify) && "value" %in% names(payload)
  message_target <- runtime_mount_id("textarea", session$ns(input_id))

  session$sendInputMessage(message_target, payload)
  invisible(NULL)
}

#' Create a styled single-line text input
#'
#' @param input_id Input id.
#' @param value Initial value.
#' @param placeholder Optional placeholder text.
#' @param type Input type. One of `"text"`, `"password"`, `"email"`,
#'   `"url"`, `"tel"`, `"search"`, or `"number"`. Defaults to `"text"`.
#' @param width Optional CSS width value (applied to the wrapper).
#' @param disabled Whether the control is disabled.
#' @param invalid Whether the control should show invalid styling
#'   (sets `aria-invalid="true"`).
#' @param style Inline CSS styles for the input element.
#' @param class Additional classes for the wrapper.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_input <- function(
  input_id,
  value = "",
  placeholder = NULL,
  type = c("text", "password", "email", "url", "tel", "search", "number"),
  width = NULL,
  disabled = FALSE,
  invalid = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  type <- match.arg(type)

  hidden_native <- htmltools::tags$input(
    id = input_id,
    type = type,
    class = "sb-input-native",
    tabindex = "-1",
    `aria-hidden` = "true",
    `data-shiny-no-bind-input` = "",
    style = "display:none",
    value = if (is.null(value)) "" else as.character(value)
  )

  wrapper_class <- merge_classes("sb-input", class)
  wrapper_style <- if (!is.null(width)) paste0("width:", htmltools::validateCssUnit(width), ";") else NULL

  runtime_component(
    component = "input",
    props = list(
      placeholder = placeholder,
      type = type,
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = if (is.null(value)) "" else as.character(value)),
    binding = list(input = TRUE, type = "shinyblocks.input"),
    class = wrapper_class,
    style = wrapper_style,
    children = list(hidden_native)
  )
}

#' Update a runtime text input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_input()`.
#' @param value Optional replacement value.
#' @param placeholder Optional replacement placeholder text.
#' @param type Optional input type.
#' @param disabled Optional disabled state.
#' @param invalid Optional invalid flag.
#' @param style Optional replacement inline CSS styles for the input.
#' @param class Optional replacement classes for the wrapper.
#' @param notify Whether Shiny should receive an input event when `value`
#'   changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_input <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  value,
  placeholder,
  type,
  disabled,
  invalid,
  style,
  class,
  notify = TRUE
) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$ns)) {
    stop("`session` must provide an `ns()` method.", call. = FALSE)
  }
  if (!is.function(session$sendInputMessage)) {
    stop("`session` must provide a `sendInputMessage()` method.", call. = FALSE)
  }

  validate_input_id(input_id)
  payload <- list()

  if (!missing(value)) {
    payload$value <- if (is.null(value)) "" else as.character(value)
  }
  if (!missing(placeholder)) {
    payload["placeholder"] <- list(placeholder)
  }
  if (!missing(type)) {
    payload$type <- match.arg(type, c("text", "password", "email", "url", "tel", "search", "number"))
  }
  if (!missing(disabled)) {
    payload$disabled <- isTRUE(disabled)
  }
  if (!missing(invalid)) {
    payload$invalid <- isTRUE(invalid)
  }
  if (!missing(style)) {
    payload["style"] <- list(if (is.null(style)) NULL else normalize_runtime_style(style))
  }
  if (!missing(class)) {
    payload["class"] <- list(class)
  }

  payload$notify <- isTRUE(notify) && "value" %in% names(payload)
  message_target <- runtime_mount_id("input", session$ns(input_id))

  session$sendInputMessage(message_target, payload)
  invisible(NULL)
}

#' Create a styled checkbox input
#'
#' @param input_id Input id.
#' @param label Checkbox label.
#' @param value Whether the checkbox starts checked.
#' @param disabled Whether the control is disabled.
#' @param style Inline CSS styles.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_checkbox <- function(
  input_id,
  label,
  value = FALSE,
  disabled = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)

  hidden_native <- htmltools::tags$input(
    id = input_id,
    type = "checkbox",
    class = "sb-checkbox-native",
    tabindex = "-1",
    `aria-hidden` = "true",
    `data-shiny-no-bind-input` = "",
    checked = if (isTRUE(value)) NA else NULL,
    disabled = if (isTRUE(disabled)) NA else NULL
  )

  runtime_component(
    component = "checkbox",
    props = list(
      labelHtml = html_fragment(label),
      disabled = isTRUE(disabled),
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = isTRUE(value)),
    binding = list(input = TRUE, type = "shinyblocks.checkbox"),
    class = merge_classes("sb-checkbox", class),
    children = list(hidden_native)
  )
}

#' Update a runtime checkbox input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_checkbox()`.
#' @param checked Optional checked state.
#' @param disabled Optional disabled state.
#' @param style Optional replacement inline CSS styles.
#' @param class Optional replacement classes.
#' @param notify Whether Shiny should receive an input event when `checked`
#'   is updated. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_checkbox <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  checked,
  disabled,
  style,
  class,
  notify = TRUE
) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$ns)) {
    stop("`session` must provide an `ns()` method.", call. = FALSE)
  }
  if (!is.function(session$sendInputMessage)) {
    stop("`session` must provide a `sendInputMessage()` method.", call. = FALSE)
  }

  validate_input_id(input_id)
  payload <- list()

  if (!missing(checked)) {
    payload$checked <- isTRUE(checked)
  }
  if (!missing(disabled)) {
    payload$disabled <- isTRUE(disabled)
  }
  if (!missing(style)) {
    payload["style"] <- list(if (is.null(style)) NULL else normalize_runtime_style(style))
  }
  if (!missing(class)) {
    payload["class"] <- list(class)
  }

  payload$notify <- isTRUE(notify) && "checked" %in% names(payload)
  message_target <- runtime_mount_id("checkbox", session$ns(input_id))

  session$sendInputMessage(message_target, payload)
  invisible(NULL)
}

#' Create a styled switch input
#'
#' @param input_id Input id.
#' @param label Switch label.
#' @param value Whether the switch starts on.
#' @param disabled Whether the control is disabled.
#' @param style Inline CSS styles.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_switch <- function(
  input_id,
  label,
  value = FALSE,
  disabled = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)

  hidden_native <- htmltools::tags$input(
    id = input_id,
    type = "checkbox",
    class = "sb-switch-native",
    tabindex = "-1",
    `aria-hidden` = "true",
    `data-shiny-no-bind-input` = "",
    checked = if (isTRUE(value)) NA else NULL,
    disabled = if (isTRUE(disabled)) NA else NULL
  )

  runtime_component(
    component = "switch",
    props = list(
      labelHtml = html_fragment(label),
      disabled = isTRUE(disabled),
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = isTRUE(value)),
    binding = list(input = TRUE, type = "shinyblocks.switch"),
    class = merge_classes("sb-switch", class),
    children = list(hidden_native)
  )
}

#' Update a runtime switch input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_switch()`.
#' @param checked Optional checked state.
#' @param disabled Optional disabled state.
#' @param style Optional replacement inline CSS styles.
#' @param class Optional replacement classes.
#' @param notify Whether Shiny should receive an input event when `checked`
#'   is updated. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_switch <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  checked,
  disabled,
  style,
  class,
  notify = TRUE
) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$ns)) {
    stop("`session` must provide an `ns()` method.", call. = FALSE)
  }
  if (!is.function(session$sendInputMessage)) {
    stop("`session` must provide a `sendInputMessage()` method.", call. = FALSE)
  }

  validate_input_id(input_id)
  payload <- list()

  if (!missing(checked)) {
    payload$checked <- isTRUE(checked)
  }
  if (!missing(disabled)) {
    payload$disabled <- isTRUE(disabled)
  }
  if (!missing(style)) {
    payload["style"] <- list(if (is.null(style)) NULL else normalize_runtime_style(style))
  }
  if (!missing(class)) {
    payload["class"] <- list(class)
  }

  payload$notify <- isTRUE(notify) && "checked" %in% names(payload)
  message_target <- runtime_mount_id("switch", session$ns(input_id))

  session$sendInputMessage(message_target, payload)
  invisible(NULL)
}

#' Create a styled slider input
#'
#' Wraps [`shiny::sliderInput()`] with token-driven track, range, and
#' thumb styling that tracks the shadcn slider contract. Wrap-by-
#' default per ADR 0014.
#'
#' @param input_id Input id.
#' @param value Initial value. Length 1 for a single-handle slider;
#'   length 2 for a range slider.
#' @param min Numeric lower bound.
#' @param max Numeric upper bound.
#' @param step Step size. Defaults to `NULL` (Shiny's auto-step).
#' @param ticks Whether to show tick marks on the rail.
#' @param width Optional CSS width value.
#' @param disabled Whether the control is disabled.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_slider <- function(
  input_id,
  value,
  min,
  max,
  step = NULL,
  ticks = FALSE,
  width = NULL,
  disabled = FALSE,
  class = NULL
) {
  if (missing(value) || !is.numeric(value) || length(value) < 1 ||
        length(value) > 2 || any(is.na(value))) {
    stop(
      "`value` must be one or two numeric values.",
      call. = FALSE
    )
  }
  if (missing(min) || !is.numeric(min) || length(min) != 1 || is.na(min)) {
    stop("`min` must be a single numeric value.", call. = FALSE)
  }
  if (missing(max) || !is.numeric(max) || length(max) != 1 || is.na(max)) {
    stop("`max` must be a single numeric value.", call. = FALSE)
  }
  if (min >= max) {
    stop("`min` must be strictly less than `max`.", call. = FALSE)
  }

  slider_tag <- shiny::sliderInput(
    inputId = input_id,
    label = NULL,
    min = min,
    max = max,
    value = value,
    step = step,
    ticks = isTRUE(ticks),
    width = width %||% "100%"
  )

  query <- htmltools::tagQuery(slider_tag)
  query$find("input")$addClass("sb-slider-control")

  if (disabled) {
    query$find("input")$addAttrs(disabled = NA)
  }

  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-slider", class),
      `data-disabled` = if (disabled) "true" else NULL,
      query$allTags()
    )
  )
}

