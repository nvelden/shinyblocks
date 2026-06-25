htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Layout", first = TRUE,
        block_field(
          block_field_label("Primitive", `for` = "showcase_layout_primitives_type"),
          block_select(
            "showcase_layout_primitives_type",
            choices = c(
              "Stack" = "stack",
              "Cluster" = "cluster",
              "Grid" = "grid"
            ),
            selected = "stack"
          )
        ),
        block_field(
          block_field_label("Gap", `for` = "showcase_layout_primitives_gap"),
          block_select(
            "showcase_layout_primitives_gap",
            choices = c("Small" = "sm", "Medium" = "md", "Large" = "lg"),
            selected = "md"
          )
        ),
        block_field(
          block_field_label("Cross-axis alignment", `for` = "showcase_layout_primitives_align"),
          block_select(
            "showcase_layout_primitives_align",
            choices = c(
              "Stretch" = "stretch",
              "Start" = "start",
              "Center" = "center",
              "End" = "end"
            ),
            selected = "stretch"
          )
        ),
        block_field(
          block_field_label("Items", `for` = "showcase_layout_primitives_count"),
          block_select(
            "showcase_layout_primitives_count",
            choices = c("Two" = "2", "Three" = "3", "Four" = "4"),
            selected = "4"
          )
        )
      ),
      shiny::conditionalPanel(
        condition = "input.showcase_layout_primitives_type == 'cluster'",
        showcase_controls_group(
          "Cluster",
          block_field(
            block_field_label("justify", `for` = "showcase_layout_primitives_justify"),
            block_select(
              "showcase_layout_primitives_justify",
              choices = c(
                "Start" = "start",
                "Center" = "center",
                "End" = "end",
                "Space between" = "between"
              ),
              selected = "start"
            )
          ),
          block_field(
            block_field_label("wrap", `for` = "showcase_layout_primitives_wrap"),
            block_checkbox(
              "showcase_layout_primitives_wrap",
              label = "Allow wrapping",
              value = TRUE
            )
          )
        )
      ),
      shiny::conditionalPanel(
        condition = "input.showcase_layout_primitives_type == 'grid'",
        showcase_controls_group(
          "Grid",
          block_field(
            block_field_label("Preferred column width", `for` = "showcase_layout_primitives_min_width"),
            block_select(
              "showcase_layout_primitives_min_width",
              choices = c(
                "10rem" = "10rem",
                "14rem" = "14rem",
                "18rem" = "18rem",
                "24rem" = "24rem"
              ),
              selected = "14rem"
            )
          )
        )
      ),
      shiny::conditionalPanel(
        condition = "input.showcase_layout_primitives_type != 'stack'",
        showcase_controls_group(
          "Alignment demo",
          block_field(
            block_checkbox(
              "showcase_layout_primitives_vary_heights",
              label = "Use different card heights",
              value = TRUE
            )
          )
        )
      )
    ),
    preview_output_id = "showcase_layout_primitives_preview_ui",
    code_output_id = "showcase_layout_primitives_preview_code",
    preview_canvas_class = "showcase-preview-canvas--stretch",
    preview_canvas_style = paste(
      "padding: 1rem; background: color-mix(in oklab, var(--muted) 25%, transparent);",
      "border-style: dashed; min-height: 160px;"
    )
  ),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "API Reference"
  ),
  shiny::uiOutput("showcase_layout_primitives_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Theme and style fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable structural instances used by the theme and style-profile checks."
  ),
  block_stack(
    gap = "md",
    class = "sb-parity-stack-default",
    htmltools::tags$span("Stack item one"),
    htmltools::tags$span("Stack item two")
  ),
  block_cluster(
    gap = "sm",
    class = "sb-parity-cluster-default",
    block_badge("Cluster one", variant = "secondary"),
    block_badge("Cluster two", variant = "outline")
  ),
  block_grid(
    min_width = "10rem",
    gap = "md",
    class = "sb-parity-grid-default",
    block_card(title = "Grid one", "Responsive card"),
    block_card(title = "Grid two", "Responsive card")
  )
)
