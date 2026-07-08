#' Create a breadcrumb trail
#'
#' Static navigation landmark showing the path to the current page, following
#' the shadcn breadcrumb pattern. Children must be [block_breadcrumb_item()]
#' or [block_breadcrumb_ellipsis()] entries; a separator is inserted between
#' consecutive children automatically and hidden from assistive technology.
#'
#' @param ... Breadcrumb entries built with [block_breadcrumb_item()] or
#'   [block_breadcrumb_ellipsis()].
#' @param separator Optional separator rendered between entries. Either a
#'   string (e.g. `"/"`) or an `htmltools` tag; defaults to a chevron icon.
#' @param style Inline CSS styles for the `<nav>` container.
#' @param class Additional classes for the `<nav>` container.
#'
#' @return An `htmltools` tag: a `<nav aria-label="breadcrumb">` landmark.
#' @family navigation
#' @export
block_breadcrumb <- function(..., separator = NULL, style = NULL, class = NULL) {
  children <- list(...)
  if (length(children) == 0L) {
    stop(
      "`block_breadcrumb()` needs at least one `block_breadcrumb_item()`.",
      call. = FALSE
    )
  }
  validate_children(
    children,
    c("breadcrumb-item", "breadcrumb-ellipsis"),
    "block_breadcrumb"
  )

  separator_content <- if (is.null(separator)) {
    block_icon("chevron-right")
  } else if (inherits(separator, "shiny.tag")) {
    separator
  } else if (is.character(separator) && length(separator) == 1L && !is.na(separator)) {
    separator
  } else {
    stop(
      "`separator` must be NULL, a single string, or an htmltools tag.",
      call. = FALSE
    )
  }

  entries <- vector("list", 2L * length(children) - 1L)
  for (i in seq_along(children)) {
    entries[[2L * i - 1L]] <- children[[i]]
    if (i < length(children)) {
      entries[[2L * i]] <- htmltools::tags$li(
        class = "sb-breadcrumb-separator",
        role = "presentation",
        `aria-hidden` = "true",
        separator_content
      )
    }
  }

  attach_shinyblocks_deps(
    htmltools::tags$nav(
      class = merge_classes("sb-breadcrumb", class),
      style = style,
      `aria-label` = "breadcrumb",
      htmltools::tags$ol(class = "sb-breadcrumb-list", entries)
    )
  )
}

#' Create a breadcrumb entry
#'
#' @param label Entry label. A string or an `htmltools` tag.
#' @param href Destination URL. Ignored when `current = TRUE` (the current
#'   page is not a link).
#' @param current Whether this entry is the current page. Rendered as a
#'   non-interactive `<span aria-current="page">`.
#' @param class Additional classes for the `<li>` entry.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_breadcrumb_item <- function(
  label,
  href = NULL,
  current = FALSE,
  class = NULL
) {
  if (missing(label) || is.null(label)) {
    stop("`label` is required for `block_breadcrumb_item()`.", call. = FALSE)
  }
  check_flag(current, "current")
  check_string(
    href, "href", null_ok = TRUE,
    msg = "`href` must be NULL or a single string."
  )

  content <- if (isTRUE(current)) {
    # Matches shadcn's BreadcrumbPage: exposed as a disabled link so AT users
    # hear it in the trail, but not focusable or activatable.
    htmltools::tags$span(
      class = "sb-breadcrumb-page",
      role = "link",
      `aria-disabled` = "true",
      `aria-current` = "page",
      label
    )
  } else if (!is.null(href)) {
    htmltools::tags$a(class = "sb-breadcrumb-link", href = href, label)
  } else {
    htmltools::tags$span(class = "sb-breadcrumb-text", label)
  }

  attach_shinyblocks_deps(
    htmltools::tags$li(
      class = merge_classes("sb-breadcrumb-item", class),
      `data-sb-child` = "breadcrumb-item",
      content
    )
  )
}

#' Create a collapsed-middle breadcrumb marker
#'
#' Placeholder for hidden entries in a long trail, following shadcn's
#' `BreadcrumbEllipsis`: a decorative ellipsis icon hidden from assistive
#' technology with a visually hidden text alternative.
#'
#' @param label Visually hidden text announced to assistive technology.
#' @param class Additional classes for the `<li>` entry.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_breadcrumb_ellipsis <- function(label = "More", class = NULL) {
  check_string(
    label, "label",
    msg = "`label` must be a single string."
  )

  attach_shinyblocks_deps(
    htmltools::tags$li(
      class = merge_classes("sb-breadcrumb-item", class),
      `data-sb-child` = "breadcrumb-ellipsis",
      htmltools::tags$span(
        class = "sb-breadcrumb-ellipsis",
        role = "presentation",
        `aria-hidden` = "true",
        block_icon("more-horizontal")
      ),
      htmltools::tags$span(class = "sb-breadcrumb-sr-only", label)
    )
  )
}
