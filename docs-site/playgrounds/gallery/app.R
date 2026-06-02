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

gallery_style_profiles <- block_style_profiles()
gallery_theme_presets <- block_theme_presets()

panel <- function(...) {
  htmltools::div(style = "display: flex; flex-direction: column; gap: 1rem; min-width: 0;", ...)
}

stack <- function(..., gap = "0.75rem") {
  htmltools::div(style = paste0("display: flex; flex-direction: column; gap: ", gap, "; min-width: 0;"), ...)
}

row <- function(..., gap = "0.5rem", wrap = TRUE) {
  htmltools::div(
    style = paste0(
      "display: flex; align-items: center; gap: ", gap, ";",
      if (isTRUE(wrap)) " flex-wrap: wrap;" else "",
      " min-width: 0;"
    ),
    ...
  )
}

mini_label <- function(label, value) {
  htmltools::div(
    style = "display: flex; align-items: center; justify-content: space-between; gap: 1rem; font-size: 0.875rem;",
    htmltools::span(style = "color: var(--muted-foreground);", label),
    htmltools::strong(style = "font-weight: 600;", value)
  )
}

loading_lines <- function() {
  stack(
    block_skeleton(style = "height: 0.75rem; width: 70%;"),
    block_skeleton(style = "height: 0.75rem; width: 46%;"),
    block_skeleton(style = "height: 3rem; width: 100%;"),
    gap = "0.5rem"
  )
}

ui <- block_page(
  title = "shinyblocks - Live gallery",
  theme = htmltools::tagList(
    block_theme(preset = "neutral"),
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$script(htmltools::HTML(
      "(function registerGalleryStyleHandler() {
        if (!window.Shiny || !Shiny.addCustomMessageHandler) {
          window.setTimeout(registerGalleryStyleHandler, 50);
          return;
        }
        Shiny.addCustomMessageHandler('gallery:set-style-profile', function(profile) {
          var root = document.querySelector('.sb-app');
          if (root && profile) root.setAttribute('data-sb-style', profile);
        });
      })();"
    ))
  ),
  style = block_style("default"),
  htmltools::div(style = "display: none;", uiOutput("gallery_theme_assets")),
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
    block_card(
      title = "Appearance",
      description = "Session theme controls",
      style = "padding-bottom: 1rem;",
      htmltools::div(
        style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 13rem), 1fr)); gap: 1rem;",
        block_field(
          block_field_label("Style profile", `for` = "gallery_style_profile"),
          block_select(
            "gallery_style_profile",
            choices = stats::setNames(gallery_style_profiles, gallery_style_profiles),
            selected = "default",
            size = "sm"
          )
        ),
        block_field(
          block_field_label("Theme preset", `for` = "gallery_theme_preset"),
          block_select(
            "gallery_theme_preset",
            choices = stats::setNames(gallery_theme_presets, gallery_theme_presets),
            selected = "neutral",
            size = "sm"
          )
        )
      )
    ),
    uiOutput("gallery_alert"),
    htmltools::div(
      style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 1rem;",
      uiOutput("gallery_metric"),
      uiOutput("gallery_budget_metric"),
      block_value_box(
        title = "Members",
        value = "24",
        description = "+3 this week",
        icon = "users",
        block_badge("Growing", variant = "secondary")
      ),
      block_value_box(
        title = "Uptime",
        value = "99.98%",
        description = "Last 30 days",
        icon = "gauge",
        block_badge("Healthy", variant = "outline")
      )
    ),
    htmltools::div(
      style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 260px), 1fr)); gap: 1rem; align-items: stretch;",
      panel(
        htmltools::div(
          `data-component-preview` = "card",
          style = "height: 100%;",
          block_card(
            title = "Payment method",
            description = "Secure checkout profile",
            style = "height: 100%;",
            block_field_group(
              block_field(block_field_label("Name on card"), block_input("gallery_name", placeholder = "Jane Smith")),
              block_field(
                block_field_label("Billing email"),
                block_input_group(
                  block_input_group_addon(block_icon("mail")),
                  block_input("gallery_email", placeholder = "billing@acme.app", type = "email")
                )
              ),
              block_field(block_field_label("Plan"), block_select("gallery_plan", choices = c("Starter", "Professional", "Enterprise"), selected = "Professional", size = "sm")),
              block_field(block_field_label("Notes"), block_textarea("gallery_notes", placeholder = "Billing notes", rows = 2, resize = "none"))
            ),
            footer = row(
              htmltools::div(
                `data-component-preview` = "button",
                block_button("Save payment", id = "gallery_save", size = "sm", icon = "save")
              ),
              block_dialog(
                "gallery_invoice_dialog",
                title = "Invoice preview",
                description = "A compact dialog using the current dashboard values.",
                stack(
                  mini_label("Plan", "Professional"),
                  mini_label("Budget", "$5,200 / month"),
                  mini_label("Environment", "Production")
                ),
                footer = block_button("Close", size = "sm", variant = "outline"),
                trigger = "Preview invoice",
                size = "sm"
              ),
              wrap = TRUE
            )
          )
        )
      ),
      panel(
        block_card(
          title = "Budget",
          description = "Monthly operating budget",
          style = "height: 100%;",
          block_slider("gallery_budget", min = 1000, max = 10000, value = 5200, step = 100),
          block_separator(),
          stack(
            mini_label("Monthly spend", textOutput("gallery_budget_value", inline = TRUE)),
            mini_label("Forecast", textOutput("gallery_forecast_value", inline = TRUE)),
            mini_label("Refresh jobs", uiOutput("gallery_refresh_state"))
          ),
          block_separator(),
          stack(
            htmltools::strong(style = "font-size: 0.875rem; font-weight: 600;", "Workspace status"),
            row(
              block_badge("Production"),
              block_badge("Synced", variant = "secondary"),
              block_badge("Verified", variant = "outline")
            )
          )
        )
      ),
      panel(
        block_card(
          title = "Preferences",
          description = "Workspace notifications",
          style = "height: 100%;",
          block_field_group(
            block_switch("gallery_notifications", "Email notifications", value = TRUE),
            block_checkbox("gallery_terms", "Enable weekly digest", value = TRUE),
            block_radio_group(
              "gallery_environment",
              choices = c("Production" = "prod", "Staging" = "stage", "Review" = "review"),
              selected = "prod",
              orientation = "vertical"
            )
          ),
          block_separator(),
          block_tabs(
            id = "gallery_tabs",
            selected = "activity",
            block_tab(
              "Activity",
              value = "activity",
              stack(
                block_alert("All systems operational.", description = "Runtime alerts, tabs, badges, and form controls are active."),
                block_popover(
                  "Deploy notes",
                  stack(
                    htmltools::tags$p(style = "margin: 0;", "Latest release shipped component previews and budget checks."),
                    block_badge("No incidents", variant = "secondary")
                  ),
                  id = "gallery_popover",
                  align = "end"
                )
              )
            ),
            block_tab(
              "Members",
              value = "members",
              block_empty(
                "No pending invites",
                description = "New invitations appear here.",
                icon = "users",
                action = block_button("Invite member", size = "sm", variant = "outline", icon = "plus")
              )
            ),
            block_tab(
              "Deploy",
              value = "deploy",
              block_code(
                "block_page(\n  block_card(\n    title = \"Workspace dashboard\",\n    block_value_box(\"Uptime\", \"99.98%\")\n  )\n)",
                language = "r",
                header = TRUE,
                line_numbers = FALSE
              )
            )
          )
        )
      )
    ),
    block_card(
      title = "Pipeline readiness",
      description = "Skeletons, separators, badges, alerts, and spinner states in one workflow.",
      htmltools::div(
        style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem;",
        stack(block_badge("Loading surface", variant = "secondary"), loading_lines()),
        stack(
          block_badge("Checks", variant = "outline"),
          mini_label("Runtime CSS", "OK"),
          block_separator(),
          mini_label("Shiny binding", "OK"),
          block_separator(),
          mini_label("Docs preview", "OK")
        ),
        stack(
          block_badge("Next sync"),
          row(block_spinner(size = "sm", color = "muted"), htmltools::span("Waiting for changes"), wrap = FALSE),
          block_alert("Ready to publish", description = "Refresh the dashboard to simulate a live update.", icon = "check-circle")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  refreshes <- reactiveVal(0L)
  saved <- reactiveVal(FALSE)

  selected_style_profile <- reactive({
    value <- input$gallery_style_profile %||% "default"
    if (!value %in% gallery_style_profiles) "default" else value
  })

  selected_theme_preset <- reactive({
    value <- input$gallery_theme_preset %||% "neutral"
    if (!value %in% gallery_theme_presets) "neutral" else value
  })

  observe({
    session$sendCustomMessage("gallery:set-style-profile", selected_style_profile())
  })

  output$gallery_theme_assets <- renderUI({
    style_profile <- selected_style_profile()
    htmltools::tagList(
      block_theme(preset = selected_theme_preset(), scope = ".sb-app"),
      block_style(style_profile, scope = ".sb-app")$style
    )
  })

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
      icon = "chart-bar"
    )
  })

  output$gallery_budget_metric <- renderUI({
    value <- input$gallery_budget %||% 5200
    block_value_box(
      title = "Budget",
      value = paste0("$", format(value, big.mark = ",", scientific = FALSE)),
      description = "Monthly cap",
      icon = "pie-chart",
      block_badge(if (value > 8000) "High" else "On track", variant = if (value > 8000) "destructive" else "secondary")
    )
  })

  output$gallery_budget_value <- renderText({
    value <- input$gallery_budget %||% 5200
    paste0("$", format(value, big.mark = ",", scientific = FALSE), " / month")
  })

  output$gallery_forecast_value <- renderText({
    value <- input$gallery_budget %||% 5200
    paste0("$", format(round(value * 1.12), big.mark = ",", scientific = FALSE))
  })

  output$gallery_refresh_state <- renderUI({
    if (refreshes() == 0L) {
      block_badge("Idle", variant = "outline")
    } else {
      row(block_spinner(size = "sm", color = "muted"), block_badge(paste(refreshes(), "runs"), variant = "secondary"), wrap = FALSE)
    }
  })

}

shinyApp(ui, server)
