#!/usr/bin/env Rscript
# Asset performance budget reporter.
#
# Run via `make budget`. Prints sizes of shipped assets against
# targets defined in the active ADRs. Runtime budgets track the current
# migrated component set with modest headroom. Exits non-zero if any
# asset with a limit is over budget.
#
# Legacy compatibility targets remain while native assets exist:
#   inst/www/shinyblocks.css           <= 10 KB gzipped
#   inst/www/shinyblocks.js            <= 15 KB raw
#   inst/www/icons/sprite.svg          <= 25 KB gzipped

targets <- list(
  list(
    path = "inst/www/shinyblocks.css",
    limit_kb = 10,
    metric = "gzipped",
    group = "compatibility"
  ),
  list(
    path = "inst/www/shinyblocks.js",
    limit_kb = 15,
    metric = "raw",
    group = "compatibility"
  ),
  list(
    # Recalibrated for the post-#36 Rhea + feedback-token component set, then
    # again for the #51 reactive-table feature set (skeleton / striped /
    # bordered / loading variants). Gzipped (below) is the meaningful transfer
    # budget and stays the binding constraint; raw is a headroom guard.
    path = "inst/www/shinyblocks-runtime.css",
    limit_kb = 49,
    metric = "raw",
    group = "runtime"
  ),
  list(
    path = "inst/www/shinyblocks-runtime.css",
    limit_kb = 7,
    metric = "gzipped",
    group = "runtime"
  ),
  list(
    path = "inst/www/shinyblocks-runtime.js",
    limit_kb = 275,
    metric = "raw",
    group = "runtime"
  ),
  list(
    path = "inst/www/shinyblocks-runtime.js",
    limit_kb = 75,
    metric = "gzipped",
    group = "runtime"
  ),
  list(
    path = "inst/www/icons/sprite.svg",
    limit_kb = 25,
    metric = "gzipped",
    group = "icons"
  )
)

gzip_size <- function(path) {
  raw <- readBin(path, what = "raw", n = file.info(path)$size)
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
      metric = t$metric,
      group = t$group
    ))
  }
  size_bytes <- if (identical(t$metric, "gzipped")) {
    gzip_size(t$path)
  } else {
    file.info(t$path)$size
  }
  status <- if (is.null(t$limit_kb)) {
    "reported"
  } else if (size_bytes / 1024 > t$limit_kb) {
    "OVER BUDGET"
  } else {
    "ok"
  }
  list(
    path = t$path,
    status = status,
    size_bytes = size_bytes,
    limit_kb = t$limit_kb,
    metric = t$metric,
    group = t$group
  )
})

cat("\nshinyblocks asset budget\n")
cat(strrep("-", 60), "\n", sep = "")
for (r in results) {
  if (identical(r$status, "missing")) {
    cat(sprintf(
      "  %-40s %-13s %s\n",
      r$path,
      sprintf("[%s]", r$group),
      "(missing — not yet built)"
    ))
    next
  }
  limit <- if (is.null(r$limit_kb)) {
    "baseline pending"
  } else {
    sprintf("%d KB", r$limit_kb)
  }
  cat(sprintf(
    "  %-40s %-13s %8s  /  %s  [%s, %s]\n",
    r$path,
    sprintf("[%s]", r$group),
    format_kb(r$size_bytes),
    limit,
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
