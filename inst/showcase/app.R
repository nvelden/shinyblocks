library(shiny)
library(shinyblocks)

source(file.path("R", "render_example.R"), local = TRUE)

ui <- block_page(
  title = "shinyblocks showcase",
  sidebar = block_sidebar(
    title = "shinyblocks",
    block_nav_item("Shell", href = "#shell", selected = TRUE)
  ),
  header = block_header("Showcase"),
  render_example("R/examples/shell.R")
)

server <- function(input, output, session) {}

shinyApp(ui, server)
