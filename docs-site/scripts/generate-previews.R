# Source registry
source("content/previews/_registry.R")

# Load shinyblocks R package locally
devtools::load_all("..")

# Create directories if they do not exist
dir.create("public/runtime", recursive = TRUE, showWarnings = FALSE)
dir.create("lib", recursive = TRUE, showWarnings = FALSE)

manifest_list <- list()
all_deps <- list()

for (entry in registry) {
  # Source preview file to get the tag object
  preview_file <- file.path("content/previews", entry$file)
  ui <- source(preview_file)$value
  
  # Render the tags
  rendered <- htmltools::renderTags(ui)
  
  # Clean HTML sprite URLs to point to absolute static path
  html_cleaned <- gsub("(shinyblocks-[0-9a-fA-F.-]+/icons/sprite.svg)", "/shinyblocks/runtime/\\1", rendered$html)
  
  # Write HTML fragment to sibling .html file
  html_file <- file.path("content/previews", paste0(entry$slug, ".html"))
  writeLines(html_cleaned, html_file)
  
  # Capture HTML dependencies
  if (!is.null(rendered$dependencies)) {
    all_deps <- c(all_deps, rendered$dependencies)
  }
  
  # Read code recipe content
  code_content <- paste(readLines(preview_file, warn = FALSE), collapse = "\n")
  
  # Add to manifest
  manifest_list[[length(manifest_list) + 1]] <- list(
    name = entry$name,
    slug = entry$slug,
    description = entry$description,
    featured = entry$featured,
    code = code_content,
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

# Write preview manifest JSON
jsonlite::write_json(
  manifest_list,
  "lib/preview-manifest.json",
  auto_unbox = TRUE,
  pretty = TRUE
)

cat("Successfully generated preview HTML files and manifest.json!\n")
