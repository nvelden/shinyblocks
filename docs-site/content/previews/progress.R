htmltools::div(
  style = "display: flex; flex-direction: column; gap: 1.25rem; padding: 1rem; max-width: 420px; margin: 0 auto;",
  shinyblocks::block_progress("preview_progress_upload", value = 0.6, label = "Upload", show_value = TRUE),
  shinyblocks::block_progress(
    "preview_progress_import",
    value = 0.35,
    message = "Importing rows...",
    detail = "1,200 of 3,400",
    variant = "info"
  ),
  shinyblocks::block_progress("preview_progress_done", value = 1, variant = "success", show_value = TRUE),
  shinyblocks::block_progress("preview_progress_busy", indeterminate = TRUE, message = "Working...")
)
