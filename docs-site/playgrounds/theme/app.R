if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch({
      webr::mount("/packages", path)
      if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
        mounted <- TRUE
        break
      }
    }, error = function(e) {})
  }

  if (!mounted) {
    webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
  }

  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a

showcase_render_code <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    block_code(
      paste(as.character(eval(quoted, envir = env)), collapse = "\n"),
      language = "r",
      copyable = TRUE,
      line_numbers = TRUE
    )
  })
}

group_header_style <- "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;"

ui <- block_page(
  title = "shinyblocks - Theme playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground",
    block_cluster(
      gap = "lg",
      align = "start",
      class = "showcase-playground__split",
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        style = "flex: 1; min-width: 280px; max-width: 320px;",
        block_stack(
          gap = "sm",
          class = "showcase-controls-group showcase-controls-group--first",
          htmltools::tags$h4(style = group_header_style, "Tokens"),
          block_field(
            block_field_label("preset", `for` = "showcase_theme_doc_preset"),
            block_select(
              "showcase_theme_doc_preset",
              choices = c(
                "default (no preset)" = "inherit",
                stats::setNames(
                  shinyblocks:::theme_preset_names(),
                  shinyblocks:::theme_preset_names()
                )
              ),
              selected = "inherit",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("style profile", `for` = "showcase_theme_doc_style"),
            block_select(
              "showcase_theme_doc_style",
              choices = c(
                "default" = "inherit",
                stats::setNames(
                  setdiff(shinyblocks:::style_profile_names(), "default"),
                  setdiff(shinyblocks:::style_profile_names(), "default")
                )
              ),
              selected = "inherit",
              size = "sm"
            ),
            block_field_description(
              "block_style() visual profile. Token controls below layer over the profile."
            )
          ),
          block_field(
            block_field_label("radius", `for` = "showcase_theme_doc_radius"),
            block_select("showcase_theme_doc_radius", choices = c("0rem", "0.25rem", "0.5rem", "1rem", "1.5rem"), selected = "0.5rem", size = "sm")
          ),
          block_field(
            block_field_label("primary", `for` = "showcase_theme_doc_primary"),
            block_select("showcase_theme_doc_primary", choices = c(
              "default (adapts to light/dark)" = "inherit",
              "blue" = "hsl(221.2, 83.2%, 53.3%)",
              "green" = "hsl(142.1, 76.2%, 36.3%)",
              "violet" = "hsl(262.1, 83.3%, 57.8%)",
              "rose" = "hsl(346.8, 77.2%, 49.8%)"
            ), selected = "inherit", size = "sm")
          ),
          block_field(
            block_field_label("secondary", `for` = "showcase_theme_doc_secondary"),
            block_select("showcase_theme_doc_secondary", choices = c(
              "default (adapts to light/dark)" = "inherit",
              "cool" = "oklch(0.93 0.03 250)",
              "warm" = "oklch(0.95 0.04 80)"
            ), selected = "inherit", size = "sm")
          ),
          block_field(
            block_field_label("accent", `for` = "showcase_theme_doc_accent"),
            block_select("showcase_theme_doc_accent", choices = c(
              "default (adapts to light/dark)" = "inherit",
              "blue tint" = "hsl(214, 95%, 93%)",
              "green tint" = "hsl(142, 69%, 90%)",
              "amber tint" = "hsl(48, 96%, 89%)",
              "rose tint" = "hsl(351, 95%, 93%)"
            ), selected = "inherit", size = "sm")
          ),
          block_field(
            block_field_label("destructive", `for` = "showcase_theme_doc_destructive"),
            block_select("showcase_theme_doc_destructive", choices = c(
              "default (adapts to light/dark)" = "inherit",
              "orange" = "oklch(0.65 0.2 40)",
              "crimson" = "hsl(346.8, 77.2%, 49.8%)"
            ), selected = "inherit", size = "sm")
          ),
          block_field(
            block_field_label("muted", `for` = "showcase_theme_doc_muted"),
            block_select("showcase_theme_doc_muted", choices = c(
              "default (adapts to light/dark)" = "inherit",
              "cool" = "oklch(0.95 0.02 250)",
              "warm" = "oklch(0.96 0.02 80)"
            ), selected = "inherit", size = "sm")
          ),
          block_field(
            block_field_label("border", `for` = "showcase_theme_doc_border"),
            block_select("showcase_theme_doc_border", choices = c(
              "default (adapts to light/dark)" = "inherit",
              "strong" = "oklch(0.8 0 0)",
              "blue" = "oklch(0.8 0.05 250)"
            ), selected = "inherit", size = "sm")
          ),
          block_field(
            block_field_label("ring", `for` = "showcase_theme_doc_ring"),
            block_select("showcase_theme_doc_ring", choices = c(
              "default (adapts to light/dark)" = "inherit",
              "blue" = "hsl(221.2, 83.2%, 53.3%)",
              "green" = "hsl(142.1, 76.2%, 36.3%)"
            ), selected = "inherit", size = "sm")
          )
        ),
        block_stack(
          gap = "sm",
          class = "showcase-controls-group",
          htmltools::tags$h4(style = group_header_style, "Dark mode overrides"),
          block_field(
            block_field_label("primary (dark)", `for` = "showcase_theme_doc_primary_dark"),
            block_select("showcase_theme_doc_primary_dark", choices = c(
              "same as light" = "inherit",
              "blue" = "hsl(217, 91%, 60%)",
              "green" = "hsl(142, 71%, 45%)",
              "violet" = "hsl(263, 90%, 70%)",
              "rose" = "hsl(347, 77%, 60%)"
            ), selected = "inherit", size = "sm"),
            block_field_description(
              "Applied only in dark mode (block_theme(dark = ...)). Toggle the theme to compare."
            )
          ),
          block_field(
            block_field_label("accent (dark)", `for` = "showcase_theme_doc_accent_dark"),
            block_select("showcase_theme_doc_accent_dark", choices = c(
              "same as light" = "inherit",
              "blue" = "oklch(0.3 0.07 250)",
              "green" = "oklch(0.33 0.08 150)",
              "violet" = "oklch(0.34 0.09 290)"
            ), selected = "inherit", size = "sm")
          )
        ),
        block_stack(
          gap = "sm",
          class = "showcase-controls-group",
          htmltools::tags$h4(style = group_header_style, "Actions (Server Update)"),
          block_button("Force Light Mode", id = "showcase_theme_set_light", variant = "outline", size = "sm"),
          block_button("Force Dark Mode", id = "showcase_theme_set_dark", variant = "outline", size = "sm"),
          block_button("Sync with System", id = "showcase_theme_set_system", variant = "outline", size = "sm")
        )
      ),
      block_stack(
        gap = "lg",
        class = "showcase-playground__main",
        block_stack(
          gap = "sm",
          htmltools::div(style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);", "Preview"),
          htmltools::div(
            style = paste(
              "position: relative;",
              "padding: 1.5rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
              "border: 0; border-radius: 0.75rem; min-height: 330px; box-sizing: border-box;"
            ),
            uiOutput("showcase_theme_preview_ui")
          )
        ),
        htmltools::div(
          htmltools::div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_theme_preview_code")
        ),
        htmltools::div(
          htmltools::div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "Server Action"
          ),
          uiOutput("showcase_theme_action_code")
        )
      )
        )
)
  )
)

server <- function(input, output, session) {
  observeEvent(input$showcase_theme_set_light, {
    update_block_theme(session, mode = "light")
  })
  observeEvent(input$showcase_theme_set_dark, {
    update_block_theme(session, mode = "dark")
  })
  observeEvent(input$showcase_theme_set_system, {
    update_block_theme(session, mode = "system")
  })

  pick <- function(id) {
    v <- input[[id]]
    if (is.null(v) || !nzchar(v) || identical(v, "inherit")) NULL else v
  }

  selected_preset <- reactive({
    value <- input$showcase_theme_doc_preset
    if (is.null(value) || !nzchar(value) || identical(value, "inherit")) {
      return(NULL)
    }
    value
  })

  selected_style <- reactive({
    value <- input$showcase_theme_doc_style
    if (is.null(value) || !nzchar(value) || identical(value, "inherit") ||
      identical(value, "default")) {
      return(NULL)
    }
    value
  })

  # Base overrides apply to both modes; "inherit" leaves a token at its
  # adaptive light/dark default so it stays readable in both modes.
  theme_overrides <- reactive({
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

  # Dark-mode-only overrides, applied when [data-theme="dark"] is active.
  theme_dark_overrides <- reactive({
    ov <- list(
      primary = pick("showcase_theme_doc_primary_dark"),
      accent = pick("showcase_theme_doc_accent_dark")
    )
    ov[!vapply(ov, is.null, logical(1))]
  })

  output$showcase_theme_preview_ui <- renderUI({
    preset <- selected_preset()
    style_profile <- selected_style()
    o <- theme_overrides()
    d <- theme_dark_overrides()

    # block_style() returns a shinyblocks_style object (profile + style tag);
    # take only its $style tag for the preview. The profile name activates the
    # scoped component CSS via data-sb-style on the wrapper below.
    style_tag <- if (!is.null(style_profile)) {
      block_style(style_profile, scope = ".sb-theme-demo-scope")$style
    }

    label_style <- "font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground);"
    surface <- function(bg, fg, text) htmltools::div(
      style = paste(
        "padding: 0.85rem; font-size: 0.8rem; font-weight: 500;",
        if (!is.null(bg)) sprintf("background: %s;", bg) else "",
        if (!is.null(fg)) sprintf("color: %s;", fg) else "",
        "border-radius: var(--radius);"
      ),
      text
    )

    htmltools::tagList(
      do.call(
        block_theme,
        c(
          list(preset = preset),
          o,
          list(scope = ".sb-theme-demo-scope", dark = if (length(d)) d else NULL)
        )
      ),
      style_tag,
      block_stack(
        gap = "lg",
        class = "sb-theme-demo-scope",
        `data-sb-style` = style_profile,
        style = "width: 100%;",
        block_stack(
          gap = "sm",
          htmltools::span(style = label_style, "Buttons: primary / secondary / destructive / outline / ghost"),
          block_cluster(
            gap = "sm",
            align = "center",
            block_button("Primary", variant = "default"),
            block_button("Secondary", variant = "secondary"),
            block_button("Destructive", variant = "destructive"),
            block_button("Outline", variant = "outline"),
            block_button("Ghost", variant = "ghost")
          )
        ),
        block_stack(
          gap = "sm",
          htmltools::span(style = label_style, "Badges"),
          block_cluster(
            gap = "sm",
            align = "center",
            block_badge("Primary", variant = "default"),
            block_badge("Secondary", variant = "secondary"),
            block_badge("Outline", variant = "outline"),
            block_badge("Destructive", variant = "destructive")
          )
        ),
        htmltools::div(
          style = "display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 0.75rem;",
          surface("var(--accent)", "var(--accent-foreground)", "Accent surface (--accent)"),
          surface("var(--muted)", "var(--muted-foreground)", "Muted surface (--muted)"),
          htmltools::div(
            style = "padding: 0.85rem; font-size: 0.8rem; font-weight: 500; border: 1px solid var(--border); border-radius: var(--radius);",
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
        block_card(
          title = "Dynamic Card",
          description = "Rounded corners and surface colors follow the tokens above.",
          "Every control on the left maps to a block_theme() token; the preview reflects it live."
        )
      )
    )
  })

  output$showcase_theme_preview_code <- showcase_render_code({
    preset <- selected_preset()
    style_profile <- selected_style()
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
    theme_call <- paste0("block_theme(\n", paste(args, collapse = ",\n"), "\n)")

    if (is.null(style_profile)) {
      return(theme_call)
    }
    paste0(
      "block_page(\n",
      sprintf("  style = block_style(\"%s\"),\n", style_profile),
      "  theme = ", gsub("\n", "\n  ", theme_call), "\n)"
    )
  })

  output$showcase_theme_action_code <- showcase_render_code({
    paste(
      "update_block_theme(",
      "  session = session,",
      "  mode = \"dark\"",
      ")",
      sep = "\n"
    )
  })
}

shinyApp(ui, server)
