test_that("update_block_tabs sends an input message", {
  capture <- local_input_message_session()

  expect_invisible(update_block_tabs(capture$session, "account_tabs", selected = "usage"))
  message <- capture$last_message()

  expect_identical(message$input_id, "account_tabs")
  expect_identical(
    message$payload,
    list(selected = "usage", notify = TRUE)
  )
})

test_that("update_block_tabs respects namespaces and notify", {
  capture <- local_input_message_session(ns = function(id) paste0("mod-", id))

  update_block_tabs(
    capture$session,
    "account_tabs",
    selected = "settings",
    notify = FALSE
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "mod-account_tabs")
  expect_identical(
    message$payload,
    list(selected = "settings", notify = FALSE)
  )
})

test_that("update_block_tabs routes module updates through the root session once", {
  capture <- local_module_message_session("mod")

  update_block_tabs(capture$session, "account_tabs", selected = "usage")

  expect_identical(capture$last_target(), "mod-account_tabs")
})

test_that("update_block_tabs validates inputs", {
  capture <- local_input_message_session()

  expect_error(
    update_block_tabs(NULL, "account_tabs", selected = "usage"),
    "`session` is required"
  )
  expect_error(
    update_block_tabs(list(), "account_tabs", selected = "usage"),
    "sendInputMessage"
  )
  expect_error(update_block_tabs(capture$session, "", selected = "usage"), "input_id")
  expect_error(update_block_tabs(capture$session, "account_tabs", selected = ""), "`selected`")
  expect_error(update_block_tabs(capture$session, "account_tabs"), "`selected`")
})
