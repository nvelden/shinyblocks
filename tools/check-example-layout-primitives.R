#!/usr/bin/env Rscript

# Static layout-primitive audit.
#
# Flags new hand-authored generic flex/grid layout in app-author-facing example
# code (showcase examples, docs-site playgrounds + previews, README, templates).
# Ordinary `display:flex` / direction / wrap / gap / alignment / auto-fit grid
# layout must be expressed through block_stack() / block_cluster() / block_grid()
# instead of inline CSS.
#
# Modes:
#   - warn-only (default): prints every hit and exits 0.
#   - strict (`--strict` or SHINYBLOCKS_LAYOUT_AUDIT_STRICT=true): exits 1 on any
#     hit that is not explicitly allowlisted below.
#
# Allowlist policy (mirrors tools/check-legacy-audit.R): each entry pins a
# specific file *and* a specific declaration pattern with a rationale. This keeps
# exceptions narrow to genuinely-fixed demonstration geometry that does not map
# to the semantic primitives. Whole-file or whole-directory exclusions are not
# permitted.

args <- commandArgs(trailingOnly = TRUE)
strict <- "--strict" %in% args ||
  identical(tolower(Sys.getenv("SHINYBLOCKS_LAYOUT_AUDIT_STRICT")), "true")

roots <- c(
  "inst/showcase/R/examples",
  "docs-site/playgrounds",
  "docs-site/content/previews",
  "README.md",
  "inst/templates"
)

patterns <- c(
  "display\\s*:\\s*flex",
  "display\\s*:\\s*grid",
  "flex-direction\\s*:",
  "flex-wrap\\s*:",
  "(^|[;\"'[:space:]])gap\\s*:",
  "row-gap\\s*:",
  "column-gap\\s*:",
  "grid-template-columns\\s*:",
  "align-items\\s*:",
  "justify-content\\s*:"
)

# Narrow fixed-geometry exceptions: file pattern + declaration pattern + reason.
allowlist <- data.frame(
  path = c(
    "docs-site/playgrounds/code/app\\.R$",
    "docs-site/playgrounds/dialog/app\\.R$",
    "docs-site/playgrounds/layout/app\\.R$",
    "docs-site/playgrounds/layout/app\\.R$",
    "docs-site/playgrounds/layout/app\\.R$",
    "docs-site/playgrounds/layout/app\\.R$",
    "docs-site/playgrounds/layout/app\\.R$",
    "docs-site/playgrounds/theme/app\\.R$",
    "docs-site/playgrounds/toast/app\\.R$",
    "docs-site/playgrounds/toast/app\\.R$",
    "docs-site/playgrounds/toast/app\\.R$",
    "docs-site/playgrounds/toast/app\\.R$",
    "docs-site/content/previews/dialog\\.R$",
    "docs-site/content/previews/style\\.R$",
    "docs-site/content/previews/theme\\.R$"
  ),
  pattern = c(
    "display: flex;",
    "position: relative; display: flex; flex-direction: column; gap: 1rem;",
    "height: 300px",
    "transition: width 0.3s ease",
    "flex: 1; display: flex; flex-direction: column;",
    "display: inline-flex; align-items: center; justify-content: center;",
    "grid-template-columns: repeat\\(2, 1fr\\)",
    "grid-template-columns: repeat\\(2, minmax\\(0, 1fr\\)\\)",
    "grid-template-columns: auto minmax\\(0, 1fr\\)",
    "column-gap: 0.75rem",
    "display: flex; align-items: flex-start; padding-top",
    "display: flex; flex-direction: column; gap: 0.25rem; min-width: 0;",
    "width:18rem;max-width:100%",
    "display: flex; flex-direction: column; gap: 0.75rem; align-items: center; justify-content: center;",
    "display: flex; flex-direction: column; align-items: center; justify-content: center;"
  ),
  reason = c(
    "Literal CSS inside the Code component's syntax-highlight sample, not playground layout.",
    "Reproduces the .sb-dialog-content data-slot DOM mock (component-internal geometry).",
    "Fixed 300px app-shell illustration frame (two-column divider, no gap).",
    "Animated sidebar column: dynamic width + width transition, not a static stack.",
    "Main column flex:1 with no inter-region gap (topbar sits flush above content).",
    "Centered avatar glyph (inline-flex circle), component-internal centering.",
    "Fixed two-column metrics grid; block_grid() is auto-fit, not a 2-track grid.",
    "Fixed two-column swatch grid; block_grid() is auto-fit, not a 2-track grid.",
    "Reproduces the .sb-toast surface DOM mock (icon/content auto+minmax grid).",
    "Reproduces the .sb-toast surface DOM mock (sub-token column gap).",
    "Reproduces the .sb-toast icon slot DOM mock.",
    "Reproduces the .sb-toast content slot DOM mock.",
    "Reproduces the .sb-dialog-content data-slot DOM mock (overlay positioning neutralised).",
    "Two-axis-centered style preview canvas; block_stack has no main-axis justify.",
    "Two-axis-centered theme preview canvas; block_stack has no main-axis justify."
  ),
  stringsAsFactors = FALSE
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

hits <- list()
for (path in files) {
  lines <- readLines(path, warn = FALSE)
  for (i in seq_along(lines)) {
    if (any(vapply(patterns, grepl, logical(1), x = lines[[i]], ignore.case = TRUE, perl = TRUE))) {
      hits[[length(hits) + 1]] <- list(path = path, line = i, text = trimws(lines[[i]]))
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
      grepl(allowlist$pattern[[j]], hit$text, fixed = FALSE, perl = TRUE)
  }, logical(1)))
}

allowed <- vapply(hits, is_allowed, logical(1))
unexpected <- hits[!allowed]
fmt <- function(h) sprintf("%s:%d: %s", h$path, h$line, h$text)

if (length(unexpected)) {
  cat(sprintf(
    "Layout primitive audit found %d un-allowlisted declaration(s)%s:\n\n",
    length(unexpected),
    if (strict) "" else " (warn-only)"
  ))
  cat(paste(vapply(unexpected, fmt, character(1)), collapse = "\n"), "\n")
  if (strict) {
    cat("\nMigrate to block_stack()/block_cluster()/block_grid(), or add a narrow\n")
    cat("file+pattern entry to the allowlist in tools/check-example-layout-primitives.R.\n")
    quit(save = "no", status = 1)
  }
} else {
  cat(sprintf(
    "Layout primitive audit passed: %d fixed-geometry declaration(s) are explicitly allowlisted.\n",
    length(hits)
  ))
}
