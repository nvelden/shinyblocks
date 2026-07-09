# Build interactive Shinylive playgrounds for component detail pages.
#
# For each subdir under docs-site/playgrounds/, run shinylive::export() to
# produce a self-contained Shinylive site under public/playgrounds/<slug>/.
# `shinyblocks` is loaded from the bundled WASM filesystem image, not
# Shinylive's public webR package repo. Playground app.R files should
# mount `library.data.gz` before loading shinyblocks, and
# shinylive::export() must run with `wasm_packages = FALSE` so its
# dependency scanner does not try `webr::install("shinyblocks")`.
#
# Then merge the playground metadata (hasPlayground, playgroundHeight)
# into lib/preview-manifest.json so the detail page knows which slugs
# have an interactive playground to embed.

# Ensure a UTF-8 locale so non-ASCII literals in playground app.R sources
# survive export instead of degrading into byte markers under a C/POSIX locale.
for (loc in c("en_US.UTF-8", "C.UTF-8", "en_US.utf8", "C.utf8")) {
  if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break
}

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
# WASM package image (library.data.gz + library.js.metadata) mounted by each
# playground at runtime. Populated by CI from the *latest release*, so it can
# LAG `HEAD`: a playground that uses a newly added component/function (e.g. a
# brand-new block_*()) will boot blank with "could not find function" in the
# nested Shinylive console until this image is rebuilt from the *current local*
# package. When that happens, rebuild + repack the image into this dir, re-run
# this script, and restart `npm run preview`. See docs-site/README.md
# ("Troubleshooting a blank playground iframe").
wasm_src_dir <- "playgrounds/_wasm"  # populated by CI from latest release

# Per-slug iframe height. Default 720; override here when a component
# needs more vertical room (icons gallery, layouts, etc).
playground_heights <- list(
  accordion = 860L,
  alert = 720L,
  badge = 720L,
  button = 720L,
  `task-button` = 720L,
  card = 720L,
  checkbox = 720L,
  code = 720L,
  `date-picker` = 720L,
  `date-range-picker` = 720L,
  empty = 720L,
  `file-input` = 720L,
  field = 720L,
  `image-output` = 720L,
  `plot-output` = 720L,
  icon = 720L,
  input = 720L,
  `input-group` = 720L,
  `radio-group` = 720L,
  `toggle-group` = 720L,
  select = 720L,
  separator = 720L,
  skeleton = 720L,
  slider = 720L,
  spinner = 720L,
  progress = 720L,
  switch = 720L,
  tabs = 720L,
  theme = 720L,
  toast = 720L,
  style = 720L,
  table = 720L,
  layout = 720L,
  `layout-primitives` = 820L,
  tooltip = 720L,
  popover = 720L,
  dialog = 720L,
  gallery = 1080L,
  textarea = 720L,
  `value-box` = 720L
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
shared_shinylive_dir <- file.path(playgrounds_out, "shinylive")
shared_sw_path <- file.path(playgrounds_out, "shinylive-sw.js")
shared_assets_copied <- FALSE

for (slug in slugs) {
  app_dir <- file.path(playgrounds_src, slug)
  out_dir <- file.path(playgrounds_out, slug)

  if (dir.exists(out_dir)) {
    unlink(out_dir, recursive = TRUE, force = TRUE)
  }

  # Stage the wasm filesystem image inside the app source directory so
  # app.json remains self-contained for local Shinylive app inspection.
  # The exported site also copies these files to public/playgrounds/,
  # which is the path the app.R bootstrap mounts at runtime.
  staged <- c()
  for (asset in c("library.data.gz", "library.js.metadata")) {
    src <- file.path(wasm_src_dir, asset)
    if (!file.exists(src)) {
      warning(sprintf(
        "Wasm asset %s not found at %s — playground will fail to load shinyblocks.",
        asset, src
      ), call. = FALSE)
      next
    }
    dest <- file.path(app_dir, asset)
    file.copy(src, dest, overwrite = TRUE)
    staged <- c(staged, dest)
  }

  cat(sprintf("Exporting %s → %s\n", app_dir, out_dir))
  on.exit(unlink(staged), add = TRUE)
  shinylive::export(app_dir, out_dir, wasm_packages = FALSE)
  unlink(staged)

  local_shinylive_dir <- file.path(out_dir, "shinylive")
  local_sw_path <- file.path(out_dir, "shinylive-sw.js")

  if (!shared_assets_copied) {
    if (dir.exists(shared_shinylive_dir)) unlink(shared_shinylive_dir, recursive = TRUE, force = TRUE)
    if (file.exists(shared_sw_path)) unlink(shared_sw_path, force = TRUE)
    
    file.rename(local_shinylive_dir, shared_shinylive_dir)
    file.rename(local_sw_path, shared_sw_path)
    shared_assets_copied <- TRUE
    cat("  Created shared Shinylive assets at public/playgrounds/shinylive/\n")
  } else {
    if (dir.exists(local_shinylive_dir)) unlink(local_shinylive_dir, recursive = TRUE, force = TRUE)
    if (file.exists(local_sw_path)) unlink(local_sw_path, force = TRUE)
  }

  html_path <- file.path(out_dir, "index.html")
  if (file.exists(html_path)) {
    html_lines <- readLines(html_path, warn = FALSE)
    html_content <- paste(html_lines, collapse = "\n")
    
    meta_tag <- '    <meta name="shinylive:serviceworker_dir" content="../" />'
    html_content <- sub("</head>", paste0(meta_tag, "\n  </head>"), html_content, fixed = TRUE)
    
    html_content <- gsub('src="./shinylive/', 'src="../shinylive/', html_content, fixed = TRUE)
    html_content <- gsub('href="./shinylive/', 'href="../shinylive/', html_content, fixed = TRUE)
    html_content <- gsub('import { runExportedApp } from "./shinylive/', 'import { runExportedApp } from "../shinylive/', html_content, fixed = TRUE)
    
    writeLines(html_content, html_path)
    cat("  Rewrote index.html to use shared Shinylive assets\n")
  }
}

# Copy the WASM assets directly into the parent shared directory so they are
# served as static files on the web server at a single location.
for (asset in c("library.data.gz", "library.js.metadata")) {
  src <- file.path(wasm_src_dir, asset)
  if (file.exists(src)) {
    dest <- file.path(playgrounds_out, asset)
    file.copy(src, dest, overwrite = TRUE)
    cat(sprintf("Static WASM asset copied to parent: %s → %s\n", src, dest))
  }
}

# Copy latest local runtime CSS to a static path so playgrounds inside iframes can override/load HEAD styles
local_css <- "../inst/www/shinyblocks-runtime.css"
showcase_css <- "../inst/showcase/www/showcase.css"
if (file.exists(local_css)) {
  file.copy(local_css, "public/shinyblocks-runtime-override.css", overwrite = TRUE)
  if (file.exists(showcase_css)) {
    write(
      paste0(
        "\n\n/* Showcase custom overrides appended during build */\n",
        paste(readLines(showcase_css, warn = FALSE), collapse = "\n")
      ),
      file = "public/shinyblocks-runtime-override.css",
      append = TRUE
    )
  }
  cat("Staged local runtime CSS override in public/\n")
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
