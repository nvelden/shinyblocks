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
  expect_match(js, "$socket", fixed = TRUE)
  expect_match(js, "sbPendingInput", fixed = TRUE)
  expect_match(js, "shinyblocksRuntimePendingInputFlushTimer", fixed = TRUE)
  expect_match(js, "shiny:connected", fixed = TRUE)
  expect_match(js, "Shiny.addCustomMessageHandler", fixed = TRUE)
  expect_match(js, '"sb:update"', fixed = TRUE)
})

test_that("runtime JS includes dynamic UI lifecycle hooks", {
  js <- runtime_js()

  expect_match(js, "MutationObserver", fixed = TRUE)
  expect_match(js, "removedNodes", fixed = TRUE)
  expect_match(js, "addedNodes", fixed = TRUE)
  expect_match(js, "data-shinyblocks-runtime", fixed = TRUE)
})

test_that("runtime JS preserves Shiny child binding hooks", {
  js <- runtime_js()

  expect_match(js, "Shiny.bindAll", fixed = TRUE)
  expect_match(js, "Shiny.unbindAll", fixed = TRUE)
  expect_match(js, "data-shinyblocks-children", fixed = TRUE)
})

test_that("runtime JS includes the React mount path", {
  js <- runtime_js()

  expect_match(js, "createRoot", fixed = TRUE)
  expect_match(js, "data-shinyblocks-react", fixed = TRUE)
  expect_match(js, "data-shinyblocks-react-mounted", fixed = TRUE)
  expect_no_match(js, "Download the React DevTools", fixed = TRUE)
  expect_no_match(js, "process.env.NODE_ENV", fixed = TRUE)
})

test_that("runtime JS creates scoped portal roots", {
  js <- runtime_js()

  expect_match(js, "data-shinyblocks-portal-root", fixed = TRUE)
  expect_no_match(js, "document.body.innerHTML", fixed = TRUE)
})
