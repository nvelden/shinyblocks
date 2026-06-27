test_that("block_page renders the shell landmarks", {
  page <- block_page(
    title = "Example",
    sidebar = block_sidebar(
      title = "Navigation",
      block_nav_item("Home", selected = TRUE)
    ),
    header = block_header("Header"),
    "Body"
  )

  rendered <- htmltools::renderTags(page)
  html <- paste(rendered$html, collapse = "")
  head <- paste(rendered$head, collapse = "")

  expect_match(html, '<div class="sb-app">', fixed = TRUE)
  expect_match(html, 'class="sb-page has-sidebar"', fixed = TRUE)
  expect_match(html, 'data-sidebar-enhanced="false"', fixed = TRUE)
  expect_match(html, 'data-sidebar-mobile-open="false"', fixed = TRUE)
  expect_match(html, 'class="sb-sidebar"', fixed = TRUE)
  expect_match(html, 'class="sb-sidebar-backdrop"', fixed = TRUE)
  expect_match(html, 'class="sb-sidebar-mobile-trigger"', fixed = TRUE)
  expect_match(
    html,
    'class="sb-sidebar-backdrop"[\\s\\S]*class="sb-sidebar"',
    perl = TRUE,
    info = "the mobile backdrop must paint before and therefore below the sidebar"
  )
  expect_match(html, '<header class="sb-header">', fixed = TRUE)
  expect_match(html, '<main class="sb-body">', fixed = TRUE)
  expect_match(html, 'data-shinyblocks-portal-root=""', fixed = TRUE)
  expect_match(
    html,
    '<div class="sb-app">[\\s\\S]*data-shinyblocks-portal-root=""',
    perl = TRUE
  )
  expect_match(head, "window.shinyblocksInitialThemeMode", fixed = TRUE)
})

test_that("block_page includes optional theme overrides in head", {
  page <- block_page(
    title = "Example",
    theme = block_theme(primary = "oklch(0.5 0.2 250)")
  )
  head <- paste(htmltools::renderTags(page)$head, collapse = "")

  expect_match(head, "sb-theme-overrides", fixed = TRUE)
  expect_match(head, "--primary: oklch(0.5 0.2 250);", fixed = TRUE)
})

test_that("block_page emits a page-owner body reset (Preflight is scoped to .sb-app)", {
  head <- paste(htmltools::renderTags(block_page("Body"))$head, collapse = "")

  # The Tailwind Preflight reset is scoped to .sb-app (ADR 0022), so the
  # page-owning entry point restores the body margin reset itself.
  expect_match(head, "sb-page-chrome", fixed = TRUE)
  expect_match(head, "body{margin:0;padding:0}", fixed = TRUE)
})

test_that("block_page applies a style profile and injects its overrides", {
  page <- block_page(
    title = "Example",
    style = block_style("default", control_height = "2.5rem")
  )
  rendered <- htmltools::renderTags(page)
  html <- paste(rendered$html, collapse = "")
  head <- paste(rendered$head, collapse = "")

  expect_match(html, 'data-sb-style="default"', fixed = TRUE)
  expect_match(head, "sb-style-overrides", fixed = TRUE)
  expect_match(head, "--sb-control-height: 2.5rem;", fixed = TRUE)
})

test_that("block_page applies the luma profile", {
  page <- block_page(
    title = "Example",
    style = block_style("luma")
  )
  rendered <- htmltools::renderTags(page)
  html <- paste(rendered$html, collapse = "")
  head <- paste(rendered$head, collapse = "")

  expect_match(html, 'data-sb-style="luma"', fixed = TRUE)
  expect_match(head, "sb-style-overrides", fixed = TRUE)
  expect_match(head, "--sb-control-gap: 0.375rem;", fixed = TRUE)
})

test_that("block_page omits data-sb-style when no style is supplied", {
  html <- paste(htmltools::renderTags(block_page("Body"))$html, collapse = "")
  expect_no_match(html, "data-sb-style", fixed = TRUE)
})

test_that("block_page rejects a non-style object", {
  expect_error(
    block_page("Body", style = block_theme(primary = "red")),
    "must be a `block_style\\(\\)` object"
  )
})

test_that("layout helpers merge user classes", {
  expect_identical(
    tag_attr(block_header("Header", class = "custom"), "class"),
    "sb-header custom"
  )
  expect_identical(
    tag_attr(block_body("Body", class = "custom"), "class"),
    "sb-body custom"
  )
  expect_identical(
    tag_attr(block_sidebar("Item", class = "custom"), "class"),
    "sb-sidebar custom"
  )
  expect_identical(
    tag_attr(block_stack(class = "custom"), "class"),
    "sb-stack sb-layout-gap-md sb-layout-align-stretch custom"
  )
  expect_identical(
    tag_attr(block_cluster(class = "custom"), "class"),
    paste(
      "sb-cluster sb-layout-gap-sm sb-layout-align-center",
      "sb-layout-justify-start custom"
    )
  )
  expect_identical(
    tag_attr(block_grid(class = "custom"), "class"),
    "sb-grid sb-layout-gap-md sb-layout-align-stretch custom"
  )
})

test_that("text nav items carry the label as a title for tooltip and a11y name", {
  # In the collapsed icon rail the visible label is visually hidden and the icon
  # is aria-hidden, so `title` is the link's accessible-name fallback.
  expect_identical(tag_attr(block_nav_item("Reports"), "title"), "Reports")

  # Non-character labels (e.g. a tag) must not be coerced into a title.
  tagged <- block_nav_item(htmltools::tags$span("Reports"))
  expect_null(tag_attr(tagged, "title"))
})

test_that("selected nav items expose aria-current", {
  selected <- block_nav_item("Home", selected = TRUE)
  unselected <- block_nav_item("Reports")

  expect_identical(tag_attr(selected, "aria-current"), "page")
  expect_null(tag_attr(unselected, "aria-current"))
})

test_that("nav items advertise themselves as nav-item children", {
  ns <- local_internal()
  item <- block_nav_item("Home")

  expect_identical(tag_attr(item, "data-sb-child"), "nav-item")
  expect_invisible(
    ns$validate_children(list(item), "nav-item", "block_nav")
  )
})

test_that("nav containers merge classes and wrap items", {
  nav <- block_nav(
    block_nav_item("Home"),
    block_nav_item("Reports"),
    class = "custom"
  )

  expect_identical(tag_attr(nav, "class"), "sb-nav custom")
})

test_that("block_nav(id) marks the container as a nav input", {
  with_id <- block_nav(block_nav_item("Home"), id = "page")
  without_id <- block_nav(block_nav_item("Home"))

  expect_identical(tag_attr(with_id, "data-sb-nav-input-id"), "page")
  expect_null(tag_attr(without_id, "data-sb-nav-input-id"))
})

test_that("nav items carry a data-value defaulting to the text label", {
  default_value <- block_nav_item("Users")
  explicit_value <- block_nav_item("Users", value = "users")
  tag_label <- block_nav_item(htmltools::tags$span("Users"), value = "users")

  expect_identical(tag_attr(default_value, "data-value"), "Users")
  expect_identical(tag_attr(explicit_value, "data-value"), "users")
  expect_identical(tag_attr(tag_label, "data-value"), "users")
  # A tag label without an explicit value has no input value to report.
  expect_null(tag_attr(block_nav_item(htmltools::tags$span("Users")), "data-value"))
})

test_that("sidebar reuses a provided nav container instead of nesting nav landmarks", {
  sidebar <- block_sidebar(
    title = "Navigation",
    block_nav(
      block_nav_item("Home"),
      block_nav_item("Reports")
    )
  )
  html <- render_html(sidebar)

  expect_match(html, '<nav class="sb-nav sb-sidebar-nav">', fixed = TRUE)
  expect_false(grepl('<nav class="sb-sidebar-nav">\\s*<nav', html, perl = TRUE))
})

test_that("block_tabs emits package-owned tab markup", {
  tabs <- block_tabs(
    id = "demo_tabs",
    selected = "usage",
    variant = "line",
    block_tab("Overview", value = "overview", "Overview body"),
    block_tab("Usage", value = "usage", "Usage body"),
    class = "custom"
  )
  html <- render_html(tabs)

  expect_match(
    html,
    'id="demo_tabs" class="sb-tabs custom" data-sb-tabs="true"',
    fixed = TRUE
  )
  expect_match(
    html,
    'data-sb-tabs-input-id="demo_tabs"',
    fixed = TRUE
  )
  expect_match(html, 'class="sb-tabs-list" role="tablist"', fixed = TRUE)
  expect_match(html, 'data-variant="line"', fixed = TRUE)
  expect_match(html, 'aria-orientation="horizontal"', fixed = TRUE)
  expect_false(grepl("data-bs-toggle", html, fixed = TRUE))
  expect_false(grepl("shiny-tab-input", html, fixed = TRUE))
  expect_false(grepl("nav-link", html, fixed = TRUE))
  expect_false(grepl("tab-pane", html, fixed = TRUE))
  expect_match(html, 'class="sb-tabs-trigger"', fixed = TRUE)
  expect_match(html, 'role="tab"', fixed = TRUE)
  expect_match(html, 'data-state="active"', fixed = TRUE)
  expect_match(html, 'data-state="inactive"', fixed = TRUE)
  expect_match(html, 'aria-selected="true"', fixed = TRUE)
  expect_match(html, 'tabindex="-1"', fixed = TRUE)
  expect_match(html, 'class="sb-tabs-content"', fixed = TRUE)
  expect_match(html, 'role="tabpanel"', fixed = TRUE)
  expect_match(html, 'class="sb-tabs-panel"', fixed = TRUE)
  expect_match(html, 'hidden="hidden"', fixed = TRUE)
})

test_that("block_tabs falls back to first tab for invalid selected value", {
  tabs <- block_tabs(
    selected = "missing",
    block_tab("Overview", value = "overview", "Overview body"),
    block_tab("Usage", value = "usage", "Usage body")
  )
  html <- render_html(tabs)

  expect_match(
    html,
    'data-value="overview" data-state="active"',
    fixed = TRUE
  )
  expect_match(
    html,
    'data-value="usage" data-state="inactive"',
    fixed = TRUE
  )
})

test_that("sidebar collapse attrs and toggle render", {
  sidebar <- block_sidebar(
    title = "Navigation",
    block_nav_item("Home"),
    collapsible = TRUE,
    collapsed = TRUE,
    id = "main-sidebar"
  )
  html <- render_html(sidebar)

  expect_identical(tag_attr(sidebar, "data-collapsible"), "true")
  expect_identical(tag_attr(sidebar, "data-collapsed"), "true")
  expect_identical(tag_attr(sidebar, "id"), "main-sidebar")
  expect_match(html, 'class="sb-sidebar-toggle"', fixed = TRUE)
  expect_match(html, 'aria-expanded="false"', fixed = TRUE)
})

test_that("nav items and buttons decorate icons", {
  nav <- render_html(block_nav_item("Home", icon = "home"))
  button_start <- runtime_payload_from(block_button("Search", icon = "search"))
  button_end <- runtime_payload_from(
    block_button("Open", icon = "arrow-right", icon_position = "inline-end")
  )

  expect_match(nav, 'data-icon="inline-start"', fixed = TRUE)
  expect_match(
    nav,
    'href="shinyblocks-[0-9.]+(?:\\.[0-9]+)?/icons/sprite\\.svg#sb-icon-home"'
  )
  expect_identical(button_start$props$iconName, "search")
  expect_identical(button_start$props$iconPosition, "inline-start")
  expect_identical(button_end$props$iconName, "arrow-right")
  expect_identical(button_end$props$iconPosition, "inline-end")
})

test_that("button variants and sizes map to runtime props", {
  destructive <- runtime_payload_from(
    block_button("Delete", variant = "destructive")
  )
  link <- runtime_payload_from(block_button("Open", variant = "link"))
  small <- runtime_payload_from(block_button("Save", size = "sm"))
  icon <- runtime_payload_from(block_button("", size = "icon"))

  expect_identical(destructive$props$variant, "destructive")
  expect_identical(link$props$variant, "link")
  expect_identical(small$props$size, "sm")
  expect_identical(icon$props$size, "icon")
})

test_that("button classes pass through the runtime payload", {
  button <- runtime_payload_from(
    block_button("Save", variant = "outline", size = "lg", class = "custom")
  )

  expect_identical(button$className, "custom")
  expect_identical(button$props$variant, "outline")
  expect_identical(button$props$size, "lg")
})

test_that("button inline style is normalized for runtime rendering", {
  button <- runtime_payload_from(
    block_button(
      "Save",
      style = "color: red; min-width: 10rem; --custom-accent: #f00 !important;"
    )
  )

  expect_identical(button$props$attrs$style$color, "red")
  expect_identical(button$props$attrs$style$minWidth, "10rem")
  expect_identical(button$props$attrs$style$`--custom-accent`, "#f00")
})

test_that("runtime inline style fails hard for malformed input", {
  expect_error(
    block_button("Save", style = "color red"),
    "`style` declarations must use `property: value` syntax.",
    fixed = TRUE
  )
  expect_error(
    block_button("Save", style = c("color: red;", "background: black;")),
    "`style` must be a single CSS declaration string.",
    fixed = TRUE
  )
  expect_error(
    block_button("Save", style = list(color = "red", "10rem")),
    "`style` lists must be fully named.",
    fixed = TRUE
  )
})

test_that("dark mode toggle renders expected button attrs", {
  toggle <- block_dark_mode_toggle(class = "custom")
  html <- render_html(toggle)
  payload <- runtime_payload_from(toggle)

  expect_identical(
    tag_attr(toggle, "class"),
    "sb-runtime-mount"
  )
  expect_match(html, 'data-sb-component="button"', fixed = TRUE)
  expect_identical(payload$className, "sb-dark-mode-toggle custom")
  expect_identical(payload$props$variant, "outline")
  expect_identical(payload$props$size, "sm")
  expect_identical(payload$props$attrs$`data-sb-theme-toggle`, "true")
  expect_identical(payload$props$attrs$`aria-pressed`, "false")
  expect_match(payload$props$labelHtml, "sb-dark-mode-icon-light", fixed = TRUE)
  expect_match(payload$props$labelHtml, "sb-dark-mode-icon-dark", fixed = TRUE)
})
