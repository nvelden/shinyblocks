#' Create a styled select input
#'
#' `block_select()` renders a hidden native `<select>` as the Shiny input
#' value source, plus a package runtime overlay for the visible
#' shadcn-style trigger and popup.
#'
#' @param input_id Input id.
#' @param choices Choice labels and values.
#' @param selected Optional selected value. When `multiple = TRUE`, use a
#'   character vector.
#' @param placeholder Optional placeholder shown when no value is selected.
#' @param disabled Whether the control is disabled.
#' @param width Optional CSS width value.
#' @param class Additional classes.
#' @param size Select size. One of `"default"`, `"sm"`, or `"lg"`.
#' @param style Inline CSS styles.
#' @param invalid Whether to show the invalid/error state.
#' @param multiple Whether multiple values can be selected.
#' @param max_items Optional maximum number of selected values when
#'   `multiple = TRUE`.
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
  invalid = FALSE,
  multiple = FALSE,
  max_items = NULL
) {
  validate_input_id(input_id)
  size <- match_arg(size, c("default", "sm", "lg"))
  choices_df <- normalize_choices(choices)
  validate_select_choice_values(choices_df$value)
  choice_values <- choices_df$value
  multiple <- isTRUE(multiple)
  max_items <- normalize_select_max_items(max_items)

  selected_value <- normalize_select_selected(
    selected,
    choice_values,
    multiple = multiple,
    placeholder = placeholder
  )
  width_value <- if (is.null(width)) {
    "100%"
  } else {
    htmltools::validateCssUnit(width)
  }
  native_options <- lapply(seq_len(nrow(choices_df)), function(i) {
    option_value <- choices_df$value[[i]]
    htmltools::tags$option(
      value = option_value,
      selected = if (option_value %in% selected_value) NA else NULL,
      choices_df$label[[i]]
    )
  })

  if (!multiple && !is.null(placeholder)) {
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
    multiple = if (multiple) NA else NULL,
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
      multiple = multiple,
      maxItems = max_items,
      spriteHref = sprite_href()
    ),
    input_id = input_id,
    state = list(value = if (multiple) I(selected_value) else selected_value),
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
#' @param selected Optional selected value. Use a character vector for
#'   multiple selects. `NULL` clears single selects to `""`; `character(0)`
#'   clears multiple selects.
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
  payload <- list()

  if (!missing(choices)) {
    choices_df <- normalize_choices(choices)
    validate_select_choice_values(choices_df$value)
    payload$choices <- runtime_choice_records(choices_df)

    if (
      !missing(selected) &&
        !is.null(selected)
    ) {
      selected_values <- normalize_select_update_selected(selected)
      if (any(!selected_values %in% choices_df$value)) {
        stop("`selected` must match one of `choices`.", call. = FALSE)
      }
    }
  }

  payload <- apply_update_fields(
    payload,
    list(
      field("selected", transform = normalize_select_update_selected),
      field_clearable("placeholder"),
      field("disabled", transform = isTRUE),
      field_clearable("width", transform = htmltools::validateCssUnit),
      field_clearable("class"),
      field("invalid", transform = isTRUE)
    )
  )

  if (!missing(size)) {
    payload$size <- match_arg(size, c("default", "sm", "lg"))
  }

  runtime_input_update(
    session,
    input_id,
    "select",
    payload,
    notify_key = "selected",
    notify = notify
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

normalize_select_selected <- function(
  selected,
  choice_values,
  multiple = FALSE,
  placeholder = NULL
) {
  if (is.null(selected)) {
    if (multiple) {
      return(character())
    }
    return(if (is.null(placeholder)) choice_values[[1]] else "")
  }

  selected <- as.character(selected)
  validate_select_selected_values(selected, choice_values, multiple = multiple)
  selected
}

validate_select_selected_values <- function(selected, choice_values, multiple) {
  if (anyNA(selected)) {
    stop("`selected` must not contain missing values.", call. = FALSE)
  }

  if (!multiple && length(selected) != 1L) {
    stop(
      "`selected` must be a single value when `multiple = FALSE`.",
      call. = FALSE
    )
  }

  if (any(!selected %in% choice_values)) {
    stop("`selected` must match one of `choices`.", call. = FALSE)
  }

  invisible(selected)
}

normalize_select_update_selected <- function(value) {
  if (is.null(value)) {
    ""
  } else {
    selected <- as.character(value)
    if (anyNA(selected)) {
      stop("`selected` must not contain missing values.", call. = FALSE)
    }
    selected
  }
}

normalize_select_max_items <- function(max_items) {
  if (is.null(max_items)) {
    return(NULL)
  }

  if (
    !is.numeric(max_items) ||
      length(max_items) != 1L ||
      is.na(max_items) ||
      max_items < 1 ||
      max_items != floor(max_items)
  ) {
    stop("`max_items` must be a positive whole number.", call. = FALSE)
  }

  as.integer(max_items)
}
