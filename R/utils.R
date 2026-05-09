`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

merge_classes <- function(...) {
  values <- unlist(list(...), use.names = FALSE)
  values <- values[!is.na(values) & nzchar(values)]

  classes <- unlist(strsplit(values, "\\s+"), use.names = FALSE)
  classes <- classes[nzchar(classes)]

  if (length(classes) == 0) {
    return(NULL)
  }

  paste(unique(classes), collapse = " ")
}

match_arg <- function(arg, choices, arg_name = deparse(substitute(arg))) {
  if (length(arg) > 1 && all(arg %in% choices)) {
    arg <- arg[[1]]
  }

  if (length(arg) != 1 || is.na(arg) || !arg %in% choices) {
    stop(
      sprintf(
        "`%s` must be one of %s.",
        arg_name,
        paste(sprintf('"%s"', choices), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  arg
}

validate_children <- function(children, type, parent) {
  invalid <- vapply(
    children,
    function(child) {
      !inherits(child, "shiny.tag") ||
        !identical(child$attribs[["data-sb-child"]], type)
    },
    logical(1)
  )

  if (any(invalid)) {
    stop(
      sprintf("All children of `%s()` must be `%s` items.", parent, type),
      call. = FALSE
    )
  }

  invisible(children)
}

as_icon_tag <- function(icon) {
  if (is.null(icon)) {
    return(NULL)
  }

  if (inherits(icon, "shiny.tag")) {
    return(icon)
  }

  block_icon(icon)
}

set_icon_position <- function(
  icon,
  position = c("inline-start", "inline-end")
) {
  if (is.null(icon)) {
    return(NULL)
  }

  position <- match_arg(
    position,
    c("inline-start", "inline-end"),
    "icon_position"
  )
  icon <- as_icon_tag(icon)
  icon$attribs[["data-icon"]] <- position
  icon
}

as_alert_child <- function(value, type, builder) {
  if (is.null(value)) {
    return(NULL)
  }

  if (
    inherits(value, "shiny.tag") &&
      identical(value$attribs[["data-sb-child"]], type)
  ) {
    return(value)
  }

  builder(value)
}
