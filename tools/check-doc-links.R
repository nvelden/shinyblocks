#!/usr/bin/env Rscript
# Cross-link validator for public markdown files.
#
# Walks tracked public markdown files and verifies that every relative
# markdown link `[label](path.md...)` points at a file that exists.
# Anchors (#section) are not validated for existence — only the file.
#
# Run via `make doc-links`. Exits non-zero on broken links.

roots <- c(
  "CONTRIBUTING.md",
  "README.md",
  "NEWS.md"
)
roots <- roots[file.exists(roots)]

pattern <- "\\[[^\\]]*\\]\\(([^)#?]+)(#[^)]*)?\\)"

broken <- character()
checked <- 0L

strip_html_comments <- function(text) {
  collapsed <- paste(text, collapse = "\n")
  collapsed <- gsub("(?s)<!--.*?-->", "", collapsed, perl = TRUE)
  strsplit(collapsed, "\n", fixed = TRUE)[[1]]
}

for (file in roots) {
  text <- readLines(file, warn = FALSE)
  text <- strip_html_comments(text)
  for (line_no in seq_along(text)) {
    line <- text[line_no]
    matches <- regmatches(line, gregexpr(pattern, line, perl = TRUE))[[1]]
    for (m in matches) {
      target <- sub(pattern, "\\1", m, perl = TRUE)
      target <- trimws(target)
      # Skip http(s), mailto, and anchor-only links.
      if (grepl("^(https?:|mailto:|#)", target)) next
      if (
        startsWith(file, "docs/component-specs/") &&
          grepl("^_screenshots/.+\\.(png|jpg|jpeg|webp)$", target)
      ) {
        checked <- checked + 1L
        next
      }
      # Resolve relative to the file's directory.
      base_dir <- dirname(file)
      resolved <- if (startsWith(target, "/")) {
        substring(target, 2)
      } else {
        file.path(base_dir, target)
      }
      resolved <- normalizePath(resolved, mustWork = FALSE)
      checked <- checked + 1L
      if (!file.exists(resolved) && !dir.exists(resolved)) {
        broken <- c(broken, sprintf(
          "  %s:%d  -> %s",
          file, line_no, target
        ))
      }
    }
  }
}

cat(sprintf(
  "\ndoc-links: checked %d link(s) across %d file(s)\n",
  checked, length(roots)
))
if (length(broken) > 0) {
  cat("FAIL: broken markdown links:\n")
  cat(paste(broken, collapse = "\n"), "\n", sep = "")
  quit(status = 1L)
}
cat("OK: all links resolve.\n")
