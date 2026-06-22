# rendered frames match snapshot

    Code
      cat(render_html(block_image_output("img", aspect = "16/9", border = TRUE,
        caption = "A photo")))
    Output
      <figure class="sb-output-frame sb-image-output">
        <div class="sb-output-media" data-aspect data-border data-rounded style="width:100%;--sb-output-fit:cover;--sb-output-aspect:16/9;">
          <div id="img" class="shiny-image-output" style="width:100%;height:100%;"></div>
        </div>
        <figcaption class="sb-output-caption">A photo</figcaption>
      </figure>

---

    Code
      cat(render_html(block_plot_output("plot", border = TRUE, rounded = FALSE)))
    Output
      <figure class="sb-output-frame sb-plot-output">
        <div class="sb-output-media" data-border style="width:100%;--sb-output-fit:cover;">
          <div class="shiny-plot-output html-fill-item" id="plot" style="width:100%;height:400px;"></div>
        </div>
      </figure>

