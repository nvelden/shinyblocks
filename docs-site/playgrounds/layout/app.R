if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch(
      {
        webr::mount("/packages", path)
        if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
          mounted <- TRUE
          break
        }
      },
      error = function(e) {}
    )
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

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

# A small, static user roster shown on the layout preview's "Users" page.
layout_preview_users_table <- function() {
  users <- data.frame(
    Name = c("Ada Lovelace", "Alan Turing", "Grace Hopper", "Katherine Johnson"),
    Role = c("Admin", "Editor", "Editor", "Viewer"),
    Status = c("Active", "Active", "Invited", "Active"),
    stringsAsFactors = FALSE
  )
  cell <- function(value, muted = FALSE) {
    htmltools::tags$td(
      style = paste0(
        "padding: 0.375rem 0.5rem; border-bottom: 1px solid var(--border);",
        if (muted) " color: var(--muted-foreground);" else ""
      ),
      value
    )
  }
  htmltools::tagList(
    htmltools::tags$h4(
      style = "margin: 0 0 0.5rem 0; font-size: 0.875rem; font-weight: 600;",
      "Users"
    ),
    htmltools::tags$table(
      style = "width: 100%; border-collapse: collapse; font-size: 0.75rem;",
      htmltools::tags$thead(
        htmltools::tags$tr(
          lapply(c("Name", "Role", "Status"), function(heading) {
            htmltools::tags$th(
              style = paste(
                "text-align: left; padding: 0.375rem 0.5rem; font-weight: 600;",
                "color: var(--muted-foreground); border-bottom: 1px solid var(--border);"
              ),
              heading
            )
          })
        )
      ),
      htmltools::tags$tbody(
        lapply(seq_len(nrow(users)), function(i) {
          htmltools::tags$tr(
            cell(users$Name[i]),
            cell(users$Role[i], muted = TRUE),
            cell(users$Status[i], muted = TRUE)
          )
        })
      )
    )
  )
}

ui <- block_page(
  title = "shinyblocks - Layout playground",
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
          block_stack(
            gap = "sm",
            class = "showcase-controls-group showcase-controls-group--first",
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "Header & Sidebar"
            ),
            block_field(
              block_field_label("header title", `for` = "showcase_layout_doc_title"),
              block_textarea("showcase_layout_doc_title", value = "Admin Dashboard", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("sidebar title", `for` = "showcase_layout_doc_sidebar_title"),
              block_textarea("showcase_layout_doc_sidebar_title", value = "Acme Corp", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("profile avatar", `for` = "showcase_layout_doc_profile"),
              block_checkbox("showcase_layout_doc_profile", label = "Show profile avatar", value = TRUE)
            ),
            block_field(
              block_field_label("profile label", `for` = "showcase_layout_doc_profile_label"),
              block_textarea("showcase_layout_doc_profile_label", value = "NV", rows = 1, resize = "none")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "Sidebar State"
            ),
            block_field(
              block_field_label("collapsible", `for` = "showcase_layout_doc_collapsible"),
              block_checkbox("showcase_layout_doc_collapsible", label = "Enable sidebar toggle button", value = TRUE)
            ),
            block_field(
              block_field_label("collapsed", `for` = "showcase_layout_doc_collapsed"),
              block_checkbox("showcase_layout_doc_collapsed", label = "Sidebar starts collapsed", value = FALSE)
            )
          )
        ),
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          block_stack(
            gap = "sm",
            htmltools::div(class = "showcase-playground__label", "Preview"),
            htmltools::div(
              class = "showcase-preview-canvas showcase-preview-canvas--muted showcase-preview-canvas--stretch",
              style = "padding: 1rem; min-height: 332px;",
              uiOutput("showcase_layout_preview_ui")
            )
          ),
          htmltools::div(
            htmltools::div(
              class = "showcase-playground__label showcase-playground__label--code",
              "UI Definition"
            ),
            uiOutput("showcase_layout_preview_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  collapsed_state <- reactiveVal(FALSE)
  # Current sidebar page; block_nav(id = ...) reports the clicked value here.
  preview_page <- reactiveVal("dashboard")

  observeEvent(input$showcase_layout_doc_collapsed,
    {
      collapsed_state(isTRUE(input$showcase_layout_doc_collapsed))
    },
    ignoreInit = FALSE
  )

  observeEvent(input$showcase_layout_preview_toggle, {
    if (isTRUE(input$showcase_layout_doc_collapsible)) {
      collapsed_state(!isTRUE(collapsed_state()))
    }
  })

  observeEvent(input$showcase_layout_preview_nav, {
    preview_page(input$showcase_layout_preview_nav)
  })

  output$showcase_layout_preview_ui <- renderUI({
    title <- input$showcase_layout_doc_title %||% "Admin Dashboard"
    sidebar_title <- input$showcase_layout_doc_sidebar_title %||% "Acme Corp"
    collapsible <- isTRUE(input$showcase_layout_doc_collapsible)
    collapsed <- if (collapsible) isTRUE(collapsed_state()) else FALSE
    show_profile <- isTRUE(input$showcase_layout_doc_profile)
    profile_label <- input$showcase_layout_doc_profile_label %||% "NV"
    profile_label <- trimws(profile_label)
    if (!nzchar(profile_label)) profile_label <- "NV"
    active_page <- preview_page() %||% "dashboard"

    htmltools::div(
      class = "sb-page has-sidebar",
      `data-sidebar-enhanced` = "true",
      `data-sidebar-mobile-open` = "false",
      `data-sidebar-collapsed` = tolower(as.character(collapsed)),
      style = "display: flex; min-height: 0; height: 300px; width: 100%; position: relative; overflow: hidden; background: var(--background); border: 1px solid var(--border); border-radius: 0.5rem; box-shadow: 0 2px 6px rgb(0 0 0 / 0.08);",
      htmltools::div(
        style = paste0(
          "width: ", if (collapsed) "4.5rem" else "200px", ";",
          "transition: width 0.3s ease; display: flex; flex-direction: column; padding: 1rem;",
          "position: relative; overflow: hidden; border-right: 1px solid var(--border); background: var(--muted);"
        ),
        htmltools::div(
          class = "sb-sidebar-title",
          style = "border-bottom: 0; padding: 0; margin-bottom: 1.5rem; white-space: nowrap;",
          htmltools::tags$span(
            class = "sb-sidebar-title-text",
            style = "font-weight: 700; font-size: 0.875rem;",
            sidebar_title
          ),
          if (collapsible) {
            block_button(
              "",
              id = "showcase_layout_preview_toggle",
              variant = "ghost",
              size = "icon",
              icon = "panel-left",
              style = "width: 1.75rem; height: 1.75rem;",
              `aria-label` = "Toggle sidebar"
            )
          }
        ),
        # A real navigation input: clicking an item reports its value as
        # input$showcase_layout_preview_nav and the page below switches.
        block_nav(
          id = "showcase_layout_preview_nav",
          block_nav_item(
            "Dashboard",
            value = "dashboard",
            icon = "layout-dashboard",
            selected = identical(active_page, "dashboard")
          ),
          block_nav_item(
            "Users",
            value = "users",
            icon = "users",
            selected = identical(active_page, "users")
          )
        )
      ),
      # Fixed-geometry main column: flex:1 with no inter-region gap (topbar sits
      # flush above the scrolling content). Not a block_stack target — primitive
      # gaps cannot be zero.
      htmltools::div(
        style = "flex: 1; display: flex; flex-direction: column;",
        block_cluster(
          align = "center",
          justify = "between",
          gap = "md",
          style = "height: 50px; padding: 0 1rem; border-bottom: 1px solid var(--border); background: var(--background);",
          block_cluster(
            align = "center",
            gap = "sm",
            block_icon("menu"),
            htmltools::tags$span(style = "font-weight: 600; font-size: 0.875rem;", title)
          ),
          if (show_profile) {
            htmltools::div(
              title = "Profile area",
              style = paste(
                "width: 1.75rem; height: 1.75rem; border-radius: 9999px;",
                "display: inline-flex; align-items: center; justify-content: center;",
                "background: var(--muted); color: var(--muted-foreground);",
                "font-size: 0.6875rem; font-weight: 700;"
              ),
              substr(profile_label, 1, 2)
            )
          }
        ),
        htmltools::div(
          style = "flex: 1; padding: 1rem; background: var(--background); overflow-y: auto;",
          conditionalPanel(
            condition = "input.showcase_layout_preview_nav != 'users'",
            htmltools::tags$h4(style = "margin: 0 0 0.5rem 0; font-size: 0.875rem; font-weight: 600;", "Overview Metrics"),
            htmltools::div(
              style = "display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.75rem;",
              htmltools::div(
                style = "padding: 0.75rem; border-radius: 0.5rem; border: 1px solid var(--border);",
                htmltools::div(style = "font-size: 0.6875rem; color: var(--muted-foreground);", "Sales"),
                htmltools::div(style = "font-size: 0.875rem; font-weight: 700;", "$12,402")
              ),
              htmltools::div(
                style = "padding: 0.75rem; border-radius: 0.5rem; border: 1px solid var(--border);",
                htmltools::div(style = "font-size: 0.6875rem; color: var(--muted-foreground);", "Active Users"),
                htmltools::div(style = "font-size: 0.875rem; font-weight: 700;", "1,280")
              )
            )
          ),
          conditionalPanel(
            condition = "input.showcase_layout_preview_nav == 'users'",
            layout_preview_users_table()
          )
        )
      )
    )
  })

  output$showcase_layout_preview_code <- showcase_render_code({
    title <- input$showcase_layout_doc_title %||% "Admin Dashboard"
    sidebar_title <- input$showcase_layout_doc_sidebar_title %||% "Acme Corp"
    collapsible <- as.character(isTRUE(input$showcase_layout_doc_collapsible))
    collapsed <- as.character(isTRUE(input$showcase_layout_doc_collapsed))
    show_profile <- isTRUE(input$showcase_layout_doc_profile)
    profile_code <- if (show_profile) {
      paste0(
        ",\n",
        "    htmltools::div(\n",
        "      class = \"profile-avatar\",\n",
        "      ", string_literal(substr(input$showcase_layout_doc_profile_label %||% "NV", 1, 2)), "\n",
        "    )"
      )
    } else {
      ""
    }
    paste0(
      "ui <- block_page(\n",
      "  title = ", string_literal(title), ",\n",
      "  sidebar = block_sidebar(\n",
      "    title = ", string_literal(sidebar_title), ",\n",
      "    collapsible = ", collapsible, ",\n",
      "    collapsed = ", collapsed, ",\n",
      "    # block_nav(id = ...) makes the items a Shiny input.\n",
      "    block_nav(\n",
      "      id = \"page\",\n",
      "      block_nav_item(\"Dashboard\", value = \"dashboard\",\n",
      "                     icon = \"layout-dashboard\", selected = TRUE),\n",
      "      block_nav_item(\"Users\", value = \"users\", icon = \"users\")\n",
      "    )\n",
      "  ),\n",
      "  header = block_header(\n",
      "    ", string_literal(title), profile_code, "\n",
      "  ),\n",
      "  block_body(\n",
      "    conditionalPanel(\n",
      "      \"input.page == 'dashboard'\",\n",
      "      block_card(title = \"Overview Metrics\", textOutput(\"summary\"))\n",
      "    ),\n",
      "    conditionalPanel(\n",
      "      \"input.page == 'users'\",\n",
      "      block_card(title = \"Users\", tableOutput(\"users\"))\n",
      "    )\n",
      "  )\n",
      ")\n\n",
      "server <- function(input, output, session) {\n",
      "  # input$page is a normal Shiny input: \"dashboard\" or \"users\".\n",
      "  output$summary <- renderText(\n",
      "    sprintf(\"You are viewing the %s page.\", input$page)\n",
      "  )\n\n",
      "  output$users <- renderTable(\n",
      "    data.frame(\n",
      "      Name   = c(\"Ada Lovelace\", \"Alan Turing\", \"Grace Hopper\"),\n",
      "      Role   = c(\"Admin\", \"Editor\", \"Viewer\"),\n",
      "      Status = c(\"Active\", \"Active\", \"Invited\")\n",
      "    )\n",
      "  )\n\n",
      "  # Jump to a page from the server when you need to:\n",
      "  # update_block_nav(session, \"page\", \"users\")\n",
      "}"
    )
  })
}

shinyApp(ui, server)
