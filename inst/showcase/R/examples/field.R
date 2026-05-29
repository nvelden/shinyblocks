htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        class = "showcase-playground", style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
        
        # Left Column (Live Preview + UI Code) -> matches desktop child 1
        htmltools::div(
          class = "showcase-playground__main", style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
          block_field(
            block_field_label("Preview", `for` = "showcase_field_preview"),
            shiny::uiOutput("showcase_field_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
                "UI Definition"
              ),
              shiny::uiOutput("showcase_field_preview_code")
            )
          )
        ),
        
        # Right Column (Designer controls panel) -> matches desktop child 2
        htmltools::div(
          class = "showcase-playground__controls", style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          
          # Category 1: Form Layout Settings
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Form Layout"),
            block_field(
              block_field_label("legend text", `for` = "showcase_field_legend"),
              block_textarea(
                "showcase_field_legend",
                value = "Account Details",
                rows = 1,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("first name label", `for` = "showcase_field_fname_label"),
              block_textarea(
                "showcase_field_fname_label",
                value = "First name",
                rows = 1,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("first name description", `for` = "showcase_field_fname_desc"),
              block_textarea(
                "showcase_field_fname_desc",
                value = "Enter your primary name.",
                rows = 2,
                resize = "none"
              )
            )
          ),
          
          # Category 2: Validation State
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
            block_field(
              block_field_label("email label", `for` = "showcase_field_email_label"),
              block_textarea(
                "showcase_field_email_label",
                value = "Email address",
                rows = 1,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("email description", `for` = "showcase_field_email_desc"),
              block_textarea(
                "showcase_field_email_desc",
                value = "We will never share your email address with anyone.",
                rows = 2,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("password error message", `for` = "showcase_field_pw_error"),
              block_textarea(
                "showcase_field_pw_error",
                value = "Password must be at least 8 characters long and contain a digit.",
                rows = 2,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("password invalid state", `for` = "showcase_field_pw_invalid"),
              block_checkbox(
                "showcase_field_pw_invalid",
                label = "Mark password field invalid",
                value = TRUE
              )
            )
          ),
          
          # Category 3: Styling
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("class", `for` = "showcase_field_class"),
              block_checkbox(
                "showcase_field_class",
                label = "Use custom dashed-border class",
                value = FALSE
              )
            )
          )
        )
      )
    )
  ),
  
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_field_api_table"),
  
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
