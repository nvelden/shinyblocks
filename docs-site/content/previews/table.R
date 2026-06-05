shinyblocks::block_table(
  data.frame(
    metric = c("Revenue", "Orders", "Conversion"),
    value = c("$42k", "128", "4.8%"),
    delta = c("+12%", "+8%", "+0.6 pts")
  ),
  columns = list(
    value = shinyblocks::table_column(label = "Value", align = "right"),
    delta = shinyblocks::table_column(label = "Delta", align = "right")
  ),
  caption = "Monthly operating metrics."
)
