htmltools::div(
  style = "display: flex; gap: 0.75rem; align-items: center; justify-content: center; padding: 1rem; flex-wrap: wrap;",
  shinyblocks::block_task_button("preview_task_button", "Run analysis", label_busy = "Crunching…"),
  shinyblocks::block_task_button("preview_task_button_secondary", "Export", label_busy = "Exporting…", variant = "secondary")
)
