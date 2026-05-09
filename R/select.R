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

  selected_value <- selected %||%
    if (is.null(placeholder)) choice_values[[1]] else ""
  selected_label <- if (identical(selected_value, "")) {
    placeholder %||% ""
  } else {
    choices_df$label[match(selected_value, choice_values)]
  }

  option_tags <- lapply(seq_len(nrow(choices_df)), function(i) {
    value <- choices_df$value[[i]]
    label <- choices_df$label[[i]]

    htmltools::tags$option(
      value = value,
      selected = if (identical(value, selected_value)) NA else NULL,
      label
    )
  })

  if (!is.null(placeholder)) {
    option_tags <- c(list(
      htmltools::tags$option(
        value = "",
        selected = if (identical(selected_value, "")) NA else NULL,
        hidden = NA,
        placeholder
      )
    ), option_tags)
  }

  item_tags <- lapply(seq_len(nrow(choices_df)), function(i) {
    value <- choices_df$value[[i]]
    label <- choices_df$label[[i]]
    active <- identical(value, selected_value)

    htmltools::tags$button(
      class = merge_classes("sb-select-item", if (active) "is-selected"),
      type = "button",
      role = "option",
      `data-value` = value,
      `aria-selected` = if (active) "true" else "false",
      htmltools::tags$span(class = "sb-select-item-text", label),
      htmltools::tags$span(
        class = "sb-select-item-indicator",
        block_icon("check")
      )
    )
  })

  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-select", class),
      `data-placeholder` = placeholder %||% "",
      `data-value` = selected_value,
      style = if (!is.null(width)) paste0("width: ", width, ";"),
      htmltools::tags$select(
        id = input_id,
        class = "sb-select-native shiny-input-select",
        disabled = if (disabled) NA else NULL,
        option_tags
      ),
      htmltools::tags$button(
        class = "sb-select-trigger",
        type = "button",
        `aria-controls` = paste0(input_id, "-content"),
        `aria-expanded` = "false",
        `aria-haspopup` = "listbox",
        disabled = if (disabled) NA else NULL,
        htmltools::tags$span(
          class = merge_classes(
            "sb-select-value",
            if (identical(selected_value, "")) "is-placeholder"
          ),
          selected_label
        ),
        block_icon("chevron-down")
      ),
      htmltools::tags$div(
        id = paste0(input_id, "-content"),
        class = "sb-select-content",
        role = "listbox",
        hidden = NA,
        htmltools::tags$div(class = "sb-select-viewport", item_tags)
      )
    )
  )
}
