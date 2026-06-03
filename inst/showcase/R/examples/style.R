htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Profile", first = TRUE,
        block_field(
          block_field_label("style profile", `for` = "showcase_style_doc_profile"),
          block_select(
            "showcase_style_doc_profile",
            choices = c(
              "default" = "default",
              stats::setNames(
                setdiff(shinyblocks:::style_profile_names(), "default"),
                setdiff(shinyblocks:::style_profile_names(), "default")
              )
            ),
            selected = "luma",
            size = "sm"
          ),
          block_field_description(
            "block_style() visual profile. Pass to block_page(style = ). Overrides below layer on top."
          )
        )
      ),
      showcase_controls_group(
        "Overrides",
        block_field(
          block_field_label("control height", `for` = "showcase_style_doc_control_height"),
          block_select("showcase_style_doc_control_height", choices = c(
            "profile default" = "inherit",
            "compact (1.75rem)" = "1.75rem",
            "comfortable (2.5rem)" = "2.5rem",
            "large (3rem)" = "3rem"
          ), selected = "inherit", size = "sm")
        ),
        block_field(
          block_field_label("surface gap", `for` = "showcase_style_doc_surface_gap"),
          block_select("showcase_style_doc_surface_gap", choices = c(
            "profile default" = "inherit",
            "tight (0.75rem)" = "0.75rem",
            "roomy (1.5rem)" = "1.5rem",
            "spacious (2rem)" = "2rem"
          ), selected = "inherit", size = "sm")
        ),
        block_field(
          block_field_label("surface padding", `for` = "showcase_style_doc_surface_padding"),
          block_select("showcase_style_doc_surface_padding", choices = c(
            "profile default" = "inherit",
            "compact (1rem)" = "1rem",
            "roomy (2rem)" = "2rem",
            "spacious (2.5rem)" = "2.5rem"
          ), selected = "inherit", size = "sm")
        ),
        block_field(
          block_field_label("control font size", `for` = "showcase_style_doc_control_font_size"),
          block_select("showcase_style_doc_control_font_size", choices = c(
            "profile default" = "inherit",
            "small (0.8rem)" = "0.8rem",
            "large (1rem)" = "1rem",
            "x-large (1.125rem)" = "1.125rem"
          ), selected = "inherit", size = "sm")
        )
      )
    ),
    preview_output_id = "showcase_style_preview_ui",
    code_output_id = "showcase_style_preview_code",
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 1.5rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
      "border: 0; border-radius: 0.75rem; min-height: 330px; box-sizing: border-box;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_style_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  # Style-profile parity fixture: a Luma block_style() scoped to this wrapper.
  # block_style() emits a <style class="sb-style-overrides"> with the luma
  # profile tokens; data-sb-style="luma" on the wrapper activates the scoped
  # component CSS. Stable instance for tools/parity/; do not remove.
  htmltools::div(
    class = "sb-parity-style-baseline",
    `data-sb-style` = "luma",
    style = "display: flex; gap: 1rem; align-items: center;",
    block_style("luma", scope = ".sb-parity-style-baseline"),
    block_button("Luma Button (Style)"),
    block_badge("Luma", variant = "secondary")
  )
)
