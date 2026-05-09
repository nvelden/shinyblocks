#' Create an input group
#'
#' @param ... Input group content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_input_group <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-input-group", class),
      `data-sb-child` = "input-group",
      ...
    )
  )
}

#' Create an input group addon
#'
#' @param ... Addon content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_input_group_addon <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-input-group-addon", class),
      `data-sb-child` = "input-group-addon",
      ...
    )
  )
}
