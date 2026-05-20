shinyblocks::block_code(
  code = "library(shinyblocks)\n\nui <- block_page(\n  block_header(title = \"Dashboard\"),\n  block_body(\n    block_card(\n      title = \"Active Users\",\n      value = \"1,234\"\n    )\n  )\n)\n\nserver <- function(input, output, session) {}\nshinyApp(ui, server)",
  language = "r",
  copyable = TRUE,
  variant = "default"
)
