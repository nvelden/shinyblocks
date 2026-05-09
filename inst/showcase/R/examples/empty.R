htmltools::div(
  style = paste(
    "display: grid;",
    "grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));",
    "gap: 1rem;"
  ),
  block_empty(
    "No reports yet",
    description = "Generate your first report to populate this space.",
    icon = "folder",
    action = block_button("Create report")
  ),
  block_empty(
    "No saved filters",
    htmltools::tags$p(
      style = "margin: 0;",
      "Save a filter from the results screen to reuse it later."
    ),
    icon = "filter"
  )
)
