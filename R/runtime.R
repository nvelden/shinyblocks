runtime_mount_state <- new.env(parent = emptyenv())
runtime_mount_state$next_id <- 0L

runtime_component <- function(
  component,
  props = list(),
  slots = list(),
  children = list(),
  input_id = NULL,
  state = list(),
  binding = list(),
  class = NULL,
  style = NULL,
  root_class = NULL,
  mount_id = NULL
) {
  payload <- runtime_payload(
    component = component,
    props = props,
    slots = slots,
    children = list(),
    input_id = input_id,
    state = state,
    binding = binding,
    class = class,
    style = if (is.null(style)) NULL else normalize_runtime_style(style)
  )
  mount_id <- mount_id %||% runtime_mount_id(component, input_id)

  attach_shinyblocks_deps(
    htmltools::tags$div(
      id = mount_id,
      class = merge_classes("sb-runtime-mount", root_class),
      style = style,
      `data-shinyblocks-root` = "",
      `data-shinyblocks-runtime` = "true",
      `data-sb-component` = component,
      `data-sb-input-id` = input_id,
      htmltools::tags$script(
        type = "application/json",
        `data-shinyblocks-payload` = "",
        htmltools::HTML(runtime_payload_json(payload))
      ),
      htmltools::tags$div(`data-shinyblocks-react` = ""),
      htmltools::tags$div(`data-shinyblocks-children` = "", children)
    )
  )
}

runtime_portal_root <- function() {
  htmltools::tags$div(
    `data-shinyblocks-portal-root` = "",
    `aria-live` = "polite"
  )
}

runtime_mount_id <- function(component, input_id = NULL) {
  component_slug <- runtime_id_slug(component)
  source <- input_id %||% component_slug
  slug <- runtime_id_slug(source)

  if (!is.null(input_id)) {
    return(paste0("sb-runtime-", component_slug, "-", slug))
  }

  runtime_mount_state$next_id <- runtime_mount_state$next_id + 1L
  paste0("sb-runtime-", component_slug, "-", slug, "-", runtime_mount_state$next_id)
}

validate_input_id <- function(input_id) {
  if (
    !is.character(input_id) ||
      length(input_id) != 1 ||
      is.na(input_id) ||
      !nzchar(input_id)
  ) {
    stop("`input_id` must be a non-empty string.", call. = FALSE)
  }

  invisible(input_id)
}

runtime_id_slug <- function(value) {
  slug <- gsub("[^A-Za-z0-9_-]+", "-", value)
  slug <- gsub("^-|-$", "", slug)

  if (!nzchar(slug)) {
    return("component")
  }

  slug
}
