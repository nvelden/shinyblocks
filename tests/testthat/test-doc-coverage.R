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
  gallery_dir <- file.path(repo_root(), "gallery", "components")
  pages <- sub("\\.qmd$", "", list.files(gallery_dir, pattern = "\\.qmd$"))

  expected_slugs <- gsub("_", "-", sub("^block_", "", exported))
  missing <- setdiff(expected_slugs, pages)

  expect_identical(
    missing,
    character(),
    label = paste(
      "Components exported but missing a gallery page under",
      "gallery/components/. Missing:",
      paste(missing, collapse = ", ")
    )
  )
})

# Components currently without a docs/component-specs/<name>.md spec.
# Each entry must come paired with a written spec (and a captured
# reference screenshot) before being removed from this list. See
# ADR 0015 and docs/component-specs/README.md for the authoring flow.
# When this list is empty, drop it and the test enforces specs
# unconditionally for every export.
backfill_pending_specs <- c(
  "block_alert",
  "block_alert_description",
  "block_alert_title",
  "block_badge",
  "block_body",
  "block_card_content",
  "block_card_description",
  "block_card_footer",
  "block_card_header",
  "block_card_title",
  "block_empty",
  "block_field",
  "block_field_description",
  "block_field_group",
  "block_field_invalid",
  "block_field_label",
  "block_field_legend",
  "block_field_set",
  "block_header",
  "block_icon",
  "block_input_group",
  "block_input_group_addon",
  "block_nav",
  "block_nav_item",
  "block_page",
  "block_select",
  "block_separator",
  "block_sidebar",
  "block_skeleton",
  "block_spinner",
  "block_value_box"
)

spec_path <- function(fn_name) {
  slug <- gsub("_", "-", sub("^block_", "", fn_name))
  file.path(repo_root(), "docs", "component-specs", paste0(slug, ".md"))
}

test_that("every exported block_*() has a component spec doc", {
  exported <- block_exports()

  required <- setdiff(exported, backfill_pending_specs)
  expect_gt(
    length(required),
    0,
    label = paste(
      "No components require a spec. Either backfill_pending_specs",
      "is wrong or every component has been backfilled — if the",
      "latter, drop the allowlist (see ADR 0015)."
    )
  )

  missing <- required[!vapply(required, function(fn) {
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

test_that("backfill_pending_specs stays honest about what is missing", {
  drift <- intersect(
    backfill_pending_specs,
    Filter(function(fn) file.exists(spec_path(fn)), block_exports())
  )

  expect_identical(
    drift,
    character(),
    label = paste(
      "These components have a spec but are still listed in",
      "backfill_pending_specs. Remove them from the list in",
      "tests/testthat/test-doc-coverage.R so the gap stays honest:",
      paste(drift, collapse = ", ")
    )
  )
})
