#' Create a styled select input
#'
#' `block_select()` renders a hidden native `<select>` as the Shiny input
#' value source, plus a package runtime overlay for the visible
#' shadcn-style trigger and popup.
#'
#' @param input_id Input id.
#' @param choices Choice labels and values.
#' @param selected Optional selected value.
#' @param placeholder Optional placeholder shown when no value is selected.
#' @param disabled Whether the control is disabled.
#' @param width Optional CSS width value.
#' @param class Additional classes.
#' @param size Select size. One of `"default"`, `"sm"`, or `"lg"`.
#' @param style Inline CSS styles.
#' @param invalid Whether to show the invalid/error state.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_select <- function(
  input_id,
  choices,
  selected = NULL,
  placeholder = NULL,
  disabled = FALSE,
  width = NULL,
  class = NULL,
  size = c("default", "sm", "lg"),
  style = NULL,
  invalid = FALSE
) {
  validate_input_id(input_id)
  size <- match_arg(size, c("default", "sm", "lg"))
  choices_df <- normalize_choices(choices)
  validate_select_choice_values(choices_df$value)
  choice_values <- choices_df$value

  if (!is.null(selected) && !selected %in% choice_values) {
    stop("`selected` must match one of `choices`.", call. = FALSE)
  }
  selected_value <- selected %||% if (is.null(placeholder)) choice_values[[1]] else ""
  width_value <- if (is.null(width)) "100%" else htmltools::validateCssUnit(width)
  native_options <- lapply(seq_len(nrow(choices_df)), function(i) {
    option_value <- choices_df$value[[i]]
    htmltools::tags$option(
      value = option_value,
      selected = if (identical(option_value, selected_value)) NA else NULL,
      choices_df$label[[i]]
    )
  })

  if (!is.null(placeholder)) {
    native_options <- c(
      list(htmltools::tags$option(
        value = "",
        selected = if (identical(selected_value, "")) NA else NULL,
        placeholder
      )),
      native_options
    )
  }

  hidden_native <- htmltools::tags$select(
    id = input_id,
    class = "sb-select-native",
    tabindex = "-1",
    `aria-hidden` = "true",
    `data-shiny-no-bind-input` = "",
    disabled = if (isTRUE(disabled)) NA else NULL,
    native_options
  )

  runtime_component(
    component = "select",
    props = list(
      choices = runtime_choice_records(choices_df),
      placeholder = placeholder,
      disabled = isTRUE(disabled),
      width = width_value,
      style = normalize_runtime_style(style),
      size = size,
      invalid = isTRUE(invalid),
      spriteHref = sprite_href()
    ),
    input_id = input_id,
    state = list(value = selected_value),
    binding = list(input = TRUE, type = "shinyblocks.select"),
    class = class,
    children = list(hidden_native)
  )
}

#' Update a runtime select input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_select()`.
#' @param choices Optional replacement choices.
#' @param selected Optional selected value. `NULL` clears the value.
#' @param placeholder Optional replacement placeholder.
#' @param disabled Optional disabled state.
#' @param width Optional replacement CSS width value.
#' @param class Optional replacement classes.
#' @param size Optional replacement size. One of `"default"`, `"sm"`, or `"lg"`.
#' @param invalid Optional invalid/error state.
#' @param notify Whether Shiny should receive an input event when `selected`
#'   is updated. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_select <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  choices,
  selected,
  placeholder,
  disabled,
  width,
  class,
  size,
  invalid,
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

  if (!missing(choices)) {
    choices_df <- normalize_choices(choices)
    validate_select_choice_values(choices_df$value)
    payload$choices <- runtime_choice_records(choices_df)

    if (
      !missing(selected) &&
        !is.null(selected) &&
        !selected %in% choices_df$value
    ) {
      stop("`selected` must match one of `choices`.", call. = FALSE)
    }
  }
  if (!missing(selected)) {
    payload$selected <- selected %||% ""
  }
  if (!missing(placeholder)) {
    payload["placeholder"] <- list(placeholder)
  }
  if (!missing(disabled)) {
    payload$disabled <- isTRUE(disabled)
  }
  if (!missing(width)) {
    payload["width"] <- list(if (is.null(width)) NULL else htmltools::validateCssUnit(width))
  }
  if (!missing(class)) {
    payload["class"] <- list(class)
  }
  if (!missing(size)) {
    payload$size <- match_arg(size, c("default", "sm", "lg"))
  }
  if (!missing(invalid)) {
    payload$invalid <- isTRUE(invalid)
  }

  payload$notify <- isTRUE(notify) && "selected" %in% names(payload)
  message_target <- runtime_mount_id("select", session$ns(input_id))

  session$sendInputMessage(
    message_target,
    payload
  )
  invisible(NULL)
}

runtime_choice_records <- function(choices_df) {
  unname(lapply(seq_len(nrow(choices_df)), function(i) {
    list(
      value = choices_df$value[[i]],
      label = choices_df$label[[i]]
    )
  }))
}
