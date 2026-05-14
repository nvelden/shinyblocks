block_dialog(
  title = "Phase 4.1 skeleton",
  description = paste(
    "Initial open state only — Shiny binding, trigger button,",
    "escape and outside-click close, focus trap, and update_block_dialog()",
    "land in sub-phases 4.2 through 4.5."
  ),
  htmltools::tags$p(
    "Click the overlay or the X button to close locally.",
    "This dialog is forced open via open = TRUE so it renders on load."
  ),
  open = TRUE
)
