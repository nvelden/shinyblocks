register_theme_showcase <- function(input, output, session) {
  # Observe button events to update active theme mode
  shiny::observeEvent(input$showcase_theme_set_light, {
    update_block_theme(session, mode = "light")
  })
  shiny::observeEvent(input$showcase_theme_set_dark, {
    update_block_theme(session, mode = "dark")
  })
  shiny::observeEvent(input$showcase_theme_set_system, {
    update_block_theme(session, mode = "system")
  })

  selected_preset <- shiny::reactive({
    value <- input$showcase_theme_doc_preset
    if (is.null(value) || !nzchar(value) || identical(value, "inherit")) {
      return(NULL)
    }
    value
  })

  # Resolve the active token overrides from the controls. A `block_theme()`
  # override applies to BOTH light and dark mode (one value), so any token left
  # at "inherit" is intentionally NOT overridden — it keeps the package's
  # adaptive light/dark default and stays readable in both modes. Only tokens
  # the user explicitly picks are overridden.
  theme_overrides <- shiny::reactive({
    pick <- function(id) {
      v <- input[[id]]
      if (is.null(v) || !nzchar(v) || identical(v, "inherit")) NULL else v
    }
    ov <- list(
      radius = input$showcase_theme_doc_radius %||% "0.5rem",
      primary = pick("showcase_theme_doc_primary"),
      secondary = pick("showcase_theme_doc_secondary"),
      accent = pick("showcase_theme_doc_accent"),
      destructive = pick("showcase_theme_doc_destructive"),
      muted = pick("showcase_theme_doc_muted"),
      border = pick("showcase_theme_doc_border"),
      ring = pick("showcase_theme_doc_ring")
    )
    ov[!vapply(ov, is.null, logical(1))]
  })

  # Dark-mode-only overrides. These apply only when [data-theme="dark"] is
  # active, mirroring shadcn's separate light/dark token values.
  theme_dark_overrides <- shiny::reactive({
    pick <- function(id) {
      v <- input[[id]]
      if (is.null(v) || !nzchar(v) || identical(v, "inherit")) NULL else v
    }
    ov <- list(
      primary = pick("showcase_theme_doc_primary_dark"),
      accent = pick("showcase_theme_doc_accent_dark")
    )
    ov[!vapply(ov, is.null, logical(1))]
  })

  # Dynamic preview UI (renders style overrides + components covering every
  # exposed token).
  output$showcase_theme_preview_ui <- shiny::renderUI({
    preset <- selected_preset()
    o <- theme_overrides()
    d <- theme_dark_overrides()

    swatch_style <- function(...) paste(
      "display: flex; flex-direction: column; gap: 0.35rem;", ...
    )
    label_style <- "font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground);"

    htmltools::tagList(
      # Scope the override to this preview only so the demo does not leak
      # its token colors into the rest of the gallery. Only user-picked tokens
      # are passed; the rest keep their adaptive light/dark defaults.
      do.call(
        block_theme,
        c(
          list(preset = preset),
          o,
          list(scope = ".sb-theme-demo-scope", dark = if (length(d)) d else NULL)
        )
      ),
      htmltools::div(
        class = "sb-theme-demo-scope",
        style = "display: flex; flex-direction: column; gap: 1.1rem; width: 100%;",
        # Buttons exercise --primary, --secondary, --destructive, and --border.
        htmltools::div(
          style = swatch_style(),
          htmltools::span(style = label_style, "Buttons: primary / secondary / destructive / outline / ghost"),
          htmltools::div(
            style = "display: flex; gap: 0.6rem; align-items: center; flex-wrap: wrap;",
            block_button("Primary", variant = "default"),
            block_button("Secondary", variant = "secondary"),
            block_button("Destructive", variant = "destructive"),
            block_button("Outline", variant = "outline"),
            block_button("Ghost", variant = "ghost")
          )
        ),
        # Badges exercise --primary, --secondary, --destructive.
        htmltools::div(
          style = swatch_style(),
          htmltools::span(style = label_style, "Badges"),
          htmltools::div(
            style = "display: flex; gap: 0.5rem; align-items: center; flex-wrap: wrap;",
            block_badge("Primary", variant = "default"),
            block_badge("Secondary", variant = "secondary"),
            block_badge("Outline", variant = "outline"),
            block_badge("Destructive", variant = "destructive"),
            block_badge("Success", variant = "success"),
            block_badge("Warning", variant = "warning"),
            block_badge("Info", variant = "info")
          )
        ),
        htmltools::div(
          style = swatch_style(),
          htmltools::span(style = label_style, "Feedback alerts: shinyblocks extensions"),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 0.5rem;",
            block_alert("Success", variant = "success", icon = "check"),
            block_alert("Warning", variant = "warning", icon = "alert-triangle"),
            block_alert("Info", variant = "info", icon = "info")
          )
        ),
        # Surfaces exercise --accent, --muted, --border, --ring.
        htmltools::div(
          style = "display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 0.75rem;",
          htmltools::div(
            style = paste(
              "padding: 0.85rem; font-size: 0.8rem; font-weight: 500;",
              "background: var(--accent); color: var(--accent-foreground);",
              "border-radius: var(--radius);"
            ),
            "Accent surface (--accent)"
          ),
          htmltools::div(
            style = paste(
              "padding: 0.85rem; font-size: 0.8rem; font-weight: 500;",
              "background: var(--muted); color: var(--muted-foreground);",
              "border-radius: var(--radius);"
            ),
            "Muted surface (--muted)"
          ),
          htmltools::div(
            style = paste(
              "padding: 0.85rem; font-size: 0.8rem; font-weight: 500;",
              "border: 1px solid var(--border); border-radius: var(--radius);"
            ),
            "Border (--border)"
          ),
          htmltools::div(
            style = paste(
              "padding: 0.85rem; font-size: 0.8rem; font-weight: 500;",
              "border: 1px solid var(--ring); border-radius: var(--radius);",
              "box-shadow: 0 0 0 3px color-mix(in oklch, var(--ring) 50%, transparent);"
            ),
            "Focus ring (--ring)"
          )
        ),
        # Card exercises --card, --card-foreground, --border, --radius.
        block_card(
          title = "Dynamic Card",
          description = "Rounded corners and surface colors follow the tokens above.",
          "Every control on the left maps to a block_theme() token; the preview reflects it live."
        )
      )
    )
  })
  shiny::outputOptions(
    output,
    "showcase_theme_preview_ui",
    suspendWhenHidden = FALSE
  )

  # Dynamic code snippet rendering
  output$showcase_theme_preview_code <- showcase_render_code({
    preset <- selected_preset()
    o <- theme_overrides()
    d <- theme_dark_overrides()
    args <- vapply(
      names(o),
      function(name) sprintf("  %s = \"%s\"", name, o[[name]]),
      character(1)
    )
    if (length(d)) {
      dark_args <- vapply(
        names(d),
        function(name) sprintf("    %s = \"%s\"", name, d[[name]]),
        character(1)
      )
      args <- c(args, paste0(
        "  dark = list(\n", paste(dark_args, collapse = ",\n"), "\n  )"
      ))
    }
    if (!is.null(preset)) {
      args <- c(sprintf("  preset = \"%s\"", preset), args)
    }
    paste0("block_theme(\n", paste(args, collapse = ",\n"), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_theme_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_theme_action_code <- showcase_render_code({
    paste(
      "update_block_theme(",
      "  session = session,",
      "  mode = \"dark\"",
      ")",
      sep = "\n"
    )
  })
  shiny::outputOptions(
    output,
    "showcase_theme_action_code",
    suspendWhenHidden = FALSE
  )

  # API Reference table
  output$showcase_theme_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("preset", "...", "session", "mode"),
      Type = c("character", "Named HSL/CSS token overrides", "Shiny Session", "character"),
      Default = c("NULL", "none", "getDefaultReactiveDomain()", "required"),
      Description = c(
        "Optional built-in semantic light/dark palette.",
        "CSS variables to override (e.g., primary, radius, border, background, chart-1).",
        "The active Shiny session domain (required for theme updates).",
        "The targeted theme mode: 'system', 'light', or 'dark'."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_theme_api_table",
    suspendWhenHidden = FALSE
  )
}
