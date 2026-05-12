.runtime_revision_state <- new.env(parent = emptyenv())
.runtime_revision_state$value <- 0L

next_runtime_revision <- function() {
  .runtime_revision_state$value <- .runtime_revision_state$value + 1L
  .runtime_revision_state$value
}

runtime_update <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  component,
  ...,
  notify = FALSE,
  clearable = character()
) {
  updates <- list(...)
  message <- runtime_update_message(
    session = session,
    input_id = input_id,
    component = component,
    updates = updates,
    notify = notify,
    clearable = clearable
  )

  session$sendCustomMessage("sb:update", message)
  invisible(NULL)
}

runtime_update_message <- function(
  session,
  input_id,
  component,
  updates = list(),
  notify = FALSE,
  clearable = character()
) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$ns)) {
    stop("`session` must provide an `ns()` method.", call. = FALSE)
  }
  if (!is.function(session$sendCustomMessage)) {
    stop("`session` must provide a `sendCustomMessage()` method.", call. = FALSE)
  }

  validate_runtime_component(component)
  validate_input_id(input_id)
  validate_named_list(updates, "updates")

  null_updates <- names(updates)[vapply(updates, is.null, logical(1))]
  not_clearable <- setdiff(null_updates, clearable)
  if (length(not_clearable) > 0) {
    stop(
      sprintf(
        "Cannot clear non-clearable update field(s): %s.",
        paste(sprintf("`%s`", not_clearable), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  list(
    schemaVersion = 1L,
    id = session$ns(input_id),
    component = component,
    updates = updates,
    notify = isTRUE(notify),
    revision = next_runtime_revision()
  )
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
