test_that("merge_classes deduplicates class names", {
  ns <- local_internal()

  expect_identical(
    ns$merge_classes("sb-header custom", "custom", NULL, ""),
    "sb-header custom"
  )
  expect_null(ns$merge_classes(NULL, ""))
})

test_that("match_arg reports allowed values", {
  ns <- local_internal()

  expect_identical(
    ns$match_arg("light", c("system", "light", "dark"), "theme_mode"),
    "light"
  )

  expect_snapshot(error = TRUE, {
    ns$match_arg("auto", c("system", "light", "dark"), "theme_mode")
  })
})

test_that("validate_children accepts only tagged child items", {
  ns <- local_internal()
  item <- htmltools::tags$div(`data-sb-child` = "nav-item")
  invalid <- htmltools::tags$div()

  expect_invisible(ns$validate_children(list(item), "nav-item", "block_nav"))

  expect_snapshot(error = TRUE, {
    ns$validate_children(list(invalid), "nav-item", "block_nav")
  })
})

test_that("validate_icon_name reports unknown icons", {
  ns <- local_internal()

  expect_snapshot(error = TRUE, {
    ns$validate_icon_name("not-an-icon")
  })
})

test_that("block_button validates variant and size", {
  expect_snapshot(error = TRUE, {
    block_button("Save", variant = "primary")
  })

  expect_snapshot(error = TRUE, {
    block_button("Save", size = "xl")
  })
})

test_that("block_badge validates variant", {
  expect_snapshot(error = TRUE, {
    block_badge("New", variant = "primary")
  })
})

test_that("block_alert validates required title and variant", {
  expect_snapshot(error = TRUE, {
    block_alert(NULL)
  })

  expect_snapshot(error = TRUE, {
    block_alert("Notice", variant = "warning")
  })
})

test_that("block_separator validates orientation", {
  expect_snapshot(error = TRUE, {
    block_separator(orientation = "diagonal")
  })
})

test_that("block_nav validates child types", {
  expect_snapshot(error = TRUE, {
    block_nav(htmltools::tags$div("Bad child"))
  })
})

test_that("block_field_invalid validates field input", {
  expect_snapshot(error = TRUE, {
    block_field_invalid(htmltools::tags$div("Bad field"), "Nope")
  })
})

test_that("block_select validates choices and selected value", {
  expect_snapshot(error = TRUE, {
    block_select("plan", choices = character())
  })

  expect_snapshot(error = TRUE, {
    block_select("plan", choices = c("Free", "Pro"), selected = "Team")
  })
})

test_that("block_textarea validates rows", {
  expect_snapshot(error = TRUE, {
    block_textarea("notes", rows = 0)
  })
})

test_that("block_theme validates named and known tokens", {
  expect_snapshot(error = TRUE, {
    block_theme("bad")
  })

  expect_snapshot(error = TRUE, {
    block_theme(not_a_token = "red")
  })
})

test_that("update_block_theme sends a custom message", {
  message <- NULL
  session <- list(
    sendCustomMessage = function(type, payload) {
      message <<- list(type = type, payload = payload)
    }
  )

  expect_invisible(update_block_theme(session, mode = "dark"))
  expect_identical(message$type, "sb:theme")
  expect_identical(message$payload$mode, "dark")
})

test_that("update_block_theme requires a session", {
  expect_snapshot(error = TRUE, {
    update_block_theme(NULL)
  })
})
