#!/usr/bin/env Rscript

# Legacy/runtime migration audit.
# New hits for these patterns must either be removed or explicitly classified
# in the allowlist below with a removal trigger.

repo <- normalizePath(getwd(), mustWork = TRUE)

scan_roots <- c("R", "inst", "tests", "tools")
forbidden <- c(
  "selectize|Selectize|\\.selectize-",
  "ionRangeSlider|irs--shiny|\\.irs-|\\birs-",
  "shiny::sliderInput\\(",
  "shiny::textInput\\(",
  "shiny::textAreaInput\\(",
  "shiny::checkboxInput\\(",
  "shiny::tabsetPanel\\(",
  "BootstrapTabInputBinding",
  "shiny-tab-input",
  "nav-link",
  "tab-pane",
  "sb-button-"
)

excluded_path <- function(path) {
  grepl("^inst/www/shinyblocks-runtime\\.(js|css)$", path) |
    grepl("^inst/www/shinyblocks\\.css$", path) |
    grepl("^tools/check-legacy-audit\\.R$", path) |
    grepl("^node_modules/|^site/|^parity/dist/", path)
}

allowlist <- data.frame(
  path = c(
    "^tests/testthat/test-runtime-css\\.R$",
    "^tools/runtime-shiny-(fixture\\.R|smoke\\.mjs)$",
    "^tests/testthat/test-shell\\.R$"
  ),
  pattern = c(
    "selectize|irs-|nav-link|tab-pane",
    "selectize|Selectize|nav-link|shiny::textInput",
    "shiny-tab-input|nav-link|tab-pane"
  ),
  reason = c(
    "Runtime CSS test asserts these host selectors are absent from runtime CSS.",
    "Host collision fixture intentionally creates non-shinyblocks Bootstrap/Selectize-like nodes and one nested raw Shiny text input.",
    "Shell tests assert old tab internals are absent from the rendered contract."
  ),
  stringsAsFactors = FALSE
)

all_files <- unlist(lapply(scan_roots, function(root) {
  full <- file.path(repo, root)
  if (!dir.exists(full)) return(character())
  list.files(full, recursive = TRUE, full.names = TRUE, all.files = FALSE, no.. = TRUE)
}), use.names = FALSE)

all_files <- all_files[file.info(all_files)$isdir %in% FALSE]
text_extensions <- "\\.(R|r|md|Rmd|qmd|js|jsx|mjs|css|scss|yml|yaml|json|txt)$"
all_files <- all_files[grepl(text_extensions, all_files, ignore.case = TRUE)]
normalized_files <- normalizePath(all_files, mustWork = FALSE)
prefix <- paste0(repo, .Platform$file.sep)
rel_files <- ifelse(
  startsWith(normalized_files, prefix),
  substring(normalized_files, nchar(prefix) + 1L),
  normalized_files
)
keep <- !excluded_path(rel_files)
all_files <- all_files[keep]
rel_files <- rel_files[keep]

hits <- list()
for (i in seq_along(all_files)) {
  lines <- tryCatch(readLines(all_files[[i]], warn = FALSE), error = function(e) character())
  if (!length(lines)) next
  for (pattern in forbidden) {
    matched <- grep(pattern, lines, perl = TRUE)
    if (!length(matched)) next
    for (line_no in matched) {
      hits[[length(hits) + 1L]] <- data.frame(
        path = rel_files[[i]],
        line = line_no,
        pattern = pattern,
        text = lines[[line_no]],
        stringsAsFactors = FALSE
      )
    }
  }
}

if (!length(hits)) {
  message("Legacy audit passed: no forbidden legacy hits found.")
  quit(status = 0)
}

hits <- do.call(rbind, hits)

is_allowed <- vapply(seq_len(nrow(hits)), function(i) {
  any(vapply(seq_len(nrow(allowlist)), function(j) {
    grepl(allowlist$path[[j]], hits$path[[i]], perl = TRUE) &&
      grepl(allowlist$pattern[[j]], hits$text[[i]], perl = TRUE)
  }, logical(1)))
}, logical(1))

unexpected <- hits[!is_allowed, , drop = FALSE]
if (nrow(unexpected)) {
  cat("Legacy audit failed. Remove these hits or classify them in tools/check-legacy-audit.R.\n\n")
  for (i in seq_len(nrow(unexpected))) {
    cat(sprintf("%s:%s: %s\n", unexpected$path[[i]], unexpected$line[[i]], trimws(unexpected$text[[i]])))
  }
  quit(status = 1)
}

message(sprintf(
  "Legacy audit passed: %d legacy hits are explicitly allowlisted.",
  nrow(hits)
))
