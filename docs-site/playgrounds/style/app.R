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
      class = "showcase-playground", style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        style = "flex: 1; min-width: 280px; max-width: 320px;",
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem;",
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
            ),
            block_field_description(
              "block_style() visual profile. Pass to block_page(style = ). Overrides below layer on top."
            )
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
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
            block_field_label("focus ring width", `for` = "showcase_style_doc_focus_ring_width"),
            block_select("showcase_style_doc_focus_ring_width", choices = c(
              "profile default" = "inherit",
              "thin (1px)" = "1px",
              "bold (3px)" = "3px"
            ), selected = "inherit", size = "sm")
          )
        )
      ),
      htmltools::div(
        class = "showcase-playground__main", style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.5rem;",
          htmltools::div(style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);", "Preview"),
          htmltools::div(
            style = paste(
              "position: relative;",
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
      focus_ring_width = pick("showcase_style_doc_focus_ring_width")
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
      htmltools::div(
        class = "sb-style-demo-scope",
        `data-sb-style` = profile,
        style = "display: flex; flex-direction: column; gap: var(--sb-surface-gap, 1.1rem); width: 100%;",
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
