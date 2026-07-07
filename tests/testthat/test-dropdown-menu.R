test_that("block_dropdown_menu emits a runtime payload with items and binding", {
  payload <- runtime_payload_from(
    block_dropdown_menu(
      "Open menu",
      id = "actions",
      dropdown_menu_label("Account"),
      dropdown_menu_item("profile", "Profile", icon = "user"),
      dropdown_menu_separator(),
      dropdown_menu_item("logout", "Log out", variant = "destructive", shortcut = "⌘Q"),
      side = "top",
      align = "end"
    )
  )

  expect_identical(payload$component, "dropdown-menu")
  expect_identical(payload$id, "actions")
  expect_identical(payload$props$side, "top")
  expect_identical(payload$props$align, "end")
  expect_match(payload$props$triggerHtml, "Open menu", fixed = TRUE)
  expect_identical(payload$binding$input, TRUE)
  expect_identical(payload$binding$type, "shinyblocks.dropdown-menu")

  items <- payload$props$items
  expect_length(items, 4)
  expect_identical(items[[1]]$type, "label")
  expect_identical(items[[2]]$type, "item")
  expect_identical(items[[2]]$value, "profile")
  expect_identical(items[[2]]$iconName, "user")
  expect_identical(items[[3]]$type, "separator")
  expect_identical(items[[4]]$variant, "destructive")
  expect_identical(items[[4]]$shortcut, "⌘Q")
})

test_that("block_dropdown_menu without id is client-only", {
  payload <- runtime_payload_from(
    block_dropdown_menu("Open", dropdown_menu_item("a"))
  )
  expect_identical(payload$binding$input, FALSE)
  expect_false("type" %in% names(payload$binding))
})

test_that("block_dropdown_menu accepts a tag trigger and forwards label", {
  payload <- runtime_payload_from(
    block_dropdown_menu(
      htmltools::tags$span("⋯"),
      label = "Row actions",
      dropdown_menu_item("edit", "Edit")
    )
  )
  expect_match(payload$props$triggerHtml, "⋯", fixed = TRUE)
  expect_identical(payload$props$triggerLabel, "Row actions")
})

test_that("block_dropdown_menu validates trigger, items, side, and align", {
  expect_error(block_dropdown_menu(trigger = 1L), "single string label", fixed = TRUE)
  expect_error(
    block_dropdown_menu("Open", "not an item"),
    "dropdown_menu_item",
    fixed = TRUE
  )
  expect_error(block_dropdown_menu("Open", side = "diagonal"), "must be one of")
  expect_error(block_dropdown_menu("Open", align = "weird"), "must be one of")
})

test_that("dropdown_menu_item validates value and variant", {
  expect_error(dropdown_menu_item(value = NULL), "single string", fixed = TRUE)
  expect_error(dropdown_menu_item("a", variant = "loud"), "must be one of")
})

test_that("update_block_dropdown_menu sends replacement items without notifying", {
  capture <- local_input_message_session()

  update_block_dropdown_menu(
    capture$session,
    "actions",
    items = list(
      dropdown_menu_item("new", "New item")
    ),
    open = TRUE,
    side = "left",
    align = "start"
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-dropdown-menu-actions")
  expect_identical(message$payload$open, TRUE)
  expect_identical(message$payload$side, "left")
  expect_identical(message$payload$align, "start")
  expect_identical(message$payload$items[[1]]$value, "new")
  # Reported value is event-style (item value); updates never notify.
  expect_null(message$payload$notify)
})

test_that("update_block_dropdown_menu clears content class and forwards style", {
  capture <- local_input_message_session()

  update_block_dropdown_menu(
    capture$session,
    "actions",
    class = NULL,
    style = "min-width: 16rem;",
    disabled = TRUE
  )

  message <- capture$last_payload()
  expect_true("contentClass" %in% names(message))
  expect_null(message$contentClass)
  expect_identical(message$contentStyle$minWidth, "16rem")
  expect_identical(message$disabled, TRUE)
})
