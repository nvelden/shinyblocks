#' Create a styled radio group input
#'
#' Renders a shadcn-style radio group where exactly one option is
#' selected at a time. Reports the selected value through a
#' package-local Shiny input binding.
#'
#' @param input_id Input id.
#' @param choices Choice labels and values. A named character vector
#'   (`c(Label = "value")`), a list, or a character vector.
#' @param selected Optional initial value. Must match one of `choices`.
#' @param disabled Whether the entire group is disabled.
#' @param invalid Whether the group should show invalid styling
#'   (sets `aria-invalid="true"` on the wrapper).
#' @param orientation Either `"vertical"` (default) or `"horizontal"`.
#' @param style Inline CSS styles applied to the radio-group wrapper.
#' @param class Additional classes for the wrapper.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_radio_group <- function(
  input_id,
  choices,
  selected = NULL,
  disabled = FALSE,
  invalid = FALSE,
  orientation = c("vertical", "horizontal"),
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  orientation <- match.arg(orientation)
  choices_df <- normalize_choices(choices)
  validate_select_choice_values(choices_df$value)
  choice_values <- choices_df$value

  if (!is.null(selected) && !selected %in% choice_values) {
    stop("`selected` must match one of `choices`.", call. = FALSE)
  }
  selected_value <- selected %||% choice_values[[1]]

  hidden_native <- htmltools::tags$input(
    id = input_id,
    type = "hidden",
    class = "sb-radio-group-native",
    `data-shiny-no-bind-input` = "",
    value = selected_value
  )

  wrapper_class <- merge_classes("sb-radio-group", class)

  runtime_component(
    component = "radio-group",
    props = list(
      choices = runtime_choice_records(choices_df),
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      orientation = orientation,
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = selected_value),
    binding = list(input = TRUE, type = "shinyblocks.radio-group"),
    class = wrapper_class,
    children = list(hidden_native)
  )
}

#' Update a runtime radio group input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_radio_group()`.
#' @param selected Optional new selected value.
#' @param choices Optional replacement choices.
#' @param disabled Optional disabled state.
#' @param invalid Optional invalid flag.
#' @param orientation Optional new orientation.
#' @param style Optional replacement inline CSS styles.
#' @param class Optional replacement classes.
#' @param notify Whether Shiny should receive an input event when
#'   `selected` changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_radio_group <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  selected,
  choices,
  disabled,
  invalid,
  orientation,
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

  if (!missing(choices)) {
    choices_df <- normalize_choices(choices)
    validate_select_choice_values(choices_df$value)
    payload$choices <- runtime_choice_records(choices_df)
  }
  if (!missing(selected)) {
    payload["selected"] <- list(if (is.null(selected)) NULL else as.character(selected))
  }
  if (!missing(disabled)) {
    payload$disabled <- isTRUE(disabled)
  }
  if (!missing(invalid)) {
    payload$invalid <- isTRUE(invalid)
  }
  if (!missing(orientation)) {
    payload$orientation <- match.arg(orientation, c("vertical", "horizontal"))
  }
  if (!missing(style)) {
    payload["style"] <- list(if (is.null(style)) NULL else normalize_runtime_style(style))
  }
  if (!missing(class)) {
    payload["class"] <- list(class)
  }

  payload$notify <- isTRUE(notify) && "selected" %in% names(payload)
  message_target <- runtime_mount_id("radio-group", session$ns(input_id))

  session$sendInputMessage(message_target, payload)
  invisible(NULL)
}
