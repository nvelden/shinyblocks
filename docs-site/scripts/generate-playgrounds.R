# Build interactive Shinylive playgrounds for component detail pages.
#
# For each subdir under docs-site/playgrounds/, run shinylive::export() to
# produce a self-contained Shinylive site under public/playgrounds/<slug>/.
# The local shinyblocks source must be installed in the R library before
# this runs so that library(shinyblocks) inside each app.R resolves.
#
# Then merge the playground metadata (hasPlayground, playgroundHeight)
# into lib/preview-manifest.json so the detail page knows which slugs
# have an interactive playground to embed.

`%||%` <- function(a, b) if (is.null(a)) b else a

if (!requireNamespace("shinylive", quietly = TRUE)) {
  stop(
    "shinylive is required. Install with install.packages('shinylive').",
    call. = FALSE
  )
}

playgrounds_src <- "playgrounds"
playgrounds_out <- "public/playgrounds"
manifest_path <- "lib/preview-manifest.json"
wasm_src_dir <- "playgrounds/_wasm"  # populated by CI from latest release

# Per-slug iframe height. Default 720; override here when a component
# needs more vertical room (icons gallery, layouts, etc).
playground_heights <- list(
  select = 760L
)

if (!dir.exists(playgrounds_src)) {
  cat("No playgrounds/ directory; nothing to export.\n")
  quit(save = "no", status = 0)
}

dir.create(playgrounds_out, recursive = TRUE, showWarnings = FALSE)

slugs <- list.dirs(playgrounds_src, recursive = FALSE, full.names = FALSE)
slugs <- slugs[file.exists(file.path(playgrounds_src, slugs, "app.R"))]

if (!length(slugs)) {
  cat("No app.R files found under playgrounds/.\n")
  quit(save = "no", status = 0)
}

for (slug in slugs) {
  app_dir <- file.path(playgrounds_src, slug)
  out_dir <- file.path(playgrounds_out, slug)

  if (dir.exists(out_dir)) {
    unlink(out_dir, recursive = TRUE, force = TRUE)
  }

  cat(sprintf("Exporting %s → %s\n", app_dir, out_dir))
  shinylive::export(app_dir, out_dir)

  # Copy the wasm filesystem image alongside the exported app so the
  # bootstrap snippet's webr::mount("library.data.gz") resolves.
  for (asset in c("library.data.gz", "library.js.metadata")) {
    src <- file.path(wasm_src_dir, asset)
    if (file.exists(src)) {
      file.copy(src, file.path(out_dir, asset), overwrite = TRUE)
    } else {
      warning(sprintf(
        "Wasm asset %s not found at %s — playground will fail to load shinyblocks.",
        asset, src
      ), call. = FALSE)
    }
  }
}

# Merge playground metadata into preview-manifest.json
if (!file.exists(manifest_path)) {
  stop(
    sprintf("Expected manifest at %s; run generate-previews.R first.", manifest_path),
    call. = FALSE
  )
}

manifest <- jsonlite::fromJSON(manifest_path, simplifyVector = FALSE)
for (i in seq_along(manifest)) {
  slug <- manifest[[i]]$slug
  if (slug %in% slugs) {
    manifest[[i]]$hasPlayground <- TRUE
    manifest[[i]]$playgroundHeight <- playground_heights[[slug]] %||% 720L
  } else {
    manifest[[i]]$hasPlayground <- FALSE
  }
}

jsonlite::write_json(
  manifest,
  manifest_path,
  auto_unbox = TRUE,
  pretty = TRUE
)

cat(sprintf(
  "Exported %d playground(s): %s\n",
  length(slugs),
  paste(slugs, collapse = ", ")
))
