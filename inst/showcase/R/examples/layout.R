htmltools::tagList(
  htmltools::tags$p(
    "The page you are viewing is itself built with shinyblocks. ",
    htmltools::tags$code("block_page()"),
    " wraps the document, ",
    htmltools::tags$code("block_sidebar()"),
    " on the left holds the ",
    htmltools::tags$code("block_nav_item()"),
    " links, ",
    htmltools::tags$code("block_header()"),
    " is the bar at the top, and the gallery sections below sit inside ",
    htmltools::tags$code("block_body()"),
    "."
  ),
  htmltools::tags$p(
    htmltools::tags$strong("How to verify:"),
    " resize the window to confirm the sidebar collapses below the header on narrow viewports, and tab through the page to confirm focus rings appear on every interactive element."
  )
)
