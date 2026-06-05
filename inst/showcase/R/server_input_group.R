register_input_group_showcase <- function(input, output, session) {
  output$showcase_input_group_preview_ui <- shiny::renderUI({
    pattern <- input$showcase_input_group_doc_pattern %||% "leading_icon"
    placeholder <- input$showcase_input_group_doc_placeholder %||% "Search workspace..."
    initial_value <- input$showcase_input_group_doc_value %||% ""
    invalid <- isTRUE(input$showcase_input_group_doc_invalid)
    disabled <- isTRUE(input$showcase_input_group_doc_disabled)
    
    # Construct children based on pattern
    children <- list()
    
    if (pattern == "leading_icon") {
      children <- list(
        block_input_group_addon(block_icon("search")),
        block_input("showcase_input_group_preview", value = initial_value, placeholder = placeholder, invalid = invalid, disabled = disabled)
      )
    } else if (pattern == "trailing_icon") {
      children <- list(
        block_input("showcase_input_group_preview", value = initial_value, placeholder = placeholder, invalid = invalid, disabled = disabled),
        block_input_group_addon(block_icon("mail"))
      )
    } else if (pattern == "both_addons") {
      children <- list(
        block_input_group_addon("$"),
        block_input("showcase_input_group_preview", value = initial_value, placeholder = placeholder, invalid = invalid, disabled = disabled),
        block_input_group_addon("USD")
      )
    } else if (pattern == "workspace_slug") {
      children <- list(
        block_input_group_addon("acme.app/"),
        block_input("showcase_input_group_preview", value = initial_value, placeholder = placeholder, invalid = invalid, disabled = disabled)
      )
    }
    
    style_val <- input$showcase_input_group_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL

    class_val <- if (isTRUE(input$showcase_input_group_doc_class)) {
      "showcase-input-group-preview-custom"
    } else {
      NULL
    }
    
    args_list <- c(children, list(class = class_val))
    if (!is.null(style_val)) {
      args_list <- c(args_list, list(style = style_val))
    }
    do.call(block_input_group, args_list)
  })
  shiny::outputOptions(output, "showcase_input_group_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_input_group_preview_value <- showcase_render_code({
    value <- input$showcase_input_group_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (!nzchar(value)) {
      "<EMPTY>"
    } else {
      value
    }
    paste0("input$showcase_input_group_preview = ", val_str)
  })
  shiny::outputOptions(output, "showcase_input_group_preview_value", suspendWhenHidden = FALSE)

  output$showcase_input_group_preview_code <- showcase_render_code({
    pattern <- input$showcase_input_group_doc_pattern %||% "leading_icon"
    placeholder <- input$showcase_input_group_doc_placeholder %||% "Search workspace..."
    initial_value <- input$showcase_input_group_doc_value %||% ""
    invalid <- isTRUE(input$showcase_input_group_doc_invalid)
    disabled <- isTRUE(input$showcase_input_group_doc_disabled)
    custom_class <- isTRUE(input$showcase_input_group_doc_class)
    style_val <- input$showcase_input_group_doc_style %||% ""
    
    input_args <- c(
      'input_id = "showcase_input_group_preview"',
      paste0('value = "', initial_value, '"'),
      paste0('placeholder = "', placeholder, '"')
    )
    if (invalid) input_args <- c(input_args, "invalid = TRUE")
    if (disabled) input_args <- c(input_args, "disabled = TRUE")
    
    input_code <- paste0("block_input(\n    ", paste(input_args, collapse = ",\n    "), "\n  )")
    
    children_code <- ""
    if (pattern == "leading_icon") {
      children_code <- paste0("  block_input_group_addon(block_icon(\"search\")),\n  ", input_code)
    } else if (pattern == "trailing_icon") {
      children_code <- paste0("  ", input_code, ",\n  block_input_group_addon(block_icon(\"mail\"))")
    } else if (pattern == "both_addons") {
      children_code <- paste0("  block_input_group_addon(\"$\"),\n  ", input_code, ",\n  block_input_group_addon(\"USD\")")
    } else if (pattern == "workspace_slug") {
      children_code <- paste0("  block_input_group_addon(\"acme.app/\"),\n  ", input_code)
    }
    
    group_args <- c(children_code)
    if (custom_class) {
      group_args <- c(group_args, 'class = "showcase-input-group-preview-custom"')
    }
    if (nzchar(style_val)) {
      group_args <- c(group_args, paste0('style = "', style_val, '"'))
    }
    
    paste0("block_input_group(\n", paste(group_args, collapse = ",\n"), "\n)")
  })
  shiny::outputOptions(output, "showcase_input_group_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_input() code here."
  ))

  output$showcase_input_group_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(output, "showcase_input_group_reactive_code", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$showcase_input_group_set_value, {
    update_block_input(
      session,
      "showcase_input_group_preview",
      value = "workspace-success"
    )
    reactive_code(paste0(
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_group_preview\",\n",
      "  value = \"workspace-success\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_input_group_clear, {
    initial_value <- input$showcase_input_group_doc_value %||% ""
    update_block_input(
      session,
      "showcase_input_group_preview",
      value = initial_value
    )
    reactive_code(paste0(
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_group_preview\",\n",
      "  value = \"", initial_value, "\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_input_group_disable, {
    update_block_input(session, "showcase_input_group_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_group_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_input_group_enable, {
    update_block_input(session, "showcase_input_group_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_input_group_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  output$showcase_input_group_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("...", "class"),
      Type = c("htmltools tags", "character"),
      Default = c("(empty)", "NULL"),
      Description = c(
        "Child tags. Order matters: leading addon, then the input, then trailing addon. Prefer block_input() for the control and block_input_group_addon() for addon slots.",
        "Additional class merged onto the .sb-input-group wrapper."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_input_group_api_table", suspendWhenHidden = FALSE)
}
