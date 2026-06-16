htmltools::tagList(
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 1rem 0; font-size: 0.875rem;",
    paste(
      "Embedded, display-only progress bar. Unlike Shiny's native progress",
      "notification panel, it renders inline where it is placed and is driven",
      "from the server with update_block_progress() / inc_block_progress().",
      "Full interactive playground lands in slice 4."
    )
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 1.5rem; max-width: 360px;",
    block_progress("showcase_progress_default", value = 0.6, label = "Upload", show_value = TRUE),
    block_progress(
      "showcase_progress_message",
      value = 0.35,
      message = "Importing rows...",
      detail = "1,200 of 3,400"
    ),
    block_progress("showcase_progress_success", value = 1, variant = "success", show_value = TRUE),
    block_progress("showcase_progress_destructive", value = 0.45, variant = "destructive"),
    block_progress("showcase_progress_indeterminate", indeterminate = TRUE, message = "Working...")
  ),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.75rem; max-width: 300px;",
    block_progress("showcase_parity_progress_default", value = 0.6, class = "sb-parity-progress-default"),
    block_progress(
      "showcase_parity_progress_success",
      value = 0.6,
      variant = "success",
      class = "sb-parity-progress-success"
    ),
    block_progress(
      "showcase_parity_progress_destructive",
      value = 0.6,
      variant = "destructive",
      class = "sb-parity-progress-destructive"
    ),
    block_progress(
      "showcase_parity_progress_indeterminate",
      indeterminate = TRUE,
      class = "sb-parity-progress-indeterminate"
    )
  )
)
