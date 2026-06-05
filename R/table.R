#' Render a data frame as a styled table
#'
#' `block_table()` renders a data frame or tibble as a runtime-owned shadcn
#' table. Cell formatting happens in R before the payload is sent to the
#' browser.
#'
#' @param data A data frame or tibble.
#' @param columns Optional named list of per-column overrides created with
#'   `table_column()`. Names must match columns in `data`.
#' @param caption Optional caption rendered below the table.
#' @param max_rows Optional non-negative integer limiting the number of rendered
#'   rows. When rows are truncated, a footer note reports the total row count.
#' @param class Additional classes on the runtime mount.
#' @param style Optional inline custom styles.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_table <- function(
  data,
  columns = NULL,
  caption = NULL,
  max_rows = NULL,
  class = NULL,
  style = NULL
) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  column_names <- names(data)
  if (is.null(column_names) || any(!nzchar(column_names))) {
    stop("`data` must have non-empty column names.", call. = FALSE)
  }

  columns <- normalize_table_columns(columns, column_names)
  row_count <- nrow(data)
  max_rows <- normalize_table_max_rows(max_rows, row_count)
  display_rows <- if (is.null(max_rows)) row_count else min(row_count, max_rows)

  formatted_columns <- Map(
    function(name, spec) {
      table_format_column(data[[name]], spec$format, name)
    },
    column_names,
    columns
  )

  rows <- lapply(seq_len(display_rows), function(row_index) {
    unname(lapply(formatted_columns, function(column) column[[row_index]]))
  })

  runtime_component(
    component = "table",
    props = list(
      columns = unname(Map(
        function(name, spec) {
          list(
            key = name,
            label = spec$label %||% name,
            align = spec$align,
            width = spec$width
          )
        },
        column_names,
        columns
      )),
      rows = rows,
      caption = normalize_table_optional_string(caption, "caption"),
      truncated = !is.null(max_rows) && display_rows < row_count,
      totalRows = row_count
    ),
    class = class,
    style = style,
    root_class = "sb-table"
  )
}

#' Define display options for a `block_table()` column
#'
#' @param label Header label. Defaults to the data column name.
#' @param align Text alignment. One of `"left"`, `"center"`, or `"right"`.
#' @param format Optional function applied to the full column vector. The result
#'   must have the same length as the input and is coerced to character.
#' @param width Optional CSS width for the column.
#'
#' @return A table column specification.
#' @family content
#' @export
table_column <- function(
  label = NULL,
  align = c("left", "center", "right"),
  format = NULL,
  width = NULL
) {
  align <- match_arg(align, c("left", "center", "right"))

  if (!is.null(format) && !is.function(format)) {
    stop("`format` must be NULL or a function.", call. = FALSE)
  }

  list(
    label = normalize_table_optional_string(label, "label"),
    align = align,
    format = format,
    width = normalize_table_optional_string(width, "width")
  )
}

normalize_table_columns <- function(columns, column_names) {
  defaults <- stats::setNames(
    lapply(column_names, function(name) table_column()),
    column_names
  )

  if (is.null(columns)) {
    return(defaults)
  }

  if (!is.list(columns)) {
    stop("`columns` must be NULL or a named list.", call. = FALSE)
  }

  names <- names(columns)
  if (length(columns) > 0 && (is.null(names) || any(!nzchar(names)))) {
    stop("`columns` must be a fully named list.", call. = FALSE)
  }

  unknown <- setdiff(names, column_names)
  if (length(unknown) > 0) {
    stop(
      sprintf(
        "`columns` contains unknown data columns: %s.",
        paste(sQuote(unknown), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  for (name in names) {
    defaults[[name]] <- normalize_table_column_spec(columns[[name]], name)
  }

  defaults
}

normalize_table_column_spec <- function(spec, name) {
  if (!is.list(spec)) {
    stop(
      sprintf("`columns[[%s]]` must be created with `table_column()`.", sQuote(name)),
      call. = FALSE
    )
  }

  table_column(
    label = spec$label,
    align = spec$align %||% "left",
    format = spec$format,
    width = spec$width
  )
}

normalize_table_optional_string <- function(value, arg) {
  if (is.null(value)) {
    return(NULL)
  }
  if (!is.character(value) || length(value) != 1 || is.na(value)) {
    stop(sprintf("`%s` must be NULL or a single character string.", arg), call. = FALSE)
  }

  value
}

normalize_table_max_rows <- function(max_rows, row_count) {
  if (is.null(max_rows)) {
    return(NULL)
  }
  if (
    !is.numeric(max_rows) ||
      length(max_rows) != 1 ||
      is.na(max_rows) ||
      max_rows < 0 ||
      max_rows != floor(max_rows)
  ) {
    stop("`max_rows` must be NULL or a non-negative integer.", call. = FALSE)
  }

  as.integer(min(max_rows, row_count))
}

table_format_column <- function(value, formatter, name) {
  formatted <- if (is.null(formatter)) {
    table_default_format(value)
  } else {
    formatter(value)
  }

  if (length(formatted) != length(value)) {
    stop(
      sprintf(
        "`format` for column %s must return one value per row.",
        sQuote(name)
      ),
      call. = FALSE
    )
  }

  formatted <- as.character(formatted)
  formatted[is.na(value) | is.na(formatted)] <- ""
  formatted
}

table_default_format <- function(value) {
  if (is.numeric(value)) {
    return(format(value, trim = TRUE, na.encode = FALSE))
  }

  as.character(value)
}
