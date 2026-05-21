#' Create page-scoped theme overrides
#'
#' @param ... Named CSS token overrides, such as `primary`,
#'   `background`, or `radius`.
#'
#' @return An `htmltools` tag.
#' @family theme
#' @export
block_theme <- function(...) {
  overrides <- list(...)
  names <- names(overrides)

  if (length(overrides) == 0 || is.null(names) || any(!nzchar(names))) {
    stop("`block_theme()` requires named token overrides.", call. = FALSE)
  }

  invalid <- setdiff(names, theme_token_names())
  if (length(invalid) > 0) {
    stop(
      sprintf(
        "Unknown theme token(s): %s.",
        paste(sprintf("`%s`", invalid), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  declarations <- vapply(names, function(name) {
    sprintf("--%s: %s;", name, overrides[[name]])
  }, character(1))
  decls <- paste(declarations, collapse = "")
  theme_css <- paste0(
    ".sb-app{", decls, "}",
    ".sb-app [data-shinyblocks-root],",
    ".sb-app [data-shinyblocks-portal-root]{", decls, "}"
  )

  attach_shinyblocks_deps(
    htmltools::tags$style(
      class = "sb-theme-overrides",
      htmltools::HTML(theme_css)
    )
  )
}

#' Update the active theme
#'
#' @param session Shiny session.
#' @param mode Theme mode: `system`, `light`, or `dark`.
#'
#' @return Invisibly returns `NULL`.
#' @family theme
#' @export
update_block_theme <- function(
  session = shiny::getDefaultReactiveDomain(),
  mode = c("system", "light", "dark")
) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }

  mode <- match_arg(mode, c("system", "light", "dark"))
  session$sendCustomMessage("sb:theme", list(mode = mode))
  invisible(NULL)
}

theme_token_names <- function() {
  c(
    "radius",
    "background",
    "foreground",
    "card",
    "card-foreground",
    "popover",
    "popover-foreground",
    "primary",
    "primary-foreground",
    "secondary",
    "secondary-foreground",
    "muted",
    "muted-foreground",
    "accent",
    "accent-foreground",
    "destructive",
    "destructive-foreground",
    "border",
    "input",
    "ring",
    "sidebar",
    "sidebar-foreground",
    "sidebar-primary",
    "sidebar-primary-foreground",
    "sidebar-accent",
    "sidebar-accent-foreground",
    "sidebar-border",
    "sidebar-ring",
    "chart-1",
    "chart-2",
    "chart-3",
    "chart-4",
    "chart-5"
  )
}
