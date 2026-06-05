register_nav_item_showcase <- function(input, output, session) {
  output$showcase_nav_item_preview_ui <- shiny::renderUI({
    label <- input$showcase_nav_item_doc_label %||% "Home"
    icon_name <- input$showcase_nav_item_doc_icon %||% "home"
    icon_tag <- if (icon_name != "none") icon_name else NULL
    selected <- isTRUE(input$showcase_nav_item_doc_selected)
    href <- input$showcase_nav_item_doc_href %||% "#"
    class <- if (isTRUE(input$showcase_nav_item_doc_class)) "sb-nav-demo-highlight" else NULL
    
    htmltools::tagList(
      htmltools::tags$style(".sb-nav-demo-highlight { outline: 2px solid var(--ring); outline-offset: 2px; }"),
      htmltools::div(
        style = "background: var(--sidebar); color: var(--sidebar-foreground); padding: 0.75rem; border-radius: 0.5rem; max-width: 18rem; width: 100%; border: 1px solid var(--border);",
        block_nav(
          class = "sb-sidebar-nav",
          block_nav_item(
            label = label,
            href = href,
            icon = icon_tag,
            selected = selected,
            class = class
          )
        )
      )
    )
  })
  shiny::outputOptions(
    output,
    "showcase_nav_item_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_nav_item_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    label_val <- input$showcase_nav_item_doc_label %||% "Home"
    icon_val <- input$showcase_nav_item_doc_icon %||% "home"
    selected_val <- isTRUE(input$showcase_nav_item_doc_selected)
    href_val <- input$showcase_nav_item_doc_href %||% "#"
    class_val <- isTRUE(input$showcase_nav_item_doc_class)

    args <- c(
      paste0("label = ", string_literal(label_val))
    )
    if (href_val != "#") {
      args <- c(args, paste0("href = ", string_literal(href_val)))
    }
    if (icon_val != "none") {
      args <- c(args, paste0('icon = "', icon_val, '"'))
    }
    if (selected_val) {
      args <- c(args, "selected = TRUE")
    }
    if (class_val) {
      args <- c(args, 'class = "sb-nav-demo-highlight"')
    }

    paste0("block_nav_item(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_nav_item_preview_code",
    suspendWhenHidden = FALSE
  )

  # API Reference table
  output$showcase_nav_item_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("label", "href", "icon", "selected", "class"),
      Type = c("character", "character", "character | tag", "logical", "character"),
      Default = c("required", "'#'", "NULL", "FALSE", "NULL"),
      Description = c(
        "Navigation item label string.",
        "Target URL destination.",
        "Leading Lucide icon name or tag.",
        "Whether the navigation item is active/selected.",
        "Additional CSS class merged onto the navigation item link."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_nav_item_api_table",
    suspendWhenHidden = FALSE
  )
}
