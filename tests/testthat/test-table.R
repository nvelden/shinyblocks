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
})
