if (!"shinyblocks" %in% rownames(installed.packages())) {
  install.packages(
    "shinyblocks",
    repos = c("https://nvelden.r-universe.dev", "https://repo.r-wasm.org")
  )
}
library(shiny)
library(shinyblocks)

ui <- block_page(
  title = "shinyblocks · Pagination playground",
  theme = htmltools::tags$link(
    rel = "stylesheet",
    href = "../../../shinyblocks-runtime-override.css"
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; overflow-x: hidden;",
    block_cluster(
      gap = "lg",
      align = "start",
      class = "showcase-playground__split",
      block_card(
        title = "Preview",
        class = "showcase-playground__preview",
        htmltools::tags$div(
          style = "padding: 2rem 0; border: 1px dashed var(--border);",
          block_pagination("page", 20, 8)
        ),
        htmltools::tags$p(
          "Selected page: ",
          shiny::textOutput("value", inline = TRUE)
        ),
        block_code(
          'block_pagination("page", pages = 20, selected = 8)',
          language = "r",
          copyable = TRUE
        )
      ),
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        block_stack(
          gap = "sm",
          block_button(
            "First page",
            id = "first",
            variant = "outline",
            size = "sm"
          ),
          block_button(
            "Last page",
            id = "last",
            variant = "outline",
            size = "sm"
          ),
          block_button(
            "Toggle disabled",
            id = "disable",
            variant = "outline",
            size = "sm"
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  disabled <- reactiveVal(FALSE)
  output$value <- renderText(if (is.null(input$page)) 8L else input$page)
  observeEvent(
    input$first,
    update_block_pagination(session, "page", selected = 1)
  )
  observeEvent(
    input$last,
    update_block_pagination(session, "page", selected = 20)
  )
  observeEvent(input$disable, {
    disabled(!disabled())
    update_block_pagination(session, "page", disabled = disabled())
  })
}

shinyApp(ui, server)
