#' Create a tab
#'
#' @param title Tab label.
#' @param ... Tab content.
#' @param value Optional tab value.
#'
#' @return A Shiny tab panel.
#' @family navigation
#' @export
block_tab <- function(title, ..., value = NULL) {
  shiny::tabPanel(
    title = title,
    htmltools::tags$div(class = "sb-tab", ...),
    value = value %||% title
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
  tabs <- shiny::tabsetPanel(..., id = id, selected = selected)
  tabs$attribs[["data-sb-tabs"]] <- "true"
  tabs$attribs[["data-orientation"]] <- orientation
  tabs$attribs[["data-variant"]] <- variant
  query <- htmltools::tagQuery(tabs)
  anchors <- query$find("ul.nav > li > a")$selectedTags()
  selected_value <- selected %||% anchors[[1]]$attribs[["data-value"]] %||% ""

  query$
    addClass(merge_classes("sb-tabs", class))$
    find("ul.nav")$
    each(function(tag, index) {
      tag$attribs[["role"]] <- "tablist"
      tag$attribs[["aria-orientation"]] <- orientation
      tag$attribs[["class"]] <- merge_classes(
        gsub("\\bnav-tabs\\b", "", tag$attribs[["class"]] %||% ""),
        "sb-tabs-list"
      )
      tag$attribs[["data-orientation"]] <- orientation
      tag$attribs[["data-variant"]] <- variant
    })$
  resetSelected()$
    find("ul.nav > li")$
    each(function(tag, index) {
      tag$attribs[["class"]] <- merge_classes(
        gsub("\\bactive\\b", "", tag$attribs[["class"]] %||% ""),
        "nav-item"
      )
    })$
  resetSelected()$
    find("ul.nav > li > a")$
    each(function(tag, index) {
      is_active <- identical(
        tag$attribs[["data-value"]] %||% "",
        selected_value
      )
      controls <- sub("^#", "", tag$attribs[["href"]] %||% "")

      tag$attribs[["id"]] <- paste0(controls, "-trigger")

      tag$attribs[["class"]] <- merge_classes(
        gsub("\\bactive\\b", "", tag$attribs[["class"]] %||% ""),
        "nav-link",
        "sb-tabs-trigger"
      )
      tag$attribs[["role"]] <- "tab"
      tag$attribs[["aria-selected"]] <- if (is_active) "true" else "false"
      tag$attribs[["tabindex"]] <- if (is_active) "0" else "-1"
      tag$attribs[["aria-controls"]] <- controls
      tag$attribs[["data-state"]] <- if (is_active) "active" else "inactive"
      tag$attribs[["data-orientation"]] <- orientation
      tag$attribs[["data-variant"]] <- variant
    })$
  resetSelected()$
    find(".tab-content")$
    each(function(tag, index) {
      tag$attribs[["class"]] <- merge_classes(
        tag$attribs[["class"]],
        "sb-tabs-content"
      )
      tag$attribs[["data-orientation"]] <- orientation
      tag$attribs[["data-variant"]] <- variant
    })$
  resetSelected()$
    find(".tab-pane")$
    each(function(tag, index) {
      is_active <- identical(
        tag$attribs[["data-value"]] %||% "",
        selected_value
      )
      pane_id <- tag$attribs[["id"]] %||% ""

      tag$attribs[["class"]] <- merge_classes(
        gsub("\\bactive\\b", "", tag$attribs[["class"]] %||% ""),
        "tab-pane",
        "sb-tabs-panel"
      )
      tag$attribs[["role"]] <- "tabpanel"
      tag$attribs[["tabindex"]] <- "0"
      tag$attribs[["data-state"]] <- if (is_active) "active" else "inactive"
      tag$attribs[["data-orientation"]] <- orientation
      tag$attribs[["data-variant"]] <- variant
      if (nzchar(pane_id)) {
        tag$attribs[["aria-labelledby"]] <- paste0(pane_id, "-trigger")
      }

      if (is_active) {
        tag$attribs[["hidden"]] <- NULL
      } else {
        tag$attribs[["hidden"]] <- "hidden"
      }
    })

  attach_shinyblocks_deps(query$allTags())
}
