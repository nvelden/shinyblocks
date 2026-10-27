# Multi-artifact coverage tests. Whenever a new block_*() is exported,
# the same commit must update every artifact that documents it. A green test
# here is a necessary (not sufficient) condition for a phase exit.

repo_root <- function() {
  testthat::test_path("..", "..")
}

block_exports <- function() {
  sort(grep("^block_", getNamespaceExports("shinyblocks"), value = TRUE))
}

docs_api_block_names <- function() {
  path <- file.path(repo_root(), "docs-site", "lib", "api-reference.ts")
  if (!file.exists(path)) {
    skip("docs-site API reference is repo-only and absent from the package build")
  }

  text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  matches <- regmatches(
    text,
    gregexpr('name: "block_[a-z0-9_]+"', text, perl = TRUE)
  )[[1]]
  sort(unique(sub('"$', "", sub('^name: "', "", matches))))
}

test_that("every exported block_*() appears in the docs-site API reference", {
  documented <- docs_api_block_names()
  exported <- block_exports()

  missing <- setdiff(exported, documented)
  expect_identical(
    missing,
    character(),
    label = paste(
      "Components exported but absent from docs-site/lib/api-reference.ts.",
      "Add each name under the matching component slug.",
      "Missing:",
      paste(missing, collapse = ", ")
    )
  )

  stale <- setdiff(documented, exported)
  expect_identical(
    stale,
    character(),
    label = paste(
      "The docs-site API reference names components that are not exported.",
      "Remove the entry or restore the export.",
      "Stale:",
      paste(stale, collapse = ", ")
    )
  )
})

spec_path <- function(fn_name) {
  slug <- gsub("_", "-", sub("^block_", "", fn_name))
  file.path(repo_root(), "docs", "component-specs", paste0(slug, ".md"))
}

test_that("every exported block_*() has a component spec doc", {
  if (!dir.exists(file.path(repo_root(), "docs", "component-specs"))) {
    skip("component specs are repo-only and not present in R CMD check build")
  }

  exported <- block_exports()

  missing <- exported[!vapply(exported, function(fn) {
    file.exists(spec_path(fn))
  }, logical(1))]

  expect_identical(
    missing,
    character(),
    label = paste(
      "Components exported but missing a spec under",
      "docs/component-specs/. Each new block_*() must ship with a",
      "component contract. Missing:",
      paste(missing, collapse = ", ")
    )
  )
})

test_that("docs-site playground icon names are vendored", {
  docs_site <- file.path(repo_root(), "docs-site")
  if (!dir.exists(docs_site)) {
    skip("docs-site is repo-only and not present in R CMD check build")
  }

  files <- list.files(
    docs_site,
    pattern = "\\.R$",
    recursive = TRUE,
    full.names = TRUE
  )
  lines <- unlist(lapply(files, readLines, warn = FALSE), use.names = FALSE)
  matches <- regmatches(
    lines,
    gregexpr("icon\\s*=\\s*\"[a-z0-9-]+\"", lines, perl = TRUE)
  )
  icon_names <- sort(unique(sub(
    ".*\"([a-z0-9-]+)\"$",
    "\\1",
    unlist(matches, use.names = FALSE)
  )))

  missing <- setdiff(icon_names, shinyblocks:::shinyblocks_icon_names())
  expect_identical(
    missing,
    character(),
    label = paste(
      "docs-site playgrounds reference icons absent from",
      "inst/www/icons/MANIFEST.json:",
      paste(missing, collapse = ", ")
    )
  )
})
