shinyblocks::block_stack(
  gap = "md",
  shinyblocks::block_cluster(
    justify = "between",
    htmltools::tags$h3("Dashboard"),
    shinyblocks::block_dark_mode_toggle()
  ),
  shinyblocks::block_grid(
    min_width = "14rem",
    shinyblocks::block_card(title = "Revenue", value = "$42,100"),
    shinyblocks::block_card(title = "Orders", value = "2,418")
  )
)
