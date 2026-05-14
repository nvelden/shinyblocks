htmltools::tagList(
  block_dialog(
    id = "dialog_demo",
    title = "Confirm action",
    description = paste(
      "Phase 4.2 — input$dialog_demo reflects open/closed state.",
      "Use the trigger to open, or send a server update."
    ),
    htmltools::tags$p(
      "The trigger button opens the dialog locally.",
      "The server controls below call update_block_dialog()."
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
  )
)
