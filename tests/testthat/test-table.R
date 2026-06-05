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

test_that("block_table() omits rowMeta when no row_format", {
  table <- block_table(data.frame(item = "A"))
  payload <- runtime_payload_from(table)

  expect_null(payload$props$rowMeta)
  expect_false(payload$props$striped)
  expect_true(payload$props$hover)
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
