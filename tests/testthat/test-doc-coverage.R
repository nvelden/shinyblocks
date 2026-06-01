# Multi-artifact coverage tests. Whenever a new block_*() is exported,
# the same commit must update every artifact that documents it. The
# ROADMAP's gate-exit rule mirrors these tests; a green test here is a
# necessary (not sufficient) condition for a phase exit.

repo_root <- function() {
  testthat::test_path("..", "..")
}

read_pkgdown_yml <- function() {
  path <- file.path(repo_root(), "_pkgdown.yml")
  if (!file.exists(path)) {
    skip(sprintf("_pkgdown.yml missing at %s", path))
  }
  readLines(path, warn = FALSE)
}

block_exports <- function() {
  sort(grep("^block_", getNamespaceExports("shinyblocks"), value = TRUE))
}

extract_yml_block_names <- function(lines) {
  hits <- grep("^\\s*-\\s+block_[a-z_]+\\s*$", lines, value = TRUE)
  unique(trimws(sub("^\\s*-\\s+", "", hits)))
}

test_that("every exported block_*() appears in _pkgdown.yml reference", {
  yml <- read_pkgdown_yml()
  in_yml <- extract_yml_block_names(yml)
  exported <- block_exports()

  missing <- setdiff(exported, in_yml)
  expect_identical(
    missing,
    character(),
    label = paste(
      "Components exported but absent from _pkgdown.yml.",
      "Add each name under the matching `reference:` group.",
      "Missing:",
      paste(missing, collapse = ", ")
    )
  )

  stale <- setdiff(in_yml, exported)
  expect_identical(
    stale,
    character(),
    label = paste(
      "_pkgdown.yml references components that are not exported.",
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
      "spec per ADR 0015. Missing:",
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
