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

test_that("every exported block_*() has a gallery .qmd page", {
  # The gallery is on hold pending shinyblocks publication to
  # repo.r-wasm.org (see ADR 0013 / the path-B WASM work). Once that
  # lands, drop the skip() and require a page per component.
  skip("Gallery pages blocked on WASM resolution; see ADR 0013.")

  exported <- block_exports()
  gallery_dir <- file.path(
    repo_root(),
    "vignettes",
    "articles",
    "components"
  )
  pages <- sub("\\.qmd$", "", list.files(gallery_dir, pattern = "\\.qmd$"))

  expected_slugs <- gsub("_", "-", sub("^block_", "", exported))
  missing <- setdiff(expected_slugs, pages)

  expect_identical(
    missing,
    character(),
    label = paste(
      "Components exported but missing a gallery page under",
      "vignettes/articles/components/. Missing:",
      paste(missing, collapse = ", ")
    )
  )
})
