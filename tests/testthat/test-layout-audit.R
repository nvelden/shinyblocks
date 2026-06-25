# Fixture tests for tools/check-example-layout-primitives.R. They run the real
# script against a temporary scan root so the per-declaration detection and the
# allowlist behaviour are exercised end to end.

audit_script <- normalizePath(
  testthat::test_path("..", "..", "tools", "check-example-layout-primitives.R"),
  mustWork = FALSE
)

run_audit <- function(root, strict = TRUE) {
  skip_if_not(file.exists(audit_script), "audit script not found")
  rscript <- file.path(R.home("bin"), "Rscript")
  out <- suppressWarnings(system2(
    rscript,
    c(shQuote(audit_script), if (strict) "--strict"),
    stdout = TRUE, stderr = TRUE,
    env = paste0("SHINYBLOCKS_LAYOUT_AUDIT_ROOTS=", root)
  ))
  list(status = attr(out, "status") %||% 0L, output = paste(out, collapse = "\n"))
}

`%||%` <- function(a, b) if (is.null(a)) b else a

test_that("strict audit flags an extra layout declaration sharing a line", {
  # The mixed line carries a benign property plus two layout declarations; a
  # per-line allowlist would have masked them. Nothing here is allowlisted.
  root <- withr::local_tempdir()
  writeLines(c(
    'htmltools::div(',
    '  style = "padding: 1rem; display: flex; gap: 0.5rem;",',
    '  "x"',
    ')'
  ), file.path(root, "app.R"))
  res <- run_audit(root)
  expect_identical(res$status, 1L)
  expect_match(res$output, "display: flex", fixed = TRUE)
  expect_match(res$output, "gap: 0.5rem", fixed = TRUE)
})

test_that("strict audit catches standalone display:inline-flex and inline-grid", {
  root <- withr::local_tempdir()
  writeLines(c(
    'a <- htmltools::div(style = "display: inline-flex")',
    'b <- htmltools::div(style = "display: inline-grid")'
  ), file.path(root, "app.R"))
  res <- run_audit(root)
  expect_identical(res$status, 1L)
  expect_match(res$output, "display: inline-flex", fixed = TRUE)
  expect_match(res$output, "display: inline-grid", fixed = TRUE)
})

test_that("clean fixture passes in strict mode", {
  root <- withr::local_tempdir()
  writeLines(c(
    'block_cluster(gap = "sm", block_button("Go"))',
    'htmltools::div(style = "padding: 1rem; color: red;", "ok")'
  ), file.path(root, "app.R"))
  res <- run_audit(root)
  expect_identical(res$status, 0L)
  expect_match(res$output, "audit passed", fixed = TRUE)
})
