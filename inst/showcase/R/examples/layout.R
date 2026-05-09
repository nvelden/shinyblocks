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
    "This showcase also enables ",
    htmltools::tags$code("block_sidebar(collapsible = TRUE)"),
    ", so the desktop sidebar can be collapsed and the mobile trigger",
    " opens it as a sheet."
  ),
  htmltools::tags$p(
    htmltools::tags$strong("How to verify:"),
    paste(
      " use the sidebar toggle on desktop, resize below the mobile",
      "breakpoint to confirm the header trigger opens the sidebar,",
      "and tab through the nav to confirm arrow/home/end keyboard",
      "movement and visible focus rings."
    )
  )
)
