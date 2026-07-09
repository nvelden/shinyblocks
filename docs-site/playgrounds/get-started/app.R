# AUTO-GENERATED — do not edit.
# Source: docs-site/content/guides/get-started.ts (CODE_COMPLETE)
# Regenerate: npm run prebuild
#            (or: npx tsx scripts/generate-get-started-playground.ts)
#
# This is the exact canonical app from the Get Started guide, wrapped with the
# Shinylive WASM bootstrap so it runs as the guide's embedded live preview.

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

report_view <- function(df) {
  data.frame(
    Month = df$month,
    Revenue = sprintf("$%s", format(df$revenue, big.mark = ",", scientific = FALSE)),
    Orders = format(df$orders, big.mark = ",", scientific = FALSE),
    check.names = FALSE
  )
}

ui <- block_page(
  title = "Regional sales",
  theme = block_theme(preset = "zinc"),
  style = block_style("default"),
  sidebar = block_sidebar(
    title = "Acme Analytics",
    collapsible = TRUE,
    block_nav(
      id = "page",
      block_nav_item(
        "Overview",
        value = "overview",
        icon = "layout-dashboard",
        selected = TRUE
      ),
      block_nav_item(
        "Reports",
        value = "reports",
        icon = "file-text"
      )
    )
  ),
  header = block_header(
    block_cluster(
      align = "center",
      justify = "between",
      wrap = FALSE,
      style = "width: 100%;",
      htmltools::div(
        htmltools::tags$strong("Regional sales"),
        htmltools::tags$div(
          style = "color: var(--muted-foreground); font-size: 0.875rem;",
          "Performance for the first six months"
        )
      ),
      block_dark_mode_toggle()
    )
  ),
  block_stack(
    gap = "md",
    block_card(
      title = "Dashboard filters",
      description = "Choose a region or restore the default.",
      block_field(
        block_cluster(
          align = "center",
          justify = "between",
          wrap = FALSE,
          block_field_label("Region", `for` = "region"),
          block_task_button(
            "reset_filters",
            "Reset",
            label_busy = "Resetting...",
            variant = "ghost",
            size = "sm",
            icon = "refresh-cw"
          )
        ),
        block_select(
          "region",
          choices = c("Americas", "EMEA", "APAC"),
          selected = "Americas"
        ),
        block_field_description(
          "All dashboard values use this region."
        )
      )
    ),
    # Overview page. conditionalPanel() shows it only when the sidebar selects
    # it; both pages stay in the document so their outputs keep updating.
    conditionalPanel(
      "output.current_page == 'overview'",
      block_stack(
        gap = "md",
        block_grid(
          min_width = "14rem",
          gap = "md",
          block_value_box(
            title = "Revenue",
            description = "Six-month total",
            value = textOutput("revenue", inline = TRUE),
            icon = "dollar-sign"
          ),
          block_value_box(
            title = "Orders",
            description = "Six-month total",
            value = textOutput("orders", inline = TRUE),
            icon = "package"
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
    ),
    # Reports page.
    conditionalPanel(
      "output.current_page == 'reports'",
      block_card(
        title = "Monthly breakdown",
        description = "Revenue and orders by month for the selected region",
        block_table(
          report_view(sales[sales$region == "Americas", , drop = FALSE]),
          id = "report_table",
          striped = TRUE
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # block_nav(id = "page") reports "overview" or "reports".
  output$current_page <- reactive({
    if (is.null(input$page)) "overview" else input$page
  })
  outputOptions(output, "current_page", suspendWhenHidden = FALSE)

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

  observe({
    update_block_table(
      session,
      "report_table",
      data = report_view(filtered_sales()),
      striped = TRUE
    )
  })

  observeEvent(input$reset_filters, {
    update_block_select(
      session,
      "region",
      selected = "Americas"
    )
  })
}

shinyApp(ui, server)
