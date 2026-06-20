test_that("field wrappers expose expected classes and child markers", {
  field <- block_field(
    block_field_label("Email", `for` = "email"),
    block_input("email"),
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

test_that("block_radio_group emits a runtime payload with choice records", {
  rg <- block_radio_group(
    "channel",
    choices = c(All = "all", Mentions = "mentions", None = "none"),
    selected = "mentions",
    orientation = "horizontal",
    invalid = TRUE,
    class = "custom"
  )
  html <- render_html(rg)
  payload <- runtime_payload_from(rg)

  expect_identical(
    tag_attr(rg, "class"),
    "sb-runtime-mount sb-radio-group"
  )
  expect_identical(payload$className, "custom")
  expect_match(html, 'data-sb-component="radio-group"', fixed = TRUE)
  expect_match(
    html,
    '<input id="channel" type="hidden" class="sb-radio-group-native"',
    fixed = TRUE
  )
  expect_identical(payload$id, "channel")
  expect_identical(payload$state$value, "mentions")
  expect_identical(payload$props$orientation, "horizontal")
  expect_identical(payload$props$invalid, TRUE)
  expect_identical(length(payload$props$choices), 3L)
  expect_identical(payload$props$choices[[1]]$value, "all")
  expect_identical(payload$props$choices[[1]]$label, "All")
  expect_identical(payload$binding$type, "shinyblocks.radio-group")
})

test_that("block_radio_group rejects an unknown selected value", {
  expect_error(
    block_radio_group("c", choices = c(A = "a", B = "b"), selected = "z"),
    "must match one of"
  )
})

test_that("block_input emits a runtime payload and hidden native input", {
  input <- block_input(
    "email",
    value = "n@example.com",
    placeholder = "you@example.com",
    type = "email",
    invalid = TRUE,
    style = "color: red;",
    class = "custom"
  )
  html <- render_html(input)
  payload <- runtime_payload_from(input)

  expect_identical(
    tag_attr(input, "class"),
    "sb-runtime-mount sb-input"
  )
  expect_identical(payload$className, "custom")
  expect_match(html, 'data-sb-component="input"', fixed = TRUE)
  expect_match(
    html,
    '<input id="email" type="email" class="sb-input-native"',
    fixed = TRUE
  )
  expect_match(html, "data-shiny-no-bind-input", fixed = TRUE)
  expect_identical(payload$id, "email")
  expect_identical(payload$state$value, "n@example.com")
  expect_identical(payload$props$placeholder, "you@example.com")
  expect_identical(payload$props$type, "email")
  expect_identical(payload$props$invalid, TRUE)
  expect_identical(payload$props$style$color, "red")
  expect_identical(payload$binding$type, "shinyblocks.input")
})

test_that("block_file_input emits bindable native file input markup", {
  file_input <- block_file_input(
    "upload",
    multiple = TRUE,
    accept = c(".csv", "text/csv"),
    button_label = "Choose",
    placeholder = "No CSV selected",
    invalid = TRUE,
    style = "min-height: 3rem;",
    class = "custom"
  )
  html <- render_html(file_input)
  payload <- runtime_payload_from(file_input)

  expect_identical(
    tag_attr(file_input, "class"),
    "sb-runtime-mount sb-file-input"
  )
  expect_identical(payload$component, "file-input")
  expect_null(payload$id)
  expect_identical(payload$className, "custom")
  expect_match(html, 'data-sb-component="file-input"', fixed = TRUE)
  # Deterministic mount id lets update_block_file_input() route messages here.
  expect_match(html, 'id="sb-runtime-file-input-upload"', fixed = TRUE)
  expect_match(
    html,
    '<input id="upload" type="file" class="shiny-input-file sb-file-input-native"',
    fixed = TRUE
  )
  # Native input is kept out of the tab order; the button is the sole tab stop.
  expect_match(html, 'tabindex="-1"', fixed = TRUE)
  expect_match(html, 'multiple accept=".csv,text/csv"', fixed = TRUE)
  expect_match(html, 'id="upload_progress"', fixed = TRUE)
  expect_match(html, "progress active shiny-file-input-progress", fixed = TRUE)
  expect_no_match(html, "data-shiny-no-bind-input", fixed = TRUE)
  expect_identical(payload$props$buttonLabel, "Choose")
  expect_identical(payload$props$placeholder, "No CSV selected")
  expect_identical(payload$props$multiple, TRUE)
  expect_identical(payload$props$accept, ".csv,text/csv")
  expect_identical(payload$props$invalid, TRUE)
  expect_identical(payload$props$style$minHeight, "3rem")
})

test_that("block_file_input defaults to the button variant", {
  payload <- runtime_payload_from(block_file_input("upload"))
  expect_identical(payload$props$variant, "button")
})

test_that("block_file_input dropzone variant emits dropzone props", {
  file_input <- block_file_input(
    "upload",
    variant = "dropzone",
    dropzone_label = "Drop here",
    dropzone_hint = "CSV only"
  )
  payload <- runtime_payload_from(file_input)
  expect_identical(payload$props$variant, "dropzone")
  expect_identical(payload$props$dropzoneLabel, "Drop here")
  expect_identical(payload$props$dropzoneHint, "CSV only")
})

test_that("block_file_input emits dropzone icon name and sprite href", {
  payload <- runtime_payload_from(
    block_file_input("upload", variant = "dropzone", dropzone_icon = "upload")
  )
  expect_identical(payload$props$dropzoneIconName, "upload")
  expect_null(payload$props$dropzoneIconHtml)
  expect_true(nzchar(payload$props$spriteHref))
})

test_that("block_file_input serializes a tag dropzone_icon to html", {
  payload <- runtime_payload_from(
    block_file_input(
      "upload",
      variant = "dropzone",
      dropzone_icon = htmltools::tags$svg(class = "x")
    )
  )
  expect_null(payload$props$dropzoneIconName)
  expect_match(payload$props$dropzoneIconHtml, "<svg", fixed = TRUE)
})

test_that("block_file_input serializes dropzone_content to html", {
  payload <- runtime_payload_from(
    block_file_input(
      "upload",
      variant = "dropzone",
      dropzone_content = htmltools::tagList(
        htmltools::tags$strong("Upload"),
        htmltools::tags$button(`data-dropzone-trigger` = NA, "Pick")
      )
    )
  )
  expect_match(payload$props$dropzoneContentHtml, "<strong>Upload</strong>", fixed = TRUE)
  expect_match(payload$props$dropzoneContentHtml, "data-dropzone-trigger", fixed = TRUE)
})

test_that("block_file_input has no dropzone icon/content by default", {
  payload <- runtime_payload_from(block_file_input("upload", variant = "dropzone"))
  expect_null(payload$props$dropzoneIconName)
  expect_null(payload$props$dropzoneIconHtml)
  expect_null(payload$props$dropzoneContentHtml)
})

test_that("block_file_input validates input id, accept, variant, and icon name", {
  expect_error(block_file_input(""), "`input_id` must be a non-empty string")
  expect_error(block_file_input("upload", accept = 1), "`accept` must be NULL or a character vector")
  expect_error(block_file_input("upload", variant = "tile"), "`variant` must be one of")
  expect_error(
    block_file_input("upload", variant = "dropzone", dropzone_icon = "not-a-real-icon-xyz")
  )
})

test_that("textarea emits a runtime payload and hidden native textarea", {
  textarea <- block_textarea(
    "notes",
    value = "hello",
    placeholder = "Write a note",
    rows = 5,
    invalid = TRUE,
    resize = "none",
    style = "color: red;",
    class = "custom"
  )
  html <- render_html(textarea)
  payload <- runtime_payload_from(textarea)

  expect_identical(
    tag_attr(textarea, "class"),
    "sb-runtime-mount sb-textarea"
  )
  expect_identical(payload$className, "custom")
  expect_match(html, 'data-sb-component="textarea"', fixed = TRUE)
  expect_match(
    html,
    '<textarea id="notes" class="sb-textarea-native"',
    fixed = TRUE
  )
  expect_match(html, "data-shiny-no-bind-input", fixed = TRUE)
  expect_identical(payload$id, "notes")
  expect_identical(payload$state$value, "hello")
  expect_identical(payload$props$placeholder, "Write a note")
  expect_identical(payload$props$rows, 5L)
  expect_identical(payload$props$invalid, TRUE)
  expect_identical(payload$props$resize, "none")
  expect_identical(payload$props$style$color, "red")
  expect_identical(payload$binding$type, "shinyblocks.textarea")
})

test_that("slider emits runtime payload and binding metadata", {
  slider <- block_slider(
    "volume",
    value = 50,
    min = 0,
    max = 100,
    step = 5,
    orientation = "vertical",
    show_value = TRUE,
    min_label = "Quiet",
    max_label = "Loud",
    invalid = TRUE,
    style = "max-width: 20rem;",
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

  payload <- runtime_payload_from(slider)
  range_payload <- runtime_payload_from(range)

  slider_html <- render_html(slider)
  expect_identical(
    tag_attr(slider, "class"),
    "sb-runtime-mount sb-slider-root"
  )
  expect_identical(payload$className, "custom")
  expect_match(slider_html, 'data-sb-component="slider"', fixed = TRUE)
  expect_match(slider_html, '<input id="volume" type="hidden" class="sb-slider-native"', fixed = TRUE)
  expect_match(slider_html, "data-shiny-no-bind-input", fixed = TRUE)
  expect_match(render_html(disabled), 'data-sb-component="slider"', fixed = TRUE)

  expect_identical(payload$component, "slider")
  expect_identical(payload$id, "volume")
  expect_equal(payload$state$value, 50)
  expect_equal(payload$props$min, 0)
  expect_equal(payload$props$max, 100)
  expect_equal(payload$props$step, 5)
  expect_identical(payload$props$orientation, "vertical")
  expect_identical(payload$props$showValue, TRUE)
  expect_identical(payload$props$minLabel, "Quiet")
  expect_identical(payload$props$maxLabel, "Loud")
  expect_identical(payload$props$invalid, TRUE)
  expect_identical(payload$props$style$maxWidth, "20rem")
  expect_identical(payload$binding$type, "shinyblocks.slider")
  expect_equal(unlist(range_payload$state$value), c(25, 75))
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
    block_slider("x", value = 50, min = 0, max = 100, step = 0),
    "positive numeric",
    fixed = TRUE
  )
  expect_error(
    block_slider("x", value = 50, min = 0, max = 100, orientation = "diagonal"),
    "must be one of",
    fixed = TRUE
  )
  expect_error(
    block_slider("x", value = 50),
    "min",
    fixed = TRUE
  )
})

test_that("checkbox and switch emit runtime payloads", {
  checkbox <- block_checkbox(
    "marketing",
    "Email me updates",
    value = TRUE,
    style = "padding: 0.5rem;",
    class = "custom"
  )
  switch <- block_switch(
    "alerts",
    "Send incident alerts",
    value = TRUE,
    size = "lg",
    class = "custom"
  )
  checkbox_html <- render_html(checkbox)
  switch_html <- render_html(switch)
  checkbox_payload <- runtime_payload_from(checkbox)
  switch_payload <- runtime_payload_from(switch)

  expect_identical(
    tag_attr(checkbox, "class"),
    "sb-runtime-mount sb-checkbox"
  )
  expect_match(checkbox_html, 'data-sb-component="checkbox"', fixed = TRUE)
  expect_match(
    checkbox_html,
    '<input id="marketing" type="checkbox" class="sb-checkbox-native"',
    fixed = TRUE
  )
  expect_match(checkbox_html, "data-shiny-no-bind-input", fixed = TRUE)
  expect_match(checkbox_html, "Email me updates", fixed = TRUE)
  expect_identical(checkbox_payload$id, "marketing")
  expect_identical(checkbox_payload$state$value, TRUE)
  expect_identical(checkbox_payload$props$labelHtml, "Email me updates")
  expect_identical(checkbox_payload$props$style$padding, "0.5rem")
  expect_identical(checkbox_payload$className, "custom")
  expect_identical(checkbox_payload$binding$type, "shinyblocks.checkbox")

  expect_identical(
    tag_attr(switch, "class"),
    "sb-runtime-mount sb-switch"
  )
  expect_match(switch_html, 'data-sb-component="switch"', fixed = TRUE)
  expect_match(
    switch_html,
    '<input id="alerts" type="checkbox" class="sb-switch-native"',
    fixed = TRUE
  )
  expect_match(switch_html, "data-shiny-no-bind-input", fixed = TRUE)
  expect_match(switch_html, "Send incident alerts", fixed = TRUE)
  expect_identical(switch_payload$id, "alerts")
  expect_identical(switch_payload$state$value, TRUE)
  expect_identical(switch_payload$props$labelHtml, "Send incident alerts")
  expect_identical(switch_payload$props$size, "lg")
  expect_identical(switch_payload$className, "custom")
  expect_identical(switch_payload$binding$type, "shinyblocks.switch")
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
        block_input("api_key")
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
  expect_match(checkbox, 'data-sb-component="checkbox"', fixed = TRUE)
  expect_match(checkbox, 'class="sb-checkbox-native"', fixed = TRUE)
  expect_match(switch, 'data-sb-component="switch"', fixed = TRUE)
  expect_match(switch, 'class="sb-switch-native"', fixed = TRUE)
})

test_that("buttons accept aria-invalid passthrough attrs", {
  button <- runtime_payload_from(block_button("Delete", `aria-invalid` = "true"))

  expect_identical(button$props$attrs[["aria-invalid"]], "true")
})

test_that("input groups merge user classes and render addons", {
  input_group <- block_input_group(
    block_input_group_addon(block_icon("search"), class = "addon-custom"),
    block_input("query", placeholder = "Search"),
    class = "custom"
  )
  html <- render_html(input_group)

  expect_identical(tag_attr(input_group, "class"), "sb-input-group custom")
  expect_match(html, 'class="sb-input-group-addon addon-custom"', fixed = TRUE)
  expect_match(html, "sb-icon-search", fixed = TRUE)
  expect_match(html, '"component":"input"', fixed = TRUE)
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

  expect_identical(tag_attr(select, "class"), "sb-runtime-mount")
  expect_match(html, 'data-sb-component="select"', fixed = TRUE)
  expect_match(html, '<select id="plan" class="sb-select-native"', fixed = TRUE)
  expect_match(html, "data-shiny-no-bind-input", fixed = TRUE)
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

test_that("block_select emits a multiple runtime select payload", {
  select <- block_select(
    "plan",
    choices = c(Free = "free", Pro = "pro", Team = "team"),
    selected = c("free", "team"),
    placeholder = "Choose plans",
    multiple = TRUE,
    max_items = 2
  )
  html <- render_html(select)
  payload <- runtime_payload_from(select)

  expect_match(html, '<select id="plan" class="sb-select-native"', fixed = TRUE)
  expect_match(html, " multiple", fixed = TRUE)
  expect_match(html, '<option value="free" selected', fixed = TRUE)
  expect_match(html, '<option value="team" selected', fixed = TRUE)
  expect_no_match(html, '<option value="">Choose plans</option>', fixed = TRUE)
  expect_identical(payload$component, "select")
  expect_identical(payload$state$value, list("free", "team"))
  expect_identical(payload$props$multiple, TRUE)
  expect_identical(payload$props$maxItems, 2L)
  expect_identical(payload$binding$type, "shinyblocks.select")
})

test_that("block_select multiple defaults to no selection", {
  select <- runtime_payload_from(
    block_select("plan", choices = c("Free", "Pro"), multiple = TRUE)
  )

  expect_identical(select$state$value, list())
})

test_that("block_select multiple keeps a single selection as an array", {
  select <- runtime_payload_from(
    block_select(
      "plan",
      choices = c(Free = "free", Pro = "pro"),
      selected = "free",
      multiple = TRUE
    )
  )

  expect_identical(select$state$value, list("free"))
})

test_that("block_select multiple rejects an initial selection over max_items", {
  expect_error(
    block_select(
      "plan",
      choices = c(Free = "free", Pro = "pro", Team = "team"),
      selected = c("free", "pro", "team"),
      multiple = TRUE,
      max_items = 2
    ),
    "max_items"
  )
})

test_that("block_select multiple accepts a selection at the max_items cap", {
  select <- runtime_payload_from(
    block_select(
      "plan",
      choices = c(Free = "free", Pro = "pro", Team = "team"),
      selected = c("free", "pro"),
      multiple = TRUE,
      max_items = 2
    )
  )

  expect_identical(select$state$value, list("free", "pro"))
})
