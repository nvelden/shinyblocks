register_style_showcase <- function(input, output, session) {
  selected_profile <- shiny::reactive({
    value <- input$showcase_style_doc_profile
    if (is.null(value) || !nzchar(value)) "default" else value
  })

  # Curated block_style() overrides from the controls. A control left at
  # "inherit" keeps the profile's built-in value and is not emitted.
  style_overrides <- shiny::reactive({
    pick <- function(id) {
      v <- input[[id]]
      if (is.null(v) || !nzchar(v) || identical(v, "inherit")) NULL else v
    }
    ov <- list(
      control_height = pick("showcase_style_doc_control_height"),
      surface_gap = pick("showcase_style_doc_surface_gap"),
      surface_padding = pick("showcase_style_doc_surface_padding"),
      control_font_size = pick("showcase_style_doc_control_font_size")
    )
    ov[!vapply(ov, is.null, logical(1))]
  })

  # Live preview. block_style() emits the profile's --sb-* tokens scoped to the
  # preview wrapper; data-sb-style on the wrapper activates the scoped component
  # CSS. block_style() returns a shinyblocks_style object (profile + style tag);
  # take only its $style tag for the preview.
  output$showcase_style_preview_ui <- shiny::renderUI({
    profile <- selected_profile()
    o <- style_overrides()
    is_glass <- identical(profile, "glass")

    style_obj <- do.call(
      block_style,
      c(list(profile = profile), o, list(scope = ".sb-style-demo-scope"))
    )
    style_tag <- style_obj$style

    label_style <- "font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground);"

    htmltools::tagList(
      style_tag,
      htmltools::div(
        class = "sb-style-demo-scope",
        `data-sb-style` = profile,
        style = paste(
          "position: relative; isolation: isolate; overflow: hidden;",
          "display: flex; flex-direction: column; gap: var(--sb-surface-gap, 1.1rem);",
          "width: 100%; border-radius: var(--sb-card-radius, 1rem);",
          if (is_glass) "padding: 1.25rem;" else ""
        ),
        if (is_glass) {
          htmltools::div(
            `aria-hidden` = "true",
            style = paste(
              "position: absolute; inset: 0; z-index: -1;",
              "background:",
              "linear-gradient(135deg, color-mix(in oklch, var(--primary) 24%, transparent), transparent 34%),",
              "linear-gradient(225deg, color-mix(in oklch, var(--accent) 52%, transparent), transparent 38%),",
              "repeating-linear-gradient(90deg, color-mix(in oklch, var(--border) 38%, transparent) 0 1px, transparent 1px 18px),",
              "color-mix(in oklch, var(--muted) 32%, transparent);"
            )
          )
        },
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.35rem;",
          htmltools::span(style = label_style, "Buttons: control height, radius, focus ring follow the profile"),
          htmltools::div(
            style = "display: flex; gap: 0.6rem; align-items: center; flex-wrap: wrap;",
            block_button("Primary", variant = "default"),
            block_button("Secondary", variant = "secondary"),
            block_button("Outline", variant = "outline"),
            block_button("Ghost", variant = "ghost")
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.35rem;",
          htmltools::span(style = label_style, "Badges + input control sizing"),
          htmltools::div(
            style = "display: flex; gap: 0.5rem; align-items: center; flex-wrap: wrap;",
            block_badge("Primary", variant = "default"),
            block_badge("Secondary", variant = "secondary"),
            block_badge("Outline", variant = "outline")
          ),
          block_input("showcase_style_demo_input", placeholder = "Profile-sized input")
        ),
        block_card(
          title = "Surface metrics",
          description = "Padding, gap, radius, and elevation come from the active profile.",
          "Switch profile or layer overrides on the left to see the visual feel change live."
        )
      )
    )
  })
  shiny::outputOptions(
    output,
    "showcase_style_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_style_preview_code <- showcase_render_code({
    profile <- selected_profile()
    o <- style_overrides()
    style_args <- c(
      sprintf("\"%s\"", profile),
      vapply(
        names(o),
        function(name) sprintf("  %s = \"%s\"", name, o[[name]]),
        character(1)
      )
    )
    if (length(o)) {
      style_call <- paste0(
        "block_style(\n  ", style_args[1], ",\n",
        paste(style_args[-1], collapse = ",\n"), "\n)"
      )
    } else {
      style_call <- sprintf("block_style(%s)", style_args[1])
    }
    paste0(
      "block_page(\n",
      "  style = ", gsub("\n", "\n  ", style_call), ",\n",
      "  ...\n",
      ")"
    )
  })
  shiny::outputOptions(
    output,
    "showcase_style_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_style_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("profile", "...", "scope"),
      Type = c("character", "Named token overrides", "character"),
      Default = c("\"default\"", "none", "NULL"),
      Description = c(
        "Built-in visual style profile (see block_style_profiles()).",
        "Curated snake-case overrides, e.g. control_height, surface_gap, surface_padding.",
        "Optional CSS selector to scope the profile to a subtree instead of the whole page."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_style_api_table",
    suspendWhenHidden = FALSE
  )
}
