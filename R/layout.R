LAYOUT_GAPS <- c("sm", "md", "lg")
LAYOUT_ALIGNS <- c("stretch", "start", "center", "end")
LAYOUT_JUSTIFIES <- c("start", "center", "end", "between")

layout_gap_class <- function(gap) {
  paste0("sb-layout-gap-", match_arg(gap, LAYOUT_GAPS, "gap"))
}

layout_align_class <- function(align) {
  paste0("sb-layout-align-", match_arg(align, LAYOUT_ALIGNS, "align"))
}

layout_justify_class <- function(justify) {
  paste0(
    "sb-layout-justify-",
    match_arg(justify, LAYOUT_JUSTIFIES, "justify")
  )
}

#' Stack content vertically
#'
#' Arrange content in a vertical flow with package-owned semantic spacing.
#'
#' @param ... Child content to arrange. Named arguments are applied to the
#'   container as HTML attributes (the `htmltools` convention), e.g. `id`,
#'   `style`, or `data-*`. Layout itself (display, direction, gap, alignment) is
#'   owned by the primitive's classes — use `gap`/`align`, not an inline
#'   `style`, to control it.
#' @param gap Spacing between children: `"sm"`, `"md"`, or `"lg"`.
#' @param align Cross-axis alignment: `"stretch"`, `"start"`, `"center"`, or
#'   `"end"`.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family layout
#' @export
block_stack <- function(
  ...,
  gap = c("md", "sm", "lg"),
  align = c("stretch", "start", "center", "end"),
  class = NULL
) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes(
        "sb-stack",
        layout_gap_class(gap),
        layout_align_class(align),
        class
      ),
      ...
    )
  )
}

#' Cluster content horizontally
#'
#' Arrange content in a horizontal group with semantic spacing and optional
#' wrapping.
#'
#' @param ... Child content to arrange. Named arguments are applied to the
#'   container as HTML attributes (the `htmltools` convention), e.g. `id`,
#'   `style`, or `data-*`. Layout itself (display, wrapping, gap, alignment) is
#'   owned by the primitive's classes — use `gap`/`align`/`justify`/`wrap`, not
#'   an inline `style`, to control it.
#' @param gap Spacing between children: `"sm"`, `"md"`, or `"lg"`.
#' @param align Cross-axis alignment: `"center"`, `"start"`, `"end"`, or
#'   `"stretch"`.
#' @param justify Main-axis distribution: `"start"`, `"center"`, `"end"`, or
#'   `"between"`.
#' @param wrap Whether children may wrap onto additional rows.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family layout
#' @export
block_cluster <- function(
  ...,
  gap = c("sm", "md", "lg"),
  align = c("center", "start", "end", "stretch"),
  justify = c("start", "center", "end", "between"),
  wrap = TRUE,
  class = NULL
) {
  check_flag(wrap, "wrap")

  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes(
        "sb-cluster",
        layout_gap_class(gap),
        layout_align_class(align),
        layout_justify_class(justify),
        class
      ),
      `data-wrap` = tolower(as.character(wrap)),
      ...
    )
  )
}

# Strict validation for `block_grid(min_width =)`.
#
# `min_width` is interpolated verbatim into the inline `style` attribute (inside
# a `min()`/`minmax()` grid track), so it is a CSS-injection sink:
# `htmltools::validateCssUnit()` is far too permissive here — its `calc(.*)`
# branch accepts arbitrary text including `;`, letting callers smuggle extra
# declarations into `style`, and it also waves through non-length keywords
# (`"auto"`, `"inherit"`, `"fit-content"`, `"calc(auto)"`) that silently break
# the responsive track. Accept only a single finite, non-negative numeric or a
# strict `<number><length-unit>` / `<number>%` string. `calc()` and CSS-wide
# keywords are rejected outright (no current call site needs them).
GRID_MIN_WIDTH_PATTERN <- paste0(
  "^(?:[0-9]+(?:\\.[0-9]+)?|\\.[0-9]+)",
  "(?:px|rem|em|ex|ch|vw|vh|vmin|vmax|cm|mm|in|pt|pc|q|%)$"
)

validate_grid_min_width <- function(min_width) {
  reject <- function() {
    stop(
      "`min_width` must be a single non-negative CSS length or percentage ",
      "(e.g. \"16rem\", \"280px\", \"50%\").",
      call. = FALSE
    )
  }

  if (length(min_width) != 1 || is.na(min_width)) {
    reject()
  }

  if (is.numeric(min_width)) {
    if (!is.finite(min_width) || min_width < 0) {
      reject()
    }
    return(paste0(format(min_width, scientific = FALSE, trim = TRUE), "px"))
  }

  if (!is.character(min_width)) {
    reject()
  }

  value <- trimws(min_width)
  # Unitless zero is the only valid lengthless value in a grid track.
  if (grepl("^0+(?:\\.0+)?$", value, perl = TRUE)) {
    return("0")
  }
  if (!grepl(GRID_MIN_WIDTH_PATTERN, value, ignore.case = TRUE, perl = TRUE)) {
    reject()
  }
  value
}

#' Create a responsive content grid
#'
#' Arrange repeated content in a responsive auto-fit grid whose columns shrink
#' safely to the available width.
#'
#' @param ... Child content to arrange. Named arguments are applied to the
#'   container as HTML attributes (the `htmltools` convention), e.g. `id`,
#'   `style`, or `data-*`. The grid's responsive track (`--sb-grid-min`) is
#'   managed from the validated `min_width` and is authoritative: a caller
#'   `style` cannot override it.
#' @param min_width Minimum preferred column width as a single non-negative CSS
#'   length or percentage (e.g. `"16rem"`, `280`, `"50%"`). `calc()` and
#'   CSS-wide keywords are not accepted.
#' @param gap Spacing between children: `"sm"`, `"md"`, or `"lg"`.
#' @param align Cross-axis alignment: `"stretch"`, `"start"`, `"center"`, or
#'   `"end"`.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family layout
#' @export
block_grid <- function(
  ...,
  min_width = "16rem",
  gap = c("md", "sm", "lg"),
  align = c("stretch", "start", "center", "end"),
  class = NULL
) {
  min_width <- validate_grid_min_width(min_width)

  # A caller may pass `style` through `...` (htmltools convention). The grid
  # track is component-owned and was validated from `min_width`, so emit
  # `--sb-grid-min` *after* any caller style: within one inline `style`
  # attribute the last declaration of a property wins, making the validated
  # value authoritative and closing the override vector that a trailing
  # `style = "--sb-grid-min:..."` would otherwise open.
  dots <- list(...)
  dot_names <- names(dots)
  caller_style <- NULL
  if (!is.null(dot_names)) {
    is_style <- nzchar(dot_names) & dot_names == "style"
    if (any(is_style)) {
      caller_style <- paste(
        vapply(dots[is_style], function(s) paste(as.character(s), collapse = ""), character(1)),
        collapse = "; "
      )
      dots <- dots[!is_style]
    }
  }

  grid_decl <- paste0("--sb-grid-min:", min_width, ";")
  style <- if (!is.null(caller_style) && nzchar(trimws(caller_style))) {
    paste0(sub(";?\\s*$", "; ", trimws(caller_style)), grid_decl)
  } else {
    grid_decl
  }

  attach_shinyblocks_deps(
    do.call(
      htmltools::tags$div,
      c(
        list(
          class = merge_classes(
            "sb-grid",
            layout_gap_class(gap),
            layout_align_class(align),
            class
          ),
          style = style
        ),
        dots
      )
    )
  )
}

#' Create a dashboard sidebar
#'
#' @param ... Sidebar content.
#' @param title Optional sidebar title.
#' @param collapsible Whether the sidebar can collapse on larger screens.
#' @param collapsed Whether the sidebar starts collapsed on larger screens.
#' @param id Optional sidebar DOM id.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family layout
#' @export
block_sidebar <- function(
  ...,
  title = NULL,
  collapsible = FALSE,
  collapsed = FALSE,
  id = NULL,
  class = NULL
) {
  children <- list(...)

  attach_shinyblocks_deps(
    htmltools::tags$aside(
      id = id,
      class = merge_classes("sb-sidebar", class),
      `data-collapsible` = tolower(as.character(isTRUE(collapsible))),
      `data-collapsed` = tolower(as.character(isTRUE(collapsed))),
      if (!is.null(title)) {
        htmltools::tags$div(
          class = "sb-sidebar-title",
          htmltools::tags$span(class = "sb-sidebar-title-text", title),
          if (isTRUE(collapsible)) {
            htmltools::tags$button(
              class = "sb-sidebar-toggle",
              type = "button",
              `aria-label` = "Toggle sidebar",
              `aria-expanded` = if (isTRUE(collapsed)) "false" else "true",
              block_icon("panel-left")
            )
          }
        )
      },
      sidebar_content(children)
    )
  )
}

#' Create a dashboard header
#'
#' @param ... Header content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family layout
#' @export
block_header <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$header(class = merge_classes("sb-header", class), ...)
  )
}

#' Create a navigation container
#'
#' @param ... Navigation items.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_nav <- function(..., class = NULL) {
  children <- list(...)
  validate_children(children, "nav-item", "block_nav")

  attach_shinyblocks_deps(
    htmltools::tags$nav(
      class = merge_classes("sb-nav", class),
      children
    )
  )
}

#' Create a sidebar navigation item
#'
#' @param label Navigation label.
#' @param href Destination URL.
#' @param icon Optional icon tag or vendored icon name.
#' @param selected Whether the item is selected.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_nav_item <- function(
  label,
  href = "#",
  icon = NULL,
  selected = FALSE,
  class = NULL
) {
  icon <- set_icon_position(icon, "inline-start")

  # A plain-text label doubles as the native hover tooltip and, when the
  # sidebar collapses to the icon rail, as the link's accessible-name fallback
  # (the visible `.sb-nav-label` is visually hidden there, and the icon is
  # `aria-hidden`). Non-character labels (e.g. a tag) are left untitled.
  tooltip <- if (is.character(label) && length(label) == 1L) label

  attach_shinyblocks_deps(
    htmltools::tags$a(
      class = merge_classes("sb-nav-item", if (selected) "is-selected", class),
      href = href,
      title = tooltip,
      `aria-current` = if (selected) "page" else NULL,
      `data-sb-child` = "nav-item",
      icon,
      htmltools::tags$span(class = "sb-nav-label", label)
    )
  )
}

sidebar_content <- function(children) {
  if (length(children) == 0) {
    return(NULL)
  }

  if (all(vapply(children, is_nav_item_tag, logical(1)))) {
    return(htmltools::tags$nav(class = "sb-sidebar-nav", children))
  }

  if (length(children) == 1 && is_nav_container_tag(children[[1]])) {
    nav <- children[[1]]
    nav$attribs$class <- merge_classes(nav$attribs$class, "sb-sidebar-nav")
    return(nav)
  }

  children
}

is_nav_item_tag <- function(x) {
  inherits(x, "shiny.tag") &&
    identical(x$attribs[["data-sb-child"]], "nav-item")
}

is_nav_container_tag <- function(x) {
  inherits(x, "shiny.tag") &&
    identical(x$name, "nav")
}
