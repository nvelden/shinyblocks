#' Create a tab
#'
#' @param title Tab label.
#' @param ... Tab content.
#' @param value Optional tab value.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_tab <- function(title, ..., value = NULL) {
  htmltools::tags$div(
    class = "sb-tab-source",
    `data-title` = title,
    `data-value` = value %||% title,
    ...
  )
}

#' Create styled tabs
#'
#' @param ... `block_tab()` or `shiny::tabPanel()` items.
#' @param id Optional input id.
#' @param selected Optional selected tab value.
#' @param variant Visual variant: `default` or `line`.
#' @param orientation Layout orientation: `horizontal` or `vertical`.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_tabs <- function(
  ...,
  id = NULL,
  selected = NULL,
  variant = c("default", "line"),
  orientation = c("horizontal", "vertical"),
  class = NULL
) {
  variant <- match_arg(variant, c("default", "line"))
  orientation <- match_arg(orientation, c("horizontal", "vertical"))
  tab_items <- lapply(list(...), normalize_block_tab)
  if (!length(tab_items)) {
    stop("`block_tabs()` requires at least one tab.", call. = FALSE)
  }

  values <- vapply(tab_items, function(tab) tab$value, character(1))
  selected_value <- selected %||% values[[1]]
  if (!selected_value %in% values) {
    selected_value <- values[[1]]
  }

  tabset_id <- id %||% paste0("sb-tabs-", tab_id_suffix(values))
  trigger_tags <- Map(function(tab, index) {
    panel_id <- paste0(tabset_id, "-panel-", index)
    trigger_id <- paste0(tabset_id, "-trigger-", index)
    active <- identical(tab$value, selected_value)

    htmltools::tags$button(
      id = trigger_id,
      type = "button",
      class = "sb-tabs-trigger",
      role = "tab",
      `aria-selected` = if (active) "true" else "false",
      `aria-controls` = panel_id,
      tabindex = if (active) "0" else "-1",
      `data-value` = tab$value,
      `data-state` = if (active) "active" else "inactive",
      `data-orientation` = orientation,
      `data-variant` = variant,
      tab$title
    )
  }, tab_items, seq_along(tab_items))

  panel_tags <- Map(function(tab, index) {
    panel_id <- paste0(tabset_id, "-panel-", index)
    trigger_id <- paste0(tabset_id, "-trigger-", index)
    active <- identical(tab$value, selected_value)

    htmltools::tags$div(
      id = panel_id,
      class = "sb-tabs-panel",
      role = "tabpanel",
      tabindex = "0",
      `aria-labelledby` = trigger_id,
      `data-value` = tab$value,
      `data-state` = if (active) "active" else "inactive",
      `data-orientation` = orientation,
      `data-variant` = variant,
      hidden = if (active) NULL else "hidden",
      tab$children
    )
  }, tab_items, seq_along(tab_items))

  attach_shinyblocks_deps(
    htmltools::tags$div(
      id = tabset_id,
      class = merge_classes("sb-tabs", class),
      `data-sb-tabs` = "true",
      `data-sb-tabs-input-id` = id,
      `data-orientation` = orientation,
      `data-variant` = variant,
      htmltools::tags$div(
        class = "sb-tabs-list",
        role = "tablist",
        `aria-orientation` = orientation,
        `data-orientation` = orientation,
        `data-variant` = variant,
        trigger_tags
      ),
      htmltools::tags$div(
        class = "sb-tabs-content",
        `data-orientation` = orientation,
        `data-variant` = variant,
        panel_tags
      )
    )
  )
}

#' Update styled tabs
#'
#' Selects a tab rendered by [block_tabs()] from the server.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to [block_tabs()].
#' @param selected Tab value to activate.
#' @param notify Whether Shiny should receive an input event after the tab
#'   is selected.
#'
#' @return Invisibly returns `NULL`.
#' @family navigation
#' @export
update_block_tabs <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  selected,
  notify = TRUE
) {
  selected <- if (missing(selected)) NULL else selected
  shell_selection_update(session, input_id, selected, notify, "tab")
}

normalize_block_tab <- function(tab) {
  if (!inherits(tab, "shiny.tag")) {
    stop("`block_tabs()` children must be `block_tab()` or `shiny::tabPanel()` tags.", call. = FALSE)
  }

  title <- tab$attribs[["data-title"]] %||% tab$attribs[["title"]]
  value <- tab$attribs[["data-value"]] %||% title
  if (is.null(title) || !nzchar(as.character(title))) {
    stop("Each tab must have a non-empty title.", call. = FALSE)
  }
  if (is.null(value) || !nzchar(as.character(value))) {
    value <- title
  }

  list(
    title = as.character(title),
    value = as.character(value),
    children = tab$children
  )
}

tab_id_suffix <- function(values) {
  text <- paste(values, collapse = "|")
  sum(utf8ToInt(text) * seq_along(utf8ToInt(text)))
}
