htmltools::tagList(
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.75rem;",
    htmltools::tags$p("Section one"),
    block_separator(),
    htmltools::tags$p("Section two")
  ),
  htmltools::div(
    style = paste(
      "display: flex;",
      "align-items: center;",
      "gap: 1rem;",
      "height: 2rem;"
    ),
    htmltools::tags$span("Filters"),
    block_separator(orientation = "vertical"),
    htmltools::tags$span("Sort"),
    block_separator(orientation = "vertical"),
    htmltools::tags$span("Export")
  )
)
