# Static gallery preview. block_plot_output() frames shiny::plotOutput(), which
# renders empty without a running Shiny server, so this mirrors the real
# component frame (the same .sb-output-* classes and CSS) with a representative
# bar chart in the media box. The bars use the theme's --primary token so the
# preview tracks light/dark and block_theme(). See the playground for live
# renderPlot() usage: output$id <- shiny::renderPlot(...).
chart <- htmltools::HTML(
  '<svg viewBox="0 0 320 180" preserveAspectRatio="none" width="100%" height="100%" role="img" aria-label="Quarterly revenue by region">
  <line x1="26" y1="156" x2="308" y2="156" style="stroke:var(--border)" stroke-width="1.5"/>
  <g style="fill:var(--primary)">
    <rect x="34" y="116" width="24" height="40" rx="2"/>
    <rect x="102" y="86" width="24" height="70" rx="2"/>
    <rect x="170" y="100" width="24" height="56" rx="2"/>
    <rect x="238" y="62" width="24" height="94" rx="2"/>
  </g>
  <g style="fill:var(--primary);opacity:0.42">
    <rect x="60" y="98" width="24" height="58" rx="2"/>
    <rect x="128" y="60" width="24" height="96" rx="2"/>
    <rect x="196" y="78" width="24" height="78" rx="2"/>
    <rect x="264" y="42" width="24" height="114" rx="2"/>
  </g>
</svg>'
)

htmltools::tags$figure(
  class = "sb-output-frame sb-plot-output",
  htmltools::tags$div(
    class = "sb-output-media",
    `data-aspect` = NA, `data-border` = NA, `data-rounded` = NA,
    style = "width:100%;--sb-output-aspect:16/9;",
    chart
  ),
  htmltools::tags$figcaption(
    class = "sb-output-caption",
    "Quarterly revenue by region"
  )
)
