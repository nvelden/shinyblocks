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
  expect_match(html, '<header class="sb-header">', fixed = TRUE)
  expect_match(html, '<main class="sb-body">', fixed = TRUE)
  expect_match(html, 'data-shinyblocks-portal-root=""', fixed = TRUE)
  expect_match(head, "document.documentElement.dataset.theme", fixed = TRUE)
  expect_match(head, "window.shinyblocksTheme.apply", fixed = TRUE)
  expect_match(head, "data-sb-theme-toggle", fixed = TRUE)
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

test_that("block_tabs preserves Shiny tabset markup and adds sb classes", {
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
    'class="tabbable sb-tabs custom" data-sb-tabs="true"',
    fixed = TRUE
  )
  expect_match(
    html,
    'class="nav shiny-tab-input sb-tabs-list"',
    fixed = TRUE
  )
  expect_match(html, 'data-variant="line"', fixed = TRUE)
  expect_match(html, 'role="tablist"', fixed = TRUE)
  expect_match(html, 'aria-orientation="horizontal"', fixed = TRUE)
  expect_match(html, 'data-bs-toggle="tab"', fixed = TRUE)
  expect_match(html, 'class="nav-link sb-tabs-trigger"', fixed = TRUE)
  expect_match(html, 'role="tab"', fixed = TRUE)
  expect_match(html, 'data-state="active"', fixed = TRUE)
  expect_match(html, 'data-state="inactive"', fixed = TRUE)
  expect_match(html, 'aria-selected="true"', fixed = TRUE)
  expect_match(html, 'tabindex="-1"', fixed = TRUE)
  expect_match(html, 'class="tab-content sb-tabs-content"', fixed = TRUE)
  expect_match(html, 'role="tabpanel"', fixed = TRUE)
  expect_match(html, 'class="tab-pane sb-tabs-panel"', fixed = TRUE)
  expect_match(html, 'hidden="hidden"', fixed = TRUE)
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
    'href="shinyblocks-0.0.0.9000/icons/sprite.svg#sb-icon-home"',
    fixed = TRUE
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

  expect_identical(
    tag_attr(toggle, "class"),
    "sb-button sb-button-outline sb-button-size-sm sb-dark-mode-toggle custom"
  )
  expect_identical(tag_attr(toggle, "data-sb-theme-toggle"), "true")
  expect_match(html, "sb-dark-mode-icon-light", fixed = TRUE)
  expect_match(html, "sb-dark-mode-icon-dark", fixed = TRUE)
})

test_that("field wrappers expose expected classes and child markers", {
  field <- block_field(
    block_field_label("Email", `for` = "email"),
    shiny::textInput("email", NULL),
    block_field_description("We won't share it."),
    class = "custom"
  )
  fieldset <- block_field_set(
    block_field_legend("Notifications"),
    field
  )
  group <- block_field_group(fieldset)

  expect_identical(tag_attr(field, "class"), "sb-field custom")
  expect_identical(tag_attr(field, "data-sb-child"), "field")
  expect_identical(tag_attr(fieldset, "data-sb-child"), "field-set")
  expect_identical(tag_attr(group, "data-sb-child"), "field-group")
})

test_that("textarea wraps Shiny markup and supports placeholder", {
  textarea <- block_textarea(
    "notes",
    value = "hello",
    placeholder = "Write a note",
    rows = 5,
    class = "custom"
  )
  html <- render_html(textarea)

  expect_identical(tag_attr(textarea, "class"), "sb-textarea custom")
  expect_match(html, "sb-textarea-control", fixed = TRUE)
  expect_match(html, 'placeholder="Write a note"', fixed = TRUE)
  expect_match(html, 'rows="5"', fixed = TRUE)
})

test_that("slider wraps Shiny markup and exposes the data-disabled flag", {
  slider <- block_slider(
    "volume",
    value = 50,
    min = 0,
    max = 100,
    class = "custom"
  )
  range <- block_slider("price", value = c(25, 75), min = 0, max = 100)
  disabled <- block_slider(
    "off",
    value = 30,
    min = 0,
    max = 100,
    disabled = TRUE
  )

  expect_identical(tag_attr(slider, "class"), "sb-slider custom")
  expect_null(tag_attr(slider, "data-disabled"))
  expect_identical(tag_attr(disabled, "data-disabled"), "true")

  slider_html <- render_html(slider)
  expect_match(slider_html, "sb-slider-control", fixed = TRUE)
  expect_match(slider_html, 'data-min="0"', fixed = TRUE)
  expect_match(slider_html, 'data-max="100"', fixed = TRUE)
  expect_match(slider_html, 'data-from="50"', fixed = TRUE)

  range_html <- render_html(range)
  expect_match(range_html, 'data-type="double"', fixed = TRUE)
  expect_match(range_html, 'data-from="25"', fixed = TRUE)
  expect_match(range_html, 'data-to="75"', fixed = TRUE)
})

test_that("block_slider validates its arguments", {
  expect_error(
    block_slider("x", value = "fifty", min = 0, max = 100),
    "must be one or two numeric values",
    fixed = TRUE
  )
  expect_error(
    block_slider("x", value = c(1, 2, 3), min = 0, max = 100),
    "must be one or two numeric values",
    fixed = TRUE
  )
  expect_error(
    block_slider("x", value = 50, min = 100, max = 100),
    "strictly less than",
    fixed = TRUE
  )
  expect_error(
    block_slider("x", value = 50),
    "min",
    fixed = TRUE
  )
})

test_that("checkbox and switch preserve Shiny input bindings", {
  checkbox <- block_checkbox(
    "marketing",
    "Email me updates",
    value = TRUE,
    class = "custom"
  )
  switch <- block_switch(
    "alerts",
    "Send incident alerts",
    value = TRUE,
    class = "custom"
  )
  checkbox_html <- render_html(checkbox)
  switch_html <- render_html(switch)

  expect_identical(
    tag_attr(checkbox, "class"),
    "form-group shiny-input-container sb-checkbox custom"
  )
  expect_identical(
    tag_attr(switch, "class"),
    "form-group shiny-input-container sb-switch custom"
  )
  expect_match(
    checkbox_html,
    'class="shiny-input-checkbox sb-checkbox-control"',
    fixed = TRUE
  )
  expect_match(checkbox_html, 'checked="checked"', fixed = TRUE)
  expect_match(checkbox_html, 'class="sb-checkbox-indicator"', fixed = TRUE)
  expect_match(checkbox_html, "Email me updates", fixed = TRUE)
  expect_match(
    switch_html,
    'class="shiny-input-checkbox sb-checkbox-control sb-switch-control"',
    fixed = TRUE
  )
  expect_match(switch_html, 'role="switch"', fixed = TRUE)
  expect_match(switch_html, 'class="sb-switch-track"', fixed = TRUE)
  expect_match(switch_html, "Send incident alerts", fixed = TRUE)
})

test_that("field labels and descriptions expose expected attributes", {
  label <- block_field_label("Email", `for` = "email", class = "custom")
  description <- block_field_description(
    "Helper text",
    id = "email-help",
    class = "custom"
  )
  legend <- block_field_legend("Preferences", class = "custom")

  expect_identical(tag_attr(label, "for"), "email")
  expect_identical(tag_attr(label, "class"), "sb-field-label custom")
  expect_identical(tag_attr(description, "id"), "email-help")
  expect_identical(
    tag_attr(description, "class"),
    "sb-field-description custom"
  )
  expect_identical(tag_attr(legend, "class"), "sb-field-legend custom")
})

test_that("invalid fields decorate controls and append an error message", {
  invalid <- render_html(
    block_field_invalid(
      block_field(
        block_field_label("API key", `for` = "api_key"),
        shiny::textInput("api_key", NULL)
      ),
      "API key is required."
    )
  )

  expect_match(invalid, 'data-invalid="true"', fixed = TRUE)
  expect_match(invalid, 'aria-invalid="true"', fixed = TRUE)
  expect_match(invalid, 'aria-describedby="sb-field-error-', fixed = TRUE)
  expect_match(
    invalid,
    'class="sb-field-description sb-field-error"',
    fixed = TRUE
  )
})

test_that("aria-invalid reaches wrapped control types", {
  textarea <- render_html(
    block_field_invalid(
      block_field(block_textarea("notes")),
      "Textarea invalid."
    )
  )
  select <- render_html(
    block_field_invalid(
      block_field(block_select("plan", choices = c("Free", "Pro"))),
      "Select invalid."
    )
  )
  checkbox <- render_html(
    block_field_invalid(
      block_field(block_checkbox("agree", "Agree")),
      "Checkbox invalid."
    )
  )
  switch <- render_html(
    block_field_invalid(
      block_field(block_switch("alerts", "Alerts")),
      "Switch invalid."
    )
  )

  expect_match(textarea, 'aria-invalid="true"', fixed = TRUE)
  expect_match(select, 'aria-invalid="true"', fixed = TRUE)
  expect_match(checkbox, 'aria-invalid="true"', fixed = TRUE)
  expect_match(switch, 'aria-invalid="true"', fixed = TRUE)
  expect_match(checkbox, 'class="sb-checkbox-indicator"', fixed = TRUE)
  expect_match(switch, 'class="sb-switch-track"', fixed = TRUE)
})

test_that("buttons accept aria-invalid passthrough attrs", {
  button <- runtime_payload_from(block_button("Delete", `aria-invalid` = "true"))

  expect_identical(button$props$attrs[["aria-invalid"]], "true")
})

test_that("input groups merge user classes and render addons", {
  input_group <- block_input_group(
    block_input_group_addon(block_icon("search"), class = "addon-custom"),
    shiny::textInput("query", NULL),
    class = "custom"
  )
  html <- render_html(input_group)

  expect_identical(tag_attr(input_group, "class"), "sb-input-group custom")
  expect_match(html, 'class="sb-input-group-addon addon-custom"', fixed = TRUE)
  expect_match(html, "sb-icon-search", fixed = TRUE)
})

test_that("block_select emits a runtime select payload", {
  select <- block_select(
    "plan",
    choices = c(Free = "free", Pro = "pro"),
    selected = "pro",
    width = "16rem",
    class = "custom",
    size = "lg",
    style = "margin-top: 1rem;",
    invalid = TRUE
  )
  html <- render_html(select)
  payload <- runtime_payload_from(select)

  expect_identical(tag_attr(select, "class"), "sb-runtime-mount custom")
  expect_match(html, 'data-sb-component="select"', fixed = TRUE)
  expect_match(html, '<select id="plan" class="sb-select-native"', fixed = TRUE)
  expect_match(html, 'data-shiny-no-bind-input', fixed = TRUE)
  expect_match(html, '<option value="pro" selected', fixed = TRUE)
  expect_no_match(html, "sb-select-control", fixed = TRUE)
  expect_identical(payload$id, "plan")
  expect_identical(payload$state$value, "pro")
  expect_identical(payload$props$choices[[1]]$value, "free")
  expect_identical(payload$props$choices[[2]]$label, "Pro")
  expect_identical(payload$props$width, "16rem")
  expect_identical(payload$props$style$marginTop, "1rem")
  expect_identical(payload$props$size, "lg")
  expect_identical(payload$props$invalid, TRUE)
  expect_identical(payload$binding$type, "shinyblocks.select")
})

test_that("block_select defaults to first choice unless a placeholder is present", {
  select <- runtime_payload_from(block_select("plan", choices = c("Free", "Pro")))
  placeholder <- runtime_payload_from(
    block_select("plan", choices = c("Free", "Pro"), placeholder = "Choose")
  )

  expect_identical(select$state$value, "Free")
  expect_identical(placeholder$state$value, "")
})

test_that("badge variants map to runtime props", {
  destructive <- runtime_payload_from(
    block_badge("Blocked", variant = "destructive")
  )
  outline <- runtime_payload_from(block_badge("Draft", variant = "outline"))

  expect_identical(destructive$props$variant, "destructive")
  expect_identical(outline$props$variant, "outline")
})

test_that("badge classes pass through the runtime payload", {
  badge <- runtime_payload_from(block_badge("New", class = "custom"))

  expect_identical(badge$className, "custom")
  expect_identical(badge$props$variant, "default")
})

test_that("card flat arguments compose into card regions", {
  card <- render_html(
    block_card(
      title = "Revenue",
      description = "Last 30 days",
      value = "$42k",
      footer = block_button("View report"),
      "Up 12% month over month."
    )
  )

  expect_match(card, 'class="sb-card-header"', fixed = TRUE)
  expect_match(card, 'class="sb-card-title"', fixed = TRUE)
  expect_match(card, 'class="sb-card-description"', fixed = TRUE)
  expect_match(card, 'class="sb-card-content"', fixed = TRUE)
  expect_match(card, 'class="sb-card-footer"', fixed = TRUE)
  expect_match(card, 'class="sb-card-value"', fixed = TRUE)
})

test_that("card composition helpers render expected child markers", {
  header <- block_card_header(
    block_card_title("Revenue"),
    block_card_description("Last 30 days")
  )
  content <- block_card_content("Chart")
  footer <- block_card_footer(block_button("Open"))
  card <- block_card(header, content, footer, class = "custom")

  expect_identical(tag_attr(header, "data-sb-child"), "card-header")
  expect_identical(tag_attr(content, "data-sb-child"), "card-content")
  expect_identical(tag_attr(footer, "data-sb-child"), "card-footer")
  expect_identical(tag_attr(card, "class"), "sb-card custom")
})

test_that("card helper classes merge with user classes", {
  expect_identical(
    tag_attr(block_card_header("Header", class = "custom"), "class"),
    "sb-card-header custom"
  )
  expect_identical(
    tag_attr(block_card_content("Body", class = "custom"), "class"),
    "sb-card-content custom"
  )
  expect_identical(
    tag_attr(block_card_footer("Footer", class = "custom"), "class"),
    "sb-card-footer custom"
  )
})

test_that("alerts render role, variants, and icon markup", {
  alert <- render_html(
    block_alert(
      "Heads up",
      description = "Action needed.",
      variant = "destructive",
      icon = "alert-triangle"
    )
  )

  expect_match(alert, 'role="alert"', fixed = TRUE)
  expect_match(alert, 'class="sb-alert sb-alert-destructive"', fixed = TRUE)
  expect_match(alert, 'class="sb-alert-title"', fixed = TRUE)
  expect_match(alert, 'class="sb-alert-description"', fixed = TRUE)
  expect_match(alert, 'data-icon="inline-start"', fixed = TRUE)
})

test_that("alerts accept composed title and description tags", {
  title <- block_alert_title("Maintenance")
  description <- block_alert_description("Scheduled tonight.")
  alert <- block_alert(title, description = description, icon = NULL)

  expect_identical(tag_attr(title, "data-sb-child"), "alert-title")
  expect_identical(
    tag_attr(description, "data-sb-child"),
    "alert-description"
  )
  expect_identical(
    tag_attr(alert, "class"),
    "sb-alert sb-alert-default"
  )
})

test_that("value boxes render expected regions", {
  box <- render_html(
    block_value_box(
      "Revenue",
      "$42k",
      description = "Up 12% month over month.",
      icon = "trending-up"
    )
  )

  expect_match(box, 'class="sb-value-box"', fixed = TRUE)
  expect_match(box, 'class="sb-value-box-title"', fixed = TRUE)
  expect_match(box, 'class="sb-value-box-value"', fixed = TRUE)
  expect_match(box, 'class="sb-value-box-description"', fixed = TRUE)
  expect_match(box, 'data-icon="inline-start"', fixed = TRUE)
})

test_that("value boxes merge user classes", {
  classes <- tag_attr(
    block_value_box("Revenue", "$42k", class = "custom"),
    "class"
  )

  expect_identical(classes, "sb-value-box custom")
})

test_that("separators expose orientation and aria correctly", {
  vertical <- block_separator(orientation = "vertical", decorative = FALSE)
  decorative <- block_separator()

  expect_identical(
    tag_attr(vertical, "class"),
    "sb-separator sb-separator-vertical"
  )
  expect_identical(tag_attr(vertical, "role"), "separator")
  expect_identical(tag_attr(vertical, "aria-orientation"), "vertical")
  expect_identical(tag_attr(decorative, "aria-hidden"), "true")
})

test_that("skeletons and spinners expose expected attributes", {
  skeleton <- block_skeleton(class = "custom")
  spinner <- block_spinner(label = "Loading table", class = "custom")

  expect_identical(tag_attr(skeleton, "class"), "sb-skeleton custom")
  expect_identical(tag_attr(skeleton, "aria-hidden"), "true")
  expect_identical(tag_attr(spinner, "class"), "sb-spinner custom")
  expect_identical(tag_attr(spinner, "role"), "status")
  expect_identical(tag_attr(spinner, "aria-label"), "Loading table")
})

test_that("empty states render icon, description, and action", {
  empty <- render_html(
    block_empty(
      "No results",
      description = "Try broadening your search.",
      icon = "folder",
      action = block_button("Clear filters")
    )
  )

  expect_match(empty, 'class="sb-empty"', fixed = TRUE)
  expect_match(empty, 'class="sb-empty-title"', fixed = TRUE)
  expect_match(empty, 'class="sb-empty-description"', fixed = TRUE)
  expect_match(empty, 'class="sb-empty-action"', fixed = TRUE)
  expect_match(empty, 'data-icon="inline-start"', fixed = TRUE)
})
