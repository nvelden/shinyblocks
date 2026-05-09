library(shiny)
library(shinyblocks)

ui <- block_page(
  title = "block_button",
  header = block_header("Buttons"),
  block_card(
    title = "Variants",
    block_button("Default"),
    block_button("Secondary", variant = "secondary"),
    block_button("Outline", variant = "outline"),
    block_button("Ghost", variant = "ghost"),
    block_button("Destructive", variant = "destructive"),
    block_button("Link", variant = "link")
  ),
  block_card(
    title = "Sizes",
    block_button("Default size"),
    block_button("Small", size = "sm"),
    block_button("Large", size = "lg")
  ),
  block_card(
    title = "With icons",
    block_button("Search", icon = "search"),
    block_button("Open", icon = "arrow-right", icon_position = "inline-end")
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
