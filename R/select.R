#' Create a styled select input
#'
#' @param input_id Input id.
#' @param choices Choice labels and values.
#' @param selected Optional selected value.
#' @param placeholder Optional placeholder shown when no value is selected.
#' @param disabled Whether the control is disabled.
#' @param width Optional CSS width value.
#' @param class Additional classes.
#' @param size Select size. One of `"default"`, `"sm"`, or `"lg"`.
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
  invalid = FALSE
) {
  size <- match_arg(size, c("default", "sm", "lg"))
  choices_df <- normalize_choices(choices)
  choice_values <- choices_df$value

  if (!is.null(selected) && !selected %in% choice_values) {
    stop("`selected` must match one of `choices`.", call. = FALSE)
  }
  selected_value <- selected %||% if (is.null(placeholder)) choice_values[[1]] else ""

  runtime_component(
    component = "select",
    props = list(
      choices = runtime_choice_records(choices_df),
      placeholder = placeholder,
      disabled = isTRUE(disabled),
      width = width %||% "100%",
      size = size,
      invalid = isTRUE(invalid)
    ),
    input_id = input_id,
    state = list(value = selected_value),
    binding = list(input = TRUE),
    class = class
  )
}

#' Update a runtime select input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_select()`.
#' @param selected Optional selected value. `NULL` clears the value.
#' @param choices Optional replacement choices.
#' @param placeholder Optional replacement placeholder.
#' @param disabled Optional disabled state.
#' @param notify Whether Shiny should receive an input event for `selected`.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_select <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  selected,
  choices,
  placeholder,
  disabled,
  notify = FALSE
) {
  updates <- list()

  if (!missing(selected)) {
    updates$value <- selected %||% ""
  }
  if (!missing(choices)) {
    choices_df <- normalize_choices(choices)
    updates$choices <- runtime_choice_records(choices_df)

    if (
      !missing(selected) &&
        !is.null(selected) &&
        !selected %in% choices_df$value
    ) {
      stop("`selected` must match one of `choices`.", call. = FALSE)
    }
  }
  if (!missing(placeholder)) {
    updates$placeholder <- placeholder
  }
  if (!missing(disabled)) {
    updates$disabled <- isTRUE(disabled)
  }

  do.call(
    runtime_update,
    c(
      list(
        session = session,
        input_id = input_id,
        component = "select"
      ),
      updates,
      list(
        notify = notify,
        clearable = "value"
      )
    )
  )
}

runtime_choice_records <- function(choices_df) {
  unname(lapply(seq_len(nrow(choices_df)), function(i) {
    list(
      value = choices_df$value[[i]],
      label = choices_df$label[[i]]
    )
  }))
}
