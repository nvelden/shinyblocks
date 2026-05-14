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

  expect_snapshot(error = TRUE, {
    block_select("plan", choices = c("Free", "Pro"), size = "xl")
  })

  expect_error(
    block_select("plan", choices = c(None = "", Free = "free")),
    "placeholder sentinel"
  )

  expect_error(
    block_select("plan", choices = c(Free = "free", AlsoFree = "free")),
    "must be unique"
  )
})

test_that("validate_select_choice_values rejects invalid values", {
  expect_error(
    validate_select_choice_values(c("free", "")),
    "placeholder sentinel"
  )
  expect_error(
    validate_select_choice_values(c("free", "pro", "free")),
    "must be unique"
  )
  expect_invisible(validate_select_choice_values(c("free", "pro")))
})

test_that("update_block_select sends input binding messages", {
  message <- NULL
  session <- list(
    ns = identity,
    sendInputMessage = function(input_id, payload) {
      message <<- list(input_id = input_id, payload = payload)
    }
  )

  expect_invisible(
    update_block_select(
      session,
      "plan",
      selected = "pro",
      choices = c(Free = "free", Pro = "pro"),
      placeholder = "Choose",
      disabled = TRUE,
      width = "16rem",
      class = "custom-select",
      size = "lg",
      invalid = TRUE,
      notify = TRUE
    )
  )

  expect_identical(message$input_id, "sb-runtime-select-plan")
  expect_identical(message$payload$selected, "pro")
  expect_identical(message$payload$choices[[2]]$label, "Pro")
  expect_identical(message$payload$placeholder, "Choose")
  expect_identical(message$payload$disabled, TRUE)
  expect_identical(message$payload$width, "16rem")
  expect_identical(message$payload$class, "custom-select")
  expect_identical(message$payload$size, "lg")
  expect_identical(message$payload$invalid, TRUE)
  expect_identical(message$payload$notify, TRUE)
})

test_that("update_block_select maps clearable NULL fields", {
  message <- NULL
  session <- list(
    ns = identity,
    sendInputMessage = function(input_id, payload) {
      message <<- payload
    }
  )

  expect_invisible(
    update_block_select(
      session,
      "plan",
      selected = NULL,
      placeholder = NULL,
      class = NULL
    )
  )

  expect_identical(message$selected, "")
  expect_null(message$placeholder)
  expect_null(message$class)
  expect_identical(message$notify, TRUE)
})

test_that("cosmetic update_block_select messages do not notify", {
  message <- NULL
  session <- list(
    ns = function(id) paste0("module-", id),
    sendInputMessage = function(input_id, payload) {
      message <<- list(input_id = input_id, payload = payload)
    }
  )

  update_block_select(session, "plan", width = "12rem")

  expect_identical(message$input_id, "sb-runtime-select-module-plan")
  expect_identical(message$payload$width, "12rem")
  expect_identical(message$payload$notify, FALSE)
})

test_that("update_block_select validates selected replacement choices", {
  session <- list(
    ns = identity,
    sendInputMessage = function(input_id, payload) NULL
  )

  expect_snapshot(error = TRUE, {
    update_block_select(
      session,
      "plan",
      selected = "team",
      choices = c(Free = "free", Pro = "pro")
    )
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
