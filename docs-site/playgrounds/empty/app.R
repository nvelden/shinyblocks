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
    }, error = function(e) {
      # Try the next path; Shinylive resolves mount URLs differently by host.
    })
  }

  if (!mounted) {
    tryCatch({
      webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
    }, error = function(e) {
      stop("Failed to mount shinyblocks WASM package library: ", e$message)
    })
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
    value <- eval(quoted, envir = env)
    if (is.null(value) || !length(value)) value <- ""
    block_code(
      code = paste(as.character(value), collapse = "\n"),
      language = "r",
      copyable = TRUE,
      line_numbers = TRUE
    )
  })
}

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

ui <- block_page(
  title = "shinyblocks - Empty playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::tags$div(
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
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Content"
          ),
          block_field(
            block_field_label("title", `for` = "showcase_empty_doc_title"),
            block_textarea("showcase_empty_doc_title", value = "No projects found", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("description", `for` = "showcase_empty_doc_description"),
            block_textarea("showcase_empty_doc_description", value = "Get started by creating a new repository.", rows = 2, resize = "none")
          )
        ),
        block_stack(
          gap = "sm",
          class = "showcase-controls-group",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Settings"
          ),
          block_field(
            block_field_label("icon", `for` = "showcase_empty_doc_icon"),
            block_select(
              "showcase_empty_doc_icon",
              choices = c("folder", "inbox", "search", "alert-circle", "none"),
              selected = "folder",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("action", `for` = "showcase_empty_doc_action"),
            block_checkbox("showcase_empty_doc_action", label = "Include action button", value = TRUE)
          )
        ),
        block_stack(
          gap = "sm",
          class = "showcase-controls-group",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Styling"
          ),
          block_field(
            block_field_label("class", `for` = "showcase_empty_doc_class"),
            block_select(
              "showcase_empty_doc_class",
              choices = c("none", "border-dashed", "bg-transparent"),
              selected = "none",
              size = "sm"
            )
          )
        )
      ),
      block_stack(
        gap = "lg",
        class = "showcase-playground__main",
        block_stack(
          gap = "sm",
          htmltools::tags$div(
            style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);",
            "Preview"
          ),
          htmltools::tags$div(
            class = "showcase-preview-canvas",
            uiOutput("showcase_empty_preview_ui")
          )
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_empty_preview_code")
        )
      )
        )
)
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    title <- input$showcase_empty_doc_title %||% "No projects found"
    if (!nzchar(title)) title <- "No projects found"

    description <- input$showcase_empty_doc_description %||% "Get started by creating a new repository."
    if (!nzchar(description)) description <- NULL

    icon <- input$showcase_empty_doc_icon %||% "folder"
    if (identical(icon, "none")) icon <- NULL

    class <- input$showcase_empty_doc_class %||% ""
    if (!nzchar(class) || identical(class, "none")) class <- NULL

    list(
      title = title,
      description = description,
      icon = icon,
      action = isTRUE(input$showcase_empty_doc_action),
      class = class
    )
  })

  output$showcase_empty_preview_ui <- renderUI({
    args <- preview_args()
    action_tag <- NULL
    if (args$action) {
      action_tag <- block_button(
        label = "Create project",
        id = "showcase_empty_project_btn",
        variant = "default",
        icon = "plus"
      )
    }

    block_empty(
      title = args$title,
      description = args$description,
      icon = args$icon,
      action = action_tag,
      class = args$class
    )
  })
  outputOptions(output, "showcase_empty_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_empty_preview_code <- showcase_render_code({
    args <- preview_args()
    code_args <- c(paste0("title = ", string_literal(args$title)))

    if (!is.null(args$description)) {
      code_args <- c(code_args, paste0("description = ", string_literal(args$description)))
    }
    if (!is.null(args$icon)) {
      code_args <- c(code_args, paste0("icon = ", string_literal(args$icon)))
    }
    if (args$action) {
      code_args <- c(code_args, paste0(
        "action = block_button(\n",
        "    label = \"Create project\",\n",
        "    id = \"showcase_empty_project_btn\",\n",
        "    variant = \"default\",\n",
        "    icon = \"plus\"\n",
        "  )"
      ))
    }
    if (!is.null(args$class)) {
      code_args <- c(code_args, paste0("class = ", string_literal(args$class)))
    }

    paste0("block_empty(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_empty_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
