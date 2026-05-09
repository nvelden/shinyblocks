library(shiny)
library(shinyblocks)

source(file.path("R", "render_example.R"), local = TRUE)
source(file.path("R", "section.R"), local = TRUE)

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
    title = "Fields and input groups",
    lead = paste(
      "Composable form primitives plus first-class select, textarea,",
      "checkbox, and switch controls with helper text and invalid states."
    ),
    file = "field.R"
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
    id = "empty",
    label = "Empty",
    icon = "folder",
    title = "Empty states",
    lead = paste(
      "Structured empty states with icon, copy, and optional action",
      "instead of custom centered divs."
    ),
    file = "empty.R"
  )
)

ui <- block_page(
  title = "shinyblocks — component gallery",
  sidebar = block_sidebar(
    title = "shinyblocks",
    collapsible = TRUE,
    do.call(
      block_nav,
      c(
        lapply(sections, function(s) {
          block_nav_item(s$label, href = paste0("#", s$id), icon = s$icon)
        }),
        list(class = "sb-sidebar-nav")
      )
    )
  ),
  header = block_header("Component gallery"),
  htmltools::div(
    style = paste(
      "display: flex;",
      "flex-direction: column;",
      "gap: 0.5rem;",
      "margin-bottom: 0.5rem;"
    ),
    htmltools::tags$h1(
      style = paste(
        "font-size: 1.5rem;",
        "font-weight: 600;",
        "letter-spacing: -0.025em;",
        "margin: 0;"
      ),
      "Component gallery"
    ),
    htmltools::tags$p(
      style = "color: var(--muted-foreground); margin: 0;",
      paste(
        "Live demos of every exported shinyblocks component.",
        "The gallery's own UI uses block_page(), block_sidebar(),",
        "block_header(), and block_body() — what you see is the",
        "package documenting itself."
      )
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

server <- function(input, output, session) {}

shinyApp(ui, server)
