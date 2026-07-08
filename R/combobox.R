#' Create a searchable select (combobox) input
#'
#' `block_combobox()` renders a shadcn-style combobox: a trigger plus a
#' portal-rendered popup whose first row is a type-to-filter search box over the
#' choices. Like [block_select()] it is backed by a hidden native `<select>`
#' that carries the Shiny input value, and it supports single and multiple
#' selection. Reach for it over [block_select()] when the choice list is long
#' enough that users benefit from filtering (the searchable-select gap that
#' otherwise pushes people toward heavier third-party dropdown widgets).
#'
#' @inheritParams block_select
#' @param search_placeholder Optional placeholder shown in the filter box.
#'   Defaults to `"Search..."`.
#' @param empty_message Message shown in the popup when the filter matches no
#'   choices. Defaults to `"No results found."`.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @seealso [block_select()] for a non-searchable dropdown.
#' @export
block_combobox <- function(
  input_id,
  choices,
  selected = NULL,
  placeholder = NULL,
  search_placeholder = NULL,
  empty_message = NULL,
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
  search_placeholder <- normalize_combobox_text(
    search_placeholder,
    "Search...",
    "search_placeholder"
  )
  empty_message <- normalize_combobox_text(
    empty_message,
    "No results found.",
    "empty_message"
  )

  selected_value <- normalize_select_selected(
    selected,
    choice_values,
    multiple = multiple,
    placeholder = placeholder,
    max_items = max_items
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
    component = "combobox",
    props = list(
      choices = runtime_choice_records(choices_df),
      placeholder = placeholder,
      searchPlaceholder = search_placeholder,
      emptyMessage = empty_message,
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
    binding = list(input = TRUE, type = "shinyblocks.combobox"),
    class = class,
    children = list(hidden_native)
  )
}

#' Update a runtime combobox input
#'
#' Server-side updater for [block_combobox()]. Mirrors
#' [update_block_select()]: `multiple`, `max_items`, and `style` are create-only;
#' when `selected` is supplied without `choices`, it is validated for shape only
#' and resolved against the client's current choice list.
#'
#' @inheritParams update_block_select
#' @param search_placeholder Optional replacement filter-box placeholder.
#' @param empty_message Optional replacement empty-state message.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_combobox <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  choices,
  selected,
  placeholder,
  search_placeholder,
  empty_message,
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
      field(
        "searchPlaceholder",
        arg = "search_placeholder",
        transform = function(value) {
          normalize_combobox_text(value, "Search...", "search_placeholder")
        }
      ),
      field(
        "emptyMessage",
        arg = "empty_message",
        transform = function(value) {
          normalize_combobox_text(value, "No results found.", "empty_message")
        }
      ),
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
    "combobox",
    payload,
    notify_key = "selected",
    notify = notify
  )
}

normalize_combobox_text <- function(value, default, arg) {
  if (is.null(value)) {
    return(default)
  }
  if (!is.character(value) || length(value) != 1L || is.na(value)) {
    stop(
      sprintf("`%s` must be a single string.", arg),
      call. = FALSE
    )
  }
  value
}
