runtime_js <- function() {
  path <- system.file(
    "www",
    "shinyblocks-runtime.js",
    package = "shinyblocks",
    mustWork = TRUE
  )
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

test_that("runtime JS includes Shiny bridge hooks", {
  js <- runtime_js()

  expect_match(js, "Shiny.setInputValue", fixed = TRUE)
  expect_match(js, "Shiny.addCustomMessageHandler", fixed = TRUE)
  expect_match(js, '"sb:update"', fixed = TRUE)
})

test_that("runtime JS includes dynamic UI lifecycle hooks", {
  js <- runtime_js()

  expect_match(js, "MutationObserver", fixed = TRUE)
  expect_match(js, "removedNodes", fixed = TRUE)
  expect_match(js, "addedNodes", fixed = TRUE)
  expect_match(js, "unmountRoot", fixed = TRUE)
})

test_that("runtime JS preserves Shiny child binding hooks", {
  js <- runtime_js()

  expect_match(js, "Shiny.bindAll", fixed = TRUE)
  expect_match(js, "Shiny.unbindAll", fixed = TRUE)
})

test_that("runtime JS creates scoped portal roots", {
  js <- runtime_js()

  expect_match(js, "data-shinyblocks-portal-root", fixed = TRUE)
  expect_no_match(js, "document.body.innerHTML", fixed = TRUE)
})
