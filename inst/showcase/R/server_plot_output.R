register_plot_output_showcase <- function(input, output, session) {
  # Shared output-playground helpers (showcase_output_*, showcase_interaction_*)
  # live in section.R.

  demo_values <- showcase_output_demo_values(input, "showcase_plot_output")

  frame_state <- shiny::reactive({
    showcase_output_frame_state(input, "showcase_plot_output")
  })

  output$showcase_plot_output_preview_ui <- shiny::renderUI({
    common <- c(
      showcase_output_preview_args(frame_state()),
      showcase_interaction_args("showcase_plot_output")
    )
    do.call(block_plot_output, c(list(id = "showcase_plot_output_plot"), common))
  })
  shiny::outputOptions(output, "showcase_plot_output_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_plot_output_plot <- shiny::renderPlot({
    v <- demo_values()
    op <- graphics::par(mar = c(3, 3, 1, 1))
    on.exit(graphics::par(op), add = TRUE)
    graphics::barplot(
      v,
      col = c("#2563eb", "#16a34a", "#f59e0b", "#dc2626"),
      border = NA,
      ylim = c(0, 110)
    )
  }, alt = "Bar chart of quarterly revenue by region.")
  shiny::outputOptions(output, "showcase_plot_output_plot", suspendWhenHidden = FALSE)

  output$showcase_plot_output_preview_code <- showcase_render_code({
    showcase_output_preview_code(
      frame_state(), "block_plot_output", "showcase_plot_output_plot",
      "showcase_plot_output"
    )
  })
  shiny::outputOptions(output, "showcase_plot_output_preview_code", suspendWhenHidden = FALSE)

  output$showcase_plot_output_interaction_value <- showcase_render_code({
    showcase_interaction_values(input, "showcase_plot_output")
  })
  shiny::outputOptions(output, "showcase_plot_output_interaction_value", suspendWhenHidden = FALSE)

  output$showcase_plot_output_reactive_code <- showcase_render_code({
    v <- demo_values()
    paste0(
      showcase_output_data_line(v), "\n\n",
      "output$showcase_plot_output_plot <- renderPlot({\n",
      "  barplot(values, col = palette, border = NA)\n",
      '}, alt = "Quarterly revenue by region")'
    )
  })
  shiny::outputOptions(output, "showcase_plot_output_reactive_code", suspendWhenHidden = FALSE)

  output$showcase_plot_output_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c(
        "id", "width", "height", "aspect", "border", "rounded",
        "caption", "click / dblclick / hover / brush", "inline", "fill",
        "class", "style"
      ),
      Type = c(
        "character", "character", "character", "character | numeric",
        "logical", "logical", "character", "character | *Opts()", "logical",
        "logical", "character", "character"
      ),
      Default = c(
        "required", "\"100%\"", "NULL", "NULL", "FALSE", "TRUE",
        "NULL", "NULL", "FALSE", "!inline", "NULL", "NULL"
      ),
      Description = c(
        "Shiny output id, passed verbatim to plotOutput().",
        "CSS width forwarded to the Shiny output and mirrored on the media box.",
        "CSS height. NULL resolves to \"100%\" when aspect is set, else Shiny's default.",
        "Media-box aspect ratio: NULL, a positive number, or a \"w/h\" string.",
        "Draw a border around the media box.",
        "Round the media box corners (and clip overflow).",
        "Optional <figcaption> text below the media box.",
        "Forwarded to the Shiny output unchanged (plot click/hover/brush inputs).",
        "Forwarded to the Shiny output unchanged.",
        "Forwarded to the Shiny output; default matches plotOutput().",
        "Additional classes for the <figure> wrapper.",
        "Inline style for the <figure> wrapper."
      )
    ))
  })
  shiny::outputOptions(output, "showcase_plot_output_api_table", suspendWhenHidden = FALSE)
}
