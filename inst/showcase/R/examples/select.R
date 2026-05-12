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

htmltools::tagList(
  block_field_group(
    block_field(
      block_field_label("Basic", `for` = "showcase_select_basic"),
      block_select(
        "showcase_select_basic",
        choices = c(Free = "free", Pro = "pro", Team = "team"),
        selected = "pro"
      ),
      block_field_description("Named choices with an initial selected value.")
    ),
    block_field(
      block_field_label("Placeholder", `for` = "showcase_select_placeholder"),
      block_select(
        "showcase_select_placeholder",
        choices = c(Alpha = "alpha", Beta = "beta", Stable = "stable"),
        placeholder = "Choose a release channel"
      ),
      block_field_description("Placeholder keeps the initial value empty.")
    ),
    block_field(
      block_field_label("Fixed width", `for` = "showcase_select_width"),
      block_select(
        "showcase_select_width",
        choices = c(Small = "sm", Medium = "md", Large = "lg"),
        selected = "md",
        width = "16rem",
        class = "showcase-select-width"
      ),
      block_field_description("The width and class arguments customize layout.")
    ),
    block_field(
      block_field_label("Disabled", `for` = "showcase_select_disabled"),
      block_select(
        "showcase_select_disabled",
        choices = c(Manual = "manual", Automatic = "automatic"),
        selected = "automatic",
        disabled = TRUE
      ),
      block_field_description("Disabled state is emitted by the runtime renderer.")
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
