# Component example apps

Each `<component>.R` file in this directory is a complete, runnable
Shiny app demonstrating one exported `block_*()` component. The
matching `vignettes/articles/components/<component>.qmd` includes the
file twice — once inside a `{shinylive-r}` fence to render the live
demo, once inside a plain `r` fence to show the source — so the demo
and the listing never drift apart.

When adding a new component:

1. Create `<component>.R` here. Keep it self-contained: `library(shiny)`,
   `library(shinyblocks)`, `ui <-`, `server <-`, `shinyApp(ui, server)`.
2. Create `../<component>.qmd` from the [template in ADR 0013](../../../../docs/decisions/0013-component-gallery-quarto.md).
3. Link the new page from `../../components.qmd` (the gallery index).

Examples should illustrate the default plus one or two interesting
variants — not every permutation. Long examples make the iframe
scroll and the listing tedious to read.
