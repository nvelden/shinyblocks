# AUTO-GENERATED — do not edit.
# Source: docs-site/content/guides/get-started.ts (CODE_COMPLETE)
# Regenerate: npm run prebuild
#            (or: npx tsx scripts/generate-get-started-playground.ts)
#
# This is the exact canonical app from the Get Started guide, wrapped with the
# Shinylive WASM bootstrap so it runs as the guide's embedded live preview.

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
      error = function(e) {
        # Try the next path; Shinylive resolves mount URLs differently by host.
      }
    )
  }

  if (!mounted) {
    tryCatch(
      {
        webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
      },
      error = function(e) {
        stop("Failed to mount shinyblocks WASM package library: ", e$message)
      }
    )
  }

  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
library(shinyblocks)

sales <- data.frame(
  region = rep(c("Americas", "EMEA", "APAC"), each = 6),
  month = rep(month.abb[1:6], times = 3),
  revenue = c(
    82, 91, 96, 104, 111, 119,
    74, 79, 85, 89, 96, 101,
    61, 66, 72, 78, 84, 92
  ) * 1000,
  orders = c(
    410, 452, 471, 509, 548, 581,
    361, 384, 415, 438, 469, 497,
    302, 327, 349, 376, 404, 441
  )
)

ui <- block_page(
  title = "Regional sales",
  theme = block_theme(preset = "zinc"),
  style = block_style("default"),
  sidebar = block_sidebar(
    title = "Acme Analytics",
    collapsible = TRUE,
    block_nav_item(
      "Overview",
      href = "#overview",
      icon = "layout-dashboard",
      selected = TRUE
    ),
    block_nav_item(
      "Reports",
      href = "#reports",
      icon = "file-text"
    )
  ),
  header = block_header(
    htmltools::div(
      htmltools::tags$strong("Regional sales"),
      htmltools::tags$div(
        style = "color: var(--muted-foreground); font-size: 0.875rem;",
        "Performance for the first six months"
      )
    ),
    block_dark_mode_toggle()
  ),
  block_stack(
    id = "overview",
    gap = "md",
    block_card(
      title = "Dashboard filters",
      description = "Choose a region or restore the default.",
      block_cluster(
        gap = "md",
        align = "end",
        block_field(
          block_field_label("Region", `for` = "region"),
          block_select(
            "region",
            choices = c("Americas", "EMEA", "APAC"),
            selected = "Americas"
          ),
          block_field_description(
            "All dashboard values use this region."
          )
        ),
        block_task_button(
          "reset_filters",
          "Reset filters",
          label_busy = "Resetting...",
          variant = "outline",
          icon = "refresh-cw"
        )
      )
    ),
    block_grid(
      min_width = "14rem",
      gap = "md",
      block_card(
        title = "Revenue",
        description = "Six-month total",
        value = textOutput("revenue", inline = TRUE)
      ),
      block_card(
        title = "Orders",
        description = "Six-month total",
        value = textOutput("orders", inline = TRUE)
      )
    ),
    block_card(
      title = "Monthly revenue",
      description = "Revenue by month for the selected region",
      block_plot_output(
        "revenue_plot",
        aspect = "16/9",
        border = FALSE
      )
    )
  )
)

server <- function(input, output, session) {
  filtered_sales <- reactive({
    sales[sales$region == input$region, , drop = FALSE]
  })

  output$revenue <- renderText({
    sprintf("$%s", format(
      sum(filtered_sales()$revenue),
      big.mark = ",",
      scientific = FALSE
    ))
  })

  output$orders <- renderText({
    format(
      sum(filtered_sales()$orders),
      big.mark = ",",
      scientific = FALSE
    )
  })

  output$revenue_plot <- renderPlot(
    {
      current <- filtered_sales()

      barplot(
        current$revenue / 1000,
        names.arg = current$month,
        col = "#71717a",
        border = NA,
        xlab = NULL,
        ylab = "Revenue ($000s)"
      )
    },
    alt = "Monthly revenue bar chart for the selected region"
  )

  observeEvent(input$reset_filters, {
    update_block_select(
      session,
      "region",
      selected = "Americas"
    )
  })
}

shinyApp(ui, server)
