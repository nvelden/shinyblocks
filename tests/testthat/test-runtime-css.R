runtime_css <- function() {
  path <- system.file(
    "www",
    "shinyblocks-runtime.css",
    package = "shinyblocks",
    mustWork = TRUE
  )
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

package_source_css <- function() {
  path <- testthat::test_path("..", "..", "inst", "www", "src", "shinyblocks.css")
  if (!file.exists(path)) {
    testthat::skip("package source CSS is repo-only and not present in R CMD check build")
  }
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

# Split a comma-separated selector list on top-level commas only, leaving
# commas inside functional pseudo-classes (`:is(a,b)`, `:where(a,b)`,
# `:not(a,b)`) intact. A naive split on every comma would tear an `:is()`
# group apart and misread its tail as an unscoped selector even though the
# whole compound is confined by its ancestor (e.g. `[data-shinyblocks-root]`).
split_top_level_commas <- function(selector) {
  chars <- strsplit(selector, "", fixed = TRUE)[[1]]
  depth <- 0L
  parts <- character()
  current <- ""
  for (ch in chars) {
    if (ch == "(") {
      depth <- depth + 1L
    } else if (ch == ")") {
      depth <- depth - 1L
    }
    if (ch == "," && depth == 0L) {
      parts <- c(parts, current)
      current <- ""
    } else {
      current <- paste0(current, ch)
    }
  }
  c(parts, current)
}

css_selectors <- function(css) {
  rules <- unlist(strsplit(css, "}"), use.names = FALSE)
  selectors <- sub("\\{.*$", "", rules)
  selectors <- unlist(lapply(selectors, split_top_level_commas), use.names = FALSE)
  selectors <- trimws(selectors)
  selectors[nzchar(selectors)]
}

source_class_selectors <- function(css) {
  lines <- trimws(unlist(strsplit(css, "\n", fixed = TRUE), use.names = FALSE))
  lines <- lines[grepl("^\\.sb-", lines)]
  lines <- sub("\\s*\\{.*$", "", lines)
  lines <- sub(",\\s*$", "", lines)
  lines[nzchar(lines)]
}

test_that("runtime CSS selectors are scoped to shinyblocks roots", {
  selectors <- css_selectors(runtime_css())

  allowed <- grepl(
    paste0(
      "^\\[data-shinyblocks-root\\]|",
      "^\\[data-shinyblocks-portal-root\\]|",
      "^\\[data-theme=\"dark\"\\] \\[data-shinyblocks-root\\]|",
      "^\\[data-theme=\"dark\"\\] \\[data-shinyblocks-portal-root\\]|",
      # Style-profile-scoped component CSS (e.g. data-sb-style="luma"). Still
      # confined to shinyblocks roots; the profile attribute is an ancestor.
      "^\\[data-sb-style=\"[^\"]+\"\\] \\[data-shinyblocks-root\\]|",
      "^\\[data-sb-style=\"[^\"]+\"\\] \\[data-shinyblocks-portal-root\\]|",
      "^\\[data-theme=\"dark\"\\] \\[data-sb-style=\"[^\"]+\"\\] \\[data-shinyblocks-root\\]|",
      "^\\[data-theme=\"dark\"\\] \\[data-sb-style=\"[^\"]+\"\\] \\[data-shinyblocks-portal-root\\]|",
      "^@keyframes |",
      "^@media "
    ),
    selectors
  )

  expect_identical(
    selectors[!allowed],
    character()
  )
})

test_that("package source CSS only owns shell and composition hooks", {
  selectors <- source_class_selectors(package_source_css())
  allowed <- grepl(
    paste0(
      "^\\.sb-app\\b|",
      "^\\.sb-page\\b|",
      "^\\.sb-page-main\\b|",
      "^\\.sb-header\\b|",
      "^\\.sb-header-shell\\b|",
      "^\\.sb-sidebar\\b|",
      "^\\.sb-sidebar-title\\b|",
      "^\\.sb-sidebar-title-text\\b|",
      "^\\.sb-sidebar-nav\\b|",
      "^\\.sb-sidebar-toggle\\b|",
      "^\\.sb-sidebar-mobile-trigger\\b|",
      "^\\.sb-sidebar-backdrop\\b|",
      "^\\.sb-nav\\b|",
      "^\\.sb-nav-item\\b|",
      "^\\.sb-body\\b|",
      "^\\.sb-icon\\b|",
      "^\\.sb-tabs\\b|",
      "^\\.sb-tabs-list\\b|",
      "^\\.sb-tabs-trigger\\b|",
      "^\\.sb-tabs-content\\b|",
      "^\\.sb-tabs-panel\\b|",
      "^\\.sb-field\\b|",
      "^\\.sb-field-group\\b|",
      "^\\.sb-field-label\\b|",
      "^\\.sb-field-legend\\b|",
      "^\\.sb-field-description\\b|",
      "^\\.sb-field-set\\b|",
      "^\\.sb-input-group\\b|",
      "^\\.sb-input-group-addon\\b"
    ),
    selectors
  )

  expect_identical(selectors[!allowed], character())
})

test_that("runtime CSS does not target host framework selectors", {
  css <- runtime_css()
  forbidden <- c(
    ".form-group",
    ".control-label",
    ".btn",
    ".nav-link",
    ".tab-pane",
    ".selectize-",
    ".irs-",
    ".dataTables_",
    ".html-widget",
    ":root"
  )

  hits <- forbidden[vapply(
    forbidden,
    function(pattern) grepl(pattern, css, fixed = TRUE),
    logical(1)
  )]

  expect_identical(hits, character())
  expect_false(
    grepl("(^|[},])body\\{", css, perl = TRUE),
    info = "runtime CSS must not emit a global body selector"
  )
})

test_that("runtime CSS does not reset all runtime children", {
  css <- runtime_css()

  expect_no_match(css, "[data-shinyblocks-root] *", fixed = TRUE)
  expect_no_match(css, "*::before", fixed = TRUE)
  expect_no_match(css, "*::after", fixed = TRUE)
})

test_that("runtime tokens are scoped to runtime and portal roots", {
  css <- runtime_css()

  expect_match(
    css,
    "[data-shinyblocks-root],[data-shinyblocks-portal-root]{--radius:",
    fixed = TRUE
  )
  expect_match(css, "--background:oklch(100% 0 0)", fixed = TRUE)
  expect_match(
    css,
    '[data-theme="dark"] [data-shinyblocks-root],[data-theme="dark"] [data-shinyblocks-portal-root]{--background:oklch(14.5% 0 0)', # nolint: line_length_linter
    fixed = TRUE
  )
  expect_no_match(css, ":root{--radius", fixed = TRUE)
})

test_that("runtime CSS exposes custom select selectors", {
  css <- runtime_css()

  expect_match(css, ".sb-select-native", fixed = TRUE)
  expect_match(css, ".sb-select-trigger", fixed = TRUE)
  expect_match(css, ".sb-select-content", fixed = TRUE)
  expect_match(css, ".sb-select-item", fixed = TRUE)
})

test_that("runtime slider keeps a usable standalone width", {
  css <- runtime_css()

  expect_match(css, "min-width:min(12rem,100%)", fixed = TRUE)
})

test_that("runtime CSS omits legacy native select selectors", {
  css <- runtime_css()

  expect_no_match(css, ".sb-select-control", fixed = TRUE)
  expect_no_match(css, ".sb-select-icon", fixed = TRUE)
})

test_that("runtime assets are attached and exist in the package", {
  dependency <- local_internal()$shinyblocks_dependency()
  runtime_assets <- c(
    "shinyblocks-runtime.css",
    "shinyblocks-runtime.js"
  )

  attached <- c(dependency$stylesheet, dependency$script)
  expect_setequal(
    runtime_assets,
    intersect(runtime_assets, attached)
  )

  for (asset in runtime_assets) {
    expect_equal(
      file.exists(system.file("www", asset, package = "shinyblocks")),
      TRUE,
      info = sprintf("%s should be installed under inst/www", asset)
    )
  }
})
