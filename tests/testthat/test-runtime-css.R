runtime_css <- function() {
  path <- system.file(
    "www",
    "shinyblocks-runtime.css",
    package = "shinyblocks",
    mustWork = TRUE
  )
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

css_selectors <- function(css) {
  rules <- unlist(strsplit(css, "}"), use.names = FALSE)
  selectors <- sub("\\{.*$", "", rules)
  selectors <- trimws(unlist(strsplit(selectors, ","), use.names = FALSE))
  selectors[nzchar(selectors)]
}

test_that("runtime CSS selectors are scoped to shinyblocks roots", {
  selectors <- css_selectors(runtime_css())

  allowed <- grepl(
    "^\\[data-shinyblocks-root\\]|^\\[data-shinyblocks-portal-root\\]",
    selectors
  )

  expect_identical(
    selectors[!allowed],
    character()
  )
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
    "body{",
    ":root"
  )

  hits <- forbidden[vapply(
    forbidden,
    function(pattern) grepl(pattern, css, fixed = TRUE),
    logical(1)
  )]

  expect_identical(hits, character())
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
