// Single source of truth for the Get Started guide.
//
// The complete `app.R` is assembled from the named fragments below, so the
// short snippets shown alongside each section can never drift from the
// canonical example at the bottom of the page. Edit a fragment once and both
// the inline snippet and the complete example update together.
//
// This is a docs-site content module only. It does not change package API,
// runtime components, generated assets, or `man/` pages.

export interface TocEntry {
  /** Stable fragment id, used as the section's `id` and the TOC anchor. */
  id: string;
  /** Human-readable heading text. */
  title: string;
}

/** Ordered table of contents — the single source of truth for the 13 sections. */
export const GET_STARTED_TOC: TocEntry[] = [
  { id: "what-you-will-build", title: "What you will build" },
  { id: "install", title: "Install shinyblocks" },
  { id: "create-app", title: "Create app.R" },
  { id: "page-shell", title: "Build the page shell" },
  { id: "controls", title: "Add a filter and reset action" },
  { id: "outputs", title: "Add reactive cards and a plot" },
  { id: "server-logic", title: "Connect the server" },
  { id: "run-app", title: "Run the app" },
  { id: "complete-example", title: "Complete app.R" },
  { id: "composition-model", title: "Understand composition" },
  { id: "themes-and-styles", title: "Customize the look" },
  { id: "next-steps", title: "Next steps" },
  { id: "troubleshooting", title: "Troubleshooting" },
];

// --- Canonical app fragments -------------------------------------------------
// Each constant is a contiguous slice of the final `app.R`. The complete
// example is `[IMPORTS, DATA, UI, SERVER, RUN].join("\n\n")`.

export const CODE_INSTALL = `install.packages("pak")
pak::pak("nvelden/shinyblocks")`;

const IMPORTS = `library(shiny)
library(shinyblocks)`;

const DATA = `sales <- data.frame(
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
}`;

const UI = `ui <- block_page(
  title = "Regional sales",
  theme = block_theme(preset = "zinc"),
  style = block_style("default"),
  sidebar = block_sidebar(
    title = "Acme Analytics",
    collapsible = TRUE,
    # The nav is rendered on the server so the active page stays highlighted.
    uiOutput("sidebar_nav")
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
          block_field_label("Region", \`for\` = "region"),
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
)`;

const SERVER = `server <- function(input, output, session) {
  # Which page the sidebar has selected. The nav items are action links, so each
  # click bumps its input; we store the choice and expose it for conditionalPanel.
  current_page <- reactiveVal("overview")
  observeEvent(input$nav_overview, current_page("overview"))
  observeEvent(input$nav_reports, current_page("reports"))

  output$current_page <- reactive(current_page())
  outputOptions(output, "current_page", suspendWhenHidden = FALSE)

  output$sidebar_nav <- renderUI({
    active <- current_page()
    nav_item <- function(id, label, icon, value) {
      shiny::actionLink(
        id,
        label = htmltools::tagList(
          block_icon(icon),
          htmltools::tags$span(class = "sb-nav-label", label)
        ),
        class = paste("sb-nav-item", if (identical(value, active)) "is-selected")
      )
    }
    htmltools::tags$nav(
      class = "sb-sidebar-nav",
      nav_item("nav_overview", "Overview", "layout-dashboard", "overview"),
      nav_item("nav_reports", "Reports", "file-text", "reports")
    )
  })

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
}`;

const RUN = `shinyApp(ui, server)`;

// Section-aligned snippets, all derived from the canonical fragments above.
export const CODE_IMPORTS = IMPORTS;
export const CODE_DATA = `${IMPORTS}\n\n${DATA}`;
export const CODE_UI = UI;
export const CODE_SERVER = SERVER;
export const CODE_RUN = RUN;

/** The canonical, copyable complete example. */
export const CODE_COMPLETE = [IMPORTS, DATA, UI, SERVER, RUN].join("\n\n");

// --- Illustrative fragments (not part of the assembled app) ------------------

export const CODE_SHELL_TREE = `block_page()
├── block_sidebar()
├── block_header()
└── body content`;

export const CODE_COMPOSITION_TREE = `block_page()
├── sidebar: nav items  → input$nav_overview / input$nav_reports
├── header: title + theme control
└── body
    ├── filter card
    │   ├── block_select()  → input$region
    │   └── task button     → input$reset_filters
    ├── Overview page  (conditionalPanel)
    │   ├── metric cards  ← renderText()
    │   └── plot card     ← renderPlot()
    └── Reports page   (conditionalPanel)
        └── table         ← update_block_table()`;

export const CODE_THEME_VARIANT = `theme = block_theme(preset = "mauve")
style = block_style("luma")`;

export const CODE_RUN_APP = `shiny::runApp()`;

export const CODE_RUN_SHOWCASE = `shinyblocks::run_showcase()`;
