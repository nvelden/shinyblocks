control_button <- function(input_id, label) {
  shiny::actionButton(
    input_id,
    label,
    class = paste(
      "sb-button",
      "sb-button-outline",
      "sb-button-size-sm"
    )
  )
}

arg_control <- function(...) {
  htmltools::div(
    style = "min-width: 14rem;",
    ...
  )
}

arg_row <- function(argument, default, value, description) {
  htmltools::tags$tr(
    htmltools::tags$td(htmltools::tags$code(argument)),
    htmltools::tags$td(htmltools::tags$code(default)),
    htmltools::tags$td(value),
    htmltools::tags$td(description)
  )
}

code_block <- function(code) {
  htmltools::tags$pre(
    style = paste(
      "margin: 0;",
      "padding: 0.75rem 1rem;",
      "overflow-x: auto;",
      "background: var(--muted);",
      "color: var(--foreground);",
      "border-radius: 0.5rem;",
      "font-size: 0.8125rem;",
      "line-height: 1.5;"
    ),
    htmltools::HTML(paste0(
      "<code>",
      htmltools::htmlEscape(code),
      "</code>"
    ))
  )
}

input_value_block <- function(output_id, input_name) {
  htmltools::tags$pre(
    style = paste(
      "margin: 0;",
      "padding: 0.75rem 1rem;",
      "overflow-x: auto;",
      "background: var(--muted);",
      "color: var(--foreground);",
      "border-radius: 0.5rem;",
      "font-size: 0.8125rem;",
      "line-height: 1.5;",
      "display: grid;",
      "grid-template-columns: max-content minmax(0, 1fr);",
      "column-gap: 0.5rem;"
    ),
    htmltools::tags$code(paste0("input$", input_name, " =")),
    htmltools::tags$code(shiny::textOutput(output_id, inline = TRUE))
  )
}

htmltools::tagList(
  htmltools::tags$style(htmltools::HTML(
    "
    .showcase-select-doc-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 0.875rem;
    }
    .showcase-select-doc-table th,
    .showcase-select-doc-table td {
      border-bottom: 1px solid var(--border);
      padding: 0.75rem;
      text-align: left;
      vertical-align: top;
    }
    .showcase-select-doc-table th {
      color: var(--muted-foreground);
      font-weight: 600;
    }
    .showcase-select-doc-table td:nth-child(1),
    .showcase-select-doc-table td:nth-child(2) {
      white-space: nowrap;
      width: 1%;
    }
    .showcase-select-doc-table .form-group {
      margin-bottom: 0;
    }
    .showcase-select-preview-custom .sb-select-control {
      border-style: dashed !important;
    }
    "
  )),
  block_field_set(
    block_field_legend("Configured preview"),
    block_field_group(
      block_field(
        block_field_label("Preview", `for` = "showcase_select_preview"),
        block_select(
          "showcase_select_preview",
          choices = c(Free = "free", Pro = "pro", Team = "team"),
          selected = "pro",
          placeholder = "Choose a plan",
          width = "100%"
        ),
        block_field_description(
          "Change the values in the argument table below to update this select."
        )
      ),
      input_value_block(
        "showcase_select_preview_value",
        "showcase_select_preview"
      ),
      code_block(paste0(
        "block_select(\n",
        "  input_id = \"showcase_select_preview\",\n",
        "  choices = c(Free = \"free\", Pro = \"pro\", Team = \"team\"),\n",
        "  selected = NULL,\n",
        "  placeholder = NULL,\n",
        "  disabled = FALSE,\n",
        "  width = NULL,\n",
        "  class = NULL,\n",
        "  size = \"default\",\n",
        "  invalid = FALSE\n",
        ")"
      ))
    )
  ),
  htmltools::tags$table(
    class = "showcase-select-doc-table",
    htmltools::tags$thead(
      htmltools::tags$tr(
        htmltools::tags$th("Argument"),
        htmltools::tags$th("Default"),
        htmltools::tags$th("Value"),
        htmltools::tags$th("Description")
      )
    ),
    htmltools::tags$tbody(
      arg_row(
        "choices",
        "required",
        arg_control(block_select(
          "showcase_select_doc_choices",
          choices = c(
            "Plans" = "plans",
            "Release channels" = "channels",
            "Sizes" = "sizes"
          ),
          selected = "plans"
        )),
        "The labels and values available in the select."
      ),
      arg_row(
        "selected",
        "NULL",
        arg_control(block_select(
          "showcase_select_doc_selected",
          choices = c(Free = "free", Pro = "pro", Team = "team"),
          selected = "pro"
        )),
        "Initial selected value. It must match one of the current choices."
      ),
      arg_row(
        "placeholder",
        "NULL",
        arg_control(block_textarea(
          "showcase_select_doc_placeholder",
          value = "Choose a plan",
          rows = 1
        )),
        "Optional empty-value prompt."
      ),
      arg_row(
        "disabled",
        "FALSE",
        arg_control(block_checkbox(
          "showcase_select_doc_disabled",
          "TRUE",
          value = FALSE
        )),
        "Disables browser interaction while server updates remain possible."
      ),
      arg_row(
        "width",
        "NULL",
        arg_control(block_textarea(
          "showcase_select_doc_width",
          value = "100%",
          rows = 1
        )),
        "CSS width applied to the runtime select wrapper."
      ),
      arg_row(
        "class",
        "NULL",
        arg_control(block_checkbox(
          "showcase_select_doc_class",
          "Use custom dashed-border class",
          value = FALSE
        )),
        "Additional class merged onto the runtime select wrapper."
      ),
      arg_row(
        "size",
        "default",
        arg_control(block_select(
          "showcase_select_doc_size",
          choices = c("default", "sm", "lg"),
          selected = "default"
        )),
        "Control size. One of default, sm, or lg."
      ),
      arg_row(
        "invalid",
        "FALSE",
        arg_control(block_checkbox(
          "showcase_select_doc_invalid",
          "TRUE",
          value = FALSE
        )),
        "Applies aria-invalid and destructive border/ring styling."
      )
    )
  ),
  htmltools::tags$hr(style = "border-top: 1px solid var(--border);"),
  block_field_set(
    block_field_legend("Reactivity"),
    block_field_group(
      block_field(
        block_field_label("Plan", `for` = "showcase_select_reactive"),
        block_select(
          "showcase_select_reactive",
          choices = c(Free = "free", Pro = "pro", Team = "team"),
          selected = "free",
          placeholder = "Choose a plan"
        ),
        block_field_description(
          "Use input$showcase_select_reactive to read the value."
        )
      ),
      htmltools::div(
        style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
        control_button("showcase_select_set_pro", "Set Pro"),
        control_button("showcase_select_clear", "Clear"),
        control_button("showcase_select_disable", "Disable"),
        control_button("showcase_select_enable", "Enable"),
        control_button("showcase_select_replace_choices", "Replace choices")
      ),
      input_value_block(
        "showcase_select_value",
        "showcase_select_reactive"
      ),
      code_block(paste0(
        "observeEvent(input$set_plan, {\n",
        "  update_block_select(\n",
        "    session = session,\n",
        "    input_id = \"showcase_select_reactive\",\n",
        "    selected = \"pro\",\n",
        "    choices = c(Free = \"free\", Pro = \"pro\", Team = \"team\"),\n",
        "    placeholder = \"Choose a plan\",\n",
        "    disabled = FALSE,\n",
        "    width = NULL,\n",
        "    class = NULL,\n",
        "    size = \"default\",\n",
        "    invalid = FALSE,\n",
        "    notify = TRUE\n",
        "  )\n",
        "})"
      ))
    )
  )
)
