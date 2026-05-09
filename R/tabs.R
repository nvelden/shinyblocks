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
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_tabs <- function(..., id = NULL, selected = NULL, class = NULL) {
  tabs <- shiny::tabsetPanel(..., id = id, selected = selected)
  query <- htmltools::tagQuery(tabs)
  anchors <- query$find("ul.nav > li > a")$selectedTags()
  selected_value <- selected %||% anchors[[1]]$attribs[["data-value"]] %||% ""

  query$
    addClass(merge_classes("sb-tabs", class))$
    addAttrs(`data-sb-tabs` = "true")$
    find("ul.nav")$
    each(function(tag, index) {
      tag$attribs[["role"]] <- "tablist"
      tag$attribs[["aria-orientation"]] <- "horizontal"
      tag$attribs[["class"]] <- merge_classes(
        tag$attribs[["class"]],
        "sb-tabs-list"
      )
    })$
  resetSelected()$
    find("ul.nav > li")$
    each(function(tag, index) {
      child <- htmltools::tagQuery(tag)$find("a")$selectedTags()[[1]]
      is_active <- identical(
        child$attribs[["data-value"]] %||% "",
        selected_value
      )

      tag$attribs[["class"]] <- merge_classes(
        gsub("\\bactive\\b", "", tag$attribs[["class"]] %||% ""),
        "nav-item"
        ,
        if (is_active) "active"
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
        if (is_active) "active"
      )
      tag$attribs[["role"]] <- "tab"
      tag$attribs[["aria-selected"]] <- if (is_active) "true" else "false"
      tag$attribs[["tabindex"]] <- if (is_active) "0" else "-1"
      tag$attribs[["aria-controls"]] <- controls
    })$
  resetSelected()$
    find(".tab-content")$
    addClass("sb-tabs-content")$
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
        if (is_active) "active"
      )
      tag$attribs[["role"]] <- "tabpanel"
      tag$attribs[["tabindex"]] <- "0"
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
