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
    # Raised 15 -> 19 KB for the sidebar-nav Shiny input, then 19 -> 21 KB when
    # tabs and sidebar-nav became real Shiny InputBindings (`shinyblocks.tabs` /
    # `shinyblocks.nav`) driven by delegated DOM events: this retired the
    # per-element wiring guards, the `sb:tabs`/`sb:nav` custom-message handlers,
    # and the `shiny:connected` re-sync in favour of one shared binding factory,
    # landing at ~20.4 KB. Raw is a headroom guard, not a transfer budget.
    path = "inst/www/shinyblocks.js",
    limit_kb = 21,
    metric = "raw",
    group = "compatibility"
  ),
  list(
    # Recalibrated for the post-#36 Rhea + feedback-token component set, then
    # again for the #51 reactive-table feature set (skeleton / striped /
    # bordered / loading variants), then 49 -> 50 for the #53 table styling
    # intents being scoped to [data-shinyblocks-root] (the descendant prefix
    # costs ~0.2 KB raw). The #54 file-input picker/progress styling brings the
    # built asset to ~53 KB raw while keeping gzip under its transfer budget,
    # then 54 -> 57 for the #56 file-input dropzone variant: the base
    # .sb-file-dropzone surface + dragover/reject/disabled/invalid states, then
    # the customizable interior (icon circle, content flex wrapper, default
    # trigger-button styling, and the custom drop-region cursor) bring the
    # asset to ~56 KB raw. Raised 57 -> 60 KB for a 5% headroom increase.
    # Raised 60 -> 65 KB for the #59 date-picker runtime CSS (hand-rolled, no
    # library): trigger surface + portaled calendar (month nav, weekday header,
    # day grid, selected/today/disabled/focus states) adds ~4 KB raw. Raised
    # 65 -> 70 KB for the #61 date-range-picker runtime CSS (trigger + portaled
    # range calendar: in-range band, range-start/end endpoints, hover-preview
    # reduced-emphasis states) adds ~3.5 KB raw. Raised 70 -> 74 KB for the
    # #93 toggle-group CSS (joined segmented control, outline/collapsed inner
    # borders, three sizes, icon slot) adds ~2.2 KB raw (lands at ~72.2 KB),
    # leaving margin for the in-flight #96 stepper CSS (~0.9 KB) to merge.
    # Gzipped is the meaningful transfer budget; raw is a headroom guard.
    path = "inst/www/shinyblocks-runtime.css",
    limit_kb = 74,
    metric = "raw",
    group = "runtime"
  ),
  list(
    # 7 -> 7.5 KB for DT-style row selection (selectable cursor, themed focus
    # ring, and selection-wins-over-hover/striped backgrounds), then 7.5 -> 8 KB
    # for the #56 customizable dropzone interior (icon circle, content wrapper,
    # trigger button), then 8 -> 9 KB for the #59 date-picker calendar styling.
    # Raised 9 -> 10 KB for the #64 multi-select chip CSS (multi-trigger layout,
    # wrapping removable chips with --sb-select-chip-* hooks, multi-listbox check
    # column): this sits right at the 9 KB boundary, and because the gzipped
    # metric is platform-variant (R's memCompress zlib differs by OS) it reads
    # ok locally but tips just over on CI. 10 KB restores margin.
    # Gzipped is the binding transfer budget.
    path = "inst/www/shinyblocks-runtime.css",
    limit_kb = 10,
    metric = "gzipped",
    group = "runtime"
  ),
  list(
    # Raised 275 -> 285 KB for the #61 date-range-picker runtime: the range
    # state machine (two-click commit, hover/keyboard preview, half-open
    # guard) + its binding adds ~3 KB raw on top of the shared calendar core
    # (extracted, not duplicated). Still no react-day-picker dependency.
    # Raised 285 -> 292 KB for the #64 multi-select runtime: the new
    # multi-select-view (wrapping removable chips, multi-selectable listbox,
    # max_items cap, native-mirror reconciliation) adds ~4 KB raw on top of the
    # shared select-popover hook (extracted, not duplicated). Gzipped (85 KB)
    # stays the binding transfer budget and is unchanged.
    # Raised 292 -> 296 KB for the #69 task-button runtime: the new
    # task-button component + binding (synchronous DOM click lock, busy/ready
    # state machine, decorative spinner, persistent live-status region, and the
    # author/controlled aria-label arbitration) adds ~2.6 KB raw (lands at
    # ~294.6 KB). Gzipped (86 KB) stays the meaningful transfer budget and is
    # within limit; raw remains the headroom guard. Raised 296 -> 304 KB for
    # the #93 toggle-group runtime (component with roving tabindex + single/
    # multiple value shapes, binding, native mirror) adds ~3.7 KB raw (lands
    # at ~299.7 KB), leaving margin for the in-flight #96 stepper (~1.5 KB).
    path = "inst/www/shinyblocks-runtime.js",
    limit_kb = 304,
    metric = "raw",
    group = "runtime"
  ),
  list(
    # Recalibrated 75 -> 76 KB for the #51 reactive-table runtime (stateful
    # table + receive-only binding), then 76 -> 77 KB for the #54 file-input
    # runtime picker/update path, then 77 -> 78 KB for the #56 dropzone variant
    # branch + DataTransfer drop bridge (raw grows only ~0.3 KB to 258 KB, well
    # under the 275 KB guard). NB: this gzipped metric is platform-variant
    # (R's memCompress zlib differs by OS), so sub-100-byte margins cannot be
    # measured reliably across local/CI. Raised 78 -> 82 KB for a 5% headroom
    # increase, then 82 -> 85 KB for the #61 date-range-picker runtime. Raw
    # (292 KB) stays the headroom guard. Raised 85 -> 86 KB for the #64
    # multi-select review follow-up (defensive single-mode coercion + cap
    # clamp): it lands at exactly 85.0 KB locally, which the platform-variant
    # zlib tips over on CI, so 86 KB restores margin. Raised 86 -> 87 KB for
    # the #69 task-button state machine and binding: Linux zlib reports 86.1 KB
    # while macOS remains at 86.0 KB, so the prior limit had no cross-platform
    # margin. Raised 87 -> 89 KB for the #93 toggle-group runtime: macOS lands
    # at 87.4 KB, and the in-flight #96 stepper adds a few hundred bytes more,
    # so 89 KB keeps a cross-platform zlib margin.
    path = "inst/www/shinyblocks-runtime.js",
    limit_kb = 89,
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
    sprintf("%s KB", format(r$limit_kb))
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
