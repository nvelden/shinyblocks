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
        vapply(
          dots[is_style],
          function(s) paste(as.character(s), collapse = ""),
          character(1)
        ),
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
#' When `id` is supplied the navigation becomes a Shiny input: clicking a
#' [block_nav_item()] reports that item's `value` as `input[[id]]` and moves the
#' selected highlight, so the sidebar can drive page navigation the same way a
#' Shiny tabset does. Without `id` the items stay plain links.
#'
#' @param ... Navigation items.
#' @param id Optional Shiny input id. When set, the selected item's `value` is
#'   reported as `input[[id]]`; pair it with [shiny::conditionalPanel()] or
#'   [shiny::renderUI()] to switch pages, and [update_block_nav()] to select
#'   from the server.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_nav <- function(..., id = NULL, class = NULL) {
  children <- list(...)
  validate_nav_children(children)

  # An input nav reports the clicked item's `value`, so every item must carry a
  # non-empty one. Without this an item with a tag label and no explicit
  # `value` would look clickable but never update `input[[id]]`.
  if (!is.null(id)) {
    values <- nav_leaf_values(children)
    missing_value <- !nzchar(values)
    if (any(missing_value)) {
      stop(
        "Every `block_nav_item()` in an input `block_nav(id = ...)` needs a ",
        "non-empty `value` (it is reported as `input[[id]]`). Items with a ",
        "tag label must pass `value` explicitly.",
        call. = FALSE
      )
    }
    duplicate_value <- values[duplicated(values)]
    if (length(duplicate_value)) {
      stop(
        "Every `block_nav_item()` in an input `block_nav(id = ...)` needs a ",
        "unique `value`; duplicate value: `",
        duplicate_value[[1]],
        "`.",
        call. = FALSE
      )
    }
  }

  attach_shinyblocks_deps(
    htmltools::tags$nav(
      # The DOM id is the routing target for `update_block_nav()`
      # (`sendInputMessage` dispatches by element id); the data attribute marks
      # the nav as a Shiny input for the runtime binding to find.
      id = id,
      class = merge_classes("sb-nav", class),
      `data-sb-nav-input-id` = id,
      children
    )
  )
}

#' Create a collapsible sidebar navigation group
#'
#' Groups wrap leaf [block_nav_item()] children in a disclosure region. The
#' group trigger toggles expansion only; it never reports a Shiny input value.
#'
#' @param label Group label.
#' @param ... Child [block_nav_item()] tags. Named arguments are applied to the
#'   group container as HTML attributes.
#' @param icon Optional icon tag or vendored icon name.
#' @param value Optional group identity for expansion state hooks. Stored as
#'   `data-sb-nav-group-value`; it is not reported as a nav input value.
#' @param expanded Whether the group starts expanded.
#' @param class Additional classes for the group container.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_nav_group <- function(
  label,
  ...,
  icon = NULL,
  value = NULL,
  expanded = TRUE,
  class = NULL
) {
  check_flag(expanded, "expanded")

  dots <- list(...)
  dot_names <- names(dots)
  has_name <- if (is.null(dot_names)) {
    rep(FALSE, length(dots))
  } else {
    nzchar(dot_names)
  }
  children <- dots[!has_name]
  attrs <- dots[has_name]
  attr_class <- attrs[["class"]]
  attrs[["class"]] <- NULL
  attrs[["data-sb-child"]] <- NULL
  attrs[["data-expanded"]] <- NULL
  attrs[["data-sb-nav-group-value"]] <- NULL
  validate_children(children, "nav-item", "block_nav_group")

  expanded_attr <- tolower(as.character(isTRUE(expanded)))
  group_id <- paste0(
    "sb-nav-group-",
    tab_id_suffix(c(
      as.character(value %||% nav_label_text(label) %||% "group"),
      nav_leaf_values(children)
    ))
  )

  trigger <- htmltools::tags$button(
    type = "button",
    class = "sb-nav-group-trigger",
    # When the sidebar collapses to the icon rail the visible `.sb-nav-label`
    # is hidden, so a text label doubles as the native hover tooltip (matching
    # `block_nav_item()`).
    title = nav_label_text(label),
    `aria-expanded` = expanded_attr,
    `aria-controls` = group_id,
    `data-expanded` = expanded_attr,
    `data-state` = if (isTRUE(expanded)) "open" else "closed",
    set_icon_position(icon, "inline-start"),
    htmltools::tags$span(class = "sb-nav-label", label),
    # Collapsed shows a right-pointing chevron; CSS rotates it to point down
    # when the group is expanded (matching the shadcn admin sidebar).
    set_icon_position("chevron-right", "inline-end")
  )

  items <- do.call(
    htmltools::tags$div,
    c(
      list(
        id = group_id,
        class = "sb-nav-group-items",
        role = "group",
        `aria-label` = nav_label_text(label),
        `data-expanded` = expanded_attr,
        hidden = if (isTRUE(expanded)) NULL else "hidden"
      ),
      children
    )
  )

  group_args <- c(
    attrs,
    list(
      class = merge_classes("sb-nav-group", attr_class, class),
      `data-sb-child` = "nav-group",
      `data-expanded` = expanded_attr,
      `data-sb-nav-group-value` = value,
      trigger,
      items
    )
  )

  attach_shinyblocks_deps(do.call(htmltools::tags$div, group_args))
}

#' Create a sidebar navigation section label
#'
#' Section labels are non-interactive captions inside [block_nav()]. They do not
#' report a Shiny input value.
#'
#' @param text Label text.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_nav_label <- function(text, class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-nav-section-label", class),
      `data-sb-child` = "nav-label",
      text
    )
  )
}

#' Create a sidebar navigation item
#'
#' @param label Navigation label.
#' @param value Value reported as the input when the parent [block_nav()] has an
#'   `id`. Defaults to `label` when it is a single string.
#' @param href Destination URL. Ignored when the parent [block_nav()] is an
#'   input (the click selects the item instead of following the link).
#' @param icon Optional icon tag or vendored icon name.
#' @param selected Whether the item is selected.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_nav_item <- function(
  label,
  value = NULL,
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

  # The reported input value defaults to the text label; an explicit `value`
  # is required when the label is a tag.
  value <- value %||%
    (if (is.character(label) && length(label) == 1L) label else NULL)

  attach_shinyblocks_deps(
    htmltools::tags$a(
      class = merge_classes("sb-nav-item", if (selected) "is-selected", class),
      href = href,
      title = tooltip,
      `aria-current` = if (selected) "page" else NULL,
      `data-sb-child` = "nav-item",
      `data-value` = value,
      icon,
      htmltools::tags$span(class = "sb-nav-label", label)
    )
  )
}

#' Select a sidebar navigation item from the server
#'
#' Activates an item rendered by [block_nav_item()] inside a [block_nav()] that
#' was given an `id`, mirroring the click behaviour from the server.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to [block_nav()].
#' @param selected Nav item `value` to activate.
#' @param notify Whether Shiny should receive an input event after the item is
#'   selected.
#'
#' @return Invisibly returns `NULL`.
#' @family navigation
#' @export
update_block_nav <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  selected,
  notify = TRUE
) {
  selected <- if (missing(selected)) NULL else selected
  shell_selection_update(session, input_id, selected, notify, "nav")
}

# Shared server-side selector for the tab and sidebar-nav inputs. Both are real
# runtime InputBindings keyed by their element's DOM id, so the update routes via
# `sendInputMessage()` (mirroring the runtime-component updaters). Delivery goes
# through the root session: a `moduleServer` proxy re-namespaces the first arg of
# its own `sendInputMessage()`, which would double-prefix the already-namespaced
# target and silently drop the update.
shell_selection_update <- function(session, input_id, selected, notify, noun) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$sendInputMessage)) {
    stop("`session` must provide a `sendInputMessage()` method.", call. = FALSE)
  }

  validate_input_id(input_id)
  if (is.null(selected) || !nzchar(as.character(selected)[[1]])) {
    stop(
      sprintf("`selected` must be a single non-empty %s value.", noun),
      call. = FALSE
    )
  }

  target <- if (is.function(session$ns)) session$ns(input_id) else input_id
  runtime_root_session(session)$sendInputMessage(
    target,
    list(selected = as.character(selected)[[1]], notify = isTRUE(notify))
  )
  invisible(NULL)
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
    isTRUE(
      x$attribs[["data-sb-child"]] %in% c("nav-item", "nav-group", "nav-label")
    )
}

is_nav_container_tag <- function(x) {
  inherits(x, "shiny.tag") &&
    identical(x$name, "nav")
}

validate_nav_children <- function(children) {
  validate_children(
    children,
    c("nav-item", "nav-group", "nav-label"),
    "block_nav"
  )

  groups <- vapply(
    children,
    function(child) identical(child$attribs[["data-sb-child"]], "nav-group"),
    logical(1)
  )
  lapply(children[groups], function(group) {
    items <- nav_group_items(group)
    validate_children(items, "nav-item", "block_nav_group")
  })

  invisible(children)
}

nav_leaf_values <- function(children) {
  unlist(
    lapply(children, function(child) {
      type <- child$attribs[["data-sb-child"]]
      if (identical(type, "nav-item")) {
        return(as.character(child$attribs[["data-value"]] %||% ""))
      }
      if (identical(type, "nav-group")) {
        return(nav_leaf_values(nav_group_items(child)))
      }
      character()
    }),
    use.names = FALSE
  )
}

nav_group_items <- function(group) {
  containers <- Filter(
    function(child) {
      inherits(child, "shiny.tag") &&
        identical(child$attribs[["class"]], "sb-nav-group-items")
    },
    group$children
  )
  if (!length(containers)) {
    return(list())
  }
  containers[[1]]$children
}

nav_label_text <- function(label) {
  if (is.character(label) && length(label) == 1L) {
    return(label)
  }
  NULL
}
