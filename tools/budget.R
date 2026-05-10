#!/usr/bin/env Rscript
# Asset performance budget reporter.
#
# Run via `make budget`. Prints sizes of shipped assets against
# targets defined in ADR 0006 (CSS) and ADR 0008 (sprite). Exits
# non-zero if any asset is over budget; otherwise prints a summary.
#
# Targets (gzipped where indicated):
#   inst/www/shinyblocks.css           <= 10 KB gzipped
#   inst/www/shinyblocks.js            <= 15 KB
#   inst/www/icons/sprite.svg          <= 25 KB gzipped

targets <- list(
  list(
    path = "inst/www/shinyblocks.css",
    limit_kb = 10,
    metric = "gzipped"
  ),
  list(
    path = "inst/www/shinyblocks.js",
    limit_kb = 15,
    metric = "raw"
  ),
  list(
    path = "inst/www/icons/sprite.svg",
    limit_kb = 25,
    metric = "gzipped"
  )
)

gzip_size <- function(path) {
  raw <- readBin(path, what = "raw", n = file.info(path)$size)
  con <- gzcon(rawConnection(raw, open = "wb"))
  writeBin(raw, con)
  close(con)
  length(memCompress(raw, type = "gzip"))
}

format_kb <- function(bytes) sprintf("%.1f KB", bytes / 1024)

results <- lapply(targets, function(t) {
  if (!file.exists(t$path)) {
    return(list(
      path = t$path,
      status = "missing",
      size_bytes = NA_integer_,
      limit_kb = t$limit_kb,
      metric = t$metric
    ))
  }
  size_bytes <- if (identical(t$metric, "gzipped")) {
    gzip_size(t$path)
  } else {
    file.info(t$path)$size
  }
  status <- if (size_bytes / 1024 > t$limit_kb) "OVER BUDGET" else "ok"
  list(
    path = t$path,
    status = status,
    size_bytes = size_bytes,
    limit_kb = t$limit_kb,
    metric = t$metric
  )
})

cat("\nshinyblocks asset budget\n")
cat(strrep("-", 60), "\n", sep = "")
for (r in results) {
  if (identical(r$status, "missing")) {
    cat(sprintf(
      "  %-40s %s\n",
      r$path,
      "(missing — not yet built)"
    ))
    next
  }
  cat(sprintf(
    "  %-40s %8s  /  %s  [%s, %s]\n",
    r$path,
    format_kb(r$size_bytes),
    sprintf("%d KB", r$limit_kb),
    r$metric,
    r$status
  ))
}
cat(strrep("-", 60), "\n", sep = "")

over <- vapply(results, function(r) identical(r$status, "OVER BUDGET"), logical(1))
if (any(over)) {
  cat("FAIL: one or more assets over budget.\n")
  quit(status = 1L)
}
cat("OK: all assets within budget (or not yet built).\n")
