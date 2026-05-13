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

option_row <- function(name, signature, example, description) {
  htmltools::div(
    style = paste(
      "display: grid;",
      "grid-template-columns: minmax(9rem, 12rem) minmax(14rem, 1fr);",
      "gap: 1rem;",
      "align-items: start;"
    ),
    htmltools::div(
      htmltools::tags$div(
        style = "font-weight: 600;",
        name
      ),
      htmltools::tags$code(
        style = paste(
          "display: inline-block;",
          "margin-top: 0.25rem;",
          "color: var(--muted-foreground);"
        ),
        signature
      )
    ),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 0.5rem;",
      example,
      block_field_description(description)
    )
  )
}

htmltools::tagList(
  block_field_group(
    option_row(
      "choices",
      "choices = c(Free = \"free\", ...)",
      block_select(
        "showcase_select_choices",
        choices = c(Free = "free", Pro = "pro", Team = "team"),
        selected = "pro"
      ),
      paste(
        "Named vectors use names as labels and values as Shiny input values.",
        "Unnamed vectors use the same string for label and value."
      )
    ),
    block_field(
      block_field_label("Basic", `for` = "showcase_select_basic"),
      block_select(
        "showcase_select_basic",
        choices = c(Free = "free", Pro = "pro", Team = "team"),
        selected = "pro"
      ),
      block_field_description("Named choices with an initial selected value.")
    ),
    option_row(
      "placeholder",
      "placeholder = \"Choose ...\"",
      block_select(
        "showcase_select_placeholder",
        choices = c(Alpha = "alpha", Beta = "beta", Stable = "stable"),
        placeholder = "Choose a release channel"
      ),
      "Placeholder keeps the initial browser and Shiny value empty."
    ),
    option_row(
      "selected",
      "selected = \"team\"",
      block_select(
        "showcase_select_selected",
        choices = c(Free = "free", Pro = "pro", Team = "team"),
        selected = "team"
      ),
      "Selected sets the initial value rendered in the browser and sent to Shiny."
    ),
    option_row(
      "width",
      "width = \"16rem\"",
      block_select(
        "showcase_select_width",
        choices = c(Small = "sm", Medium = "md", Large = "lg"),
        selected = "md",
        width = "16rem",
        class = "showcase-select-width"
      ),
      "Width sets the select wrapper width while preserving the token styling."
    ),
    option_row(
      "class",
      "class = \"showcase-select-width\"",
      block_select(
        "showcase_select_class",
        choices = c(Default = "default", Custom = "custom"),
        selected = "custom",
        width = "16rem",
        class = "showcase-select-width"
      ),
      "Class is merged onto the runtime select wrapper for app-level layout hooks."
    ),
    option_row(
      "disabled",
      "disabled = TRUE",
      block_select(
        "showcase_select_disabled",
        choices = c(Manual = "manual", Automatic = "automatic"),
        selected = "automatic",
        disabled = TRUE
      ),
      "Disabled blocks user changes but still allows server-side updates."
    ),
    option_row(
      "size",
      "size = \"sm\" / \"default\" / \"lg\"",
      htmltools::div(
        style = "display: flex; flex-direction: column; gap: 0.5rem;",
        block_select(
          "showcase_select_size_sm",
          choices = c(Small = "sm", Medium = "md"),
          selected = "sm",
          width = "14rem",
          size = "sm"
        ),
        block_select(
          "showcase_select_size_default",
          choices = c(Default = "default", Medium = "md"),
          selected = "default",
          width = "14rem"
        ),
        block_select(
          "showcase_select_size_lg",
          choices = c(Large = "lg", Medium = "md"),
          selected = "lg",
          width = "14rem",
          size = "lg"
        )
      ),
      "Size adjusts control height and horizontal padding."
    ),
    option_row(
      "invalid",
      "invalid = TRUE",
      block_select(
        "showcase_select_invalid",
        choices = c(Valid = "valid", Invalid = "invalid"),
        selected = "invalid",
        invalid = TRUE
      ),
      "Invalid applies aria-invalid and the destructive border/ring styling."
    )
  ),
  htmltools::tags$hr(style = "border-top: 1px solid var(--border);"),
  block_field_set(
    block_field_legend("Reactive select"),
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
        "input$showcase_select_reactive = ",
        shiny::textOutput("showcase_select_value", inline = TRUE)
      )
    )
  )
)
