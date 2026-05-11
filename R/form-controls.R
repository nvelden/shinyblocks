#' Create a styled textarea input
#'
#' @param input_id Input id.
#' @param value Initial value.
#' @param placeholder Optional placeholder text.
#' @param rows Number of visible rows.
#' @param width Optional CSS width value.
#' @param disabled Whether the control is disabled.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_textarea <- function(
  input_id,
  value = "",
  placeholder = NULL,
  rows = 2,
  width = NULL,
  disabled = FALSE,
  class = NULL
) {
  if (!is.numeric(rows) || length(rows) != 1 || is.na(rows) || rows < 1) {
    stop("`rows` must be a positive number.", call. = FALSE)
  }

  textarea_tag <- shiny::textAreaInput(
    inputId = input_id,
    label = NULL,
    value = value,
    width = width %||% "100%",
    rows = rows
  )

  query <- htmltools::tagQuery(textarea_tag)
  query$find("textarea")$addClass("sb-textarea-control")

  if (!is.null(placeholder)) {
    query$find("textarea")$addAttrs(placeholder = placeholder)
  }

  if (disabled) {
    query$find("textarea")$addAttrs(disabled = NA)
  }

  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-textarea", class),
      query$allTags()
    )
  )
}

#' Create a styled checkbox input
#'
#' @param input_id Input id.
#' @param label Checkbox label.
#' @param value Whether the checkbox starts checked.
#' @param disabled Whether the control is disabled.
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
  class = NULL
) {
  control <- boolean_control_input(input_id, value, disabled)

  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes(
        "form-group",
        "shiny-input-container",
        "sb-checkbox",
        class
      ),
      htmltools::tags$div(
        class = "sb-checkbox-shell",
        htmltools::tags$label(
          class = "sb-checkbox-label",
          control,
          htmltools::tags$span(
            class = "sb-checkbox-indicator",
            `aria-hidden` = "true"
          ),
          htmltools::tags$span(class = "sb-checkbox-text", label)
        )
      )
    )
  )
}

#' Create a styled switch input
#'
#' @param input_id Input id.
#' @param label Switch label.
#' @param value Whether the switch starts on.
#' @param disabled Whether the control is disabled.
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
  class = NULL
) {
  control <- boolean_control_input(input_id, value, disabled)
  control$attribs[["class"]] <- merge_classes(
    control$attribs[["class"]],
    "sb-switch-control"
  )
  control$attribs[["role"]] <- "switch"

  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes(
        "form-group",
        "shiny-input-container",
        "sb-switch",
        class
      ),
      htmltools::tags$div(
        class = "sb-switch-shell",
        htmltools::tags$label(
          class = "sb-switch-label",
          control,
          htmltools::tags$span(
            class = "sb-switch-track",
            `aria-hidden` = "true"
          ),
          htmltools::tags$span(class = "sb-switch-text", label)
        )
      )
    )
  )
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

boolean_control_input <- function(input_id, value, disabled) {
  checkbox_tag <- shiny::checkboxInput(input_id, NULL, value = value)
  query <- htmltools::tagQuery(checkbox_tag)
  input_tag <- query$find("input")$selectedTags()[[1]]
  input_tag$attribs[["class"]] <- merge_classes(
    input_tag$attribs[["class"]],
    "sb-checkbox-control"
  )

  if (disabled) {
    input_tag$attribs[["disabled"]] <- NA
  }

  input_tag
}
