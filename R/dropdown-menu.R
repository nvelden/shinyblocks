#' Create a dropdown menu item
#'
#' A selectable action row for [block_dropdown_menu()]. Activating the item
#' reports its `value` to `input$<id>` of the parent menu (event-style, like an
#' action button that carries a value).
#'
#' @param value String reported to the parent menu's `input$<id>` when the
#'   item is chosen. Required and must be unique within a menu.
#' @param label Item label. Defaults to `value`.
#' @param icon Optional leading icon: a vendored icon name or an `htmltools`
#'   tag.
#' @param shortcut Optional keyboard-shortcut hint rendered right-aligned
#'   (for display only; it does not bind a key).
#' @param disabled Whether the item is non-interactive.
#' @param variant Visual variant. One of `"default"` or `"destructive"`.
#'
#' @return A dropdown-menu item spec consumed by [block_dropdown_menu()].
#' @family content
#' @export
dropdown_menu_item <- function(
  value,
  label = value,
  icon = NULL,
  shortcut = NULL,
  disabled = FALSE,
  variant = c("default", "destructive")
) {
  check_string(value, "value", msg = "`value` must be a single string.")
  check_string(label, "label", msg = "`label` must be a single string.")
  check_string(shortcut, "shortcut", null_ok = TRUE)
  variant <- match_arg(variant, c("default", "destructive"))

  icon_parts <- resolve_dropdown_menu_icon(icon)

  structure(
    list(
      type = "item",
      value = value,
      labelHtml = html_fragment(label),
      iconName = icon_parts$name,
      iconHtml = icon_parts$html,
      shortcut = shortcut,
      disabled = isTRUE(disabled),
      variant = variant
    ),
    class = "shinyblocks_dropdown_menu_part"
  )
}

#' Create a dropdown menu section label
#'
#' A non-interactive heading that groups items in a [block_dropdown_menu()].
#'
#' @param label Section label text.
#'
#' @return A dropdown-menu label spec consumed by [block_dropdown_menu()].
#' @family content
#' @export
dropdown_menu_label <- function(label) {
  check_string(label, "label", msg = "`label` must be a single string.")
  structure(
    list(type = "label", labelHtml = html_fragment(label)),
    class = "shinyblocks_dropdown_menu_part"
  )
}

#' Create a dropdown menu separator
#'
#' A horizontal rule that visually divides groups of items in a
#' [block_dropdown_menu()].
#'
#' @return A dropdown-menu separator spec consumed by [block_dropdown_menu()].
#' @family content
#' @export
dropdown_menu_separator <- function() {
  structure(
    list(type = "separator"),
    class = "shinyblocks_dropdown_menu_part"
  )
}

# Resolve an item `icon` argument (icon name string or htmltools tag) into a
# `list(name=, html=)` payload pair, mirroring block_button()'s icon handling.
resolve_dropdown_menu_icon <- function(icon) {
  if (is.null(icon)) {
    return(list(name = NULL, html = NULL))
  }
  if (inherits(icon, "shiny.tag")) {
    return(list(name = NULL, html = html_fragment(icon)))
  }
  validate_icon_name(icon)
  list(name = as.character(icon), html = NULL)
}

# Serialize a `block_dropdown_menu()` `...` into the runtime `items` payload.
# Every entry must be produced by `dropdown_menu_item()` /
# `dropdown_menu_label()` / `dropdown_menu_separator()`.
normalize_dropdown_menu_items <- function(items) {
  lapply(items, function(item) {
    if (!inherits(item, "shinyblocks_dropdown_menu_part")) {
      stop(
        "`block_dropdown_menu()` items must be created with ",
        "`dropdown_menu_item()`, `dropdown_menu_label()`, or ",
        "`dropdown_menu_separator()`.",
        call. = FALSE
      )
    }
    unclass(item)
  })
}

#' Create a dropdown menu
#'
#' A portal-rendered action menu anchored to a trigger. Build the menu from
#' [dropdown_menu_item()], [dropdown_menu_label()], and
#' [dropdown_menu_separator()] parts. Choosing an item reports its `value` to
#' `input$<id>` as an event (fires again even when the same item is chosen
#' twice), so treat it like an action button that carries a value.
#'
#' The menu owns portal, focus, keyboard navigation (arrows, home/end,
#' enter/space, escape, typeahead), and dismiss behavior. Focus returns to the
#' trigger on close.
#'
#' @param trigger Trigger content. A single string renders a default-variant
#'   button label; an `htmltools` tag (icon button, avatar, ...) is rendered
#'   inside the trigger button as-is. Keep tag content inline and
#'   non-interactive to avoid nested buttons.
#' @param ... Menu parts created with [dropdown_menu_item()],
#'   [dropdown_menu_label()], and [dropdown_menu_separator()].
#' @param id Optional input id. When supplied, `input$<id>` reports the
#'   `value` of the most recently chosen item as an event.
#' @param label Optional accessible name for the trigger. Recommended when
#'   `trigger` is an icon-only tag.
#' @param side Side of the trigger to anchor on. One of `"bottom"`, `"top"`,
#'   `"left"`, `"right"`. Defaults to `"bottom"`.
#' @param align Alignment along the anchored side. One of `"start"`,
#'   `"center"`, `"end"`. Defaults to `"start"`.
#' @param trigger_variant Button variant for a string trigger. One of the
#'   [block_button()] variants. Defaults to `"outline"`.
#' @param disabled Whether the trigger is disabled.
#' @param style Optional inline CSS applied to the menu content container
#'   (string or named list).
#' @param class Additional classes for the menu content container.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_dropdown_menu <- function(
  trigger,
  ...,
  id = NULL,
  label = NULL,
  side = c("bottom", "top", "left", "right"),
  align = c("start", "center", "end"),
  trigger_variant = c(
    "outline", "default", "secondary", "ghost", "destructive", "link"
  ),
  disabled = FALSE,
  style = NULL,
  class = NULL
) {
  if (missing(trigger)) trigger <- NULL
  if (!is.character(trigger) && !inherits(trigger, "shiny.tag")) {
    stop(
      "`trigger` must be a single string label or an `htmltools` tag.",
      call. = FALSE
    )
  }
  if (is.character(trigger)) {
    check_string(trigger, "trigger", msg = "`trigger` must be a single string label.")
  }
  check_string(label, "label", null_ok = TRUE)
  if (!is.null(id)) {
    validate_input_id(id)
  }
  side <- match_arg(side, c("bottom", "top", "left", "right"))
  align <- match_arg(align, c("start", "center", "end"))
  trigger_variant <- match_arg(
    trigger_variant,
    c("outline", "default", "secondary", "ghost", "destructive", "link")
  )

  items <- normalize_dropdown_menu_items(list(...))
  content_style <- if (!is.null(style)) normalize_runtime_style(style) else NULL

  runtime_component(
    component = "dropdown-menu",
    input_id = id,
    props = list(
      triggerHtml = html_fragment(trigger),
      triggerLabel = label,
      triggerVariant = trigger_variant,
      items = items,
      side = side,
      align = align,
      disabled = isTRUE(disabled),
      spriteHref = sprite_href(),
      contentStyle = content_style,
      contentClass = class
    ),
    binding = if (is.null(id)) {
      list(input = FALSE)
    } else {
      list(input = TRUE, type = "shinyblocks.dropdown-menu")
    }
  )
}

#' Update a dropdown menu
#'
#' Send a server-driven update to a [block_dropdown_menu()].
#'
#' @param session Shiny session. Defaults to the current reactive session.
#' @param input_id Dropdown-menu input id (unnamespaced; updaters namespace
#'   via `session$ns()`).
#' @param items Optional replacement menu parts (list of
#'   [dropdown_menu_item()] / [dropdown_menu_label()] /
#'   [dropdown_menu_separator()]).
#' @param open Optional boolean. `TRUE` opens the menu, `FALSE` closes it.
#' @param side Optional side: `"bottom"`, `"top"`, `"left"`, `"right"`.
#' @param align Optional alignment: `"start"`, `"center"`, `"end"`.
#' @param disabled Optional trigger disabled state.
#' @param style Optional replacement content style (CSS string or named list).
#'   Pass `NULL` to clear.
#' @param class Optional replacement content classes. Pass `NULL` to clear.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @export
update_block_dropdown_menu <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  items,
  open,
  side,
  align,
  disabled,
  style,
  class
) {
  payload <- apply_update_fields(list(), list(
    field("open", transform = isTRUE),
    field("disabled", transform = isTRUE),
    field_style("contentStyle", "style"),
    field_clearable("contentClass", "class")
  ))

  if (!missing(items)) {
    payload$items <- normalize_dropdown_menu_items(items)
    payload$spriteHref <- sprite_href()
  }
  if (!missing(side)) {
    payload$side <- match_arg(side, c("bottom", "top", "left", "right"))
  }
  if (!missing(align)) {
    payload$align <- match_arg(align, c("start", "center", "end"))
  }

  # The reported value is event-style (item value), never the open state, so
  # server updates never notify an input event.
  runtime_input_update(
    session, input_id, "dropdown-menu", payload,
    notify_key = NULL
  )
}
