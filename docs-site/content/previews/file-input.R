shinyblocks::block_file_input(
  "upload",
  variant = "dropzone",
  multiple = TRUE,
  append = TRUE,
  accept = c(".csv", "text/csv"),
  dropzone_icon = "upload",
  dropzone_label = "Upload your files",
  dropzone_hint = "Drag and drop files here or click to browse"
)
