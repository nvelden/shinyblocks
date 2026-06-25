#!/usr/bin/env Rscript

# Static layout-primitive audit.
#
# Flags new hand-authored generic flex/grid layout in app-author-facing example
# code (showcase examples, docs-site playgrounds + previews, README, templates).
# Ordinary `display:flex` / direction / wrap / gap / alignment / auto-fit grid
# layout must be expressed through block_stack() / block_cluster() / block_grid()
# instead of inline CSS.
#
# Detection is *per declaration*: each line is split on `;` and every declaration
# is matched independently, so an extra layout declaration sharing a line with an
# allowlisted one cannot slip through.
#
# Modes:
#   - warn-only (default): prints every un-allowlisted declaration and exits 0.
#   - strict (`--strict` or SHINYBLOCKS_LAYOUT_AUDIT_STRICT=true): exits 1 on any
#     un-allowlisted declaration.
#
# Allowlist policy (mirrors tools/check-legacy-audit.R): each entry pins a
# specific file *and* a specific declaration pattern with a rationale. Entries
# match individual declarations, never whole lines, files, or directories.

args <- commandArgs(trailingOnly = TRUE)
strict <- "--strict" %in% args ||
  identical(tolower(Sys.getenv("SHINYBLOCKS_LAYOUT_AUDIT_STRICT")), "true")

# Default scan roots. Overridable (path-separator list) only for the audit's own
# fixture tests; production runs always use the defaults below.
roots_override <- Sys.getenv("SHINYBLOCKS_LAYOUT_AUDIT_ROOTS")
roots <- if (nzchar(roots_override)) {
  strsplit(roots_override, .Platform$path.sep, fixed = TRUE)[[1]]
} else {
  c(
    "inst/showcase/R/examples",
    "docs-site/playgrounds",
    "docs-site/content/previews",
    "README.md",
    "inst/templates"
  )
}

patterns <- c(
  "display\\s*:\\s*(inline-)?flex",
  "display\\s*:\\s*(inline-)?grid",
  "flex-direction\\s*:",
  "flex-wrap\\s*:",
  "(^|[;\"'[:space:]])gap\\s*:",
  "row-gap\\s*:",
  "column-gap\\s*:",
  "grid-template-columns\\s*:",
  "align-items\\s*:",
  "justify-content\\s*:"
)

# Narrow fixed-geometry exceptions: file pattern + *declaration* pattern + reason.
# Each row allows one CSS declaration in one file. Reasons are grouped per file.
allow <- function(path, decls, reason) {
  data.frame(
    path = path, pattern = decls, reason = reason, stringsAsFactors = FALSE
  )
}

allowlist <- rbind(
  allow(
    "docs-site/playgrounds/code/app\\.R$",
    "display\\s*:\\s*flex",
    "Literal CSS inside the Code component's syntax-highlight sample, not layout."
  ),
  allow(
    "docs-site/playgrounds/dialog/app\\.R$",
    c("display\\s*:\\s*flex", "flex-direction\\s*:\\s*column", "gap\\s*:\\s*1rem"),
    "Reproduces the .sb-dialog-content data-slot DOM mock (component-internal geometry)."
  ),
  allow(
    "docs-site/playgrounds/layout/app\\.R$",
    c(
      "display\\s*:\\s*flex", "flex-direction\\s*:\\s*column",
      "display\\s*:\\s*inline-flex", "align-items\\s*:\\s*center",
      "justify-content\\s*:\\s*center", "display\\s*:\\s*grid",
      "grid-template-columns\\s*:\\s*repeat\\(2, 1fr\\)", "gap\\s*:\\s*0\\.75rem"
    ),
    "Fixed-geometry app-shell illustration (300px frame, animated sidebar column, flush main column, centered avatar glyph, fixed 2-track metrics grid)."
  ),
  allow(
    "docs-site/playgrounds/theme/app\\.R$",
    c(
      "display\\s*:\\s*grid",
      "grid-template-columns\\s*:\\s*repeat\\(2, minmax\\(0, 1fr\\)\\)",
      "gap\\s*:\\s*0\\.75rem"
    ),
    "Fixed two-column swatch grid; block_grid() is auto-fit, not a 2-track grid."
  ),
  allow(
    "docs-site/playgrounds/toast/app\\.R$",
    c(
      "display\\s*:\\s*grid", "grid-template-columns\\s*:\\s*auto minmax\\(0, 1fr\\)",
      "column-gap\\s*:\\s*0\\.75rem", "display\\s*:\\s*flex",
      "align-items\\s*:\\s*flex-start", "flex-direction\\s*:\\s*column",
      "gap\\s*:\\s*0\\.25rem"
    ),
    "Reproduces the .sb-toast surface DOM mock (icon/content slots, auto+minmax grid)."
  ),
  allow(
    "docs-site/content/previews/dialog\\.R$",
    "gap\\s*:\\s*1rem",
    "Reproduces the .sb-dialog-content data-slot DOM mock (overlay positioning neutralised)."
  ),
  allow(
    "docs-site/content/previews/style\\.R$",
    c(
      "display\\s*:\\s*flex", "flex-direction\\s*:\\s*column", "gap\\s*:\\s*0\\.75rem",
      "align-items\\s*:\\s*center", "justify-content\\s*:\\s*center"
    ),
    "Two-axis-centered style preview canvas; block_stack has no main-axis justify."
  ),
  allow(
    "docs-site/content/previews/theme\\.R$",
    c(
      "display\\s*:\\s*flex", "flex-direction\\s*:\\s*column",
      "align-items\\s*:\\s*center", "justify-content\\s*:\\s*center"
    ),
    "Two-axis-centered theme preview canvas; block_stack has no main-axis justify."
  )
)

files <- unlist(lapply(roots, function(root) {
  if (dir.exists(root)) {
    list.files(root, recursive = TRUE, full.names = TRUE)
  } else if (file.exists(root)) {
    root
  } else {
    character()
  }
}), use.names = FALSE)
files <- files[grepl("\\.(R|Rmd|md)$", files, ignore.case = TRUE)]

matches_pattern <- function(text) {
  any(vapply(patterns, grepl, logical(1), x = text, ignore.case = TRUE, perl = TRUE))
}

hits <- list()
for (path in files) {
  lines <- readLines(path, warn = FALSE)
  for (i in seq_along(lines)) {
    # Split into individual declarations so each is judged on its own.
    decls <- strsplit(lines[[i]], ";", fixed = TRUE)[[1]]
    for (decl in decls) {
      decl <- trimws(decl)
      if (nzchar(decl) && matches_pattern(decl)) {
        hits[[length(hits) + 1]] <- list(path = path, line = i, decl = decl)
      }
    }
  }
}

if (!length(hits)) {
  cat("Layout primitive audit passed: no generic inline layout declarations found.\n")
  quit(save = "no", status = 0)
}

is_allowed <- function(hit) {
  any(vapply(seq_len(nrow(allowlist)), function(j) {
    grepl(allowlist$path[[j]], hit$path, perl = TRUE) &&
      grepl(allowlist$pattern[[j]], hit$decl, ignore.case = TRUE, perl = TRUE)
  }, logical(1)))
}

allowed <- vapply(hits, is_allowed, logical(1))
unexpected <- hits[!allowed]
fmt <- function(h) sprintf("%s:%d: %s", h$path, h$line, h$decl)

if (length(unexpected)) {
  cat(sprintf(
    "Layout primitive audit found %d un-allowlisted declaration(s)%s:\n\n",
    length(unexpected),
    if (strict) "" else " (warn-only)"
  ))
  cat(paste(vapply(unexpected, fmt, character(1)), collapse = "\n"), "\n")
  if (strict) {
    cat("\nMigrate to block_stack()/block_cluster()/block_grid(), or add a narrow\n")
    cat("file+declaration entry to the allowlist in tools/check-example-layout-primitives.R.\n")
    quit(save = "no", status = 1)
  }
} else {
  cat(sprintf(
    "Layout primitive audit passed: %d fixed-geometry declaration(s) are explicitly allowlisted.\n",
    length(hits)
  ))
}
