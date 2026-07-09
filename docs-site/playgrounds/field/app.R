# Install shinyblocks (pre-built WebAssembly binary) from r-universe.
# NOTE: must be installed.packages(), not requireNamespace() - webR shims
# requireNamespace() and it returns NULL (not FALSE) for packages missing
# from the default webR repo, so negating its result errors.
if (!"shinyblocks" %in% rownames(installed.packages())) {
  install.packages(
    "shinyblocks",
    repos = c("https://nvelden.r-universe.dev", "https://repo.r-wasm.org")
  )
}

library(shiny)
library(shinyblocks)

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


ui <- block_page(
  title = "shinyblocks - Field playground",
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
          block_stack(
            gap = "sm",
            class = "showcase-controls-group showcase-controls-group--first",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Form Layout"),
            block_field(
              block_field_label("legend text", `for` = "showcase_field_legend"),
              block_textarea("showcase_field_legend", value = "Account Details", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("first name label", `for` = "showcase_field_fname_label"),
              block_textarea("showcase_field_fname_label", value = "First name", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("last name description", `for` = "showcase_field_fname_desc"),
              block_textarea("showcase_field_fname_desc", value = "Enter your primary name.", rows = 2, resize = "none")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(
              block_field_label("email label", `for` = "showcase_field_email_label"),
              block_textarea("showcase_field_email_label", value = "Email address", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("email description", `for` = "showcase_field_email_desc"),
              block_textarea("showcase_field_email_desc", value = "We will never share your email address with anyone.", rows = 2, resize = "none")
            ),
            block_field(
              block_field_label("password error message", `for` = "showcase_field_pw_error"),
              block_textarea("showcase_field_pw_error", value = "Password must be at least 8 characters long and contain a digit.", rows = 2, resize = "none")
            ),
            block_field(
              block_field_label("password invalid state", `for` = "showcase_field_pw_invalid"),
              block_checkbox("showcase_field_pw_invalid", label = "Mark password field invalid", value = TRUE)
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
            block_field(
              block_field_label("class", `for` = "showcase_field_class"),
              block_checkbox("showcase_field_class", label = "Use custom dashed-border class", value = FALSE)
            )
          )
        ),
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          block_stack(
            gap = "sm",
            htmltools::tags$div(class = "showcase-playground__label", "Preview"),
            htmltools::tags$div(
              class = "showcase-preview-canvas",
              uiOutput("showcase_field_preview_ui")
            )
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              class = "showcase-playground__label--code",
              "UI Definition"
            ),
            uiOutput("showcase_field_preview_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  output$showcase_field_preview_ui <- renderUI({
    legend_text <- input$showcase_field_legend %||% "Account Details"
    fname_label <- input$showcase_field_fname_label %||% "First name"
    fname_desc <- input$showcase_field_fname_desc %||% "Enter your primary name."
    email_label <- input$showcase_field_email_label %||% "Email address"
    email_desc <- input$showcase_field_email_desc %||% "We will never share your email address with anyone."
    pw_error <- input$showcase_field_pw_error %||% "Password must be at least 8 characters long and contain a digit."
    pw_invalid <- isTRUE(input$showcase_field_pw_invalid)
    custom_class <- if (isTRUE(input$showcase_field_class)) "border-dashed" else NULL

    block_field_set(
      class = custom_class,
      block_field_legend(legend_text),
      block_field_group(
        block_field(
          block_field_label(fname_label, `for` = "showcase_field_demo_fname"),
          block_input("showcase_field_demo_fname", value = "John")
        ),
        block_field(
          block_field_label("Last name", `for` = "showcase_field_demo_lname"),
          block_input("showcase_field_demo_lname", value = "Doe"),
          block_field_description(fname_desc)
        )
      ),
      block_field(
        block_field_label(email_label, `for` = "showcase_field_demo_email"),
        block_input("showcase_field_demo_email", type = "email", value = "john.doe@example.com"),
        block_field_description(email_desc)
      ),
      if (pw_invalid) {
        block_field_invalid(
          block_field(
            block_field_label("Password", `for` = "showcase_field_demo_pw"),
            block_input("showcase_field_demo_pw", type = "password", value = "12345")
          ),
          message = pw_error
        )
      } else {
        block_field(
          block_field_label("Password", `for` = "showcase_field_demo_pw"),
          block_input("showcase_field_demo_pw", type = "password", value = "12345")
        )
      }
    )
  })
  outputOptions(output, "showcase_field_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_field_preview_code <- showcase_render_code({
    legend_text <- input$showcase_field_legend %||% "Account Details"
    fname_label <- input$showcase_field_fname_label %||% "First name"
    fname_desc <- input$showcase_field_fname_desc %||% "Enter your primary name."
    email_label <- input$showcase_field_email_label %||% "Email address"
    email_desc <- input$showcase_field_email_desc %||% "We will never share your email address with anyone."
    pw_error <- input$showcase_field_pw_error %||% "Password must be at least 8 characters long and contain a digit."
    pw_invalid <- isTRUE(input$showcase_field_pw_invalid)
    class_arg <- if (isTRUE(input$showcase_field_class)) ", class = \"border-dashed\"" else ""

    pw_block <- if (pw_invalid) {
      paste0(
        "  block_field_invalid(\n",
        "    block_field(\n",
        "      block_field_label(\"Password\", `for` = \"password\"),\n",
        "      block_input(\"password\", type = \"password\")\n",
        "    ),\n",
        "    message = \"", pw_error, "\"\n",
        "  )"
      )
    } else {
      paste0(
        "  block_field(\n",
        "    block_field_label(\"Password\", `for` = \"password\"),\n",
        "    block_input(\"password\", type = \"password\")\n",
        "  )"
      )
    }

    paste0(
      "block_field_set(\n",
      "  block_field_legend(\"", legend_text, "\")", class_arg, ",\n",
      "  block_field_group(\n",
      "    block_field(\n",
      "      block_field_label(\"", fname_label, "\", `for` = \"first_name\"),\n",
      "      block_input(\"first_name\")\n",
      "    ),\n",
      "    block_field(\n",
      "      block_field_label(\"Last name\", `for` = \"last_name\"),\n",
      "      block_input(\"last_name\"),\n",
      "      block_field_description(\"", fname_desc, "\")\n",
      "    )\n",
      "  ),\n",
      "  block_field(\n",
      "    block_field_label(\"", email_label, "\", `for` = \"email\"),\n",
      "    block_input(\"email\", type = \"email\"),\n",
      "    block_field_description(\"", email_desc, "\")\n",
      "  ),\n",
      pw_block, "\n",
      ")"
    )
  })
  outputOptions(output, "showcase_field_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
