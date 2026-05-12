runtime_payload <- function(
  component,
  props = list(),
  slots = list(),
  children = list(),
  input_id = NULL,
  state = list(),
  binding = list(),
  class = NULL,
  schema_version = 1L
) {
  validate_runtime_component(component)
  validate_named_list(props, "props")
  validate_named_list(slots, "slots")
  validate_named_list(state, "state")
  validate_named_list(binding, "binding")

  payload <- list(
    schemaVersion = as.integer(schema_version),
    component = component,
    id = input_id,
    props = props,
    slots = slots,
    children = children,
    state = state,
    binding = binding,
    className = class
  )

  validate_runtime_json(payload)
  payload
}

runtime_payload_json <- function(payload) {
  validate_runtime_json(payload)
  json <- jsonlite::toJSON(
    payload,
    auto_unbox = TRUE,
    null = "null",
    na = "null",
    digits = NA
  )

  # Keep JSON safe inside an inline script tag.
  gsub("</", "<\\/", as.character(json), fixed = TRUE)
}

validate_runtime_component <- function(component) {
  if (
    !is.character(component) ||
      length(component) != 1 ||
      is.na(component) ||
      !nzchar(component)
  ) {
    stop("`component` must be a non-empty string.", call. = FALSE)
  }

  invisible(component)
}

validate_named_list <- function(x, arg) {
  if (!is.list(x)) {
    stop(sprintf("`%s` must be a list.", arg), call. = FALSE)
  }

  names <- names(x)
  if (length(x) > 0 && (is.null(names) || any(!nzchar(names)))) {
    stop(sprintf("`%s` must be a fully named list.", arg), call. = FALSE)
  }

  invisible(x)
}

validate_runtime_json <- function(payload) {
  tryCatch(
    {
      jsonlite::toJSON(payload, auto_unbox = TRUE, null = "null")
      invisible(payload)
    },
    error = function(e) {
      stop(
        sprintf("Runtime payload is not JSON serializable: %s", conditionMessage(e)),
        call. = FALSE
      )
    }
  )
}
