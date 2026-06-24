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
  title = "shinyblocks - Style playground",
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
          htmltools::tags$h4(style = group_header_style, "Profile"),
          block_field(
            block_field_label("style profile", `for` = "showcase_style_doc_profile"),
            block_select(
              "showcase_style_doc_profile",
              choices = c(
                "default" = "default",
                stats::setNames(
                  setdiff(shinyblocks:::style_profile_names(), "default"),
                  setdiff(shinyblocks:::style_profile_names(), "default")
                )
              ),
              selected = "luma",
              size = "sm"
            )
          )
        ),
        block_stack(
          gap = "sm",
          class = "showcase-controls-group",
          htmltools::tags$h4(style = group_header_style, "Overrides"),
          block_field(
            block_field_label("control height", `for` = "showcase_style_doc_control_height"),
            block_select("showcase_style_doc_control_height", choices = c(
              "profile default" = "inherit",
              "compact (1.75rem)" = "1.75rem",
              "comfortable (2.5rem)" = "2.5rem",
              "large (3rem)" = "3rem"
            ), selected = "inherit", size = "sm")
          ),
          block_field(
            block_field_label("surface gap", `for` = "showcase_style_doc_surface_gap"),
            block_select("showcase_style_doc_surface_gap", choices = c(
              "profile default" = "inherit",
              "tight (0.75rem)" = "0.75rem",
              "roomy (1.5rem)" = "1.5rem",
              "spacious (2rem)" = "2rem"
            ), selected = "inherit", size = "sm")
          ),
          block_field(
            block_field_label("surface padding", `for` = "showcase_style_doc_surface_padding"),
            block_select("showcase_style_doc_surface_padding", choices = c(
              "profile default" = "inherit",
              "compact (1rem)" = "1rem",
              "roomy (2rem)" = "2rem",
              "spacious (2.5rem)" = "2.5rem"
            ), selected = "inherit", size = "sm")
          ),
          block_field(
            block_field_label("control font size", `for` = "showcase_style_doc_control_font_size"),
            block_select("showcase_style_doc_control_font_size", choices = c(
              "profile default" = "inherit",
              "small (0.8rem)" = "0.8rem",
              "large (1rem)" = "1rem",
              "x-large (1.125rem)" = "1.125rem"
            ), selected = "inherit", size = "sm")
          )
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
              "position: relative; display: block;",
              "padding: 1.5rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
              "border: 0; border-radius: 0.75rem; min-height: 330px; box-sizing: border-box;"
            ),
            uiOutput("showcase_style_preview_ui")
          )
        ),
        htmltools::div(
          htmltools::div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_style_preview_code")
        )
      )
        )
)
  )
)

server <- function(input, output, session) {
  pick <- function(id) {
    v <- input[[id]]
    if (is.null(v) || !nzchar(v) || identical(v, "inherit")) NULL else v
  }

  selected_profile <- reactive({
    value <- input$showcase_style_doc_profile
    if (is.null(value) || !nzchar(value)) "default" else value
  })

  style_overrides <- reactive({
    ov <- list(
      control_height = pick("showcase_style_doc_control_height"),
      surface_gap = pick("showcase_style_doc_surface_gap"),
      surface_padding = pick("showcase_style_doc_surface_padding"),
      control_font_size = pick("showcase_style_doc_control_font_size")
    )
    ov[!vapply(ov, is.null, logical(1))]
  })

  output$showcase_style_preview_ui <- renderUI({
    profile <- selected_profile()
    o <- style_overrides()

    style_obj <- do.call(
      block_style,
      c(list(profile = profile), o, list(scope = ".sb-style-demo-scope"))
    )

    label_style <- "font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground);"

    htmltools::tagList(
      style_obj$style,
      block_stack(
        gap = "lg",
        class = "sb-style-demo-scope",
        `data-sb-style` = profile,
        style = "min-width: 0; width: 100%;",
        block_stack(
          gap = "sm",
          htmltools::span(style = label_style, "Buttons: control height, radius, focus ring follow the profile"),
          block_cluster(
            gap = "sm",
            align = "center",
            block_button("Primary", variant = "default"),
            block_button("Secondary", variant = "secondary"),
            block_button("Outline", variant = "outline"),
            block_button("Ghost", variant = "ghost")
          )
        ),
        block_stack(
          gap = "sm",
          htmltools::span(style = label_style, "Badges + input control sizing"),
          block_cluster(
            gap = "sm",
            align = "center",
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

  output$showcase_style_preview_code <- showcase_render_code({
    profile <- selected_profile()
    o <- style_overrides()
    if (length(o)) {
      override_args <- vapply(
        names(o),
        function(name) sprintf("  %s = \"%s\"", name, o[[name]]),
        character(1)
      )
      style_call <- paste0(
        "block_style(\n  \"", profile, "\",\n",
        paste(override_args, collapse = ",\n"), "\n)"
      )
    } else {
      style_call <- sprintf("block_style(\"%s\")", profile)
    }
    paste0(
      "block_page(\n",
      "  style = ", gsub("\n", "\n  ", style_call), ",\n",
      "  ...\n",
      ")"
    )
  })
}

shinyApp(ui, server)
