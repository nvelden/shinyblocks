test_that("block_table() serializes a data frame payload", {
  table <- block_table(
    data.frame(
      item = c("Alpha", "Beta"),
      count = c(12, 3),
      active = c(TRUE, FALSE)
    ),
    caption = "Inventory"
  )
  payload <- runtime_payload_from(table)

  expect_identical(payload$component, "table")
  expect_identical(tag_attr(table, "class"), "sb-runtime-mount sb-table")
  expect_identical(payload$props$caption, "Inventory")
  expect_identical(payload$props$totalRows, 2L)
  expect_false(payload$props$truncated)
  expect_identical(
    payload$props$columns,
    list(
      list(key = "item", label = "item", align = "left", width = NULL),
      list(key = "count", label = "count", align = "left", width = NULL),
      list(key = "active", label = "active", align = "left", width = NULL)
    )
  )
  expect_identical(
    payload$props$rows,
    list(
      list("Alpha", "12", "TRUE"),
      list("Beta", "3", "FALSE")
    )
  )
})

test_that("table_column() applies labels, alignment, width, and formatting", {
  table <- block_table(
    data.frame(
      item = c("Alpha", "Beta"),
      revenue = c(1250.5, 88)
    ),
    columns = list(
      revenue = table_column(
        label = "Revenue",
        align = "right",
        width = "8rem",
        format = function(value) sprintf("$%.2f", value)
      )
    )
  )
  payload <- runtime_payload_from(table)

  expect_identical(
    payload$props$columns[[2]],
    list(key = "revenue", label = "Revenue", align = "right", width = "8rem")
  )
  expect_identical(
    payload$props$rows,
    list(
      list("Alpha", "$1250.50"),
      list("Beta", "$88.00")
    )
  )
})

test_that("table_column() emits theme-safe column and header styling", {
  table <- block_table(
    data.frame(metric = c("Revenue"), cost = c(-700)),
    columns = list(
      cost = table_column(
        align = "right",
        intent = "muted",
        class = "tabular-nums",
        header_intent = "primary",
        header_emphasis = "soft",
        header_style = "letter-spacing: 0.05em;"
      )
    )
  )
  payload <- runtime_payload_from(table)

  spec <- payload$props$columns[[2]]
  expect_identical(spec$intent, "muted")
  expect_identical(spec$emphasis, "text")
  expect_identical(spec$class, "tabular-nums")
  expect_identical(spec$headerIntent, "primary")
  expect_identical(spec$headerEmphasis, "soft")
  expect_identical(spec$headerStyle$letterSpacing, "0.05em")
})

test_that("table_column() omits styling fields when unset (back-compat)", {
  table <- block_table(
    data.frame(item = c("Alpha"), count = c(1)),
    columns = list(count = table_column(align = "right"))
  )
  payload <- runtime_payload_from(table)

  expect_identical(
    payload$props$columns,
    list(
      list(key = "item", label = "item", align = "left", width = NULL),
      list(key = "count", label = "count", align = "right", width = NULL)
    )
  )
})

test_that("table_column() validates intent and emphasis", {
  expect_error(table_column(intent = "danger"), "`intent` must be one of")
  expect_error(
    table_column(intent = "primary", emphasis = "bold"),
    "`emphasis` must be one of"
  )
  expect_error(
    table_column(header_intent = "nope"),
    "`header_intent` must be one of"
  )
})

test_that("block_table() renders missing values as empty cells", {
  table <- block_table(
    data.frame(
      label = c("Alpha", NA),
      count = c(NA_real_, 2)
    )
  )
  payload <- runtime_payload_from(table)

  expect_identical(
    payload$props$rows,
    list(
      list("Alpha", ""),
      list("", "2")
    )
  )
})

test_that("block_table() truncates rows with max_rows", {
  table <- block_table(
    data.frame(item = c("A", "B", "C")),
    max_rows = 2
  )
  payload <- runtime_payload_from(table)

  expect_true(payload$props$truncated)
  expect_identical(payload$props$totalRows, 3L)
  expect_identical(payload$props$rows, list(list("A"), list("B")))
})

test_that("block_table() keeps zero-row tables serializable", {
  table <- block_table(
    data.frame(item = character(), count = numeric()),
    max_rows = 0
  )
  payload <- runtime_payload_from(table)

  expect_identical(length(payload$props$rows), 0L)
  expect_false(payload$props$truncated)
  expect_identical(payload$props$totalRows, 0L)
})

test_that("block_table() renders na, digits, and rownames", {
  table <- block_table(
    data.frame(
      revenue = c(1250.5, NA, 88),
      row.names = c("a", "b", "c")
    ),
    na = "n/a",
    digits = 1,
    rownames = TRUE
  )
  payload <- runtime_payload_from(table)

  expect_identical(payload$props$columns[[1]]$key, "_rownames")
  expect_identical(
    payload$props$rows,
    list(
      list("a", "1250.5"),
      list("b", "n/a"),
      list("c", "88.0")
    )
  )
})

test_that("table_column() overrides table-level na and digits", {
  table <- block_table(
    data.frame(score = c(1.234, NA)),
    na = "n/a",
    digits = 0,
    columns = list(score = table_column(digits = 2, na = "—"))
  )
  payload <- runtime_payload_from(table)

  expect_identical(payload$props$rows, list(list("1.23"), list("—")))
})

test_that("row_format produces per-row rowMeta", {
  table <- block_table(
    data.frame(amount = c(2000, 10)),
    row_format = function(row, i) {
      if (row$amount > 1000) list(class = "is-warning", style = "font-weight:600")
    }
  )
  payload <- runtime_payload_from(table)

  expect_identical(payload$props$rowMeta[[1]]$class, "is-warning")
  expect_identical(payload$props$rowMeta[[1]]$style$fontWeight, "600")
  expect_null(payload$props$rowMeta[[2]])
})

test_that("block_table() emits empty per-row rowMeta when no row_format", {
  # rowMeta is always present (one empty entry per rendered row) so a
  # data-bearing update_block_table() payload authoritatively clears any prior
  # per-row formatting instead of leaving it stale in the runtime merge.
  table <- block_table(data.frame(item = c("A", "B")))
  payload <- runtime_payload_from(table)

  expect_length(payload$props$rowMeta, 2L)
  expect_null(payload$props$rowMeta[[1]])
  expect_null(payload$props$rowMeta[[2]])
  expect_false(payload$props$striped)
  expect_true(payload$props$hover)
})

test_that("cell_intent callbacks produce a cellMeta matrix", {
  table <- block_table(
    data.frame(metric = c("Profit", "Loss"), value = c(120, -40)),
    columns = list(
      value = table_column(
        cell_intent = function(v) ifelse(v < 0, "destructive", "success"),
        cell_emphasis = function(v) "soft"
      )
    )
  )
  payload <- runtime_payload_from(table)

  expect_length(payload$props$cellMeta, 2L)
  # Two columns per row; only the `value` column (index 2) is styled.
  expect_null(payload$props$cellMeta[[1]][[1]])
  expect_identical(payload$props$cellMeta[[1]][[2]]$intent, "success")
  expect_identical(payload$props$cellMeta[[1]][[2]]$emphasis, "soft")
  expect_identical(payload$props$cellMeta[[2]][[2]]$intent, "destructive")
})

test_that("cell_style accepts a single named list as one style object", {
  # A fully named list is one style applied to every row, not per-row entries.
  table <- block_table(
    data.frame(value = c(10, 20, 30)),
    columns = list(
      value = table_column(cell_style = function(v) list(color = "var(--primary)"))
    )
  )
  payload <- runtime_payload_from(table)

  expect_length(payload$props$cellMeta, 3L)
  for (i in seq_len(3)) {
    expect_identical(payload$props$cellMeta[[i]][[1]]$style, list(color = "var(--primary)"))
  }
})

test_that("cell_style accepts CSS strings and per-row named lists", {
  table <- block_table(
    data.frame(value = c(1, 2)),
    columns = list(
      value = table_column(
        cell_style = function(v) list(list(color = "red"), "font-weight: 600")
      )
    )
  )
  payload <- runtime_payload_from(table)

  expect_identical(payload$props$cellMeta[[1]][[1]]$style, list(color = "red"))
  expect_identical(payload$props$cellMeta[[2]][[1]]$style, list(fontWeight = "600"))
})

test_that("block_table() always emits cellMeta for clear-on-merge", {
  table <- block_table(data.frame(item = c("A", "B")))
  payload <- runtime_payload_from(table)

  expect_length(payload$props$cellMeta, 2L)
  expect_identical(payload$props$cellMeta[[1]], list(NULL))
  expect_identical(payload$props$cellMeta[[2]], list(NULL))
})

test_that("rownames adds a leading empty cellMeta slot", {
  table <- block_table(
    data.frame(value = c(5), row.names = "a"),
    rownames = TRUE,
    columns = list(value = table_column(cell_intent = function(v) "primary"))
  )
  payload <- runtime_payload_from(table)

  expect_null(payload$props$cellMeta[[1]][[1]])
  expect_identical(payload$props$cellMeta[[1]][[2]]$intent, "primary")
})

test_that("cell_* callbacks validate length and intent", {
  expect_error(
    block_table(
      data.frame(x = c(1, 2)),
      columns = list(x = table_column(cell_intent = function(v) c("primary")))
    ),
    NA
  )
  expect_error(
    block_table(
      data.frame(x = c(1, 2)),
      columns = list(x = table_column(cell_class = function(v) c("a", "b", "c")))
    ),
    "`cell_class` for column .* must return one value per row"
  )
  expect_error(
    block_table(
      data.frame(x = c(1, 2)),
      columns = list(x = table_column(cell_intent = function(v) c("primary", "bad")))
    ),
    "must be one of"
  )
  expect_error(
    table_column(cell_intent = "primary"),
    "`cell_intent` must be NULL or a function"
  )
})

test_that("row_format can return an intent", {
  table <- block_table(
    data.frame(amount = c(2000, 10)),
    row_format = function(row, i) {
      if (row$amount > 1000) list(intent = "warning", emphasis = "soft")
    }
  )
  payload <- runtime_payload_from(table)

  expect_identical(payload$props$rowMeta[[1]]$intent, "warning")
  expect_identical(payload$props$rowMeta[[1]]$emphasis, "soft")
  expect_null(payload$props$rowMeta[[2]])
})

test_that("table_build_payload is the single source for UI and updates", {
  build <- local_internal()$table_build_payload
  df <- data.frame(amount = c(2000, 10))
  args <- list(data = df, digits = 1, striped = TRUE)

  ui_props <- runtime_payload_from(
    do.call(block_table, args)
  )$props
  direct_props <- do.call(build, args)

  # The UI payload round-trips through JSON (lists, no integer class), so compare
  # the JSON-stable shape rather than R object identity.
  expect_identical(
    jsonlite::fromJSON(runtime_payload_json(list(direct_props)), simplifyVector = FALSE)[[1]],
    ui_props
  )
})

test_that("update_block_table() sends a formatted payload to the mount", {
  capture <- local_input_message_session()
  update_block_table(
    capture$session,
    "tbl",
    data = data.frame(amount = c(2000, 10)),
    striped = TRUE
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-table-tbl")
  expect_identical(message$payload$rows, list(list("2000"), list("10")))
  expect_true(message$payload$striped)
  expect_null(message$payload$notify)
})

test_that("update_block_table() can push only a loading flag", {
  capture <- local_input_message_session()
  update_block_table(capture$session, "tbl", loading = TRUE)

  payload <- capture$last_payload()
  expect_true(payload$loading)
  expect_null(payload$rows)
})

test_that("block_table() validates inputs", {
  expect_error(block_table(list(item = "A")), "`data` must be a data frame")
  expect_error(
    block_table(data.frame(item = "A"), columns = list(other = table_column())),
    "unknown data columns"
  )
  expect_error(
    block_table(data.frame(item = "A"), columns = list(table_column())),
    "`columns` must be a fully named list"
  )
  expect_error(
    table_column(align = "end"),
    "`align` must be one of"
  )
  expect_error(
    table_column(format = "comma"),
    "`format` must be NULL or a function"
  )
  expect_error(
    block_table(data.frame(item = "A"), max_rows = -1),
    "`max_rows` must be NULL or a non-negative integer"
  )
  expect_error(
    block_table(
      data.frame(item = c("A", "B")),
      columns = list(item = table_column(format = function(value) "A"))
    ),
    "`format` for column"
  )
  expect_error(
    block_table(data.frame(item = "A"), digits = -1),
    "`digits` must be NULL or a non-negative integer"
  )
  expect_error(
    block_table(data.frame(item = "A"), na = c("a", "b")),
    "`na` must be a single character string"
  )
  expect_error(
    block_table(data.frame(item = "A"), row_format = "x"),
    "`row_format` must be NULL or a function"
  )
  expect_error(
    block_table(
      data.frame(item = c("A", "B")),
      row_format = function(row, i) "nope"
    ),
    "`row_format` must return NULL or a list"
  )
})

test_that("block_table() omits selection fields by default (back-compat)", {
  payload <- runtime_payload_from(block_table(data.frame(item = c("A", "B"))))
  expect_null(payload$props$selection)
  expect_null(payload$props$selected)
})

test_that("block_table() emits selection mode and initial selection", {
  payload <- runtime_payload_from(
    block_table(
      data.frame(item = c("A", "B", "C")),
      selection = "multiple",
      selected = c(1, 3),
      id = "tbl"
    )
  )
  expect_identical(payload$props$selection, "multiple")
  expect_identical(payload$props$selected, list(1L, 3L))
})

test_that("block_table() emits selection without an initial selection", {
  payload <- runtime_payload_from(
    block_table(data.frame(item = c("A", "B")), selection = "single", id = "tbl")
  )
  expect_identical(payload$props$selection, "single")
  expect_null(payload$props$selected)
})

test_that("block_table() validates selection and selected", {
  expect_error(
    block_table(data.frame(item = "A"), selection = "many"),
    "`selection` must be one of"
  )
  expect_error(
    block_table(data.frame(item = "A"), selected = 1),
    "`selected` requires `selection`"
  )
  expect_error(
    block_table(data.frame(item = "A"), selection = "single", selected = c(1, 2)),
    "length <= 1"
  )
  expect_error(
    block_table(data.frame(item = "A"), selection = "multiple", selected = c(0, 1)),
    "positive whole numbers"
  )
})

test_that("update_block_table() pushes selection and selected", {
  capture <- local_input_message_session()
  update_block_table(
    capture$session, "tbl",
    selection = "single", selected = 2
  )
  payload <- capture$last_payload()
  expect_identical(payload$selection, "single")
  expect_identical(payload$selected, list(2L))
  expect_null(payload$rows)
})

test_that("update_block_table() clears selection with integer(0)", {
  capture <- local_input_message_session()
  update_block_table(capture$session, "tbl", selected = integer(0))
  payload <- capture$last_payload()
  expect_identical(payload$selected, list())
})
