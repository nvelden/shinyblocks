# shinyblocks

An experimental R package for building Shiny dashboards with a
shadcn/ui-inspired component system.

[**Documentation & Component Gallery**](https://nvelden.github.io/shinyblocks/)


The package aims to provide the authoring ergonomics of
`shinydashboard`, but with:

- composable dashboard layout primitives;
- accessible, modern components;
- theme tokens that can map cleanly to shadcn/Tailwind-style design language;
- a clear bridge between R `htmltools` APIs and frontend assets.

This package is early-stage and the API may change.

## Example

```r
library(shiny)
library(shinyblocks)

ui <- block_page(
  title = "Analytics",
  sidebar = block_sidebar(
    block_nav_item("Overview", icon = "layout-dashboard", selected = TRUE),
    block_nav_item("Reports", icon = "file-chart-column")
  ),
  header = block_header("Analytics"),
  block_card(
    title = "Revenue",
    value = "$42,100"
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
```

## Installation

The package is not on CRAN yet. Once the GitHub repository is
available, install the development version with:

```r
pak::pak("nvelden/shinyblocks")
```

## Development

Run the package tests with:

```r
devtools::test()
```

Check the package with:

```r
devtools::check()
```

See `CONTRIBUTING.md` for contribution guidelines.
