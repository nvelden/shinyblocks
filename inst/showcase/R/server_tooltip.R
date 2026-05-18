register_tooltip_showcase <- function(input, output, session) {
  output$showcase_tooltip_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("trigger", "...", "side", "align", "delay_duration", "style", "class"),
      Type = c(
        "character(1)",
        "htmltools tags / text",
        "character(1)",
        "character(1)",
        "numeric(1)",
        "character | list",
        "character"
      ),
      Default = c(
        "required",
        "(empty)",
        "\"top\"",
        "\"center\"",
        "700",
        "NULL",
        "NULL"
      ),
      Description = c(
        "Trigger label rendered on the anchor button.",
        "Tooltip content. HTML tags or text are accepted and serialized into the runtime payload.",
        "Side relative to the trigger: top / bottom / left / right.",
        "Alignment along the anchored side: center / start / end.",
        "Milliseconds to wait after hover or focus before opening.",
        "Inline CSS applied to the tooltip content container.",
        "Additional class merged onto the runtime tooltip content."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(output, "showcase_tooltip_api_table", suspendWhenHidden = FALSE)
}
