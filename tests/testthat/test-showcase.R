# The showcase is a development-only asset: it lives in the source tree but is
# excluded from the built package tarball (see .Rbuildignore). These tests guard
# it when run from a source checkout (devtools::test()); under R CMD check, where
# the installed package has no showcase, they skip instead of erroring.
skip_if_no_showcase <- function() {
  if (!nzchar(system.file("showcase", package = "shinyblocks"))) {
    testthat::skip("showcase is a dev-only asset, excluded from the built package")
  }
}

source_showcase <- function() {
  app_file <- system.file("showcase", "app.R", package = "shinyblocks")
  env <- new.env(parent = globalenv())
  source(app_file, local = env, chdir = TRUE)
  env
}

showcase_fixture <- local({
  fixture <- NULL

  function() {
    if (is.null(fixture)) {
      env <- source_showcase()
      rendered <- htmltools::renderTags(env$ui)
      fixture <<- list(
        env = env,
        rendered = rendered,
        head = paste(rendered$head, collapse = "\n"),
        html = paste(rendered$html, collapse = "\n")
      )
    }

    fixture
  }
})

# Functions whose markup is emitted transitively by another exported
# component (block_body via block_page) and therefore not expected as a
# standalone showcase section. They still appear in the rendered HTML
# via their parent — see the class-coverage test below.
#
# Also excludes non-rendering discovery helpers:
#   - block_theme_presets / block_style_profiles return character vectors and
#     emit no markup of their own.
# block_style is now surfaced in the Theme showcase (style-profile selector plus
# a Luma parity fixture), so it is no longer excluded.
showcase_internal <- c(
  "block_theme_presets",
  "block_style_profiles"
)

block_class_for <- function(fn_name) {
  gsub("_", "-", sub("^block_", "sb-", fn_name))
}

test_that("every showcase example evaluates to a tag", {
  skip_if_no_showcase()

  showcase_dir <- system.file(
    "showcase",
    package = "shinyblocks",
    mustWork = TRUE
  )
  helpers_env <- new.env(parent = globalenv())
  source(file.path(showcase_dir, "R", "render_example.R"), local = helpers_env)

  example_files <- list.files(
    file.path(showcase_dir, "R", "examples"),
    pattern = "\\.R$",
    full.names = TRUE
  )

  expect_gt(length(example_files), 0)

  for (path in example_files) {
    code <- readLines(path, warn = FALSE)
    result <- tryCatch(
      eval(parse(text = code), envir = new.env(parent = helpers_env)),
      error = function(e) {
        fail(sprintf(
          "Example %s failed to evaluate: %s",
          basename(path),
          conditionMessage(e)
        ))
        NULL
      }
    )

    expect_true(
      inherits(result, "shiny.tag") || inherits(result, "shiny.tag.list"),
      label = sprintf(
        "%s returned a %s, not a shiny.tag/shiny.tag.list",
        basename(path),
        paste(class(result), collapse = "/")
      )
    )
  }
})

test_that("showcase declares a sections list and renders each one", {
  skip_if_no_showcase()

  fixture <- showcase_fixture()
  env <- fixture$env

  expect_true(is.list(env$sections))
  expect_gt(length(env$sections), 0)

  required_fields <- c("id", "label", "icon", "title", "lead", "file")
  for (s in env$sections) {
    expect_true(
      all(required_fields %in% names(s)),
      label = sprintf(
        "section %s missing fields: %s",
        s$id %||% "<unnamed>",
        paste(setdiff(required_fields, names(s)), collapse = ", ")
      )
    )
  }

  rendered <- fixture$html

  for (s in env$sections) {
    expect_match(
      rendered,
      sprintf('data-sb-section="%s"', s$id),
      fixed = TRUE,
      label = sprintf("section %s missing data-sb-section marker", s$id)
    )
    expect_match(
      rendered,
      sprintf('href="#%s"', s$id),
      fixed = TRUE,
      label = sprintf("sidebar nav link for %s missing", s$id)
    )
  }
})

test_that("showcase owns its theme in the page head and renders one body landmark", {
  skip_if_no_showcase()

  fixture <- showcase_fixture()
  head <- fixture$head
  html <- fixture$html

  expect_match(head, 'href="showcase.css?v=20260708_accordion"', fixed = TRUE)
  body_matches <- regmatches(
    html,
    gregexpr('<main class="sb-body"', html, fixed = TRUE)
  )[[1L]]

  expect_length(body_matches, 1L)
  expect_false(grepl("<head>", html, fixed = TRUE))
})

test_that("showcase styling controls have matching CSS hooks", {
  skip_if_no_showcase()

  css_file <- system.file(
    "showcase",
    "www",
    "showcase.css",
    package = "shinyblocks",
    mustWork = TRUE
  )
  css <- paste(readLines(css_file, warn = FALSE), collapse = "\n")

  expect_match(
    css,
    ".sb-radio-group-control.showcase-radio-group-preview-custom",
    fixed = TRUE
  )
})

test_that("alert-dialog docs playground stays in sync with the showcase contract", {
  docs_app <- testthat::test_path(
    "..", "..", "docs-site", "playgrounds", "alert-dialog", "app.R"
  )
  if (!file.exists(docs_app)) {
    testthat::skip("docs-site source is repo-only and not present in R CMD check")
  }

  source <- paste(readLines(docs_app, warn = FALSE), collapse = "\n")
  required_markers <- c(
    "showcase_alert_dialog_title",
    "showcase_alert_dialog_description",
    "showcase_alert_dialog_confirm_label",
    "showcase_alert_dialog_cancel_label",
    "showcase_alert_dialog_trigger",
    "showcase_alert_dialog_variant",
    "showcase_alert_dialog_open",
    "showcase_alert_dialog_close",
    "showcase_alert_dialog_size",
    "showcase_alert_dialog_style",
    "showcase_alert_dialog_class",
    "showcase_alert_dialog_preview_ui",
    "showcase_alert_dialog_value",
    "showcase_alert_dialog_code",
    "showcase_alert_dialog_server_code"
  )

  for (marker in required_markers) {
    expect_match(source, marker, fixed = TRUE)
  }
  expect_match(
    source,
    'class = c("sb-parity-alert-dialog", custom_class)',
    fixed = TRUE
  )
  expect_match(
    source,
    'class = "showcase-dialog-preview-custom"',
    fixed = TRUE
  )
})

test_that("layout showcase preview uses real collapsed sidebar hooks", {
  skip_if_no_showcase()

  server_file <- system.file(
    "showcase",
    "R",
    "server_layout.R",
    package = "shinyblocks",
    mustWork = TRUE
  )
  source <- paste(readLines(server_file, warn = FALSE), collapse = "\n")

  expect_match(source, 'class = "sb-page has-sidebar"', fixed = TRUE)
  expect_match(source, '`data-sidebar-enhanced` = "true"', fixed = TRUE)
  expect_match(
    source,
    '`data-sidebar-collapsed` = tolower(as.character(collapsed))',
    fixed = TRUE
  )
  expect_match(source, 'class = "sb-sidebar-title"', fixed = TRUE)
  expect_match(source, 'class = "sb-sidebar-title-text"', fixed = TRUE)
  expect_match(source, 'if (collapsed) "4.5rem" else "200px"', fixed = TRUE)
  expect_false(
    grepl(
      'if (!collapsed) htmltools::tags$span',
      source,
      fixed = TRUE
    )
  )
})

test_that("showcase icon references are vendored", {
  skip_if_no_showcase()

  showcase_dir <- system.file(
    "showcase",
    package = "shinyblocks",
    mustWork = TRUE
  )
  files <- list.files(
    file.path(showcase_dir, "R"),
    pattern = "\\.R$",
    recursive = TRUE,
    full.names = TRUE
  )
  text <- paste(unlist(lapply(files, readLines, warn = FALSE)), collapse = "\n")

  icon_arg_matches <- regmatches(
    text,
    gregexpr("icon\\s*=\\s*\"[a-z0-9-]+\"", text, perl = TRUE)
  )[[1L]]
  icon_arg_names <- sub(".*\"([a-z0-9-]+)\"$", "\\1", icon_arg_matches)

  doc_icon_controls <- regmatches(
    text,
    gregexpr(
      "block_select\\(\\s*\"[^\"]*_doc_icon\"[\\s\\S]*?choices\\s*=\\s*c\\([^)]*\\)",
      text,
      perl = TRUE
    )
  )[[1L]]
  doc_icon_names <- unlist(regmatches(
    doc_icon_controls,
    gregexpr("\"[a-z0-9-]+\"", doc_icon_controls, perl = TRUE)
  ), use.names = FALSE)
  doc_icon_names <- gsub("\"", "", doc_icon_names, fixed = TRUE)

  icon_names <- sort(unique(setdiff(
    c(icon_arg_names, doc_icon_names),
    "none"
  )))
  missing <- setdiff(icon_names, shinyblocks:::shinyblocks_icon_names())

  expect_identical(
    missing,
    character(),
    label = paste(
      "showcase examples reference icons absent from",
      "inst/www/icons/MANIFEST.json:",
      paste(missing, collapse = ", ")
    )
  )
})

test_that("every exported block_*() renders into the showcase UI", {
  skip_if_no_showcase()

  fixture <- showcase_fixture()
  rendered <- fixture$html

  exported <- getNamespaceExports("shinyblocks")
  components <- setdiff(
    grep("^block_", exported, value = TRUE),
    showcase_internal
  )

  expect_gt(length(components), 0)

  missing <- character()
  for (fn in components) {
    cls <- block_class_for(fn)
    component <- sub("^block_", "", fn)
    has_class <- grepl(sprintf('class="[^"]*\\b%s\\b', cls), rendered, perl = TRUE) ||
      grepl(cls, rendered, fixed = TRUE)
    runtime_name <- gsub("_", "-", component)
    has_runtime <- grepl(
      sprintf('data-sb-component="%s"', runtime_name),
      rendered,
      fixed = TRUE
    )
    if (!has_class && !has_runtime) {
      missing <- c(missing, sprintf("%s (.%s)", fn, cls))
    }
  }

  expect_identical(
    missing,
    character(),
    label = paste(
      "Components exported but not rendered in inst/showcase/.",
      "Add an example in inst/showcase/R/examples/<name>.R and a row to",
      "the sections list in inst/showcase/app.R. Missing:",
      paste(missing, collapse = ", ")
    )
  )
})

test_that("only the first showcase section is initially visible", {
  skip_if_no_showcase()

  fixture <- showcase_fixture()
  env <- fixture$env
  rendered <- fixture$html

  first_id <- env$sections[[1L]]$id

  # The first section has no `hidden` attribute…
  expect_match(
    rendered,
    sprintf(
      '<section[^>]*id="%s"[^>]*data-sb-section="%s"(?![^>]*hidden)',
      first_id,
      first_id
    ),
    perl = TRUE,
    label = sprintf("first section %s should not be hidden", first_id)
  )

  # …and every other section does.
  for (s in env$sections[-1L]) {
    expect_match(
      rendered,
      sprintf(
        '<section[^>]*id="%s"[^>]*data-sb-section="%s"[^>]*hidden',
        s$id,
        s$id
      ),
      perl = TRUE,
      label = sprintf("non-first section %s should be hidden by default", s$id)
    )
  }
})

test_that("theme showcase overrides are scoped to the preview wrapper", {
  skip_if_no_showcase()

  rendered <- showcase_fixture()$html

  expect_match(
    rendered,
    'data-sb-preview="theme"',
    fixed = TRUE
  )
  expect_match(
    rendered,
    'id="showcase_theme_doc_preset"',
    fixed = TRUE
  )
  # The parity fixture scopes its override to its own wrapper (not the
  # section-wide [data-sb-preview="theme"]), so it cannot bleed into the live
  # demo preview that also lives inside the Theme section.
  expect_match(
    rendered,
    ".sb-parity-theme-baseline{--accent: oklch(0.3 0.03 260);--radius: 0.5rem;}",
    fixed = TRUE
  )
  expect_false(grepl(
    "\\.sb-app\\{--accent: oklch\\(0\\.3 0\\.03 260\\)",
    rendered
  ))
  # And it must not leak to the whole section either.
  expect_false(grepl(
    '\\[data-sb-preview="theme"\\]\\{--accent: oklch\\(0\\.3 0\\.03 260\\)',
    rendered
  ))
})

test_that("interactive sections use the full playground layout", {
  skip_if_no_showcase()

  env <- showcase_fixture()$env
  section_map <- stats::setNames(env$sections, vapply(env$sections, `[[`, "", "id"))
  interactive_contract <- list(
    button = list(require_actions = FALSE),
    select = list(require_actions = TRUE),
    dialog = list(require_actions = TRUE),
    popover = list(require_actions = TRUE),
    checkbox = list(require_actions = TRUE)
  )

  required_labels <- c(
    "Interactive Playground",
    "UI Definition",
    "Server Action",
    "Content",
    "State",
    "Styling",
    "API Reference"
  )

  for (id in names(interactive_contract)) {
    section <- section_map[[id]]
    expect_false(is.null(section), label = sprintf("missing section id: %s", id))

    example_path <- file.path(
      system.file("showcase", package = "shinyblocks", mustWork = TRUE),
      "R",
      "examples",
      section$file
    )
    code <- readLines(example_path, warn = FALSE)
    helpers_env <- new.env(parent = globalenv())
    source(
      file.path(system.file("showcase", package = "shinyblocks", mustWork = TRUE), "R", "render_example.R"),
      local = helpers_env
    )
    example_tag <- eval(parse(text = code), envir = new.env(parent = helpers_env))
    html <- paste(htmltools::renderTags(example_tag)$html, collapse = "\n")

    for (label in required_labels) {
      expect_match(
        html,
        label,
        fixed = TRUE,
        label = sprintf("section '%s' missing playground label '%s'", id, label)
      )
    }

    if (isTRUE(interactive_contract[[id]]$require_actions)) {
      expect_match(
        html,
        "Actions (Server Update)",
        fixed = TRUE,
        label = sprintf("section '%s' missing playground label 'Actions (Server Update)'", id)
      )
    }
  }
})

test_that("layout primitives showcase documents all helpers and parity fixtures", {
  skip_if_no_showcase()

  fixture <- showcase_fixture()
  rendered <- fixture$html

  expect_match(rendered, 'data-sb-section="layout-primitives"', fixed = TRUE)
  for (name in c("block_stack", "block_cluster", "block_grid")) {
    expect_match(rendered, name, fixed = TRUE)
  }
  for (class in c(
    "sb-parity-stack-default",
    "sb-parity-cluster-default",
    "sb-parity-grid-default"
  )) {
    expect_match(rendered, class, fixed = TRUE)
  }

  for (label in c("Primitive", "Cross-axis alignment")) {
    expect_match(rendered, label, fixed = TRUE)
  }

  grid_values <- list(
    type = "grid",
    gap = "md",
    align = "start",
    justify = "start",
    wrap = TRUE,
    min_width = "14rem",
    count = 2L,
    vary_heights = TRUE
  )
  grid_specs <- fixture$env$layout_primitives_demo_specs(grid_values)
  grid_code <- fixture$env$layout_primitives_demo_code(grid_values, grid_specs)

  expect_length(grid_specs, 2L)
  expect_match(grid_code, 'min_width = "14rem"', fixed = TRUE)
  expect_match(grid_code, 'style = "min-height: 8rem;"', fixed = TRUE)
  expect_match(grid_code, 'style = "min-height: 14rem;"', fixed = TRUE)
  expect_equal(
    lengths(regmatches(grid_code, gregexpr("block_card\\(", grid_code))),
    2L
  )
  expect_silent(parse(text = grid_code))

  cluster_values <- grid_values
  cluster_values$type <- "cluster"
  cluster_code <- fixture$env$layout_primitives_demo_code(
    cluster_values,
    fixture$env$layout_primitives_demo_specs(cluster_values)
  )
  expect_match(cluster_code, 'style = "min-height: 16rem;"', fixed = TRUE)
  expect_match(cluster_code, 'justify = "start"', fixed = TRUE)
  expect_silent(parse(text = cluster_code))
})
