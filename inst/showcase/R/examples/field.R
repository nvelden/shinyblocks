htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Form Layout", first = TRUE,
        block_field(
          block_field_label("legend text", `for` = "showcase_field_legend"),
          block_textarea("showcase_field_legend", value = "Account Details", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("first name label", `for` = "showcase_field_fname_label"),
          block_textarea("showcase_field_fname_label", value = "First name", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("first name description", `for` = "showcase_field_fname_desc"),
          block_textarea("showcase_field_fname_desc", value = "Enter your primary name.", rows = 2, resize = "none")
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("email label", `for` = "showcase_field_email_label"),
          block_textarea("showcase_field_email_label", value = "Email address", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("email description", `for` = "showcase_field_email_desc"),
          block_textarea("showcase_field_email_desc", value = "We will never share your email address with anyone.", rows = 2, resize = "none")
        ),
        block_field(
          block_field_label("password error message", `for` = "showcase_field_pw_error"),
          block_textarea("showcase_field_pw_error", value = "Password must be at least 8 characters long and contain a digit.", rows = 2, resize = "none")
        ),
        block_field(
          block_field_label("password invalid state", `for` = "showcase_field_pw_invalid"),
          block_checkbox("showcase_field_pw_invalid", label = "Mark password field invalid", value = TRUE)
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("class", `for` = "showcase_field_class"),
          block_checkbox("showcase_field_class", label = "Use custom dashed-border class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_field_preview_ui",
    code_output_id = "showcase_field_preview_code"
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_field_api_table"),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "Parity fixtures"),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances captured by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 1rem; padding: 1.5rem; border: 1px dashed var(--border); border-radius: 0.5rem;",
    block_field(
      class = "sb-parity-field-default",
      block_field_label("Baseline Field", `for` = "parity_field_1"),
      block_input("parity_field_1", value = "Default value"),
      block_field_description("This is a standard field helper description.")
    ),
    block_field(
      class = "sb-parity-field-disabled",
      block_field_label("Disabled Field", `for` = "parity_field_2"),
      block_input("parity_field_2", value = "Disabled input value", disabled = TRUE),
      block_field_description("This helper belongs to a disabled control.")
    ),
    block_field_invalid(
      block_field(
        class = "sb-parity-field-invalid",
        block_field_label("Invalid Field", `for` = "parity_field_3"),
        block_input("parity_field_3", value = "Wrong format")
      ),
      message = "Please enter a valid email address."
    )
  )
)
