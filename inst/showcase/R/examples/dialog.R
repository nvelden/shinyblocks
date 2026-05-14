htmltools::tagList(
  block_dialog(
    id = "dialog_demo",
    title = "Confirm action",
    description = paste(
      "Phase 4.3 — escape closes, focus traps inside the dialog,",
      "focus returns to the trigger on close, body scroll locks while open."
    ),
    htmltools::tags$p(
      "Try: open with the trigger, Tab through the focusable controls,",
      "press Escape, then notice focus returning to the trigger button."
    ),
    htmltools::tags$div(
      style = "display: flex; gap: 0.5rem;",
      block_button("First focusable", variant = "secondary"),
      block_button("Second focusable", variant = "outline")
    ),
    trigger = "Open dialog"
  ),
  htmltools::tags$div(
    style = "display: flex; gap: 0.5rem; margin-top: 1rem;",
    shiny::actionButton(
      "showcase_dialog_open",
      "Open from server",
      class = "sb-button sb-button-secondary sb-button-size-default"
    ),
    shiny::actionButton(
      "showcase_dialog_close",
      "Close from server",
      class = "sb-button sb-button-outline sb-button-size-default"
    )
  ),
  htmltools::tags$div(
    style = "margin-top: 1rem; font-size: 0.875rem;",
    "Current input$dialog_demo: ",
    shiny::textOutput("showcase_dialog_state", inline = TRUE)
  ),
  htmltools::tags$hr(style = "margin: 2rem 0;"),
  htmltools::tags$p(
    style = "font-size: 0.875rem; color: var(--muted-foreground);",
    "Second example — hide_title = TRUE keeps the dialog accessible",
    "to screen readers without rendering a visible heading."
  ),
  block_dialog(
    id = "dialog_hidden_title",
    title = "Quick confirmation",
    description = "Press OK to continue.",
    trigger = "Open hidden-title dialog",
    hide_title = TRUE
  )
)
