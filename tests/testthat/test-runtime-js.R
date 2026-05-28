runtime_js <- function() {
  path <- system.file(
    "www",
    "shinyblocks-runtime.js",
    package = "shinyblocks",
    mustWork = TRUE
  )
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

app_js <- function() {
  path <- system.file(
    "www",
    "shinyblocks.js",
    package = "shinyblocks",
    mustWork = TRUE
  )
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

runtime_bindings_source <- function() {
  path <- testthat::test_path("..", "..", "frontend", "src", "runtime", "bindings.js")
  if (!file.exists(path)) {
    testthat::skip("runtime bindings source is repo-only and not present in R CMD check build")
  }
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

runtime_source <- function() {
  path <- testthat::test_path("..", "..", "frontend", "src", "index.jsx")
  if (!file.exists(path)) {
    testthat::skip("runtime source is repo-only and not present in R CMD check build")
  }
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
  expect_match(js, "shinyblocks.button", fixed = TRUE)
  expect_match(js, "shinyblocks.popover", fixed = TRUE)
  expect_match(js, "sb:popover-change", fixed = TRUE)
  expect_match(js, "shinyblocks.checkbox", fixed = TRUE)
  expect_match(js, "sb:checkbox-change", fixed = TRUE)
  expect_match(js, "shinyblocks.switch", fixed = TRUE)
  expect_match(js, "sb:switch-change", fixed = TRUE)
  expect_match(js, "shinyblocks.slider", fixed = TRUE)
  expect_match(js, "sb:slider-change", fixed = TRUE)
})

test_that("checkbox and switch bindings fall back to native initial values", {
  js <- runtime_bindings_source()

  expect_match(js, "const native = nativeCheckbox(el);", fixed = TRUE)
  expect_match(js, "return native ? native.checked : false;", fixed = TRUE)
  expect_match(js, "const native = nativeSwitch(el);", fixed = TRUE)
})

test_that("runtime components do not defer value writes through requestAnimationFrame", {
  js <- runtime_source()

  # See issue #24. Each interactive component used to mirror React state into
  # `root.__sbXxxValue` from a useEffect, then defer the change-event dispatch
  # to a requestAnimationFrame so the deferred write would win the race. We now
  # have a single writer per path (mount effect, user action, server receive)
  # and dispatch synchronously. Guard against regressions.
  expect_no_match(js, "requestAnimationFrame(notifyChange)", fixed = TRUE)
  expect_no_match(js, "requestAnimationFrame(() => notifyChange", fixed = TRUE)
  expect_no_match(js, "root.__sbCheckboxValue = nextChecked;\n            root.dispatchEvent", fixed = TRUE)
  expect_no_match(js, "root.__sbSwitchValue = nextChecked;\n            root.dispatchEvent", fixed = TRUE)
  expect_no_match(js, "root.__sbTextareaValue = nextValue;\n            root.dispatchEvent", fixed = TRUE)
  expect_no_match(js, "root.__sbInputValue = nextValue;\n            root.dispatchEvent", fixed = TRUE)
  expect_no_match(js, "root.__sbRadioGroupValue = nextValue;\n            root.dispatchEvent", fixed = TRUE)
})

test_that("slider binding uses a Shiny throttle rate policy", {
  bindings <- runtime_bindings_source()

  # See issue #25. d0cc432 wrapped slider change dispatches in
  # requestAnimationFrame to coalesce per-pointermove notifications. The
  # proper layer for that is Shiny's binding rate policy; throttle (not
  # debounce) keeps live-display reactives responsive while bounding load.
  expect_match(bindings, 'component: "slider"', fixed = TRUE)
  expect_match(bindings, 'ratePolicy: { policy: "throttle", delay: 100 }', fixed = TRUE)

  jsx <- runtime_source()
  expect_no_match(jsx, "notifyFrameRef", fixed = TRUE)
  expect_no_match(jsx, "scheduleNotify", fixed = TRUE)
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

test_that("app JS delegates dark-mode toggle clicks", {
  js <- app_js()

  expect_match(js, "currentThemeMode", fixed = TRUE)
  expect_match(js, "window.shinyblocksInitialThemeMode", fixed = TRUE)
  expect_match(js, "syncThemeToggles", fixed = TRUE)
  expect_match(js, "window.shinyblocksTheme.apply", fixed = TRUE)
  expect_match(js, "window.shinyblocksThemeToggleWired", fixed = TRUE)
  expect_match(js, 'addCustomMessageHandler("sb:theme"', fixed = TRUE)
  expect_match(js, "document.addEventListener(\"click\"", fixed = TRUE)
  expect_match(js, "target.closest(\"[data-sb-theme-toggle]\")", fixed = TRUE)
  expect_match(js, "applyTheme(currentThemeMode())", fixed = TRUE)
  expect_no_match(js, "querySelectorAll(\"[data-sb-theme-toggle]\")\n    ).forEach(function (button) {\n      button.addEventListener(\"click\"", fixed = TRUE) # nolint: line_length_linter
})
