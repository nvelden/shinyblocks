register_field_showcase <- function(input, output, session) {
  output$showcase_field_preview_ui <- shiny::renderUI({
    legend_text <- input$showcase_field_legend %||% "Account Details"
    fname_label <- input$showcase_field_fname_label %||% "First name"
    fname_desc <- input$showcase_field_fname_desc %||% "Enter your primary name."
    email_label <- input$showcase_field_email_label %||% "Email address"
    email_desc <- input$showcase_field_email_desc %||% "We will never share your email address with anyone."
    pw_error <- input$showcase_field_pw_error %||% "Password must be at least 8 characters long and contain a digit."
    pw_invalid <- isTRUE(input$showcase_field_pw_invalid)
    custom_class <- if (isTRUE(input$showcase_field_class)) "border-dashed" else NULL

    block_field_set(
      class = custom_class,
      block_field_legend(legend_text),
      block_field_group(
        block_field(
          block_field_label(fname_label, `for` = "showcase_field_demo_fname"),
          block_input("showcase_field_demo_fname", value = "John")
        ),
        block_field(
          block_field_label("Last name", `for` = "showcase_field_demo_lname"),
          block_input("showcase_field_demo_lname", value = "Doe"),
          block_field_description(fname_desc)
        )
      ),
      block_field(
        block_field_label(email_label, `for` = "showcase_field_demo_email"),
        block_input("showcase_field_demo_email", type = "email", value = "john.doe@example.com"),
        block_field_description(email_desc)
      ),
      if (pw_invalid) {
        block_field_invalid(
          block_field(
            block_field_label("Password", `for` = "showcase_field_demo_pw"),
            block_input("showcase_field_demo_pw", type = "password", value = "12345")
          ),
          message = pw_error
        )
      } else {
        block_field(
          block_field_label("Password", `for` = "showcase_field_demo_pw"),
          block_input("showcase_field_demo_pw", type = "password", value = "12345")
        )
      }
    )
  })
  shiny::outputOptions(
    output,
    "showcase_field_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_field_preview_code <- showcase_render_code({
    legend_text <- input$showcase_field_legend %||% "Account Details"
    fname_label <- input$showcase_field_fname_label %||% "First name"
    fname_desc <- input$showcase_field_fname_desc %||% "Enter your primary name."
    email_label <- input$showcase_field_email_label %||% "Email address"
    email_desc <- input$showcase_field_email_desc %||% "We will never share your email address with anyone."
    pw_error <- input$showcase_field_pw_error %||% "Password must be at least 8 characters long and contain a digit."
    pw_invalid <- isTRUE(input$showcase_field_pw_invalid)
    class_arg <- if (isTRUE(input$showcase_field_class)) ", class = \"border-dashed\"" else ""

    pw_block <- if (pw_invalid) {
      paste0(
        "  block_field_invalid(\n",
        "    block_field(\n",
        "      block_field_label(\"Password\", `for` = \"password\"),\n",
        "      block_input(\"password\", type = \"password\")\n",
        "    ),\n",
        "    message = \"", pw_error, "\"\n",
        "  )"
      )
    } else {
      paste0(
        "  block_field(\n",
        "    block_field_label(\"Password\", `for` = \"password\"),\n",
        "    block_input(\"password\", type = \"password\")\n",
        "  )"
      )
    }

    paste0(
      "block_field_set(\n",
      "  block_field_legend(\"", legend_text, "\")", class_arg, ",\n",
      "  block_field_group(\n",
      "    block_field(\n",
      "      block_field_label(\"", fname_label, "\", `for` = \"first_name\"),\n",
      "      block_input(\"first_name\")\n",
      "    ),\n",
      "    block_field(\n",
      "      block_field_label(\"Last name\", `for` = \"last_name\"),\n",
      "      block_input(\"last_name\"),\n",
      "      block_field_description(\"", fname_desc, "\")\n",
      "    )\n",
      "  ),\n",
      "  block_field(\n",
      "    block_field_label(\"", email_label, "\", `for` = \"email\"),\n",
      "    block_input(\"email\", type = \"email\"),\n",
      "    block_field_description(\"", email_desc, "\")\n",
      "  ),\n",
      pw_block, "\n",
      ")"
    )
  })
  shiny::outputOptions(
    output,
    "showcase_field_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_field_api_table <- shiny::renderTable({
    data.frame(
      Function = c(
        "block_field", "block_field_group", "block_field_label",
        "block_field_description", "block_field_set",
        "block_field_legend", "block_field_invalid"
      ),
      Arguments = c(
        "..., class", "..., class", "..., for, class",
        "..., id, class", "..., class", "..., class",
        "field, message"
      ),
      Description = c(
        "A layout wrapper for a single form field (label, control, description/error).",
        "Flex column grid to position multiple fields side-by-side (e.g. inside forms).",
        "A text label with an optional for attribute linking to its control's input ID.",
        "Helper/description text placed below or above the control element.",
        "A fieldset surface grouping related controls under a single boundary.",
        "A legend caption detailing the purpose of the surrounding fieldset.",
        "Server-reactive validator that injects data-invalid attributes, aria descriptors, and formats red error text."
      )
    )
  }, width = "100%", align = "lll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_field_api_table",
    suspendWhenHidden = FALSE
  )
}
