register_dropdown_menu_showcase <- function(input, output, session) {
  replaced <- shiny::reactiveVal(FALSE)

  build_items <- function() {
    icons <- isTRUE(input$showcase_dropdown_menu_doc_icons)
    shortcuts <- isTRUE(input$showcase_dropdown_menu_doc_shortcuts)
    disable_billing <- isTRUE(input$showcase_dropdown_menu_doc_disable_item)
    destructive <- isTRUE(input$showcase_dropdown_menu_doc_destructive)

    parts <- list(
      dropdown_menu_label("My Account"),
      dropdown_menu_item(
        "profile", "Profile",
        icon = if (icons) "user" else NULL,
        shortcut = if (shortcuts) "⌘P" else NULL
      ),
      dropdown_menu_item(
        "billing", "Billing",
        icon = if (icons) "dollar-sign" else NULL,
        disabled = disable_billing
      ),
      dropdown_menu_item(
        "settings", "Settings",
        icon = if (icons) "settings" else NULL,
        shortcut = if (shortcuts) "⌘," else NULL
      ),
      dropdown_menu_separator()
    )
    if (destructive) {
      parts <- c(parts, list(
        dropdown_menu_item(
          "delete", "Delete account",
          icon = if (icons) "trash" else NULL,
          variant = "destructive"
        )
      ))
    }
    parts <- c(parts, list(
      dropdown_menu_item("logout", "Log out", icon = if (icons) "log-out" else NULL)
    ))
    parts
  }

  output$showcase_dropdown_menu_preview_ui <- shiny::renderUI({
    if (isTRUE(replaced())) {
      return(block_dropdown_menu(
        input$showcase_dropdown_menu_doc_trigger %||% "Open menu",
        id = "showcase_dropdown_menu_preview",
        dropdown_menu_label("Workspace"),
        dropdown_menu_item("invite", "Invite members", icon = "user"),
        dropdown_menu_item("new_team", "New team", icon = "menu"),
        side = input$showcase_dropdown_menu_doc_side %||% "bottom",
        align = input$showcase_dropdown_menu_doc_align %||% "start"
      ))
    }

    trigger <- input$showcase_dropdown_menu_doc_trigger %||% "Open menu"
    if (!nzchar(trigger)) trigger <- "Open menu"

    style_val <- input$showcase_dropdown_menu_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL

    args <- c(
      list(trigger, id = "showcase_dropdown_menu_preview"),
      build_items(),
      list(
        side = input$showcase_dropdown_menu_doc_side %||% "bottom",
        align = input$showcase_dropdown_menu_doc_align %||% "start",
        trigger_variant = input$showcase_dropdown_menu_doc_variant %||% "outline",
        disabled = isTRUE(input$showcase_dropdown_menu_doc_disabled),
        style = style_val
      )
    )
    do.call(block_dropdown_menu, args)
  })
  shiny::outputOptions(output, "showcase_dropdown_menu_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_dropdown_menu_preview_value <- showcase_render_code({
    value <- input$showcase_dropdown_menu_preview
    val_str <- if (is.null(value)) "<NULL>" else paste0('"', value, '"')
    paste0("input$showcase_dropdown_menu_preview = ", val_str)
  })
  shiny::outputOptions(output, "showcase_dropdown_menu_preview_value", suspendWhenHidden = FALSE)

  output$showcase_dropdown_menu_preview_code <- showcase_render_code({
    string_literal <- function(value) paste0('"', value, '"')
    icons <- isTRUE(input$showcase_dropdown_menu_doc_icons)
    shortcuts <- isTRUE(input$showcase_dropdown_menu_doc_shortcuts)
    disable_billing <- isTRUE(input$showcase_dropdown_menu_doc_disable_item)
    destructive <- isTRUE(input$showcase_dropdown_menu_doc_destructive)
    trigger <- input$showcase_dropdown_menu_doc_trigger %||% "Open menu"
    side <- input$showcase_dropdown_menu_doc_side %||% "bottom"
    align <- input$showcase_dropdown_menu_doc_align %||% "start"
    variant <- input$showcase_dropdown_menu_doc_variant %||% "outline"

    item_line <- function(value, label, icon = NULL, shortcut = NULL, disabled = FALSE, variant = NULL) {
      bits <- c(string_literal(value), string_literal(label))
      if (!is.null(icon)) bits <- c(bits, paste0("icon = ", string_literal(icon)))
      if (!is.null(shortcut)) bits <- c(bits, paste0("shortcut = ", string_literal(shortcut)))
      if (isTRUE(disabled)) bits <- c(bits, "disabled = TRUE")
      if (!is.null(variant)) bits <- c(bits, paste0("variant = ", string_literal(variant)))
      paste0("  dropdown_menu_item(", paste(bits, collapse = ", "), ")")
    }

    lines <- c(
      '  dropdown_menu_label("My Account")',
      item_line("profile", "Profile", icon = if (icons) "user", shortcut = if (shortcuts) "⌘P"),
      item_line("billing", "Billing", icon = if (icons) "dollar-sign", disabled = disable_billing),
      item_line("settings", "Settings", icon = if (icons) "settings", shortcut = if (shortcuts) "⌘,"),
      "  dropdown_menu_separator()"
    )
    if (destructive) {
      lines <- c(lines, item_line("delete", "Delete account", icon = if (icons) "trash", variant = "destructive"))
    }
    lines <- c(lines, item_line("logout", "Log out", icon = if (icons) "log-out"))

    tail_args <- c()
    if (!identical(side, "bottom")) tail_args <- c(tail_args, paste0("side = ", string_literal(side)))
    if (!identical(align, "start")) tail_args <- c(tail_args, paste0("align = ", string_literal(align)))
    if (!identical(variant, "outline")) tail_args <- c(tail_args, paste0("trigger_variant = ", string_literal(variant)))
    if (isTRUE(input$showcase_dropdown_menu_doc_disabled)) tail_args <- c(tail_args, "disabled = TRUE")
    tail_str <- if (length(tail_args)) paste0(",\n  ", paste(tail_args, collapse = ",\n  ")) else ""

    paste0(
      "block_dropdown_menu(\n  ",
      string_literal(trigger), ",\n  ",
      'id = "menu",\n',
      paste(lines, collapse = ",\n"),
      tail_str,
      "\n)"
    )
  })
  shiny::outputOptions(output, "showcase_dropdown_menu_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_dropdown_menu() code here."
  ))
  output$showcase_dropdown_menu_reactive_code <- showcase_render_code(reactive_code())
  shiny::outputOptions(output, "showcase_dropdown_menu_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_dropdown_menu_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("trigger", "...", "id", "label", "side", "align", "trigger_variant", "disabled", "style", "class"),
      Type = c("character | tag", "menu parts", "character", "character", "character", "character", "character", "logical", "character | list", "character"),
      Default = c("required", "-", "NULL", "NULL", "\"bottom\"", "\"start\"", "\"outline\"", "FALSE", "NULL", "NULL"),
      Description = c(
        "Trigger content: a string label or an htmltools tag (icon button, avatar).",
        "Menu parts from dropdown_menu_item(), dropdown_menu_label(), dropdown_menu_separator().",
        "Optional input id. input$<id> reports the chosen item value as an event.",
        "Accessible name for the trigger; recommended for icon-only triggers.",
        "Side of the trigger to anchor on. One of bottom, top, left, right.",
        "Alignment along the anchored side. One of start, center, end.",
        "Button variant for a string trigger.",
        "Whether the trigger is disabled.",
        "Inline CSS applied to the menu content container.",
        "Additional class merged onto the menu content container."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_dropdown_menu_api_table", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$showcase_dropdown_menu_open, {
    update_block_dropdown_menu(session, "showcase_dropdown_menu_preview", open = TRUE)
    reactive_code(paste0(
      "update_block_dropdown_menu(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dropdown_menu_preview\",\n",
      "  open = TRUE\n)"
    ))
  })

  shiny::observeEvent(input$showcase_dropdown_menu_close, {
    update_block_dropdown_menu(session, "showcase_dropdown_menu_preview", open = FALSE)
    reactive_code(paste0(
      "update_block_dropdown_menu(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dropdown_menu_preview\",\n",
      "  open = FALSE\n)"
    ))
  })

  shiny::observeEvent(input$showcase_dropdown_menu_replace, {
    replaced(TRUE)
    update_block_dropdown_menu(
      session,
      "showcase_dropdown_menu_preview",
      items = list(
        dropdown_menu_label("Workspace"),
        dropdown_menu_item("invite", "Invite members", icon = "user"),
        dropdown_menu_item("new_team", "New team", icon = "menu")
      )
    )
    reactive_code(paste0(
      "update_block_dropdown_menu(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dropdown_menu_preview\",\n",
      "  items = list(\n",
      "    dropdown_menu_label(\"Workspace\"),\n",
      "    dropdown_menu_item(\"invite\", \"Invite members\", icon = \"user\"),\n",
      "    dropdown_menu_item(\"new_team\", \"New team\", icon = \"menu\")\n",
      "  )\n)"
    ))
  })

  shiny::observeEvent(input$showcase_dropdown_menu_disable, {
    update_block_dropdown_menu(session, "showcase_dropdown_menu_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_dropdown_menu(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dropdown_menu_preview\",\n",
      "  disabled = TRUE\n)"
    ))
  })

  shiny::observeEvent(input$showcase_dropdown_menu_enable, {
    replaced(FALSE)
    update_block_dropdown_menu(session, "showcase_dropdown_menu_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_dropdown_menu(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dropdown_menu_preview\",\n",
      "  disabled = FALSE\n)"
    ))
  })
}
