#' Create a styled select input
#'
#' @param input_id Input id.
#' @param choices Choice labels and values.
#' @param selected Optional selected value.
#' @param placeholder Optional placeholder shown when no value is selected.
#' @param disabled Whether the control is disabled.
#' @param width Optional CSS width value.
#' @param class Additional classes.
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
  class = NULL
) {
  choices_df <- normalize_choices(choices)
  choice_values <- choices_df$value

  if (!is.null(selected) && !selected %in% choice_values) {
    stop("`selected` must match one of `choices`.", call. = FALSE)
  }

  choice_vector <- stats::setNames(choice_values, choices_df$label)
  selected_value <- selected

  if (!is.null(placeholder)) {
    placeholder_choice <- stats::setNames("", placeholder)
    choice_vector <- c(placeholder_choice, choice_vector)
    selected_value <- selected %||% ""
  }

  select_tag <- shiny::selectInput(
    inputId = input_id,
    label = NULL,
    choices = choice_vector,
    selected = selected_value,
    width = width %||% "100%"
  )

  select_query <- htmltools::tagQuery(select_tag)
  select_query$find("select")$addClass("sb-select-control")

  if (disabled) {
    select_query$find("select")$addAttrs(disabled = NA)
  }

  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-select", class),
      select_query$allTags()
    )
  )
}
