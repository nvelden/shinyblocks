test_that("update_block_nav sends an input message", {
  capture <- local_input_message_session()

  expect_invisible(update_block_nav(capture$session, "page", selected = "users"))
  message <- capture$last_message()

  expect_identical(message$input_id, "page")
  expect_identical(
    message$payload,
    list(selected = "users", notify = TRUE)
  )
})

test_that("update_block_nav respects namespaces and notify", {
  capture <- local_input_message_session(ns = function(id) paste0("mod-", id))

  update_block_nav(
    capture$session,
    "page",
    selected = "dashboard",
    notify = FALSE
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "mod-page")
  expect_identical(
    message$payload,
    list(selected = "dashboard", notify = FALSE)
  )
})

test_that("update_block_nav routes module updates through the root session once", {
  capture <- local_module_message_session("mod")

  update_block_nav(capture$session, "page", selected = "users")

  # The module proxy would re-namespace its own `sendInputMessage()`; routing via
  # the root session keeps the already-namespaced target prefixed exactly once.
  expect_identical(capture$last_target(), "mod-page")
})

test_that("update_block_nav validates inputs", {
  capture <- local_input_message_session()

  expect_error(
    update_block_nav(NULL, "page", selected = "users"),
    "`session` is required"
  )
  expect_error(
    update_block_nav(list(), "page", selected = "users"),
    "sendInputMessage"
  )
  expect_error(update_block_nav(capture$session, "", selected = "users"), "input_id")
  expect_error(update_block_nav(capture$session, "page", selected = ""), "`selected`")
  expect_error(update_block_nav(capture$session, "page"), "`selected`")
})
