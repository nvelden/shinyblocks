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

  hidden_native <- hidden_native_input(
    input_id,
    type = "hidden",
    class = "sb-radio-group-native",
    value = selected_value,
    style = NULL,
    tabindex = NULL,
    aria_hidden = FALSE
  )

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
    class = class,
    root_class = "sb-radio-group",
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
  payload <- list()

  if (!missing(choices)) {
    choices_df <- normalize_choices(choices)
    validate_select_choice_values(choices_df$value)
    payload$choices <- runtime_choice_records(choices_df)
  }
  if (!missing(selected)) {
    payload <- payload_set_clearable(payload, "selected", selected, as.character)
  }
  if (!missing(disabled)) {
    payload <- payload_set_if_present(payload, "disabled", disabled, isTRUE)
  }
  if (!missing(invalid)) {
    payload <- payload_set_if_present(payload, "invalid", invalid, isTRUE)
  }
  if (!missing(orientation)) {
    payload$orientation <- match.arg(orientation, c("vertical", "horizontal"))
  }
  if (!missing(style)) {
    payload <- payload_set_style(payload, "style", style)
  }
  if (!missing(class)) {
    payload <- payload_set_clearable(payload, "class", class)
  }

  runtime_input_update(
    session, input_id, "radio-group", payload,
    notify_key = "selected", notify = notify
  )
}
