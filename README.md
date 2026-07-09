# shinyblocks <img src="man/figures/logo.png" align="right" height="180" alt="shinyblocks hex sticker" />

[![R-CMD-check](https://github.com/nvelden/shinyblocks/actions/workflows/ci.yml/badge.svg)](https://github.com/nvelden/shinyblocks/actions/workflows/ci.yml)
[![Status: experimental](https://img.shields.io/badge/status-experimental-orange.svg)](https://github.com/nvelden/shinyblocks)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

`shinyblocks` is an experimental R package for building modern Shiny
dashboards with composable, accessible UI blocks inspired by shadcn/ui.
It is designed for R/Shiny authors who want polished dashboard layouts,
forms, overlays, navigation, theming, and runtime interactions without
adding a Node, Tailwind, Vite, or React build step to their app.

The package is not on CRAN yet, and the public API may change before the
first stable release.

[Documentation and component gallery](https://nvelden.github.io/shinyblocks/)

## Installation

Install the development version from GitHub:

```r
install.packages("pak")
pak::pak("nvelden/shinyblocks")
```

## Quick Example

```r
library(shiny)
library(shinyblocks)

ui <- block_page(
  title = "Operations",
  sidebar = block_sidebar(
    title = "shinyblocks",
    block_nav_item("Overview", icon = "layout-dashboard", selected = TRUE),
    block_nav_item("Reports", icon = "file-text")
  ),
  header = block_header(
    "Operations dashboard",
    block_dark_mode_toggle()
  ),
  block_card(
    title = "Revenue",
    description = "+8% from last week",
    value = "$42,100"
  ),
  block_field(
    block_field_label("Region", `for` = "region"),
    block_select(
      "region",
      choices = c("Americas", "EMEA", "APAC"),
      selected = "Americas"
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
```

## Component Gallery

Run the local showcase app from an installed package checkout:

```r
shinyblocks::run_showcase()
```

The hosted documentation and gallery are available at
<https://nvelden.github.io/shinyblocks/>.

## Use With Shinylive

`shinyblocks` can be used in Shinylive/webR apps before the package is
available through CRAN or the default webR package repositories.
Pre-built WebAssembly binaries are published on
[r-universe](https://nvelden.r-universe.dev/shinyblocks) and rebuilt
automatically from `main` on every push. Install at the top of your
Shinylive `app.R`:

```r
if (!"shinyblocks" %in% rownames(installed.packages())) {
  install.packages(
    "shinyblocks",
    repos = c("https://nvelden.r-universe.dev", "https://repo.r-wasm.org")
  )
}

library(shiny)
library(shinyblocks)
```

The first Shinylive load can take a little longer while webR downloads
and caches the package binaries.
