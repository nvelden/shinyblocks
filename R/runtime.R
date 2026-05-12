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
    class = class
  )
  mount_id <- mount_id %||% runtime_mount_id(component, input_id)

  attach_shinyblocks_deps(
    htmltools::tags$div(
      id = mount_id,
      class = merge_classes("sb-runtime-mount", class),
      `data-shinyblocks-root` = "",
      `data-shinyblocks-runtime` = "true",
      `data-sb-component` = component,
      `data-sb-input-id` = input_id,
      htmltools::tags$script(
        type = "application/json",
        `data-shinyblocks-payload` = "",
        htmltools::HTML(runtime_payload_json(payload))
      ),
      children
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

runtime_id_slug <- function(value) {
  slug <- gsub("[^A-Za-z0-9_-]+", "-", value)
  slug <- gsub("^-|-$", "", slug)

  if (!nzchar(slug)) {
    return("component")
  }

  slug
}
