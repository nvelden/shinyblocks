test_that("update_block_nav sends a custom message", {
  capture <- local_custom_message_session()

  expect_invisible(update_block_nav(capture$session, "page", selected = "users"))
  message <- capture$last_message()

  expect_identical(message$type, "sb:nav")
  expect_identical(
    message$payload,
    list(id = "page", selected = "users", notify = TRUE)
  )
})

test_that("update_block_nav respects namespaces and notify", {
  capture <- local_custom_message_session()
  capture$session$ns <- function(id) paste0("mod-", id)

  update_block_nav(
    capture$session,
    "page",
    selected = "dashboard",
    notify = FALSE
  )

  expect_identical(
    capture$last_message()$payload,
    list(id = "mod-page", selected = "dashboard", notify = FALSE)
  )
})

test_that("update_block_nav validates inputs", {
  capture <- local_custom_message_session()

  expect_error(
    update_block_nav(NULL, "page", selected = "users"),
    "`session` is required"
  )
  expect_error(
    update_block_nav(list(), "page", selected = "users"),
    "sendCustomMessage"
  )
  expect_error(update_block_nav(capture$session, "", selected = "users"), "input_id")
  expect_error(update_block_nav(capture$session, "page", selected = ""), "`selected`")
})
