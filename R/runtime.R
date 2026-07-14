runtime_mount_state <- new.env(parent = emptyenv())
runtime_mount_state$next_id <- 0L

# Canonical list of runtime component names dispatched by the React bundle
# (see `RuntimeMount` in frontend/src/index.jsx). The subset that also exposes
# a Shiny input binding lives in `RUNTIME_INPUT_COMPONENTS` in
# frontend/src/runtime/bindings.js — keep them in sync when adding a new
# component.
RUNTIME_COMPONENT_NAMES <- c(
  "alert", "badge", "button", "checkbox", "code", "combobox", "date-picker",
  "date-range-picker",
  "dialog", "dropdown-menu",
  "empty", "file-input", "input", "pagination", "popover", "progress", "radio-group", "select",
  "separator",
  "skeleton", "slider", "spinner", "switch", "table", "task-button", "textarea",
  "toaster", "toggle-group",
  "tooltip", "value-box"
)

# Style ownership (issue #50): a user `style=` argument must land on exactly one
# DOM node. For in-flow components that node is the mount `<div>` below, and the
# React renderer must NOT also spread `payload.style` onto its own root (enforced
# by tools/theme/check-style-ownership.mjs). The exception is a component whose
# visible root is rendered through a portal, outside the mount subtree: there the
# mount div can never reach it, so the renderer owns the user style on its
# portaled root and the mount div stays plain. `dialog` and `toaster` are the
# portaled components today (their content reads `payload.style`); keep this list
# in sync with the gate's allowlist.
RUNTIME_CONTENT_STYLE_COMPONENTS <- c("dialog", "toaster")

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
  mount_id = NULL,
  .validate = TRUE
) {
  if (isTRUE(.validate) && !component %in% RUNTIME_COMPONENT_NAMES) {
    stop(
      sprintf(
        "Unknown runtime `component`: %s. Expected one of %s.",
        sQuote(component),
        paste(sQuote(RUNTIME_COMPONENT_NAMES), collapse = ", ")
      ),
      call. = FALSE
    )
  }

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

  # Portaled-content components own the user style on their own root; everyone
  # else carries it here on the mount div. See RUNTIME_CONTENT_STYLE_COMPONENTS.
  mount_style <- if (component %in% RUNTIME_CONTENT_STYLE_COMPONENTS) NULL else style

  attach_shinyblocks_deps(
    htmltools::tags$div(
      id = mount_id,
      class = merge_classes("sb-runtime-mount", root_class),
      style = mount_style,
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
    # Slugging is lossy ("a.b" and "a-b" both slug to "a-b"), and the mount id
    # is both a DOM id and the `sendInputMessage()` routing target, so distinct
    # input ids must never collide. When the slug changed the id, disambiguate
    # with a short hash of the raw id; untouched ids keep their bare slug.
    if (!identical(slug, input_id)) {
      slug <- paste0(slug, "-", runtime_id_hash(input_id))
    }
    return(paste0("sb-runtime-", component_slug, "-", slug))
  }

  runtime_mount_state$next_id <- runtime_mount_state$next_id + 1L
  paste0("sb-runtime-", component_slug, "-", slug, "-", runtime_mount_state$next_id)
}

# Short deterministic hash (7 hex chars) of an arbitrary string, dependency-free.
# Polynomial rolling hash over code points; the modulus keeps the accumulator
# exact in doubles and within integer range for `sprintf("%x")`.
runtime_id_hash <- function(value) {
  h <- 0
  for (b in utf8ToInt(enc2utf8(value))) {
    h <- (h * 131 + b) %% 268435399
  }
  sprintf("%07x", as.integer(h))
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
