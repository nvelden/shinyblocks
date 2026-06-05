register_empty_showcase <- function(input, output, session) {
  output$showcase_empty_preview_ui <- shiny::renderUI({
    title <- input$showcase_empty_doc_title %||% "No projects found"
    if (!nzchar(title)) {
      title <- "No projects found"
    }
    description <- input$showcase_empty_doc_description %||% "Get started by creating a new repository."
    if (!nzchar(description)) {
      description <- NULL
    }
    icon <- input$showcase_empty_doc_icon %||% "folder"
    if (identical(icon, "none")) {
      icon <- NULL
    }
    has_action <- isTRUE(input$showcase_empty_doc_action)
    class <- input$showcase_empty_doc_class %||% ""
    if (!nzchar(class) || class == "none") {
      class <- NULL
    }

    action_tag <- NULL
    if (has_action) {
      action_tag <- block_button(
        label = "Create project",
        id = "showcase_empty_project_btn",
        variant = "default",
        icon = "plus"
      )
    }

    block_empty(
      title = title,
      description = description,
      icon = icon,
      action = action_tag,
      class = class
    )
  })
  shiny::outputOptions(
    output,
    "showcase_empty_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_empty_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    title_val <- input$showcase_empty_doc_title %||% "No projects found"
    if (!nzchar(title_val)) {
      title_val <- "No projects found"
    }
    description_val <- input$showcase_empty_doc_description %||% "Get started by creating a new repository."
    icon_val <- input$showcase_empty_doc_icon %||% "folder"
    has_action_val <- isTRUE(input$showcase_empty_doc_action)
    class_val <- input$showcase_empty_doc_class %||% ""

    args <- c(
      paste0("title = ", string_literal(title_val))
    )

    if (nzchar(description_val)) {
      args <- c(args, paste0("description = ", string_literal(description_val)))
    }
    if (icon_val != "none") {
      args <- c(args, paste0('icon = "', icon_val, '"'))
    }
    if (has_action_val) {
      args <- c(args, paste0(
        "action = block_button(\n",
        "    label = \"Create project\",\n",
        "    id = \"showcase_empty_project_btn\",\n",
        "    variant = \"default\",\n",
        "    icon = \"plus\"\n",
        "  )"
      ))
    }
    if (nzchar(class_val) && class_val != "none") {
      args <- c(args, paste0('class = "', class_val, '"'))
    }

    paste0("block_empty(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_empty_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_empty_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("title", "...", "description", "icon", "action", "class"),
      Type = c("character | tag", "named tags", "character | tag", "character | tag", "shiny.tag", "character"),
      Default = c("required", "none", "NULL", "NULL", "NULL", "NULL"),
      Description = c(
        "Header title string or child tag.",
        "Optional body elements.",
        "Optional descriptive text blocks supporting simple HTML.",
        "Lucide leading icon name or tag.",
        "Primary action element, typically a block_button().",
        "Additional CSS class merged onto the empty state container."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_empty_api_table",
    suspendWhenHidden = FALSE
  )
}
