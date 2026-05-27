register_tooltip_showcase <- function(input, output, session) {
  output$showcase_tooltip_preview_ui <- shiny::renderUI({
    trigger <- input$showcase_tooltip_doc_trigger %||% "Hover me"
    content <- input$showcase_tooltip_doc_content %||% "Tooltip details go here."
    side <- input$showcase_tooltip_doc_side %||% "top"
    align <- input$showcase_tooltip_doc_align %||% "center"
    delay <- as.numeric(input$showcase_tooltip_doc_delay %||% 700)
    
    style_val <- input$showcase_tooltip_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL
    
    class_val <- if (isTRUE(input$showcase_tooltip_doc_class)) {
      "showcase-tooltip-preview-custom"
    } else {
      NULL
    }
    
    block_tooltip(
      trigger = trigger,
      content,
      side = side,
      align = align,
      delay_duration = delay,
      style = style_val,
      class = class_val
    )
  })
  shiny::outputOptions(output, "showcase_tooltip_preview_ui", suspendWhenHidden = FALSE)
  
  output$showcase_tooltip_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    trigger <- input$showcase_tooltip_doc_trigger %||% "Hover me"
    content <- input$showcase_tooltip_doc_content %||% "Tooltip details go here."
    side <- input$showcase_tooltip_doc_side %||% "top"
    align <- input$showcase_tooltip_doc_align %||% "center"
    delay <- as.numeric(input$showcase_tooltip_doc_delay %||% 700)
    custom_class <- isTRUE(input$showcase_tooltip_doc_class)
    style_val <- input$showcase_tooltip_doc_style %||% ""
    
    args <- c(
      paste0("trigger = ", string_literal(trigger)),
      string_literal(content)
    )
    if (side != "top") args <- c(args, paste0("side = ", string_literal(side)))
    if (align != "center") args <- c(args, paste0("align = ", string_literal(align)))
    if (delay != 700) args <- c(args, paste0('delay_duration = ', delay))
    if (custom_class) args <- c(args, 'class = "showcase-tooltip-preview-custom"')
    if (nzchar(style_val)) args <- c(args, paste0("style = ", string_literal(style_val)))
    
    paste0("block_tooltip(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(output, "showcase_tooltip_preview_code", suspendWhenHidden = FALSE)

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
