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

preflight_source_css <- function() {
  path <- testthat::test_path("..", "..", "inst", "www", "src", "preflight.scoped.css")
  if (!file.exists(path)) {
    testthat::skip("Preflight source is repo-only and not present in R CMD check build")
  }
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

shell_token_source_css <- function() {
  path <- testthat::test_path("..", "..", "inst", "www", "src", "tokens.css")
  if (!file.exists(path)) {
    testthat::skip("shell token source is repo-only and not present in R CMD check build")
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

# Static-markup components emit ordinary htmltools markup with no
# `[data-shinyblocks-root]` mount (e.g. `block_card()` renders a bare
# `<div class="sb-card">`; see R/card.R). Their CSS therefore cannot be
# root-scoped or the component would render unstyled. Such selectors are
# allowed to target their own `.sb-*` class directly, optionally behind the
# `[data-theme="dark"]` / `[data-sb-style="..."]` ancestor attributes. Keep
# this list tight — one entry per static-markup component class root — so it
# stays an explicit exception, not a blanket `.sb-*` escape hatch.
static_markup_selector_roots <- c(
  "\\.sb-card"
)

test_that("static card style tokens are defined on the app shell", {
  css <- shell_token_source_css()

  for (declaration in c(
    "--sb-font-heading: inherit;",
    "--sb-surface-padding: 1.5rem;",
    "--sb-surface-gap: 1.5rem;",
    "--sb-surface-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
  )) {
    expect_match(css, declaration, fixed = TRUE)
  }
})

test_that("runtime CSS selectors are scoped to shinyblocks roots", {
  selectors <- css_selectors(runtime_css())

  static_markup_prefix <- paste(static_markup_selector_roots, collapse = "|")
  static_markup_allowed <- paste0(
    # bare component selector, e.g. `.sb-card` / `.sb-card .sb-card-header`
    "^(", static_markup_prefix, ")|",
    # behind a dark-theme and/or style-profile ancestor attribute
    "^\\[data-theme=\"dark\"\\] (", static_markup_prefix, ")|",
    "^\\[data-sb-style=\"[^\"]+\"\\] (", static_markup_prefix, ")|",
    "^\\[data-theme=\"dark\"\\] \\[data-sb-style=\"[^\"]+\"\\] (",
    static_markup_prefix, ")"
  )

  allowed <- grepl(
    paste0(
      "^\\[data-shinyblocks-root\\]|",
      "^\\[data-shinyblocks-portal-root\\]|",
      "^:is\\(\\[data-shinyblocks-root\\],\\[data-shinyblocks-portal-root\\]\\)|",
      "^\\[data-theme=\"dark\"\\] \\[data-shinyblocks-root\\]|",
      "^\\[data-theme=\"dark\"\\] \\[data-shinyblocks-portal-root\\]|",
      # Style-profile-scoped component CSS (e.g. data-sb-style="luma"). Still
      # confined to shinyblocks roots; the profile attribute is an ancestor.
      "^\\[data-sb-style=\"[^\"]+\"\\] \\[data-shinyblocks-root\\]|",
      "^\\[data-sb-style=\"[^\"]+\"\\] \\[data-shinyblocks-portal-root\\]|",
      "^\\[data-theme=\"dark\"\\] \\[data-sb-style=\"[^\"]+\"\\] \\[data-shinyblocks-root\\]|",
      "^\\[data-theme=\"dark\"\\] \\[data-sb-style=\"[^\"]+\"\\] \\[data-shinyblocks-portal-root\\]|",
      static_markup_allowed, "|",
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
      "^\\.sb-nav-group\\b|",
      "^\\.sb-nav-group-trigger\\b|",
      "^\\.sb-nav-group-items\\b|",
      "^\\.sb-nav-section-label\\b|",
      "^\\.sb-body\\b|",
      "^\\.sb-stack\\b|",
      "^\\.sb-cluster\\b|",
      "^\\.sb-grid\\b|",
      "^\\.sb-layout-gap-\\b|",
      "^\\.sb-layout-align-\\b|",
      "^\\.sb-layout-justify-\\b|",
      "^\\.sb-icon\\b|",
      "^\\.sb-tabs\\b|",
      "^\\.sb-tabs-list\\b|",
      "^\\.sb-tabs-trigger\\b|",
      "^\\.sb-tabs-content\\b|",
      "^\\.sb-tabs-panel\\b|",
      "^\\.sb-accordion\\b|",
      "^\\.sb-field\\b|",
      "^\\.sb-field-group\\b|",
      "^\\.sb-field-label\\b|",
      "^\\.sb-field-legend\\b|",
      "^\\.sb-field-description\\b|",
      "^\\.sb-field-set\\b|",
      "^\\.sb-input-group\\b|",
      "^\\.sb-input-group-addon\\b|",
      "^\\.sb-breadcrumb\\b|",
      "^\\.sb-breadcrumb-list\\b|",
      "^\\.sb-breadcrumb-item\\b|",
      "^\\.sb-breadcrumb-link\\b|",
      "^\\.sb-breadcrumb-page\\b|",
      "^\\.sb-breadcrumb-text\\b|",
      "^\\.sb-breadcrumb-separator\\b|",
      "^\\.sb-breadcrumb-ellipsis\\b|",
      "^\\.sb-breadcrumb-sr-only\\b|",
      "^\\.sb-output-frame\\b"
    ),
    selectors
  )

  expect_identical(selectors[!allowed], character())
})

test_that("mobile sidebar establishes an explicit shell overlay stack", {
  css <- package_source_css()

  expect_match(
    css,
    '\\.sb-page\\[data-sidebar-enhanced="true"\\] \\.sb-sidebar \\{[\\s\\S]*z-index: 80;',
    perl = TRUE
  )
  expect_match(
    css,
    '\\.sb-page\\[data-sidebar-enhanced="true"\\] \\.sb-sidebar-backdrop \\{[\\s\\S]*z-index: 79;',
    perl = TRUE
  )
})

test_that("accordion collapse uses a grid-rows track with padding off the grid item", {
  css <- package_source_css()

  expect_match(
    css,
    "\\.sb-accordion-content \\{[^}]*grid-template-rows: 0fr;",
    perl = TRUE
  )
  expect_match(
    css,
    "\\.sb-accordion-content\\[data-state=\"open\"\\] \\{[^}]*grid-template-rows: 1fr;",
    perl = TRUE
  )
  expect_match(
    css,
    "\\.sb-accordion-content-inner \\{[^}]*overflow: hidden;",
    perl = TRUE
  )
  inner_block <- regmatches(
    css,
    regexpr("\\.sb-accordion-content-inner \\{[^}]*\\}", css, perl = TRUE)
  )
  expect_false(grepl("padding", inner_block))
  expect_match(
    css,
    "\\.sb-accordion-content-body \\{[^}]*padding-bottom: 1rem;",
    perl = TRUE
  )
})

test_that("sidebar collapsed styling is desktop-only", {
  css <- package_source_css()
  desktop_start <- regexpr(
    "@media \\(min-width: 768px\\) \\{",
    css,
    perl = TRUE
  )[[1]]
  mobile_start <- regexpr(
    "@media \\(max-width: 767px\\) \\{",
    css,
    perl = TRUE
  )[[1]]
  collapsed_start <- regexpr(
    '\\.sb-page\\[data-sidebar-enhanced="true"\\]\\[data-sidebar-collapsed="true"\\]',
    css,
    perl = TRUE
  )[[1]]

  expect_gt(desktop_start, 0)
  expect_gt(collapsed_start, desktop_start)
  expect_gt(mobile_start, collapsed_start)
})

test_that("nav group CSS keeps expansion state class-owned", {
  css <- package_source_css()

  expect_match(css, ".sb-nav-group-trigger", fixed = TRUE)
  expect_match(css, ".sb-nav-group-items", fixed = TRUE)
  expect_match(css, ".sb-nav-section-label", fixed = TRUE)
  expect_match(css, '.sb-nav-group-trigger[data-expanded="true"] > [data-icon="inline-end"]', fixed = TRUE)
  expect_match(css, "transform: rotate(90deg);", fixed = TRUE)
  expect_match(css, '.sb-page[data-sidebar-enhanced="true"][data-sidebar-collapsed="true"] .sb-nav-section-label', fixed = TRUE)
  expect_no_match(css, ".sb-nav-group-items[hidden]", fixed = TRUE)
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

test_that("responsive grid is protected against mobile overflow", {
  css <- package_source_css()
  css_flat <- gsub("[[:space:]]+", " ", css)

  # The track must cap each column at the container width so a wide
  # `--sb-grid-min` never forces a row wider than the viewport.
  expect_match(
    css_flat,
    "repeat(auto-fit, minmax(min(100%, var(--sb-grid-min)), 1fr))",
    fixed = TRUE
  )

  # Grid items default to `min-width: auto`; without this they refuse to shrink
  # below their content min-content size and overflow on narrow viewports.
  expect_match(
    css_flat,
    ".sb-grid > * { min-width: 0; }",
    fixed = TRUE
  )
})

test_that("horizontal tabs contain intrinsic-width labels on narrow screens", {
  css <- package_source_css()
  css_flat <- gsub("[[:space:]]+", " ", css)

  expect_match(
    css_flat,
    ".sb-tabs { @apply flex flex-col gap-2; min-width: 0; }",
    fixed = TRUE
  )
  expect_match(
    css_flat,
    paste(
      ".sb-tabs-list[data-orientation=\"horizontal\"] {",
      "max-width: 100%; justify-content: flex-start;",
      "overflow-x: auto; overflow-y: hidden; }"
    ),
    fixed = TRUE
  )
})

test_that("package theme aliases resolve inside the scoped app root", {
  css <- package_source_css()

  expect_match(css, "@theme inline {", fixed = TRUE)
})

test_that("runtime CSS does not reset all runtime children", {
  css <- runtime_css()

  expect_no_match(css, "[data-shinyblocks-root] *", fixed = TRUE)
  expect_no_match(css, "*::before", fixed = TRUE)
  expect_no_match(css, "*::after", fixed = TRUE)
})

test_that("shell reset targets owned classes instead of host descendants", {
  preflight <- preflight_source_css()
  shell <- package_source_css()

  expect_match(preflight, "[class^='sb-']", fixed = TRUE)
  expect_no_match(preflight, ".sb-app *", fixed = TRUE)
  expect_no_match(preflight, ".sb-app h1", fixed = TRUE)
  expect_no_match(preflight, ".sb-app button", fixed = TRUE)
  expect_no_match(preflight, ".sb-app img", fixed = TRUE)
  expect_no_match(
    shell,
    ".sb-app :where(input, select, textarea, button, a):focus",
    fixed = TRUE
  )
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
