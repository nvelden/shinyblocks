#!/usr/bin/env Rscript

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
      hits[[length(hits) + 1]] <- sprintf("%s:%d: %s", path, i, trimws(lines[[i]]))
    }
  }
}

if (!length(hits)) {
  cat("Layout primitive audit passed: no generic inline layout declarations found.\n")
  quit(save = "no", status = 0)
}

cat(sprintf(
  "Layout primitive audit found %d declaration(s)%s:\n\n",
  length(hits),
  if (strict) "" else " (warn-only)"
))
cat(paste(unlist(hits), collapse = "\n"), "\n")

if (strict) {
  quit(save = "no", status = 1)
}
