# Ensure a UTF-8 locale so non-ASCII literals (e.g. the ellipsis in
# "Crunching…") are read and written faithfully instead of degrading into
# <e2><80><a6> byte markers under a C/POSIX locale.
for (loc in c("en_US.UTF-8", "C.UTF-8", "en_US.utf8", "C.utf8")) {
  if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break
}

# Source registry
source("content/previews/_registry.R")

# Load shinyblocks R package locally
devtools::load_all("..")

# Create directories if they do not exist
dir.create("public/runtime", recursive = TRUE, showWarnings = FALSE)
dir.create("lib", recursive = TRUE, showWarnings = FALSE)

manifest_list <- list()
all_deps <- list()

clean_runtime_paths <- function(html) {
  gsub(
    "(shinyblocks-[0-9a-fA-F.-]+/icons/sprite.svg)",
    "/shinyblocks/runtime/\\1",
    html
  )
}

render_fragment <- function(ui) {
  rendered <- htmltools::renderTags(ui)
  all_deps <<- c(all_deps, rendered$dependencies)
  clean_runtime_paths(rendered$html)
}

for (entry in registry) {
  # Source preview file to get the tag object. Force UTF-8 so non-ASCII
  # literals (e.g. the ellipsis in "Crunching…") survive into the rendered
  # HTML and the manifest rather than degrading into <e2><80><a6> byte markers.
  preview_file <- file.path("content/previews", entry$file)
  ui <- source(preview_file, encoding = "UTF-8")$value

  # Render the tags
  html_cleaned <- render_fragment(ui)

  # Write HTML fragment to sibling .html file
  html_file <- file.path("content/previews", paste0(entry$slug, ".html"))
  writeLines(html_cleaned, html_file, useBytes = TRUE)

  # Read code recipe content
  code_content <- readLines(preview_file, warn = FALSE, encoding = "UTF-8")
  Encoding(code_content) <- "UTF-8"
  code_content <- enc2utf8(paste(code_content, collapse = "\n"))
  code_html <- render_fragment(
    shinyblocks::block_code(
      code = code_content,
      language = "r",
      copyable = TRUE,
      line_numbers = TRUE,
      variant = "default"
    )
  )
  
  # Add to manifest
  manifest_list[[length(manifest_list) + 1]] <- list(
    name = entry$name,
    slug = entry$slug,
    description = entry$description,
    featured = entry$featured,
    code = code_content,
    codeHtml = code_html,
    html = html_cleaned
  )
}

# Resolve and copy HTML dependencies
if (length(all_deps) > 0) {
  resolved_deps <- htmltools::resolveDependencies(all_deps)
  for (dep in resolved_deps) {
    htmltools::copyDependencyToDir(dep, "public/runtime", mustWork = TRUE)
  }
  
  # Combine shinyblocks CSS stylesheets into public/runtime/shinyblocks.css
  for (dep in resolved_deps) {
    if (dep$name == "shinyblocks") {
      combined_css <- ""
      for (sheet in dep$stylesheet) {
        sheet_path <- file.path("public/runtime", paste0(dep$name, "-", dep$version), sheet)
        if (file.exists(sheet_path)) {
          sheet_lines <- readLines(sheet_path, warn = FALSE)
          combined_css <- paste0(combined_css, paste(sheet_lines, collapse = "\n"), "\n")
        }
      }
      writeLines(combined_css, "public/runtime/shinyblocks.css")
    }
  }
}

# Reject byte-marker corruption (e.g. <e2><80><a6>) before it reaches the
# manifest, displayed code, or runtime payloads. These markers appear when a
# multibyte UTF-8 sequence (lead/continuation bytes 0x80-0xff) is written as
# literal text instead of the original character.
byte_marker_re <- "<[89a-fA-F][0-9a-fA-F]>"
flatten_strings <- function(x) {
  if (is.character(x)) return(x)
  if (is.list(x)) return(unlist(lapply(x, flatten_strings), use.names = FALSE))
  character()
}
offending <- Filter(
  function(s) grepl(byte_marker_re, s, perl = TRUE),
  flatten_strings(manifest_list)
)
if (length(offending) > 0) {
  stop(
    "Preview content contains UTF-8 byte markers (", byte_marker_re, "). ",
    "Fix encoding handling in the generator. First offender:\n",
    substr(offending[[1]], 1, 200),
    call. = FALSE
  )
}

# Write preview manifest JSON
jsonlite::write_json(
  manifest_list,
  "lib/preview-manifest.json",
  auto_unbox = TRUE,
  pretty = TRUE
)

cat("Successfully generated preview HTML files and manifest.json!\n")
