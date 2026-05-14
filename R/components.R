#' Create a dashboard card
#'
#' @param ... Card body content or composed card region tags.
#' @param title Optional card title.
#' @param description Optional card description.
#' @param value Optional primary value.
#' @param footer Optional card footer content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card <- function(
  ...,
  title = NULL,
  description = NULL,
  value = NULL,
  footer = NULL,
  class = NULL
) {
  title_tag <- as_component_child(title, "card-title", block_card_title)
  description_tag <- as_component_child(
    description,
    "card-description",
    block_card_description
  )
  footer_tag <- as_component_child(footer, "card-footer", block_card_footer)

  header_tag <- if (!is.null(title_tag) || !is.null(description_tag)) {
    block_card_header(title_tag, description_tag)
  }

  content_tag <- block_card_content(
    if (!is.null(value)) {
      htmltools::tags$div(class = "sb-card-value", value)
    },
    ...
  )

  runtime_component(
    component = "card",
    children = list(header_tag, content_tag, footer_tag),
    class = merge_classes("sb-card", class)
  )
}

#' Create a card header
#'
#' @param ... Card header content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card_header <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-card-header", class),
      `data-sb-child` = "card-header",
      ...
    )
  )
}

#' Create a card title
#'
#' @param ... Card title content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card_title <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$h3(
      class = merge_classes("sb-card-title", class),
      `data-sb-child` = "card-title",
      ...
    )
  )
}

#' Create a card description
#'
#' @param ... Card description content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card_description <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$p(
      class = merge_classes("sb-card-description", class),
      `data-sb-child` = "card-description",
      ...
    )
  )
}

#' Create card content
#'
#' @param ... Card content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card_content <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-card-content", class),
      `data-sb-child` = "card-content",
      ...
    )
  )
}

#' Create a card footer
#'
#' @param ... Card footer content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card_footer <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-card-footer", class),
      `data-sb-child` = "card-footer",
      ...
    )
  )
}

#' Create a modern button
#'
#' @param label Button label.
#' @param variant Visual variant.
#' @param size Button size.
#' @param icon Optional icon tag or vendored icon name.
#' @param icon_position Whether the icon appears before or after the label.
#' @param ... Additional attributes passed to `htmltools::tags$button`.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family action
#' @export
block_button <- function(
  label,
  variant = c(
    "default",
    "secondary",
    "outline",
    "ghost",
    "destructive",
    "link"
  ),
  size = c("default", "sm", "lg", "icon"),
  icon = NULL,
  icon_position = c("inline-start", "inline-end"),
  ...,
  class = NULL
) {
  variant <- match_arg(
    variant,
    c("default", "secondary", "outline", "ghost", "destructive", "link")
  )
  size <- match_arg(size, c("default", "sm", "lg", "icon"))
  icon_position <- match_arg(
    icon_position,
    c("inline-start", "inline-end"),
    "icon_position"
  )
  attrs <- named_attrs(list(...))
  disabled <- isTRUE(attrs$disabled) || identical(attrs$disabled, NA)
  attrs$disabled <- NULL
  if (!is.null(attrs$style)) {
    attrs$style <- normalize_runtime_style(attrs$style)
  }

  icon_name <- NULL
  icon_html <- NULL
  if (!is.null(icon)) {
    if (inherits(icon, "shiny.tag")) {
      icon$attribs[["data-icon"]] <- icon_position
      icon_html <- html_fragment(icon)
    } else {
      validate_icon_name(icon)
      icon_name <- icon
    }
  }

  runtime_component(
    component = "button",
    props = list(
      labelHtml = html_fragment(label),
      variant = variant,
      size = size,
      iconName = icon_name,
      iconHtml = icon_html,
      iconPosition = icon_position,
      spriteHref = sprite_href(),
      attrs = attrs,
      disabled = disabled
    ),
    class = class
  )
}

#' Create a badge
#'
#' @param label Badge label.
#' @param variant Visual variant.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_badge <- function(
  label,
  variant = c("default", "secondary", "outline", "destructive"),
  class = NULL
) {
  variant <- match_arg(
    variant,
    c("default", "secondary", "outline", "destructive")
  )

  runtime_component(
    component = "badge",
    props = list(
      labelHtml = html_fragment(label),
      variant = variant
    ),
    class = class
  )
}

#' Create an alert title
#'
#' @param ... Alert title content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert_title <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$h5(
      class = merge_classes("sb-alert-title", class),
      `data-sb-child` = "alert-title",
      ...
    )
  )
}

#' Create an alert description
#'
#' @param ... Alert description content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert_description <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-alert-description", class),
      `data-sb-child` = "alert-description",
      ...
    )
  )
}

#' Create an alert
#'
#' @param title Alert title. Required for accessibility.
#' @param ... Additional alert body content.
#' @param description Optional alert description.
#' @param icon Optional icon tag or vendored icon name.
#' @param variant Visual variant.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert <- function(
  title,
  ...,
  description = NULL,
  icon = "info",
  variant = c("default", "destructive"),
  class = NULL
) {
  if (missing(title) || is.null(title)) {
    stop("`title` is required.", call. = FALSE)
  }

  variant <- match_arg(variant, c("default", "destructive"))
  title_tag <- as_component_child(title, "alert-title", block_alert_title)
  description_tag <- as_component_child(
    description,
    "alert-description",
    block_alert_description
  )
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "alert",
    props = list(
      variant = variant,
      titleHtml = html_fragment(title_tag),
      descriptionHtml = if (!is.null(description_tag)) {
        html_fragment(description_tag)
      } else {
        NULL
      },
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL
    ),
    class = class
  )
}

#' Create a dialog (Phase 4.2 — Shiny-bound modal)
#'
#' A modal dialog rendered into the runtime portal root. Reports its
#' open/closed state to `input$<id>` and accepts server-driven
#' updates through `update_block_dialog()`. A.11y behaviors (escape,
#' outside-click, focus trap, focus return, scroll lock) land in 4.3.
#'
#' @param id Required input id. `input$<id>` is `TRUE` when open,
#'   `FALSE` when closed.
#' @param title Required dialog title. Used as the accessible name.
#' @param ... Body content. Serialized to HTML in 4.1/4.2; arbitrary
#'   Shiny children become Shiny-bound in a later sub-phase.
#' @param description Optional description below the title.
#' @param trigger Optional label string. Renders a default-variant
#'   `block_button()` next to the mount node that opens the dialog
#'   when clicked. Pass `NULL` (default) to drive open state purely
#'   from the server with `update_block_dialog()`.
#' @param open Initial open state. Defaults to `FALSE`.
#' @param hide_title Whether to visually hide the title while keeping
#'   it available to assistive technology as the dialog's accessible
#'   name. Defaults to `FALSE`.
#' @param class Additional classes for the dialog content container.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_dialog <- function(
  id,
  title,
  ...,
  description = NULL,
  trigger = NULL,
  open = FALSE,
  hide_title = FALSE,
  class = NULL
) {
  if (missing(id) || is.null(id)) {
    stop("`id` is required.", call. = FALSE)
  }
  if (missing(title) || is.null(title)) {
    stop("`title` is required.", call. = FALSE)
  }
  if (!is.null(trigger) && (!is.character(trigger) || length(trigger) != 1)) {
    stop("`trigger` must be a single string label or NULL.", call. = FALSE)
  }

  runtime_component(
    component = "dialog",
    input_id = id,
    props = list(
      titleHtml = html_fragment(title),
      descriptionHtml = if (!is.null(description)) {
        html_fragment(description)
      } else {
        NULL
      },
      bodyHtml = html_fragment(...),
      triggerLabel = trigger,
      hideTitle = isTRUE(hide_title)
    ),
    state = list(value = isTRUE(open), open = isTRUE(open)),
    binding = list(input = TRUE),
    class = class
  )
}

#' Update a runtime dialog
#'
#' Send a server-driven update to a `block_dialog()`.
#'
#' @param session Shiny session. Defaults to the current reactive
#'   session.
#' @param input_id Dialog input id (unnamespaced; updaters namespace
#'   via `session$ns()`).
#' @param open Optional boolean. `TRUE` opens, `FALSE` closes.
#' @param title Optional replacement title.
#' @param description Optional replacement description.
#' @param notify Whether Shiny receives an input event when `open`
#'   changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @export
update_block_dialog <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  open,
  title,
  description,
  notify = TRUE
) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$ns)) {
    stop("`session` must provide an `ns()` method.", call. = FALSE)
  }
  if (!is.function(session$sendInputMessage)) {
    stop("`session` must provide a `sendInputMessage()` method.", call. = FALSE)
  }

  validate_input_id(input_id)
  payload <- list()

  if (!missing(open)) {
    payload$open <- isTRUE(open)
  }
  if (!missing(title)) {
    payload$titleHtml <- if (is.null(title)) NULL else html_fragment(title)
  }
  if (!missing(description)) {
    payload$descriptionHtml <- if (is.null(description)) NULL else html_fragment(description)
  }

  payload$notify <- isTRUE(notify) && "open" %in% names(payload)
  message_target <- runtime_mount_id("dialog", session$ns(input_id))

  session$sendInputMessage(message_target, payload)
  invisible(NULL)
}

#' Create a value box
#'
#' @param title Value box title.
#' @param value Primary value.
#' @param ... Additional value box body content.
#' @param description Optional value box description.
#' @param icon Optional icon tag or vendored icon name.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_value_box <- function(
  title,
  value,
  ...,
  description = NULL,
  icon = NULL,
  class = NULL
) {
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "value-box",
    props = list(
      titleHtml = html_fragment(title),
      valueHtml = html_fragment(value),
      descriptionHtml = if (!is.null(description)) html_fragment(description) else NULL,
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL
    ),
    class = class
  )
}

#' Create a separator
#'
#' @param orientation Separator orientation.
#' @param decorative Whether the separator is decorative only.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_separator <- function(
  orientation = c("horizontal", "vertical"),
  decorative = TRUE,
  class = NULL
) {
  orientation <- match_arg(
    orientation,
    c("horizontal", "vertical"),
    "orientation"
  )

  runtime_component(
    component = "separator",
    props = list(
      orientation = orientation,
      decorative = isTRUE(decorative)
    ),
    class = class
  )
}

#' Create a skeleton placeholder
#'
#' @param class Additional classes.
#' @param ... Additional attributes passed to `htmltools::tags$div`.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_skeleton <- function(class = NULL, ...) {
  attrs <- named_attrs(list(...))
  if (!is.null(attrs$style)) {
    attrs$style <- normalize_runtime_style(attrs$style)
  }
  extra_class <- attrs[["class"]]
  class <- if (is.null(class) && is.null(extra_class)) {
    NULL
  } else {
    merge_classes(class, extra_class)
  }
  attrs[["class"]] <- NULL

  runtime_component(
    component = "skeleton",
    props = list(
      attrs = attrs
    ),
    class = class
  )
}

#' Create a spinner
#'
#' @param label Accessible label.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_spinner <- function(label = "Loading", class = NULL) {
  runtime_component(
    component = "spinner",
    props = list(
      label = label
    ),
    class = class
  )
}

#' Create an empty state
#'
#' @param title Empty-state title.
#' @param ... Additional empty-state body content.
#' @param description Optional description.
#' @param icon Optional icon tag or vendored icon name.
#' @param action Optional action content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_empty <- function(
  title,
  ...,
  description = NULL,
  icon = NULL,
  action = NULL,
  class = NULL
) {
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "empty",
    props = list(
      titleHtml = html_fragment(title),
      descriptionHtml = if (!is.null(description)) html_fragment(description) else NULL,
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL,
      actionHtml = if (!is.null(action)) html_fragment(action) else NULL
    ),
    class = class
  )
}
