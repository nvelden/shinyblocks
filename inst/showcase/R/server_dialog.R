register_dialog_showcase <- function(input, output, session) {
  output$showcase_dialog_state <- shiny::renderText({
    value <- input$dialog_demo
    if (is.null(value)) "<NULL>" else if (isTRUE(value)) "TRUE" else "FALSE"
  })
  shiny::outputOptions(
    output,
    "showcase_dialog_state",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_dialog_open, {
    update_block_dialog(session, "dialog_demo", open = TRUE)
  })

  shiny::observeEvent(input$showcase_dialog_close, {
    update_block_dialog(session, "dialog_demo", open = FALSE)
  })
}
