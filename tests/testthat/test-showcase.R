source_showcase <- function() {
  app_file <- system.file("showcase", "app.R", package = "shinyblocks")
  env <- new.env(parent = globalenv())
  source(app_file, local = env, chdir = TRUE)
  env
}

# Functions whose markup is emitted transitively by another exported
# component (block_body via block_page) and therefore not expected as a
# standalone showcase section. They still appear in the rendered HTML
# via their parent — see the class-coverage test below.
showcase_internal <- character()

block_class_for <- function(fn_name) {
  gsub("_", "-", sub("^block_", "sb-", fn_name))
}

test_that("every showcase example evaluates to a tag", {
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
  env <- source_showcase()

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

  rendered <- paste(htmltools::renderTags(env$ui)$html, collapse = "\n")

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
  env <- source_showcase()
  rendered <- htmltools::renderTags(env$ui)
  head <- paste(rendered$head, collapse = "\n")
  html <- paste(rendered$html, collapse = "\n")

  expect_match(head, 'href="showcase.css?v=20260601_01"', fixed = TRUE)
  body_matches <- regmatches(
    html,
    gregexpr('<main class="sb-body">', html, fixed = TRUE)
  )[[1L]]

  expect_length(body_matches, 1L)
  expect_false(grepl("<head>", html, fixed = TRUE))
})

test_that("showcase styling controls have matching CSS hooks", {
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

test_that("every exported block_*() renders into the showcase UI", {
  env <- source_showcase()
  rendered <- paste(htmltools::renderTags(env$ui)$html, collapse = "\n")

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
  env <- source_showcase()
  rendered <- paste(htmltools::renderTags(env$ui)$html, collapse = "\n")

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
  env <- source_showcase()
  rendered <- paste(htmltools::renderTags(env$ui)$html, collapse = "\n")

  expect_match(
    rendered,
    'data-sb-preview="theme"',
    fixed = TRUE
  )
  expect_match(
    rendered,
    paste0(
      '[data-sb-preview="theme"]{',
      "--accent: oklch(0.3 0.03 260);--radius: 0.5rem;}"
    ),
    fixed = TRUE
  )
  expect_false(grepl(
    "\\.sb-app\\{--accent: oklch\\(0\\.3 0\\.03 260\\)",
    rendered
  ))
})

test_that("interactive sections use the full playground layout", {
  env <- source_showcase()
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
