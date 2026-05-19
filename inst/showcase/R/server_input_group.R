register_input_group_showcase <- function(input, output, session) {
  output$showcase_input_group_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("...", "class"),
      Type = c("htmltools tags", "character"),
      Default = c("(empty)", "NULL"),
      Description = c(
        "Child tags. Order matters: leading addon, then the input, then trailing addon. Prefer block_input() for the control and block_input_group_addon() for addon slots.",
        "Additional class merged onto the .sb-input-group wrapper."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(output, "showcase_input_group_api_table", suspendWhenHidden = FALSE)
}
