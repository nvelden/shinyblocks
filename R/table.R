#' Render a data frame as a styled table
#'
#' `block_table()` renders a data frame or tibble as a runtime-owned shadcn
#' table. Cell formatting happens in R before the payload is sent to the
#' browser. The same formatting pipeline is reused by [update_block_table()],
#' so a server-side refresh produces an identical payload.
#'
#' @param data A data frame or tibble.
#' @param columns Optional named list of per-column overrides created with
#'   `table_column()`. Names must match columns in `data`.
#' @param caption Optional caption rendered below the table.
#' @param max_rows Optional non-negative integer limiting the number of rendered
#'   rows. When rows are truncated, a footer note reports the total row count.
#' @param na String used to render missing values. Defaults to `""` (empty
#'   cell). Per-column overrides win via `table_column(na = )`.
#' @param digits Optional non-negative integer giving the number of decimal
#'   places for default numeric formatting. `NULL` keeps R's default `format()`.
#'   Ignored for columns with a custom `format` function. Per-column overrides
#'   win via `table_column(digits = )`.
#' @param rownames Whether to render `row.names(data)` as a leading column.
#' @param row_format Optional `function(row, i)` called once per rendered row,
#'   where `row` is the original (unformatted) row as a named list and `i` is the
#'   row index. Return `NULL` for no styling, or a list with optional `class`
#'   and/or `style` entries applied to that row's `<tr>`.
#' @param striped Whether to zebra-stripe body rows.
#' @param hover Whether rows highlight on hover. Defaults to `TRUE` (shadcn base).
#' @param bordered Whether to draw cell borders.
#' @param id Optional input id. Required only if the table is updated from the
#'   server with [update_block_table()]; static tables can omit it.
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
  na = "",
  digits = NULL,
  rownames = FALSE,
  row_format = NULL,
  striped = FALSE,
  hover = TRUE,
  bordered = FALSE,
  id = NULL,
  class = NULL,
  style = NULL
) {
  if (!is.null(id)) {
    validate_input_id(id)
  }

  props <- table_build_payload(
    data = data,
    columns = columns,
    caption = caption,
    max_rows = max_rows,
    na = na,
    digits = digits,
    rownames = rownames,
    row_format = row_format,
    striped = striped,
    hover = hover,
    bordered = bordered
  )

  runtime_component(
    component = "table",
    props = props,
    input_id = id,
    class = class,
    style = style,
    root_class = "sb-table"
  )
}

#' Update a runtime table from the server
#'
#' Re-renders a [block_table()] (created with an `id`) by pushing a freshly
#' formatted payload to the browser. Every argument runs through the same
#' formatting pipeline as `block_table()`, so the refreshed table is identical
#' to one rendered with the same arguments at UI time.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param id Input id passed to `block_table(id = )`.
#' @param data Optional replacement data frame. When supplied, the table re-renders
#'   with the formatting arguments below.
#' @param columns,caption,max_rows,na,digits,rownames,row_format,striped,hover,bordered
#'   Optional formatting arguments, matching [block_table()]. Used only when
#'   `data` is supplied.
#' @param loading Optional flag. `TRUE` shows skeleton rows; `FALSE` clears the
#'   loading state without changing data.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @export
update_block_table <- function(
  session = shiny::getDefaultReactiveDomain(),
  id,
  data = NULL,
  columns = NULL,
  caption = NULL,
  max_rows = NULL,
  na = "",
  digits = NULL,
  rownames = FALSE,
  row_format = NULL,
  striped = FALSE,
  hover = TRUE,
  bordered = FALSE,
  loading = NULL
) {
  payload <- list()

  if (!is.null(data)) {
    props <- table_build_payload(
      data = data,
      columns = columns,
      caption = caption,
      max_rows = max_rows,
      na = na,
      digits = digits,
      rownames = rownames,
      row_format = row_format,
      striped = striped,
      hover = hover,
      bordered = bordered
    )
    payload <- utils::modifyList(payload, props)
  }

  if (!is.null(loading)) {
    payload$loading <- isTRUE(loading)
  }

  runtime_input_update(
    session, id, "table", payload,
    notify_key = NULL
  )
}

#' Define display options for a `block_table()` column
#'
#' @param label Header label. Defaults to the data column name.
#' @param align Text alignment. One of `"left"`, `"center"`, or `"right"`.
#' @param format Optional function applied to the full column vector. The result
#'   must have the same length as the input and is coerced to character. When
#'   supplied, `digits` is ignored for this column.
#' @param width Optional CSS width for the column.
#' @param digits Optional non-negative integer for default numeric formatting,
#'   overriding the table-level `digits` for this column.
#' @param na Optional string for missing values, overriding the table-level `na`
#'   for this column.
#' @param intent Optional semantic styling intent applied to every `<td>` in the
#'   column. One of `"muted"`, `"primary"`, `"secondary"`, `"destructive"`,
#'   `"success"`, `"warning"`, or `"accent"`. Rendered as theme tokens, never a
#'   literal color, so it tracks the active theme preset, light/dark, and style
#'   profile automatically.
#' @param emphasis How an `intent` is rendered. One of `"text"` (colored
#'   foreground, the default), `"soft"` (tinted background + colored text), or
#'   `"solid"` (filled chip). Has no effect without an `intent`.
#' @param class,style Escape hatch: additional class / inline style applied to
#'   every `<td>` in the column. You own theme-correctness here — prefer
#'   `var(--token)` over literal colors.
#' @param header_intent,header_emphasis,header_class,header_style Same styling
#'   controls applied to the column's `<th>` header cell.
#' @param cell_intent,cell_emphasis,cell_class,cell_style Vectorized per-cell
#'   styling. Each is a `function(value)` called once with the column's full
#'   (unformatted) vector and must return one entry per row (length-1 results are
#'   recycled). `cell_intent` returns intents (use `NA` for no styling),
#'   `cell_emphasis` returns emphasis values, `cell_class` returns classes, and
#'   `cell_style` returns CSS declaration strings (e.g. `"color: red"`). A single
#'   fully named list (e.g. `list(color = "var(--primary)")`) is treated as one
#'   style object applied to every row; for per-row style objects return an
#'   unnamed list of named lists. Per-cell results win over the column-level
#'   `intent` / `emphasis` / `class` / `style`.
#'
#' @return A table column specification.
#' @family content
#' @export
table_column <- function(
  label = NULL,
  align = c("left", "center", "right"),
  format = NULL,
  width = NULL,
  digits = NULL,
  na = NULL,
  intent = NULL,
  emphasis = "text",
  class = NULL,
  style = NULL,
  header_intent = NULL,
  header_emphasis = "text",
  header_class = NULL,
  header_style = NULL,
  cell_intent = NULL,
  cell_emphasis = NULL,
  cell_class = NULL,
  cell_style = NULL
) {
  align <- match_arg(align, c("left", "center", "right"))

  if (!is.null(format) && !is.function(format)) {
    stop("`format` must be NULL or a function.", call. = FALSE)
  }

  list(
    label = normalize_table_optional_string(label, "label"),
    align = align,
    format = format,
    width = normalize_table_optional_string(width, "width"),
    digits = normalize_table_digits(digits),
    na = normalize_table_optional_string(na, "na"),
    intent = normalize_table_intent(intent, "intent"),
    emphasis = match_arg(emphasis, TABLE_EMPHASIS_CHOICES, arg_name = "emphasis"),
    class = normalize_table_optional_string(class, "class"),
    style = normalize_runtime_style(style),
    header_intent = normalize_table_intent(header_intent, "header_intent"),
    header_emphasis = match_arg(
      header_emphasis, TABLE_EMPHASIS_CHOICES, arg_name = "header_emphasis"
    ),
    header_class = normalize_table_optional_string(header_class, "header_class"),
    header_style = normalize_runtime_style(header_style),
    cell_intent = normalize_table_cell_fn(cell_intent, "cell_intent"),
    cell_emphasis = normalize_table_cell_fn(cell_emphasis, "cell_emphasis"),
    cell_class = normalize_table_cell_fn(cell_class, "cell_class"),
    cell_style = normalize_table_cell_fn(cell_style, "cell_style")
  )
}

TABLE_INTENT_CHOICES <- c(
  "muted", "primary", "secondary", "destructive", "success", "warning", "accent"
)
TABLE_EMPHASIS_CHOICES <- c("text", "soft", "solid")

normalize_table_intent <- function(intent, arg) {
  if (is.null(intent)) {
    return(NULL)
  }
  match_arg(intent, TABLE_INTENT_CHOICES, arg_name = arg)
}

normalize_table_cell_fn <- function(fn, arg) {
  if (is.null(fn) || is.function(fn)) {
    return(fn)
  }
  stop(sprintf("`%s` must be NULL or a function.", arg), call. = FALSE)
}

# Appends the theme-safe styling fields to a payload spec, omitting any that are
# unset so an unstyled column/header serializes byte-identically to v1. The
# `emphasis` field rides along only when an `intent` is present (it is inert
# without one). `keys` selects the column-vs-header payload key names.
table_append_style_fields <- function(
  out, intent, emphasis, class, style,
  keys = c("intent", "emphasis", "class", "style")
) {
  if (!is.null(intent)) {
    out[[keys[[1]]]] <- intent
    out[[keys[[2]]]] <- emphasis
  }
  if (!is.null(class)) {
    out[[keys[[3]]]] <- class
  }
  if (!is.null(style)) {
    out[[keys[[4]]]] <- style
  }
  out
}

# Single source of truth for the table payload. Called by both block_table()
# (UI time) and update_block_table() (server time) so the two paths can never
# drift. Returns the `props` list for the runtime component.
table_build_payload <- function(
  data,
  columns = NULL,
  caption = NULL,
  max_rows = NULL,
  na = "",
  digits = NULL,
  rownames = FALSE,
  row_format = NULL,
  striped = FALSE,
  hover = TRUE,
  bordered = FALSE
) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  column_names <- names(data)
  if (is.null(column_names) || any(!nzchar(column_names))) {
    stop("`data` must have non-empty column names.", call. = FALSE)
  }

  na <- normalize_table_na(na)
  digits <- normalize_table_digits(digits)
  if (!is.null(row_format) && !is.function(row_format)) {
    stop("`row_format` must be NULL or a function.", call. = FALSE)
  }

  columns <- normalize_table_columns(columns, column_names)
  row_count <- nrow(data)
  max_rows <- normalize_table_max_rows(max_rows, row_count)
  display_rows <- if (is.null(max_rows)) row_count else min(row_count, max_rows)

  formatted_columns <- Map(
    function(name, spec) {
      table_format_column(
        data[[name]],
        spec$format,
        name,
        digits = spec$digits %||% digits,
        na = spec$na %||% na
      )
    },
    column_names,
    columns
  )

  # Per-column cell styling, evaluated once over the full column vector. NULL for
  # a column with no `cell_*` callbacks; otherwise one meta-or-NULL per source row.
  cell_meta_columns <- Map(
    function(name, spec) table_build_cell_meta_column(data[[name]], spec, name),
    column_names,
    columns
  )

  column_specs <- Map(
    function(name, spec) {
      out <- list(
        key = name,
        label = spec$label %||% name,
        align = spec$align,
        width = spec$width
      )
      out <- table_append_style_fields(
        out, spec$intent, spec$emphasis, spec$class, spec$style
      )
      table_append_style_fields(
        out, spec$header_intent, spec$header_emphasis,
        spec$header_class, spec$header_style,
        keys = c("headerIntent", "headerEmphasis", "headerClass", "headerStyle")
      )
    },
    column_names,
    columns
  )

  include_rownames <- isTRUE(rownames)
  if (include_rownames) {
    row_labels <- as.character(row.names(data))
    column_specs <- c(
      list(list(key = "_rownames", label = "", align = "left", width = NULL)),
      column_specs
    )
  }

  rows <- lapply(seq_len(display_rows), function(row_index) {
    cells <- lapply(formatted_columns, function(column) column[[row_index]])
    if (include_rownames) {
      cells <- c(list(row_labels[[row_index]]), cells)
    }
    unname(cells)
  })

  props <- list(
    columns = unname(column_specs),
    rows = rows,
    caption = normalize_table_optional_string(caption, "caption"),
    truncated = !is.null(max_rows) && display_rows < row_count,
    totalRows = row_count,
    striped = isTRUE(striped),
    hover = isTRUE(hover),
    bordered = isTRUE(bordered)
  )

  # Always emit `rowMeta` so a data-bearing payload is authoritative: the runtime
  # merges partial updates over current props, so omitting the key would let
  # stale per-row formatting persist after `row_format` is cleared. An empty
  # per-row list (serialized as `[{}, ...]`) overwrites and clears prior styling.
  props$rowMeta <- if (is.null(row_format)) {
    vector("list", display_rows)
  } else {
    table_build_row_meta(data, row_format, display_rows)
  }

  # Always emit `cellMeta` for the same clear-on-merge reason as `rowMeta`: a
  # data-bearing update must authoritatively overwrite prior per-cell styling.
  # A per-row list of per-column meta (NULL -> `{}`) clears anything stale.
  props$cellMeta <- lapply(seq_len(display_rows), function(row_index) {
    cells <- lapply(column_names, function(name) {
      column <- cell_meta_columns[[name]]
      if (is.null(column)) NULL else column[[row_index]]
    })
    if (include_rownames) {
      cells <- c(list(NULL), cells)
    }
    unname(cells)
  })

  props
}

# Returns NULL when a column declares no `cell_*` callbacks, otherwise a list of
# length nrow(data) where each entry is a `{intent, emphasis, class, style}` meta
# (or NULL for an unstyled cell). Each callback runs once over the whole column.
table_build_cell_meta_column <- function(value, spec, name) {
  has_cell <- !is.null(spec$cell_intent) || !is.null(spec$cell_emphasis) ||
    !is.null(spec$cell_class) || !is.null(spec$cell_style)
  if (!has_cell) {
    return(NULL)
  }

  n <- length(value)
  intent <- table_eval_cell_fn(spec$cell_intent, value, n, name, "cell_intent")
  emphasis <- table_eval_cell_fn(spec$cell_emphasis, value, n, name, "cell_emphasis")
  class <- table_eval_cell_fn(spec$cell_class, value, n, name, "cell_class")
  style <- table_eval_cell_fn(
    spec$cell_style, value, n, name, "cell_style",
    is_style = TRUE
  )

  lapply(seq_len(n), function(i) {
    normalize_table_cell_meta(
      intent[[i]], emphasis[[i]], class[[i]], style[[i]], name
    )
  })
}

# Evaluates a single `cell_*` callback over the column vector, validating that it
# returns one entry per row (length-1 is recycled). NULL callback -> per-row NULLs.
# `cell_style` (is_style = TRUE) additionally treats a fully named list as one
# style object applied to every row, so `function(v) list(color = "...")` is not
# mistaken for per-row entries.
table_eval_cell_fn <- function(fn, value, n, name, arg, is_style = FALSE) {
  if (is.null(fn)) {
    return(vector("list", n))
  }
  out <- fn(value)
  if (is_style && is_named_style_list(out)) {
    return(rep(list(out), n))
  }
  if (length(out) == 1 && n > 1) {
    out <- rep(out, n)
  }
  if (length(out) != n) {
    stop(
      sprintf("`%s` for column %s must return one value per row.", arg, sQuote(name)),
      call. = FALSE
    )
  }
  as.list(out)
}

# A fully named, non-empty list is a single style object (property = value),
# not a list of per-row entries.
is_named_style_list <- function(x) {
  if (!is.list(x) || length(x) == 0) {
    return(FALSE)
  }
  names <- names(x)
  !is.null(names) && all(nzchar(names) & !is.na(names))
}

table_is_blank <- function(x) {
  is.null(x) || (length(x) == 1 && is.na(x))
}

normalize_table_cell_meta <- function(intent, emphasis, class, style, name) {
  out <- list()
  if (!table_is_blank(intent)) {
    out$intent <- match_arg(
      as.character(intent), TABLE_INTENT_CHOICES,
      arg_name = sprintf("cell_intent for column %s", sQuote(name))
    )
    out$emphasis <- if (table_is_blank(emphasis)) {
      "text"
    } else {
      match_arg(
        as.character(emphasis), TABLE_EMPHASIS_CHOICES,
        arg_name = sprintf("cell_emphasis for column %s", sQuote(name))
      )
    }
  }
  if (!table_is_blank(class)) {
    out$class <- as.character(class)
  }
  if (!table_is_blank(style)) {
    out$style <- normalize_runtime_style(style)
  }

  if (length(out) == 0) {
    return(NULL)
  }
  out
}

table_build_row_meta <- function(data, row_format, display_rows) {
  lapply(seq_len(display_rows), function(i) {
    row <- as.list(data[i, , drop = FALSE])
    meta <- row_format(row, i)
    normalize_table_row_meta(meta, i)
  })
}

normalize_table_row_meta <- function(meta, i) {
  if (is.null(meta)) {
    return(NULL)
  }
  if (!is.list(meta)) {
    stop(
      sprintf("`row_format` must return NULL or a list for row %d.", i),
      call. = FALSE
    )
  }

  out <- list()
  if (!is.null(meta$intent)) {
    out$intent <- normalize_table_intent(meta$intent, "row_format intent")
    out$emphasis <- match_arg(
      meta$emphasis %||% "text", TABLE_EMPHASIS_CHOICES,
      arg_name = "row_format emphasis"
    )
  }
  if (!is.null(meta$class)) {
    out$class <- normalize_table_optional_string(meta$class, "row_format class")
  }
  if (!is.null(meta$style)) {
    out$style <- normalize_runtime_style(meta$style)
  }

  if (length(out) == 0) {
    return(NULL)
  }
  out
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
    width = spec$width,
    digits = spec$digits,
    na = spec$na,
    intent = spec$intent,
    emphasis = spec$emphasis %||% "text",
    class = spec$class,
    style = spec$style,
    header_intent = spec$header_intent,
    header_emphasis = spec$header_emphasis %||% "text",
    header_class = spec$header_class,
    header_style = spec$header_style,
    cell_intent = spec$cell_intent,
    cell_emphasis = spec$cell_emphasis,
    cell_class = spec$cell_class,
    cell_style = spec$cell_style
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

normalize_table_na <- function(na) {
  if (is.null(na)) {
    return("")
  }
  if (!is.character(na) || length(na) != 1 || is.na(na)) {
    stop("`na` must be a single character string.", call. = FALSE)
  }

  na
}

normalize_table_digits <- function(digits) {
  if (is.null(digits)) {
    return(NULL)
  }
  if (
    !is.numeric(digits) ||
      length(digits) != 1 ||
      is.na(digits) ||
      digits < 0 ||
      digits != floor(digits)
  ) {
    stop("`digits` must be NULL or a non-negative integer.", call. = FALSE)
  }

  as.integer(digits)
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

table_format_column <- function(value, formatter, name, digits = NULL, na = "") {
  formatted <- if (is.null(formatter)) {
    table_default_format(value, digits)
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
  formatted[is.na(value) | is.na(formatted)] <- na
  formatted
}

table_default_format <- function(value, digits = NULL) {
  if (is.numeric(value)) {
    if (is.null(digits)) {
      return(format(value, trim = TRUE, na.encode = FALSE))
    }
    return(format(round(value, digits), trim = TRUE, nsmall = digits, na.encode = FALSE))
  }

  as.character(value)
}
