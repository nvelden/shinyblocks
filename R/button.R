#' Create a modern button
#'
#' @param label Button label.
#' @param variant Visual variant.
#' @param size Button size.
#' @param icon Optional icon tag or vendored icon name.
#' @param icon_position Whether the icon appears before or after the label.
#' @param ... Additional attributes passed to the rendered button. Pass
#'   `id = "..."` here to make the button addressable via
#'   [update_block_button()]. Runtime-owned `type`, `data-slot`, variant/size,
#'   class, style, and disabled attributes cannot be overridden here.
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
  input_id <- if (is.null(attrs$id)) NULL else as.character(attrs$id)
  attrs$id <- NULL
  style <- if (is.null(attrs$style)) NULL else normalize_runtime_style(attrs$style)
  attrs$style <- NULL

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

  binding <- if (is.null(input_id)) list() else list(
    input = TRUE,
    type = "shinyblocks.button"
  )

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
      style = style,
      disabled = disabled
    ),
    input_id = input_id,
    binding = binding,
    class = class
  )
}

#' Update a runtime button
#'
#' Send a runtime message to a [block_button()] created with `id = "..."`.
#' Any argument left unspecified is preserved on the client. Pass `NULL` for
#' `icon` or `style` to clear them.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_button()` (via `id = "..."`).
#' @param label Optional replacement label.
#' @param variant Optional new visual variant.
#' @param size Optional new size.
#' @param icon Optional vendored icon name, `shiny.tag`, or `NULL` to clear.
#' @param icon_position Optional `"inline-start"` / `"inline-end"`.
#' @param disabled Optional disabled state.
#' @param style Optional inline CSS styles, or `NULL` to clear.
#' @param class Optional replacement classes for the wrapper.
#'
#' @return Invisibly returns `NULL`.
#' @family action
#' @export
update_block_button <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  label,
  variant,
  size,
  icon,
  icon_position,
  disabled,
  style,
  class
) {
  payload <- list()

  if (!missing(label)) {
    payload$labelHtml <- html_fragment(label)
  }
  if (!missing(variant)) {
    variant <- match_arg(
      variant,
      c("default", "secondary", "outline", "ghost", "destructive", "link")
    )
    payload$variant <- variant
  }
  if (!missing(size)) {
    size <- match_arg(size, c("default", "sm", "lg", "icon"))
    payload$size <- size
  }
  if (!missing(icon_position)) {
    icon_position <- match_arg(
      icon_position,
      c("inline-start", "inline-end"),
      "icon_position"
    )
    payload$iconPosition <- icon_position
  }
  if (!missing(icon)) {
    if (is.null(icon)) {
      payload["iconName"] <- list(NULL)
      payload["iconHtml"] <- list(NULL)
    } else if (inherits(icon, "shiny.tag")) {
      pos <- payload$iconPosition %||% "inline-start"
      icon$attribs[["data-icon"]] <- pos
      payload["iconName"] <- list(NULL)
      payload$iconHtml <- html_fragment(icon)
    } else {
      validate_icon_name(icon)
      payload$iconName <- icon
      payload["iconHtml"] <- list(NULL)
    }
    payload$spriteHref <- sprite_href()
  }

  payload <- apply_update_fields(payload, list(
    field("disabled", transform = isTRUE),
    field_style("style"),
    field_clearable("class")
  ))

  runtime_input_update(session, input_id, "button", payload, notify_key = NULL)
}
