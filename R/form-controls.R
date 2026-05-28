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
#' @param resize Textarea resize behavior. One of `"vertical"`,
#'   `"none"`, `"both"`, or `"horizontal"`.
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
  resize = c("vertical", "none", "both", "horizontal"),
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  resize <- match_arg(resize, c("vertical", "none", "both", "horizontal"))
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

  wrapper_style <- if (!is.null(width)) paste0("width:", htmltools::validateCssUnit(width), ";") else NULL

  runtime_component(
    component = "textarea",
    props = list(
      placeholder = placeholder,
      rows = as.integer(rows),
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      resize = resize,
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = if (is.null(value)) "" else as.character(value)),
    binding = list(input = TRUE, type = "shinyblocks.textarea"),
    class = class,
    style = wrapper_style,
    root_class = "sb-textarea",
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
#' @param resize Optional textarea resize behavior. One of `"vertical"`,
#'   `"none"`, `"both"`, or `"horizontal"`.
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
  resize,
  style,
  class,
  notify = TRUE
) {
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
  if (!missing(resize)) {
    payload$resize <- match_arg(resize, c("vertical", "none", "both", "horizontal"))
  }
  if (!missing(style)) {
    payload["style"] <- list(if (is.null(style)) NULL else normalize_runtime_style(style))
  }
  if (!missing(class)) {
    payload["class"] <- list(class)
  }

  runtime_input_update(session, input_id, "textarea", payload, notify = notify)
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
    class = class,
    style = wrapper_style,
    root_class = "sb-input",
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

  runtime_input_update(session, input_id, "input", payload, notify = notify)
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
    class = class,
    root_class = "sb-checkbox",
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

  runtime_input_update(
    session, input_id, "checkbox", payload,
    notify_key = "checked", notify = notify
  )
}

#' Create a styled switch input
#'
#' @param input_id Input id.
#' @param label Switch label.
#' @param value Whether the switch starts on.
#' @param disabled Whether the control is disabled.
#' @param size Switch size. One of `"default"`, `"sm"`, or `"lg"`.
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
  size = c("default", "sm", "lg"),
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  size <- match_arg(size, c("default", "sm", "lg"))

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
      size = size,
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = isTRUE(value)),
    binding = list(input = TRUE, type = "shinyblocks.switch"),
    class = class,
    root_class = "sb-switch",
    children = list(hidden_native)
  )
}

#' Update a runtime switch input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_switch()`.
#' @param checked Optional checked state.
#' @param disabled Optional disabled state.
#' @param size Optional replacement size. One of `"default"`, `"sm"`, or `"lg"`.
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
  size,
  style,
  class,
  notify = TRUE
) {
  payload <- list()

  if (!missing(checked)) {
    payload$checked <- isTRUE(checked)
  }
  if (!missing(disabled)) {
    payload$disabled <- isTRUE(disabled)
  }
  if (!missing(size)) {
    payload$size <- match_arg(size, c("default", "sm", "lg"))
  }
  if (!missing(style)) {
    payload["style"] <- list(if (is.null(style)) NULL else normalize_runtime_style(style))
  }
  if (!missing(class)) {
    payload["class"] <- list(class)
  }

  runtime_input_update(
    session, input_id, "switch", payload,
    notify_key = "checked", notify = notify
  )
}

#' Create a styled slider input
#'
#' Runtime-rendered slider with a dedicated Shiny input binding. Supports
#' single-value and two-value range sliders.
#'
#' @param input_id Input id.
#' @param value Initial value. Length 1 for a single-handle slider;
#'   length 2 for a range slider.
#' @param min Numeric lower bound.
#' @param max Numeric upper bound.
#' @param step Step size. Defaults to `NULL` (Shiny's auto-step).
#' @param ticks Whether to show tick marks on the rail.
#' @param orientation Slider orientation. One of `"horizontal"` or
#'   `"vertical"`.
#' @param show_value Whether to render the current value above the slider.
#' @param min_label Optional label displayed at the minimum end of the rail.
#' @param max_label Optional label displayed at the maximum end of the rail.
#' @param width Optional CSS width value for horizontal sliders.
#' @param disabled Whether the control is disabled.
#' @param invalid Whether the control should show invalid styling
#'   (sets `aria-invalid="true"`).
#' @param style Inline CSS styles for the slider control.
#' @param class Additional classes for the wrapper.
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
  orientation = c("horizontal", "vertical"),
  show_value = FALSE,
  min_label = NULL,
  max_label = NULL,
  width = NULL,
  disabled = FALSE,
  invalid = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  orientation <- match_arg(orientation, c("horizontal", "vertical"))
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
  if (!is.null(step) && (!is.numeric(step) || length(step) != 1 || is.na(step) || step <= 0)) {
    stop("`step` must be a single positive numeric value.", call. = FALSE)
  }

  hidden_native <- htmltools::tags$input(
    id = input_id,
    type = "hidden",
    class = "sb-slider-native",
    tabindex = "-1",
    `aria-hidden` = "true",
    `data-shiny-no-bind-input` = "",
    value = paste(value, collapse = ",")
  )

  wrapper_style <- if (orientation == "vertical") {
    "display:inline-flex;"
  } else if (!is.null(width)) {
    paste0("width:", htmltools::validateCssUnit(width), ";")
  } else {
    NULL
  }

  runtime_component(
    component = "slider",
    props = list(
      min = min,
      max = max,
      step = step,
      ticks = isTRUE(ticks),
      orientation = orientation,
      showValue = isTRUE(show_value),
      minLabel = if (is.null(min_label)) NULL else as.character(min_label),
      maxLabel = if (is.null(max_label)) NULL else as.character(max_label),
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = as.numeric(value)),
    binding = list(input = TRUE, type = "shinyblocks.slider"),
    class = class,
    style = wrapper_style,
    root_class = "sb-slider-root",
    children = list(hidden_native)
  )
}

#' Update a runtime slider input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_slider()`.
#' @param value Optional replacement value. One or two numeric values.
#' @param min Optional lower bound.
#' @param max Optional upper bound.
#' @param step Optional step size.
#' @param orientation Optional slider orientation. One of `"horizontal"` or
#'   `"vertical"`.
#' @param show_value Optional flag for rendering the current value label.
#' @param min_label Optional replacement minimum label. Use `NULL` to clear.
#' @param max_label Optional replacement maximum label. Use `NULL` to clear.
#' @param disabled Optional disabled state.
#' @param invalid Optional invalid flag.
#' @param style Optional replacement inline CSS styles for the slider.
#' @param class Optional replacement classes for the wrapper.
#' @param notify Whether Shiny should receive an input event when `value`
#'   changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_slider <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  value,
  min,
  max,
  step,
  orientation,
  show_value,
  min_label,
  max_label,
  disabled,
  invalid,
  style,
  class,
  notify = TRUE
) {
  payload <- list()

  if (!missing(value)) {
    if (is.null(value) || !is.numeric(value) || length(value) < 1 ||
          length(value) > 2 || any(is.na(value))) {
      stop("`value` must be one or two numeric values.", call. = FALSE)
    }
    payload$value <- as.numeric(value)
  }
  if (!missing(min)) {
    if (!is.numeric(min) || length(min) != 1 || is.na(min)) {
      stop("`min` must be a single numeric value.", call. = FALSE)
    }
    payload$min <- as.numeric(min)
  }
  if (!missing(max)) {
    if (!is.numeric(max) || length(max) != 1 || is.na(max)) {
      stop("`max` must be a single numeric value.", call. = FALSE)
    }
    payload$max <- as.numeric(max)
  }
  if (!missing(min) && !missing(max) && min >= max) {
    stop("`min` must be strictly less than `max`.", call. = FALSE)
  }
  if (!missing(step)) {
    if (is.null(step)) {
      payload["step"] <- list(NULL)
    } else {
      if (!is.numeric(step) || length(step) != 1 || is.na(step) || step <= 0) {
        stop("`step` must be a single positive numeric value.", call. = FALSE)
      }
      payload$step <- as.numeric(step)
    }
  }
  if (!missing(orientation)) {
    payload$orientation <- match_arg(orientation, c("horizontal", "vertical"))
  }
  if (!missing(show_value)) {
    payload$showValue <- isTRUE(show_value)
  }
  if (!missing(min_label)) {
    payload["minLabel"] <- list(if (is.null(min_label)) NULL else as.character(min_label))
  }
  if (!missing(max_label)) {
    payload["maxLabel"] <- list(if (is.null(max_label)) NULL else as.character(max_label))
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

  runtime_input_update(session, input_id, "slider", payload, notify = notify)
}
