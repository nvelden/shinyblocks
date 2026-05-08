library(shiny)
library(shinyshadcn)

ui <- shadcn_page(
  title = "shinyshadcn demo",
  sidebar = shadcn_sidebar(
    title = "shinyshadcn",
    shadcn_nav_item("Overview", selected = TRUE),
    shadcn_nav_item("Reports"),
    shadcn_nav_item("Settings")
  ),
  header = shadcn_header("Overview"),
  shadcn_card(
    title = "Active users",
    value = "1,284",
    "A minimal component placeholder."
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
