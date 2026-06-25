shinyblocks::block_cluster(
  gap = "sm",
  align = "center",
  justify = "center",
  style = "padding: 1rem;",
  shinyblocks::block_task_button("preview_task_button", "Run analysis", label_busy = "Crunching…"),
  shinyblocks::block_task_button("preview_task_button_secondary", "Export", label_busy = "Exporting…", variant = "secondary")
)
