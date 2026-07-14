test_that("block_pagination emits its runtime input contract", {
  pagination <- block_pagination(
    "page",
    pages = 20,
    selected = 8,
    sibling_count = 2,
    show_edges = FALSE,
    disabled = TRUE,
    class = "custom"
  )
  payload <- runtime_payload_from(pagination)
  html <- render_html(pagination)

  expect_identical(
    tag_attr(pagination, "class"),
    "sb-runtime-mount sb-pagination"
  )
  expect_match(html, 'data-sb-component="pagination"', fixed = TRUE)
  expect_match(
    html,
    '<input id="page" type="hidden" class="sb-pagination-native"',
    fixed = TRUE
  )
  expect_identical(payload$id, "page")
  expect_identical(payload$state$value, 8L)
  expect_identical(payload$props$pages, 20L)
  expect_identical(payload$props$siblingCount, 2L)
  expect_identical(payload$props$showEdges, FALSE)
  expect_identical(payload$props$disabled, TRUE)
  expect_identical(payload$className, "custom")
  expect_identical(payload$binding$type, "shinyblocks.pagination")
})

test_that("block_pagination validates page arguments", {
  expect_error(block_pagination("page", pages = 0), "whole number")
  expect_error(block_pagination("page", pages = 4, selected = 5), "less than or equal")
  expect_error(block_pagination("page", pages = 4, sibling_count = -1), "whole number")
  expect_error(block_pagination("page", pages = 4, show_edges = NA), "TRUE.*FALSE")
})

test_that("update_block_pagination sends binding messages", {
  capture <- local_input_message_session()
  expect_invisible(update_block_pagination(
    capture$session,
    "page",
    pages = 12,
    selected = 6,
    disabled = TRUE,
    style = "max-width: 40rem;",
    class = "wide",
    notify = TRUE
  ))
  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-pagination-page")
  expect_identical(message$payload$pages, 12L)
  expect_identical(message$payload$selected, 6L)
  expect_identical(message$payload$disabled, TRUE)
  expect_identical(message$payload$style$maxWidth, "40rem")
  expect_identical(message$payload$class, "wide")
  expect_identical(message$payload$notify, TRUE)
})

test_that("cosmetic pagination updates do not notify", {
  capture <- local_input_message_session()
  update_block_pagination(capture$session, "page", class = "compact")
  expect_identical(capture$last_payload()$notify, FALSE)
})

test_that("page-count updates notify because they can clamp selection", {
  capture <- local_input_message_session()
  update_block_pagination(capture$session, "page", pages = 3)
  expect_identical(capture$last_payload()$notify, TRUE)
})
