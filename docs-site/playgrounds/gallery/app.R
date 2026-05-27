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
  if (!mounted) webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a

panel <- function(...) {
  htmltools::div(style = "display: flex; flex-direction: column; gap: 1rem; min-width: 0;", ...)
}

ui <- block_page(
  title = "shinyblocks - Live gallery",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::div(
    `data-shinyblocks-root` = "",
    style = "padding: 1.25rem; display: flex; flex-direction: column; gap: 1.25rem; box-sizing: border-box;",
    htmltools::div(
      style = "display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap;",
      htmltools::div(
        htmltools::tags$h2(style = "margin: 0; font-size: 1.25rem; font-weight: 650;", "Workspace dashboard"),
        htmltools::tags$p(style = "margin: 0.25rem 0 0; font-size: 0.875rem; color: var(--muted-foreground);", "Live package components composed in a Shiny workflow.")
      ),
      htmltools::div(
        style = "display: flex; align-items: center; gap: 0.5rem;",
        block_badge("Live", variant = "secondary"),
        block_button("Refresh", id = "gallery_refresh", icon = "refresh-cw", size = "sm")
      )
    ),
    uiOutput("gallery_alert"),
    htmltools::div(
      style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(235px, 1fr)); gap: 1rem; align-items: start;",
      panel(
        block_card(
          title = "Payment method",
          description = "Secure checkout profile",
          block_field_group(
            block_field(block_field_label("Name on card"), block_input("gallery_name", placeholder = "Jane Smith")),
            block_field(block_field_label("Plan"), block_select("gallery_plan", choices = c("Starter", "Professional", "Enterprise"), selected = "Professional", size = "sm")),
            block_field(block_field_label("Notes"), block_textarea("gallery_notes", placeholder = "Billing notes", rows = 2))
          ),
          footer = block_button("Save payment", id = "gallery_save", size = "sm")
        )
      ),
      panel(
        uiOutput("gallery_metric"),
        block_card(
          title = "Budget",
          description = "Monthly operating budget",
          block_slider("gallery_budget", min = 1000, max = 10000, value = 5200, step = 100),
          footer = textOutput("gallery_budget_value")
        ),
        htmltools::div(
          style = "display: flex; gap: 0.5rem; flex-wrap: wrap;",
          block_badge("Production"),
          block_badge("Synced", variant = "secondary"),
          block_badge("Verified", variant = "outline")
        )
      ),
      panel(
        block_card(
          title = "Preferences",
          description = "Workspace notifications",
          block_field_group(
            block_switch("gallery_notifications", "Email notifications", value = TRUE),
            block_checkbox("gallery_terms", "Enable weekly digest", value = TRUE),
            block_radio_group(
              "gallery_environment",
              choices = c("Production" = "prod", "Staging" = "stage"),
              selected = "prod"
            )
          )
        ),
        block_tabs(
          id = "gallery_tabs",
          selected = "activity",
          block_tab("Activity", value = "activity", block_alert("All systems operational.")),
          block_tab("Members", value = "members", block_empty("No pending invites", "New invitations appear here.", icon = "users"))
        )
      )
    )
  )
)

server <- function(input, output, session) {
  refreshes <- reactiveVal(0L)
  saved <- reactiveVal(FALSE)

  observeEvent(input$gallery_refresh, {
    refreshes(refreshes() + 1L)
  })
  observeEvent(input$gallery_save, {
    saved(TRUE)
  })

  output$gallery_alert <- renderUI({
    if (isTRUE(saved())) {
      block_alert("Payment settings saved.", description = "Your workspace billing profile is up to date.")
    } else {
      block_alert("Complete the payment profile to enable automatic renewals.", variant = "default")
    }
  })

  output$gallery_metric <- renderUI({
    plan <- input$gallery_plan %||% "Professional"
    block_value_box(
      title = "Active plan",
      value = plan,
      description = paste0("Refreshed ", refreshes(), " time", if (refreshes() == 1L) "" else "s"),
      icon = "chart-column"
    )
  })

  output$gallery_budget_value <- renderText({
    value <- input$gallery_budget %||% 5200
    paste0("$", format(value, big.mark = ",", scientific = FALSE), " / month")
  })
}

shinyApp(ui, server)
