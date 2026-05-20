register_card_showcase <- function(input, output, session) {
  output$showcase_card_preview_ui <- shiny::renderUI({
    title <- input$showcase_card_doc_title %||% "Card Title"
    if (!nzchar(title)) title <- NULL
    
    desc <- input$showcase_card_doc_desc %||% "Card Description"
    if (!nzchar(desc)) desc <- NULL
    
    value <- input$showcase_card_doc_value %||% "$45,231.89"
    if (!nzchar(value)) value <- NULL
    
    body <- input$showcase_card_doc_body %||% "+20.1% from last month"
    if (!nzchar(body)) body <- NULL
    
    has_footer <- isTRUE(input$showcase_card_doc_footer)
    footer_tag <- NULL
    if (has_footer) {
      footer_tag <- block_button("View details", variant = "outline", size = "sm")
    }
    
    class <- input$showcase_card_doc_class %||% ""
    if (!nzchar(class) || class == "none") class <- NULL

    block_card(
      title = title,
      description = desc,
      value = value,
      footer = footer_tag,
      class = class,
      body
    )
  })
  shiny::outputOptions(
    output,
    "showcase_card_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_card_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    title_val <- input$showcase_card_doc_title %||% "Card Title"
    desc_val <- input$showcase_card_doc_desc %||% "Card Description"
    value_val <- input$showcase_card_doc_value %||% "$45,231.89"
    body_val <- input$showcase_card_doc_body %||% "+20.1% from last month"
    has_footer_val <- isTRUE(input$showcase_card_doc_footer)
    class_val <- input$showcase_card_doc_class %||% ""

    args <- c()
    if (nzchar(title_val)) {
      args <- c(args, paste0("title = ", string_literal(title_val)))
    }
    if (nzchar(desc_val)) {
      args <- c(args, paste0("description = ", string_literal(desc_val)))
    }
    if (nzchar(value_val)) {
      args <- c(args, paste0("value = ", string_literal(value_val)))
    }
    if (has_footer_val) {
      args <- c(args, "footer = block_button(\"View details\", variant = \"outline\", size = \"sm\")")
    }
    if (nzchar(class_val) && class_val != "none") {
      args <- c(args, paste0('class = "', class_val, '"'))
    }
    if (nzchar(body_val)) {
      args <- c(args, string_literal(body_val))
    }

    paste0("block_card(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_card_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_card_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("...", "title", "description", "value", "footer", "class"),
      Type = c("named/unnamed elements", "character | tag", "character | tag", "character", "shiny.tag", "character"),
      Default = c("none", "NULL", "NULL", "NULL", "NULL", "NULL"),
      Description = c(
        "Card content/body elements.",
        "Optional card header title.",
        "Optional card header description.",
        "Optional primary numeric or textual highlight.",
        "Optional card footer element.",
        "Additional CSS class merged onto the card container."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_card_api_table",
    suspendWhenHidden = FALSE
  )
}
