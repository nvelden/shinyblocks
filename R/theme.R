#' Create theme overrides
#'
#' Emits a scoped `<style>` block that overrides shadcn token variables.
#' By default the overrides apply to the whole page (every `.sb-app` and
#' runtime root). Pass `scope` to confine the overrides to a single
#' subtree, which is essential when several differently-themed regions
#' share one page (for example a component gallery) so a local override
#' does not leak into the rest of the app.
#'
#' Like shadcn, tokens have separate light and dark values. The `...`
#' overrides apply to **both** light and dark mode. Pass `dark` to set
#' values that apply **only** in dark mode (when `[data-theme="dark"]` is
#' active), mirroring shadcn's `:root` / `.dark` token pairs. A token
#' present only in `dark` keeps the package default in light mode and the
#' dark value in dark mode.
#'
#' @param ... Named CSS token overrides, such as `primary`,
#'   `background`, or `radius`. Applied in both light and dark mode.
#' @param scope Optional CSS selector. When supplied, overrides apply
#'   only to elements matching `scope` and the runtime roots inside it,
#'   instead of the whole page. Defaults to `NULL` (page-wide).
#' @param dark Optional named list of token overrides applied only in
#'   dark mode, overriding the corresponding `...` value (or the package
#'   default) when `[data-theme="dark"]` is active. Defaults to `NULL`.
#'
#' @return An `htmltools` tag.
#' @family theme
#' @export
block_theme <- function(..., scope = NULL, dark = NULL) {
  overrides <- list(...)
  light_names <- names(overrides)

  if (length(overrides) > 0 && (is.null(light_names) || any(!nzchar(light_names)))) {
    stop("`block_theme()` overrides must be named.", call. = FALSE)
  }

  if (!is.null(dark)) {
    if (
      !is.list(dark) || length(dark) == 0 ||
        is.null(names(dark)) || any(!nzchar(names(dark)))
    ) {
      stop("`dark` must be a non-empty named list of token overrides.", call. = FALSE)
    }
  }

  if (length(overrides) == 0 && is.null(dark)) {
    stop("`block_theme()` requires named token overrides.", call. = FALSE)
  }

  invalid <- setdiff(c(light_names, names(dark)), theme_token_names())
  if (length(invalid) > 0) {
    stop(
      sprintf(
        "Unknown theme token(s): %s.",
        paste(sprintf("`%s`", invalid), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  if (!is.null(scope) && (!is.character(scope) || length(scope) != 1 || !nzchar(scope))) {
    stop("`scope` must be NULL or a single non-empty CSS selector.", call. = FALSE)
  }

  declarations <- function(values) {
    paste(
      vapply(
        names(values),
        function(name) sprintf("--%s: %s;", name, values[[name]]),
        character(1)
      ),
      collapse = ""
    )
  }

  root <- if (is.null(scope)) ".sb-app" else scope
  rules <- function(prefix, decls) {
    paste0(
      prefix, root, "{", decls, "}",
      prefix, root, " [data-shinyblocks-root],",
      prefix, root, " [data-shinyblocks-portal-root]{", decls, "}"
    )
  }

  theme_css <- ""
  if (length(overrides) > 0) {
    theme_css <- paste0(theme_css, rules("", declarations(overrides)))
  }
  if (!is.null(dark)) {
    theme_css <- paste0(theme_css, rules("[data-theme=\"dark\"] ", declarations(dark)))
  }

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
