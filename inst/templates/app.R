library(shiny)
library(shinyblocks)

ui <- block_page(
  title = "shinyblocks demo",
  sidebar = block_sidebar(
    title = "shinyblocks",
    block_nav_item("Overview", selected = TRUE),
    block_nav_item("Reports"),
    block_nav_item("Settings")
  ),
  header = block_header("Overview"),
  block_card(
    title = "Active users",
    value = "1,284",
    "A minimal component placeholder."
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
