#' Create a pagination input
#'
#' Renders a shadcn-style pagination control with previous, next, numbered,
#' and ellipsis controls. The selected page is reported as an integer through
#' `input$<input_id>`.
#'
#' @param input_id Input id.
#' @param pages Total number of pages; a positive whole number.
#' @param selected Initially selected page.
#' @param sibling_count Number of page links shown on each side of the selected page.
#' @param show_edges Whether to keep the first and last page visible.
#' @param disabled Whether the entire control is disabled.
#' @param style Inline CSS styles applied to the pagination wrapper.
#' @param class Additional classes for the wrapper.
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_pagination <- function(
  input_id,
  pages,
  selected = 1,
  sibling_count = 1,
  show_edges = TRUE,
  disabled = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  pages <- pagination_whole_number(pages, "pages", 1L)
  selected <- pagination_whole_number(selected, "selected", 1L)
  if (selected > pages) {
    stop("`selected` must be less than or equal to `pages`.", call. = FALSE)
  }
  sibling_count <- pagination_whole_number(sibling_count, "sibling_count", 0L)
  show_edges <- pagination_flag(show_edges, "show_edges")
  disabled <- pagination_flag(disabled, "disabled")
  native <- hidden_native_input(
    input_id,
    type = "hidden",
    class = "sb-pagination-native",
    value = selected,
    style = NULL,
    tabindex = NULL,
    aria_hidden = FALSE
  )
  runtime_component(
    component = "pagination",
    props = list(
      pages = pages,
      siblingCount = sibling_count,
      showEdges = show_edges,
      disabled = disabled
    ),
    input_id = input_id,
    state = list(value = selected),
    binding = list(input = TRUE, type = "shinyblocks.pagination"),
    class = class,
    style = style,
    root_class = "sb-pagination",
    children = list(native)
  )
}

#' Update a pagination input
#'
#' Reducing `pages` below the current selection clamps to the new last page.
#' `sibling_count` and `show_edges` are create-only.
#'
#' @param session Shiny session.
#' @param input_id Input id passed to [block_pagination()].
#' @param pages Optional new total number of pages.
#' @param selected Optional new selected page.
#' @param disabled Optional disabled state.
#' @param style Optional replacement inline CSS styles.
#' @param class Optional replacement classes.
#' @param notify Whether Shiny should receive an event when selection changes.
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_pagination <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  pages,
  selected,
  disabled,
  style,
  class,
  notify = TRUE
) {
  payload <- list()
  if (!missing(pages)) {
    payload$pages <- pagination_whole_number(pages, "pages", 1L)
  }
  if (!missing(selected)) {
    payload$selected <- pagination_whole_number(selected, "selected", 1L)
  }
  if (!missing(pages) && !missing(selected) && selected > pages) {
    stop("`selected` must be less than or equal to `pages`.", call. = FALSE)
  }
  if (!missing(disabled)) {
    payload$disabled <- pagination_flag(disabled, "disabled")
  }
  payload <- apply_update_fields(
    payload,
    list(field_style("style"), field_clearable("class"))
  )
  payload$notify <- isTRUE(notify) && any(c("pages", "selected") %in% names(payload))
  runtime_input_update(
    session,
    input_id,
    "pagination",
    payload,
    notify_key = NULL,
    notify = notify
  )
}

pagination_whole_number <- function(value, name, minimum) {
  if (
    !is.numeric(value) ||
      length(value) != 1 ||
      is.na(value) ||
      !is.finite(value) ||
      value != floor(value) ||
      value < minimum
  ) {
    stop(
      sprintf(
        "`%s` must be a whole number greater than or equal to %d.",
        name,
        minimum
      ),
      call. = FALSE
    )
  }
  as.integer(value)
}

pagination_flag <- function(value, name) {
  if (!is.logical(value) || length(value) != 1 || is.na(value)) {
    stop(sprintf("`%s` must be `TRUE` or `FALSE`.", name), call. = FALSE)
  }
  isTRUE(value)
}
