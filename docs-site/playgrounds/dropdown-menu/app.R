if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  # Try mounting from relative paths. In some environments (e.g. standard workers),
  # paths resolve relative to the worker script context. In others (e.g. blob workers/proxied environments),
  # they resolve relative to the main document base URL. We try both to be fully resilient.
  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch(
      {
        webr::mount("/packages", path)
        if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
          mounted <- TRUE
          break
        }
      },
      error = function(e) {
        # Ignore and try the next path
      }
    )
  }

  if (!mounted) {
    # If both relative paths fail, try absolute path as a last resort fallback
    # (works on the default nvelden.github.io/shinyblocks deployment)
    tryCatch(
      {
        webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
      },
      error = function(e) {
        stop("Failed to mount shinyblocks WASM package library: ", e$message)
      }
    )
  }

  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a

showcase_render_code <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    value <- eval(quoted, envir = env)
    if (is.null(value) || !length(value)) value <- ""
    block_code(
      code = paste(as.character(value), collapse = "\n"),
      language = "r",
      copyable = TRUE,
      line_numbers = TRUE
    )
  })
}

showcase_action_button <- function(input_id, label) {
  block_button(
    label,
    id = input_id,
    variant = "outline",
    size = "sm"
  )
}

ui <- block_page(
  title = "shinyblocks <U+00B7> Dropdown menu playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground",
      block_cluster(
        gap = "lg",
        align = "start",
        class = "showcase-playground__split",

        # Left Column: Controls Panel
        block_card(
          title = "Controls",
          class = "showcase-playground__controls",
          # Content Controls Group
          block_stack(
            gap = "sm",
            class = "showcase-controls-group showcase-controls-group--first",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Content"),
            block_field(
              block_field_label("trigger label", `for` = "showcase_dropdown_menu_doc_trigger"),
              block_input("showcase_dropdown_menu_doc_trigger", value = "Open menu")
            ),
            block_field(
              block_field_label("show icons", `for` = "showcase_dropdown_menu_doc_icons"),
              block_checkbox("showcase_dropdown_menu_doc_icons", "Leading item icons", value = TRUE)
            ),
            block_field(
              block_field_label("show shortcuts", `for` = "showcase_dropdown_menu_doc_shortcuts"),
              block_checkbox("showcase_dropdown_menu_doc_shortcuts", "Shortcut hints", value = TRUE)
            ),
            block_field(
              block_field_label("destructive item", `for` = "showcase_dropdown_menu_doc_destructive"),
              block_checkbox("showcase_dropdown_menu_doc_destructive", "Include a destructive \"Delete\" item", value = TRUE)
            )
          ),

          # State Controls Group
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(
              block_field_label("disabled item", `for` = "showcase_dropdown_menu_doc_disable_item"),
              block_checkbox("showcase_dropdown_menu_doc_disable_item", "Disable the \"Billing\" item", value = FALSE)
            ),
            block_field(
              block_field_label("disabled", `for` = "showcase_dropdown_menu_doc_disabled"),
              block_checkbox("showcase_dropdown_menu_doc_disabled", "Disable the trigger", value = FALSE)
            )
          ),

          # Styling Controls Group
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
            block_field(
              block_field_label("trigger_variant", `for` = "showcase_dropdown_menu_doc_variant"),
              block_select("showcase_dropdown_menu_doc_variant", choices = c("outline", "default", "secondary", "ghost"), selected = "outline", size = "sm")
            ),
            block_field(
              block_field_label("side", `for` = "showcase_dropdown_menu_doc_side"),
              block_select("showcase_dropdown_menu_doc_side", choices = c("bottom", "top", "left", "right"), selected = "bottom", size = "sm")
            ),
            block_field(
              block_field_label("align", `for` = "showcase_dropdown_menu_doc_align"),
              block_select("showcase_dropdown_menu_doc_align", choices = c("start", "center", "end"), selected = "start", size = "sm")
            ),
            block_field(
              block_field_label("style", `for` = "showcase_dropdown_menu_doc_style"),
              block_input("showcase_dropdown_menu_doc_style", value = "", placeholder = "e.g., min-width: 16rem;")
            )
          ),

          # Actions (Server Update) Group
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Actions (Server Update)"),
            block_cluster(
              gap = "sm",
              showcase_action_button("showcase_dropdown_menu_open", "Open"),
              showcase_action_button("showcase_dropdown_menu_close", "Close"),
              showcase_action_button("showcase_dropdown_menu_replace", "Replace items"),
              showcase_action_button("showcase_dropdown_menu_disable", "Disable"),
              showcase_action_button("showcase_dropdown_menu_enable", "Enable")
            )
          )
        ),

        # Right Column: Preview & Reactive Output Code Blocks
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",

          # Preview Section
          block_stack(
            gap = "sm",
            htmltools::tags$div(class = "showcase-playground__label", "Preview"),
            # Interactive Preview Canvas
            htmltools::tags$div(
              class = "showcase-preview-canvas showcase-preview-canvas--muted",
              style = "min-height: 180px;",
              uiOutput("showcase_dropdown_menu_preview_ui")
            )
          ),

          # Reactive Value Readout Indicator
          uiOutput("showcase_dropdown_menu_preview_value"),

          # Code Blocks Panel
          block_stack(
            gap = "md",
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "UI Definition"
              ),
              uiOutput("showcase_dropdown_menu_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "Server Action"
              ),
              uiOutput("showcase_dropdown_menu_reactive_code")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  replaced <- reactiveVal(FALSE)

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

  # When the "Replace items" action has fired, swap only the item list; every
  # styling/state control (trigger_variant, side, align, disabled, style) stays
  # live so the preview keeps responding to the panel.
  replaced_items <- function() {
    icons <- isTRUE(input$showcase_dropdown_menu_doc_icons)
    list(
      dropdown_menu_label("Workspace"),
      dropdown_menu_item("invite", "Invite members", icon = if (icons) "user" else NULL),
      dropdown_menu_item("new_team", "New team", icon = if (icons) "menu" else NULL)
    )
  }

  output$showcase_dropdown_menu_preview_ui <- renderUI({
    trigger <- input$showcase_dropdown_menu_doc_trigger %||% "Open menu"
    if (!nzchar(trigger)) trigger <- "Open menu"

    style_val <- input$showcase_dropdown_menu_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL

    items <- if (isTRUE(replaced())) replaced_items() else build_items()

    args <- c(
      list(trigger, id = "showcase_dropdown_menu_preview"),
      items,
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
  outputOptions(output, "showcase_dropdown_menu_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_dropdown_menu_preview_value <- showcase_render_code({
    value <- input$showcase_dropdown_menu_preview
    val_str <- if (is.null(value)) "<NULL>" else paste0('"', value, '"')
    paste0("input$showcase_dropdown_menu_preview = ", val_str)
  })
  outputOptions(output, "showcase_dropdown_menu_preview_value", suspendWhenHidden = FALSE)

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
  outputOptions(output, "showcase_dropdown_menu_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_dropdown_menu() code here."
  ))
  output$showcase_dropdown_menu_reactive_code <- showcase_render_code(reactive_code())
  outputOptions(output, "showcase_dropdown_menu_reactive_code", suspendWhenHidden = FALSE)

  observeEvent(input$showcase_dropdown_menu_open, {
    update_block_dropdown_menu(session, "showcase_dropdown_menu_preview", open = TRUE)
    reactive_code(paste0(
      "update_block_dropdown_menu(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dropdown_menu_preview\",\n",
      "  open = TRUE\n)"
    ))
  })

  observeEvent(input$showcase_dropdown_menu_close, {
    update_block_dropdown_menu(session, "showcase_dropdown_menu_preview", open = FALSE)
    reactive_code(paste0(
      "update_block_dropdown_menu(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dropdown_menu_preview\",\n",
      "  open = FALSE\n)"
    ))
  })

  observeEvent(input$showcase_dropdown_menu_replace, {
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

  observeEvent(input$showcase_dropdown_menu_disable, {
    update_block_dropdown_menu(session, "showcase_dropdown_menu_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_dropdown_menu(\n",
      "  session = session,\n",
      "  input_id = \"showcase_dropdown_menu_preview\",\n",
      "  disabled = TRUE\n)"
    ))
  })

  observeEvent(input$showcase_dropdown_menu_enable, {
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

shinyApp(ui, server)
