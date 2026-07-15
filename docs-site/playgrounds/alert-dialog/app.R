if (!"shinyblocks" %in% rownames(installed.packages())) {
  install.packages("shinyblocks", repos = c("https://nvelden.r-universe.dev", "https://repo.r-wasm.org"))
}
library(shiny)
library(shinyblocks)

ui <- block_page(
  title = "Alert dialog playground",
  theme = htmltools::tagList(htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")),
  htmltools::div(
    `data-shinyblocks-root` = "",
    style = "padding:1rem;max-width:100%;box-sizing:border-box;",
    block_cluster(
      gap = "lg", align = "start", class = "showcase-playground__split",
      block_card(
        title = "Controls", class = "showcase-playground__controls",
        block_field(block_field_label("Title", `for` = "title"), block_input("title", value = "Delete account?")),
        block_field(block_field_label("Description", `for` = "description"), block_textarea("description", value = "This action cannot be undone.", rows = 2, resize = "none")),
        block_field(block_field_label("Variant", `for` = "variant"), block_select("variant", c("default", "destructive"), selected = "destructive", size = "sm")),
        block_button("Open from server", id = "open", variant = "outline", size = "sm")
      ),
      block_stack(
        gap = "md", class = "showcase-playground__main",
        htmltools::div(class = "showcase-preview-canvas showcase-preview-canvas--muted", block_alert_dialog("decision", "Delete account?", description = "This action cannot be undone.", confirm_label = "Delete", trigger = "Delete account", confirm_variant = "destructive")),
        htmltools::tags$pre(shiny::verbatimTextOutput("value")),
        block_code('block_alert_dialog("decision", "Delete account?", confirm_label = "Delete", trigger = "Delete account", confirm_variant = "destructive")', language = "r", copyable = TRUE)
      )
    )
  )
)
server <- function(input, output, session) {
  observe({
    update_block_alert_dialog(session, "decision", title = input$title, description = input$description, confirm_variant = input$variant)
  })
  observeEvent(input$open, update_block_alert_dialog(session, "decision", open = TRUE))
  output$value <- renderText(if (is.null(input$decision)) "input$decision = NULL" else paste0('input$decision = "', input$decision, '"'))
}
shinyApp(ui, server)
