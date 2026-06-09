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

# Scalar argument validators. Each centralizes the predicate so call sites stop
# re-spelling `!is.numeric(x) || length(x) != 1 || ...`. Pass `msg` to preserve a
# component-specific error string; otherwise a generic one is built from `name`.
check_number <- function(x, name, min = NULL, positive = FALSE,
                         null_ok = FALSE, msg = NULL) {
  if (null_ok && is.null(x)) {
    return(invisible(x))
  }
  ok <- is.numeric(x) && length(x) == 1 && !is.na(x) &&
    (is.null(min) || x >= min) && (!positive || x > 0)
  if (!ok) {
    stop(msg %||% sprintf("`%s` must be a single number.", name), call. = FALSE)
  }
  invisible(x)
}

check_string <- function(x, name, null_ok = FALSE, msg = NULL) {
  if (null_ok && is.null(x)) {
    return(invisible(x))
  }
  if (!is.character(x) || length(x) != 1 || is.na(x)) {
    stop(msg %||% sprintf("`%s` must be a single string.", name), call. = FALSE)
  }
  invisible(x)
}

check_character <- function(x, name, null_ok = FALSE, msg = NULL) {
  if (null_ok && is.null(x)) {
    return(invisible(x))
  }
  if (!is.character(x) || anyNA(x)) {
    stop(msg %||% sprintf("`%s` must be a character vector.", name), call. = FALSE)
  }
  invisible(x)
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

as_component_child <- function(value, type, builder) {
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

html_fragment <- function(...) {
  rendered <- htmltools::renderTags(htmltools::tagList(...))$html
  paste(as.character(rendered), collapse = "")
}

named_attrs <- function(attrs, arg = "...") {
  if (length(attrs) == 0) {
    return(list())
  }

  names <- names(attrs)
  if (is.null(names) || any(!nzchar(names))) {
    stop(sprintf("All `%s` attributes must be named.", arg), call. = FALSE)
  }

  attrs
}

append_idref <- function(existing, value) {
  refs <- unique(c(strsplit(existing %||% "", "\\s+")[[1]], value))
  refs <- refs[nzchar(refs)]

  if (length(refs) == 0) {
    return(NULL)
  }

  paste(refs, collapse = " ")
}

normalize_runtime_style <- function(style) {
  if (is.null(style)) {
    return(NULL)
  }
  if (is.list(style)) {
    names <- names(style)
    if (
      length(style) > 0 &&
        (is.null(names) || any(is.na(names) | !nzchar(names)))
    ) {
      stop("`style` lists must be fully named.", call. = FALSE)
    }
    return(style)
  }
  if (!is.character(style) || length(style) != 1 || is.na(style)) {
    stop("`style` must be a single CSS declaration string.", call. = FALSE)
  }

  declarations <- strsplit(style, ";", fixed = TRUE)[[1]]
  if (length(declarations) == 0) {
    stop("`style` must include at least one CSS declaration.", call. = FALSE)
  }

  style_out <- list()
  for (declaration in declarations) {
    declaration <- trimws(declaration)
    if (!nzchar(declaration)) {
      next
    }

    idx <- regexpr(":", declaration, fixed = TRUE)[1]
    if (idx < 2) {
      stop(
        "`style` declarations must use `property: value` syntax.",
        call. = FALSE
      )
    }

    raw_property <- trimws(substr(declaration, 1, idx - 1))
    raw_value <- trimws(substr(declaration, idx + 1, nchar(declaration)))
    if (!nzchar(raw_property) || !nzchar(raw_value)) {
      stop(
        "`style` declarations must include non-empty properties and values.",
        call. = FALSE
      )
    }

    raw_value <- trimws(sub("\\s*!important\\s*$", "", raw_value, perl = TRUE))
    if (!nzchar(raw_value)) {
      stop(
        "`style` declarations must include non-empty values.",
        call. = FALSE
      )
    }

    property <- if (startsWith(raw_property, "--")) {
      raw_property
    } else {
      gsub(
        "-([a-z])",
        "\\U\\1",
        raw_property,
        perl = TRUE
      )
    }

    style_out[[property]] <- raw_value
  }

  if (length(style_out) == 0) {
    stop("`style` must include at least one CSS declaration.", call. = FALSE)
  } else {
    style_out
  }
}

normalize_choices <- function(choices) {
  values <- unlist(choices, recursive = TRUE, use.names = TRUE)

  if (length(values) == 0) {
    stop("`choices` must contain at least one option.", call. = FALSE)
  }

  labels <- names(values)
  if (is.null(labels)) {
    labels <- as.character(values)
  } else {
    missing <- is.na(labels) | !nzchar(labels)
    labels[missing] <- as.character(values[missing])
  }

  data.frame(
    value = as.character(unname(values)),
    label = as.character(labels),
    stringsAsFactors = FALSE
  )
}

validate_select_choice_values <- function(values) {
  if (any(!nzchar(values))) {
    stop(
      "`choices` values must be non-empty. `\"\"` is reserved as the placeholder sentinel.",
      call. = FALSE
    )
  }

  duplicates <- unique(values[duplicated(values)])
  if (length(duplicates) > 0) {
    stop(
      sprintf(
        "`choices` values must be unique. Duplicates: %s.",
        paste(sprintf('"%s"', duplicates), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  invisible(values)
}
