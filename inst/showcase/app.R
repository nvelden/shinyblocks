suppressWarnings(suppressPackageStartupMessages(library(shiny)))
suppressPackageStartupMessages(library(shinyblocks))

source(file.path("R", "render_example.R"), local = TRUE)
source(file.path("R", "section.R"), local = TRUE)
source(file.path("R", "server_button.R"), local = TRUE)
source(file.path("R", "server_select.R"), local = TRUE)
source(file.path("R", "server_date_picker.R"), local = TRUE)
source(file.path("R", "server_date_range_picker.R"), local = TRUE)
source(file.path("R", "server_checkbox.R"), local = TRUE)
source(file.path("R", "server_dialog.R"), local = TRUE)
source(file.path("R", "server_popover.R"), local = TRUE)
source(file.path("R", "server_textarea.R"), local = TRUE)
source(file.path("R", "server_file_input.R"), local = TRUE)
source(file.path("R", "server_input.R"), local = TRUE)
source(file.path("R", "server_radio_group.R"), local = TRUE)
source(file.path("R", "server_switch.R"), local = TRUE)
source(file.path("R", "server_input_group.R"), local = TRUE)
source(file.path("R", "server_slider.R"), local = TRUE)
source(file.path("R", "server_tooltip.R"), local = TRUE)
source(file.path("R", "server_toast.R"), local = TRUE)
source(file.path("R", "server_code.R"), local = TRUE)
source(file.path("R", "server_badge.R"), local = TRUE)
source(file.path("R", "server_alert.R"), local = TRUE)
source(file.path("R", "server_table.R"), local = TRUE)
source(file.path("R", "server_icon.R"), local = TRUE)
source(file.path("R", "server_separator.R"), local = TRUE)
source(file.path("R", "server_skeleton.R"), local = TRUE)
source(file.path("R", "server_spinner.R"), local = TRUE)
source(file.path("R", "server_progress.R"), local = TRUE)
source(file.path("R", "server_empty.R"), local = TRUE)
source(file.path("R", "server_card.R"), local = TRUE)
source(file.path("R", "server_value_box.R"), local = TRUE)
source(file.path("R", "server_tabs.R"), local = TRUE)
source(file.path("R", "server_theme.R"), local = TRUE)
source(file.path("R", "server_style.R"), local = TRUE)
source(file.path("R", "server_layout.R"), local = TRUE)
source(file.path("R", "server_nav_item.R"), local = TRUE)
source(file.path("R", "server_field.R"), local = TRUE)

# Sections drive both the sidebar nav and the body. Each entry maps to
# inst/showcase/R/examples/<file>.R; add a new component by adding a
# row here and dropping the example file in.
sections <- list(
  list(
    id = "layout",
    label = "Layout shell",
    icon = "layout-dashboard",
    title = "Layout shell",
    lead = paste(
      "block_page() / block_sidebar() / block_header() /",
      "block_body() — the dashboard primitives that frame this gallery."
    ),
    file = "layout.R"
  ),
  list(
    id = "nav-item",
    label = "Nav item",
    icon = "list",
    title = "Navigation items",
    lead = paste(
      "Sidebar links with a selected state.",
      "The same primitive powers this app's own sidebar."
    ),
    file = "nav_item.R"
  ),
  list(
    id = "card",
    label = "Card",
    icon = "layout-grid",
    title = "Cards",
    lead = paste(
      "Tokenised surfaces for grouped content",
      "with optional title and value slots."
    ),
    file = "card.R"
  ),
  list(
    id = "value-box",
    label = "Value box",
    icon = "trending-up",
    title = "Value boxes",
    lead = paste(
      "High-signal metrics with optional leading icons",
      "and short supporting copy."
    ),
    file = "value_box.R"
  ),
  list(
    id = "badge",
    label = "Badge",
    icon = "tag",
    title = "Badges",
    lead = "Compact status labels with four variants.",
    file = "badge.R"
  ),
  list(
    id = "alert",
    label = "Alert",
    icon = "alert-circle",
    title = "Alerts",
    lead = paste(
      "Inline messages with role=\"alert\", composable title",
      "and description slots, and a leading icon."
    ),
    file = "alert.R"
  ),
  list(
    id = "code",
    label = "Code",
    icon = "code",
    title = "Code block",
    lead = paste(
      "A shadcn-docs-style code frame with line numbers,",
      "copy-to-clipboard button, and optional editor header."
    ),
    file = "code.R"
  ),
  list(
    id = "table",
    label = "Table",
    icon = "table",
    title = "Tables",
    lead = paste(
      "Runtime-rendered data frames with shadcn table slots,",
      "R-side cell formatting, captions, and truncation notes."
    ),
    file = "table.R"
  ),
  list(
    id = "button",
    label = "Button",
    icon = "play",
    title = "Buttons",
    lead = paste(
      "Six variants (default, secondary, outline, ghost,",
      "destructive, link), four sizes, and optional inline icons."
    ),
    file = "button.R"
  ),
  list(
    id = "field",
    label = "Field",
    icon = "edit",
    title = "Fields",
    lead = paste(
      "Composes labels, helper descriptions, legends, and validation states",
      "around raw form control elements."
    ),
    file = "field.R"
  ),
  list(
    id = "select",
    label = "Select",
    icon = "chevron-down",
    title = "Select",
    lead = NULL,
    file = "select.R"
  ),
  list(
    id = "date-picker",
    label = "Date picker",
    icon = "calendar",
    title = "Date picker",
    lead = paste(
      "Runtime-rendered shadcn-style date picker: trigger button plus a portaled",
      "calendar, hidden native input, and a shiny.date value binding."
    ),
    file = "date_picker.R"
  ),
  list(
    id = "date-range-picker",
    label = "Date range picker",
    icon = "calendar",
    title = "Date range picker",
    lead = paste(
      "Runtime-rendered shadcn-style date range picker: trigger button plus a",
      "portaled two-endpoint calendar, hidden native input, and a length-2",
      "shiny.date value binding."
    ),
    file = "date_range_picker.R"
  ),
  list(
    id = "checkbox",
    label = "Checkbox",
    icon = "check",
    title = "Checkbox",
    lead = paste(
      "Runtime-rendered checkbox with native Shiny value binding,",
      "checked/disabled/invalid states, and token-driven styling."
    ),
    file = "checkbox.R"
  ),
  list(
    id = "textarea",
    label = "Textarea",
    icon = "file-text",
    title = "Textarea",
    lead = paste(
      "Runtime-rendered textarea with native Shiny value binding,",
      "placeholder/rows/disabled/invalid state, and update_block_textarea() server updates."
    ),
    file = "textarea.R"
  ),
  list(
    id = "file_input",
    label = "File input",
    icon = "upload",
    title = "File input",
    lead = paste(
      "Styled file picker that delegates upload transport to Shiny's native",
      "file upload binding, preserving the standard input data frame."
    ),
    file = "file_input.R"
  ),
  list(
    id = "input",
    label = "Input",
    icon = "edit",
    title = "Text input",
    lead = paste(
      "Runtime-rendered single-line input with text/password/email/url/tel/search/number types,",
      "placeholder, disabled/invalid state, and update_block_input() server updates."
    ),
    file = "input.R"
  ),
  list(
    id = "radio-group",
    label = "Radio group",
    icon = "circle",
    title = "Radio group",
    lead = paste(
      "Runtime-rendered radio group with arrow-key navigation, vertical/horizontal orientation,",
      "disabled/invalid state, and update_block_radio_group() server updates."
    ),
    file = "radio_group.R"
  ),
  list(
    id = "switch",
    label = "Switch",
    icon = "circle-half-stroke",
    title = "Switch",
    lead = paste(
      "Runtime-rendered toggle switch with native Shiny value binding,",
      "checked/disabled state, and update_block_switch() server updates."
    ),
    file = "switch.R"
  ),
  list(
    id = "input-group",
    label = "Input group",
    icon = "search",
    title = "Input group",
    lead = paste(
      "Composes a runtime block_input() with leading/trailing addon slots — icons,",
      "prefixes, suffixes — via block_input_group() and block_input_group_addon()."
    ),
    file = "input_group.R"
  ),
  list(
    id = "slider",
    label = "Slider",
    icon = "sliders-horizontal",
    title = "Slider",
    lead = paste(
      "Runtime-rendered single-value and range slider with Shiny value binding,",
      "disabled/invalid state, and update_block_slider() server updates."
    ),
    file = "slider.R"
  ),
  list(
    id = "tabs",
    label = "Tabs",
    icon = "layout-list",
    title = "Tabs",
    lead = paste(
      "Additive decoration around Shiny tabs:",
      "reactive tab switching with shadcn-style triggers and content."
    ),
    file = "tabs.R"
  ),
  list(
    id = "theme",
    label = "Theme",
    icon = "sun",
    title = "Theme runtime",
    lead = paste(
      "Page-scoped token overrides, persistent dark mode,",
      "and a server-side theme updater hook."
    ),
    file = "theme.R"
  ),
  list(
    id = "style",
    label = "Style",
    icon = "sparkles",
    title = "Style profile",
    lead = paste(
      "block_style() visual profiles — control sizing, spacing, surfaces,",
      "elevation, and motion — applied page-wide via block_page(style = )."
    ),
    file = "style.R"
  ),
  list(
    id = "icon",
    label = "Icon",
    icon = "image",
    title = "Icons",
    lead = paste(
      "Vendored Lucide sprite — every glyph used inside shinyblocks",
      "is referenced from one local SVG."
    ),
    file = "icon.R"
  ),
  list(
    id = "separator",
    label = "Separator",
    icon = "minus",
    title = "Separators",
    lead = paste(
      "Horizontal and vertical dividers for visual grouping",
      "without handwritten border markup."
    ),
    file = "separator.R"
  ),
  list(
    id = "skeleton",
    label = "Skeleton",
    icon = "circle-dashed",
    title = "Skeletons",
    lead = "Loading placeholders for cards, rows, and dense dashboards.",
    file = "skeleton.R"
  ),
  list(
    id = "spinner",
    label = "Spinner",
    icon = "loader-2",
    title = "Spinners",
    lead = "Small status indicators that compose cleanly into buttons.",
    file = "spinner.R"
  ),
  list(
    id = "progress",
    label = "Progress",
    icon = "loader-2",
    title = "Progress",
    lead = paste(
      "Embedded, server-driven progress bar that renders inline instead of as",
      "a Shiny notification panel. Set or increment it from the server."
    ),
    file = "progress.R"
  ),
  list(
    id = "empty",
    label = "Empty",
    icon = "folder",
    title = "Empty states",
    lead = paste(
      "Structured empty states with icon, copy, and optional action",
      "instead of custom centered divs."
    ),
    file = "empty.R"
  ),
  list(
    id = "dialog",
    label = "Dialog",
    icon = "message-circle",
    title = "Dialogs",
    lead = paste(
      "Portal-rendered modal with overlay, close button, focus trap,",
      "and full Shiny input binding. Variants, server-side updates,",
      "and accessibility behaviors covered below."
    ),
    file = "dialog.R"
  ),
  list(
    id = "popover",
    label = "Popover",
    icon = "panel-right",
    title = "Popovers",
    lead = paste(
      "Portal-rendered non-modal overlays with trigger, positioning,",
      "and Shiny open-state/update wiring."
    ),
    file = "popover.R"
  ),
  list(
    id = "tooltip",
    label = "Tooltip",
    icon = "info",
    title = "Tooltip",
    lead = paste(
      "Hover- and focus-triggered text overlay with side/align placement,",
      "configurable open delay, and Escape-to-close. Renders through the",
      "package portal root to avoid clipping."
    ),
    file = "tooltip.R"
  ),
  list(
    id = "toast",
    label = "Toast",
    icon = "bell",
    title = "Toasts",
    lead = paste(
      "Server-fired, auto-dismissing notifications. Mount one block_toaster()",
      "per screen position, then push toasts with show_toast(). Variants and",
      "icons mirror block_alert()."
    ),
    file = "toast.R"
  )
)

ui <- block_page(
  title = "shinyblocks — component gallery",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", type = "text/css", href = "showcase.css?v=20260606_02")
  ),
  sidebar = block_sidebar(
    title = "shinyblocks",
    collapsible = TRUE,
    do.call(
      block_nav,
      c(
        lapply(sections, function(s) {
          block_nav_item(s$label, href = paste0("#", s$id), icon = s$icon)
        })
      )
    )
  ),
  header = block_header(
    "Component gallery",
    htmltools::div(style = "flex: 1;"),
    block_button(
      label = NULL,
      icon = block_icon("circle-half-stroke"),
      variant = "ghost",
      size = "icon",
      class = "sb-dark-mode-toggle",
      `data-sb-theme-toggle` = "true",
      `aria-label` = "Toggle theme"
    )
  ),
  lapply(seq_along(sections), function(i) {
    s <- sections[[i]]
    sb_section(
      id = s$id,
      title = s$title,
      lead = s$lead,
      example_path = file.path("R", "examples", s$file),
      active = i == 1L
    )
  }),
  htmltools::tags$script(htmltools::HTML(
    "
(function () {
  function showSection(id) {
    var matched = false;
    document.querySelectorAll('[data-sb-section]').forEach(function (s) {
      var on = s.getAttribute('data-sb-section') === id;
      if (on) { s.removeAttribute('hidden'); matched = true; }
      else { s.setAttribute('hidden', ''); }
    });
    document.querySelectorAll(
      '.sb-sidebar-nav .sb-nav-item'
    ).forEach(function (a) {
      var href = a.getAttribute('href') || '';
      var on = href === '#' + id;
      a.classList.toggle('is-selected', on);
      if (on) a.setAttribute('aria-current', 'page');
      else a.removeAttribute('aria-current');
    });
    return matched;
  }

  function init() {
    var hash = (location.hash || '').replace(/^#/, '');
    var first = document.querySelector('[data-sb-section]');
    var fallback = first ? first.getAttribute('data-sb-section') : '';
    var target = hash || fallback;
    if (target) showSection(target);

    document.addEventListener('click', function (e) {
      var a = e.target.closest('.sb-sidebar-nav .sb-nav-item');
      if (!a) return;
      var href = a.getAttribute('href') || '';
      if (href.charAt(0) !== '#') return;
      e.preventDefault();
      var id = href.slice(1);
      if (showSection(id) && history.replaceState) {
        history.replaceState(null, '', '#' + id);
      }
    });

    window.addEventListener('hashchange', function () {
      showSection((location.hash || '').replace(/^#/, ''));
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
"
  ))
)

server <- function(input, output, session) {
  register_button_showcase(input, output, session)
  register_code_showcase(input, output, session)
  register_select_showcase(input, output, session)
  register_date_picker_showcase(input, output, session)
  register_date_range_picker_showcase(input, output, session)
  register_checkbox_showcase(input, output, session)
  register_textarea_showcase(input, output, session)
  register_file_input_showcase(input, output, session)
  register_input_showcase(input, output, session)
  register_radio_group_showcase(input, output, session)
  register_switch_showcase(input, output, session)
  register_input_group_showcase(input, output, session)
  register_slider_showcase(input, output, session)
  register_tooltip_showcase(input, output, session)
  register_toast_showcase(input, output, session)
  register_dialog_showcase(input, output, session)
  register_popover_showcase(input, output, session)
  register_badge_showcase(input, output, session)
  register_alert_showcase(input, output, session)
  register_table_showcase(input, output, session)
  register_icon_showcase(input, output, session)
  register_separator_showcase(input, output, session)
  register_skeleton_showcase(input, output, session)
  register_spinner_showcase(input, output, session)
  register_progress_showcase(input, output, session)
  register_empty_showcase(input, output, session)
  register_card_showcase(input, output, session)
  register_value_box_showcase(input, output, session)
  register_tabs_showcase(input, output, session)
  register_theme_showcase(input, output, session)
  register_style_showcase(input, output, session)
  register_layout_showcase(input, output, session)
  register_nav_item_showcase(input, output, session)
  register_field_showcase(input, output, session)
}

shinyApp(ui, server)
