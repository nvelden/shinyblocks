#' Create a styled textarea input
#'
#' @param input_id Input id.
#' @param value Initial value.
#' @param placeholder Optional placeholder text.
#' @param rows Number of visible rows.
#' @param width Optional CSS width value (applied to the wrapper).
#' @param disabled Whether the control is disabled.
#' @param invalid Whether the control should show invalid styling
#'   (sets `aria-invalid="true"`).
#' @param resize Textarea resize behavior. One of `"vertical"`,
#'   `"none"`, `"both"`, or `"horizontal"`.
#' @param style Inline CSS styles for the textarea element.
#' @param class Additional classes for the wrapper.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_textarea <- function(
  input_id,
  value = "",
  placeholder = NULL,
  rows = 3,
  width = NULL,
  disabled = FALSE,
  invalid = FALSE,
  resize = c("vertical", "none", "both", "horizontal"),
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  resize <- match_arg(resize, c("vertical", "none", "both", "horizontal"))
  check_number(rows, "rows", min = 1, msg = "`rows` must be a positive number.")

  hidden_native <- hidden_native_textarea(
    input_id,
    class = "sb-textarea-native",
    value = if (is.null(value)) "" else as.character(value)
  )

  wrapper_style <- normalize_width_style(width)

  runtime_component(
    component = "textarea",
    props = list(
      placeholder = placeholder,
      rows = as.integer(rows),
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      resize = resize,
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = if (is.null(value)) "" else as.character(value)),
    binding = list(input = TRUE, type = "shinyblocks.textarea"),
    class = class,
    style = wrapper_style,
    root_class = "sb-textarea",
    children = list(hidden_native)
  )
}

#' Update a runtime textarea input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_textarea()`.
#' @param value Optional replacement value.
#' @param placeholder Optional replacement placeholder text.
#' @param rows Optional number of visible rows.
#' @param disabled Optional disabled state.
#' @param invalid Optional invalid flag.
#' @param resize Optional textarea resize behavior. One of `"vertical"`,
#'   `"none"`, `"both"`, or `"horizontal"`.
#' @param style Optional replacement inline CSS styles for the textarea.
#' @param class Optional replacement classes for the wrapper.
#' @param notify Whether Shiny should receive an input event when `value`
#'   changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_textarea <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  value,
  placeholder,
  rows,
  disabled,
  invalid,
  resize,
  style,
  class,
  notify = TRUE
) {
  payload <- apply_update_fields(list(), list(
    field("value", transform = as_text_value),
    field_clearable("placeholder"),
    field("disabled", transform = isTRUE),
    field("invalid", transform = isTRUE),
    field_style("style"),
    field_clearable("class")
  ))

  if (!missing(rows)) {
    check_number(rows, "rows", min = 1, msg = "`rows` must be a positive number.")
    payload$rows <- as.integer(rows)
  }
  if (!missing(resize)) {
    payload$resize <- match_arg(resize, c("vertical", "none", "both", "horizontal"))
  }

  runtime_input_update(session, input_id, "textarea", payload, notify = notify)
}

#' Create a styled single-line text input
#'
#' @param input_id Input id.
#' @param value Initial value.
#' @param placeholder Optional placeholder text.
#' @param type Input type. One of `"text"`, `"password"`, `"email"`,
#'   `"url"`, `"tel"`, `"search"`, or `"number"`. Defaults to `"text"`.
#' @param width Optional CSS width value (applied to the wrapper).
#' @param disabled Whether the control is disabled.
#' @param invalid Whether the control should show invalid styling
#'   (sets `aria-invalid="true"`).
#' @param style Inline CSS styles for the input element.
#' @param class Additional classes for the wrapper.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_input <- function(
  input_id,
  value = "",
  placeholder = NULL,
  type = c("text", "password", "email", "url", "tel", "search", "number"),
  width = NULL,
  disabled = FALSE,
  invalid = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  type <- match.arg(type)

  hidden_native <- hidden_native_input(
    input_id,
    type = type,
    class = "sb-input-native",
    value = if (is.null(value)) "" else as.character(value)
  )

  wrapper_style <- normalize_width_style(width)

  runtime_component(
    component = "input",
    props = list(
      placeholder = placeholder,
      type = type,
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = if (is.null(value)) "" else as.character(value)),
    binding = list(input = TRUE, type = "shinyblocks.input"),
    class = class,
    style = wrapper_style,
    root_class = "sb-input",
    children = list(hidden_native)
  )
}

# Resolve a `dropzone_icon` argument (icon name string or htmltools tag) into a
# `list(name=, html=)` payload pair, mirroring the icon handling in block_button().
resolve_dropzone_icon <- function(icon) {
  if (is.null(icon)) {
    return(list(name = NULL, html = NULL))
  }
  if (inherits(icon, "shiny.tag")) {
    return(list(name = NULL, html = html_fragment(icon)))
  }
  validate_icon_name(icon)
  list(name = as.character(icon), html = NULL)
}

#' Create a styled file input
#'
#' Runtime-rendered file picker that delegates upload transport and progress to
#' Shiny's native file upload binding. The server receives the same
#' `input$<id>` data frame as `shiny::fileInput()`.
#'
#' @param input_id Input id.
#' @param variant Picker variant. One of `"button"` (a styled trigger button
#'   with filename text) or `"dropzone"` (a focusable drag-and-drop surface).
#'   The dropzone is cosmetic chrome over the same native Shiny upload binding;
#'   `input$<id>` is identical for both variants.
#' @param multiple Whether to allow selecting more than one file.
#' @param accept Optional character vector of accepted MIME types or file
#'   extensions. Values are comma-joined for the native `accept` attribute.
#' @param button_label Text shown on the picker button.
#' @param placeholder Text shown before a file is selected.
#' @param dropzone_label Primary text shown inside the dropzone surface (only
#'   used when `variant = "dropzone"`).
#' @param dropzone_hint Secondary hint text shown beneath `dropzone_label`
#'   (only used when `variant = "dropzone"`).
#' @param dropzone_icon Optional icon shown above the dropzone label (only used
#'   when `variant = "dropzone"`). Either a shinyblocks icon name (string, e.g.
#'   `"upload"`) or an `htmltools` tag (e.g. an `<svg>`). Rendered inside a
#'   muted circle.
#' @param dropzone_content Optional `htmltools` tag or `tagList` rendered as the
#'   full dropzone interior, replacing the default icon/label/hint stack (only
#'   used when `variant = "dropzone"`). Use plain `htmltools` markup (text,
#'   `img`, a styled `<button>`); nested `block_*()` runtime components are not
#'   hydrated inside this slot. When supplied, the surface becomes a pure drop
#'   region: mark the element that should open the file picker with
#'   `` `data-dropzone-trigger` = NA `` (a real `<button>`/`<a>` for keyboard
#'   support). Give it `class = "sb-file-dropzone-trigger"` for the default
#'   button styling.
#' @param width Optional CSS width value (applied to the wrapper).
#' @param disabled Whether the control is disabled.
#' @param invalid Whether the control should show invalid styling
#'   (sets `aria-invalid="true"`).
#' @param style Inline CSS styles for the visible control.
#' @param class Additional classes for the visible control.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_file_input <- function(
  input_id,
  variant = c("button", "dropzone"),
  multiple = FALSE,
  accept = NULL,
  button_label = "Browse",
  placeholder = "No file selected",
  dropzone_label = "Drag files here or click to browse",
  dropzone_hint = NULL,
  dropzone_icon = NULL,
  dropzone_content = NULL,
  width = NULL,
  disabled = FALSE,
  invalid = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  variant <- match_arg(variant, c("button", "dropzone"))
  check_character(
    accept, "accept", null_ok = TRUE,
    msg = "`accept` must be NULL or a character vector."
  )
  dropzone_icon <- resolve_dropzone_icon(dropzone_icon)
  dropzone_content_html <- if (is.null(dropzone_content)) {
    NULL
  } else {
    html_fragment(dropzone_content)
  }

  accept_value <- if (is.null(accept)) {
    NULL
  } else {
    paste(accept[nzchar(accept)], collapse = ",")
  }
  if (!is.null(accept_value) && !nzchar(accept_value)) accept_value <- NULL

  wrapper_style <- normalize_width_style(width)
  native_input <- native_file_input(
    input_id,
    multiple = isTRUE(multiple),
    accept = accept_value,
    disabled = isTRUE(disabled)
  )

  runtime_component(
    component = "file-input",
    props = list(
      variant = variant,
      buttonLabel = as.character(button_label %||% ""),
      placeholder = as.character(placeholder %||% ""),
      dropzoneLabel = if (is.null(dropzone_label)) NULL else as.character(dropzone_label),
      dropzoneHint = if (is.null(dropzone_hint)) NULL else as.character(dropzone_hint),
      dropzoneIconName = dropzone_icon$name,
      dropzoneIconHtml = dropzone_icon$html,
      dropzoneContentHtml = dropzone_content_html,
      spriteHref = sprite_href(),
      multiple = isTRUE(multiple),
      accept = accept_value,
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      style = normalize_runtime_style(style)
    ),
    # The file value belongs to Shiny's native file binding (`input$<id>`), so
    # the mount itself reports no value (`input_id = NULL`). A deterministic
    # `mount_id` keyed off `input_id` still lets `update_block_file_input()`
    # route `sendInputMessage()` to this mount's receive-only runtime binding.
    input_id = NULL,
    mount_id = runtime_mount_id("file-input", input_id),
    class = class,
    style = wrapper_style,
    root_class = "sb-file-input",
    children = list(native_input)
  )
}

#' Update a runtime file input
#'
#' Updates the cosmetic and stateful props of a [block_file_input()]. The file
#' value itself is owned by Shiny's native file binding and, as with
#' [shiny::fileInput()], cannot be set from the server; use `reset = TRUE` to
#' clear the current selection client-side.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_file_input()`.
#' @param variant Optional replacement variant. One of `"button"` or
#'   `"dropzone"`.
#' @param button_label Optional replacement button text.
#' @param placeholder Optional replacement placeholder text.
#' @param dropzone_label Optional replacement dropzone label. Use `NULL` to
#'   clear.
#' @param dropzone_hint Optional replacement dropzone hint. Use `NULL` to
#'   clear.
#' @param dropzone_icon Optional replacement dropzone icon (name string or
#'   `htmltools` tag). Use `NULL` to clear.
#' @param dropzone_content Optional replacement dropzone interior
#'   (`htmltools` tag/`tagList`). Use `NULL` to clear and restore the default
#'   icon/label/hint stack.
#' @param accept Optional replacement accepted types. Use `NULL` to clear.
#' @param multiple Optional flag for allowing multiple files.
#' @param disabled Optional disabled state.
#' @param invalid Optional invalid flag.
#' @param style Optional replacement inline CSS styles for the visible control.
#' @param class Optional replacement classes for the visible control.
#' @param reset Whether to clear the current file selection.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_file_input <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  variant,
  button_label,
  placeholder,
  dropzone_label,
  dropzone_hint,
  dropzone_icon,
  dropzone_content,
  accept,
  multiple,
  disabled,
  invalid,
  style,
  class,
  reset = FALSE
) {
  payload <- apply_update_fields(list(), list(
    field_clearable("buttonLabel", "button_label", as.character),
    field_clearable("placeholder", transform = as.character),
    field_clearable("dropzoneLabel", "dropzone_label", as.character),
    field_clearable("dropzoneHint", "dropzone_hint", as.character),
    field("multiple", transform = isTRUE),
    field("disabled", transform = isTRUE),
    field("invalid", transform = isTRUE),
    field_style("style"),
    field_clearable("className", "class")
  ))

  if (!missing(variant)) {
    payload$variant <- match_arg(variant, c("button", "dropzone"))
  }
  if (!missing(dropzone_icon)) {
    icon_parts <- resolve_dropzone_icon(dropzone_icon)
    payload <- payload_set_clearable(payload, "dropzoneIconName", icon_parts$name)
    payload <- payload_set_clearable(payload, "dropzoneIconHtml", icon_parts$html)
    if (!is.null(icon_parts$name)) payload$spriteHref <- sprite_href()
  }
  if (!missing(dropzone_content)) {
    content_html <- if (is.null(dropzone_content)) {
      NULL
    } else {
      html_fragment(dropzone_content)
    }
    payload <- payload_set_clearable(payload, "dropzoneContentHtml", content_html)
  }
  if (!missing(accept)) {
    check_character(
      accept, "accept", null_ok = TRUE,
      msg = "`accept` must be NULL or a character vector."
    )
    accept_value <- if (is.null(accept)) {
      NULL
    } else {
      paste(accept[nzchar(accept)], collapse = ",")
    }
    if (!is.null(accept_value) && !nzchar(accept_value)) accept_value <- NULL
    payload <- payload_set_clearable(payload, "accept", accept_value)
  }
  if (isTRUE(reset)) {
    payload$reset <- TRUE
  }

  runtime_input_update(session, input_id, "file-input", payload, notify_key = NULL)
}

#' Update a runtime text input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_input()`.
#' @param value Optional replacement value.
#' @param placeholder Optional replacement placeholder text.
#' @param type Optional input type.
#' @param disabled Optional disabled state.
#' @param invalid Optional invalid flag.
#' @param style Optional replacement inline CSS styles for the input.
#' @param class Optional replacement classes for the wrapper.
#' @param notify Whether Shiny should receive an input event when `value`
#'   changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_input <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  value,
  placeholder,
  type,
  disabled,
  invalid,
  style,
  class,
  notify = TRUE
) {
  payload <- apply_update_fields(list(), list(
    field("value", transform = as_text_value),
    field_clearable("placeholder"),
    field("disabled", transform = isTRUE),
    field("invalid", transform = isTRUE),
    field_style("style"),
    field_clearable("class")
  ))

  if (!missing(type)) {
    payload$type <- match.arg(type, c("text", "password", "email", "url", "tel", "search", "number"))
  }

  runtime_input_update(session, input_id, "input", payload, notify = notify)
}

#' Create a styled checkbox input
#'
#' @param input_id Input id.
#' @param label Checkbox label.
#' @param value Whether the checkbox starts checked.
#' @param disabled Whether the control is disabled.
#' @param style Inline CSS styles.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_checkbox <- function(
  input_id,
  label,
  value = FALSE,
  disabled = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)

  hidden_native <- hidden_native_input(
    input_id,
    type = "checkbox",
    class = "sb-checkbox-native",
    checked = isTRUE(value),
    disabled = isTRUE(disabled),
    style = NULL
  )

  runtime_component(
    component = "checkbox",
    props = list(
      labelHtml = html_fragment(label),
      disabled = isTRUE(disabled),
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = isTRUE(value)),
    binding = list(input = TRUE, type = "shinyblocks.checkbox"),
    class = class,
    root_class = "sb-checkbox",
    children = list(hidden_native)
  )
}

#' Update a runtime checkbox input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_checkbox()`.
#' @param checked Optional checked state.
#' @param disabled Optional disabled state.
#' @param style Optional replacement inline CSS styles.
#' @param class Optional replacement classes.
#' @param notify Whether Shiny should receive an input event when `checked`
#'   is updated. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_checkbox <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  checked,
  disabled,
  style,
  class,
  notify = TRUE
) {
  payload <- apply_update_fields(list(), list(
    field("checked", transform = isTRUE),
    field("disabled", transform = isTRUE),
    field_style("style"),
    field_clearable("class")
  ))

  runtime_input_update(
    session, input_id, "checkbox", payload,
    notify_key = "checked", notify = notify
  )
}

#' Create a styled switch input
#'
#' @param input_id Input id.
#' @param label Switch label.
#' @param value Whether the switch starts on.
#' @param disabled Whether the control is disabled.
#' @param size Switch size. One of `"default"`, `"sm"`, or `"lg"`.
#' @param style Inline CSS styles.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_switch <- function(
  input_id,
  label,
  value = FALSE,
  disabled = FALSE,
  size = c("default", "sm", "lg"),
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  size <- match_arg(size, c("default", "sm", "lg"))

  hidden_native <- hidden_native_input(
    input_id,
    type = "checkbox",
    class = "sb-switch-native",
    checked = isTRUE(value),
    disabled = isTRUE(disabled),
    style = NULL
  )

  runtime_component(
    component = "switch",
    props = list(
      labelHtml = html_fragment(label),
      disabled = isTRUE(disabled),
      size = size,
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = isTRUE(value)),
    binding = list(input = TRUE, type = "shinyblocks.switch"),
    class = class,
    root_class = "sb-switch",
    children = list(hidden_native)
  )
}

#' Update a runtime switch input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_switch()`.
#' @param checked Optional checked state.
#' @param disabled Optional disabled state.
#' @param size Optional replacement size. One of `"default"`, `"sm"`, or `"lg"`.
#' @param style Optional replacement inline CSS styles.
#' @param class Optional replacement classes.
#' @param notify Whether Shiny should receive an input event when `checked`
#'   is updated. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_switch <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  checked,
  disabled,
  size,
  style,
  class,
  notify = TRUE
) {
  payload <- apply_update_fields(list(), list(
    field("checked", transform = isTRUE),
    field("disabled", transform = isTRUE),
    field_style("style"),
    field_clearable("class")
  ))

  if (!missing(size)) {
    payload$size <- match_arg(size, c("default", "sm", "lg"))
  }

  runtime_input_update(
    session, input_id, "switch", payload,
    notify_key = "checked", notify = notify
  )
}

#' Create a styled slider input
#'
#' Runtime-rendered slider with a dedicated Shiny input binding. Supports
#' single-value and two-value range sliders.
#'
#' @param input_id Input id.
#' @param value Initial value. Length 1 for a single-handle slider;
#'   length 2 for a range slider.
#' @param min Numeric lower bound.
#' @param max Numeric upper bound.
#' @param step Step size. Defaults to `NULL` (Shiny's auto-step).
#' @param ticks Whether to show tick marks on the rail.
#' @param orientation Slider orientation. One of `"horizontal"` or
#'   `"vertical"`.
#' @param show_value Whether to render the current value above the slider.
#' @param min_label Optional label displayed at the minimum end of the rail.
#' @param max_label Optional label displayed at the maximum end of the rail.
#' @param width Optional CSS width value for horizontal sliders.
#' @param disabled Whether the control is disabled.
#' @param invalid Whether the control should show invalid styling
#'   (sets `aria-invalid="true"`).
#' @param style Inline CSS styles for the slider control.
#' @param class Additional classes for the wrapper.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_slider <- function(
  input_id,
  value,
  min,
  max,
  step = NULL,
  ticks = FALSE,
  orientation = c("horizontal", "vertical"),
  show_value = FALSE,
  min_label = NULL,
  max_label = NULL,
  width = NULL,
  disabled = FALSE,
  invalid = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  orientation <- match_arg(orientation, c("horizontal", "vertical"))
  if (missing(value) || !is.numeric(value) || length(value) < 1 ||
        length(value) > 2 || any(is.na(value))) {
    stop(
      "`value` must be one or two numeric values.",
      call. = FALSE
    )
  }
  if (missing(min) || !is.numeric(min) || length(min) != 1 || is.na(min)) {
    stop("`min` must be a single numeric value.", call. = FALSE)
  }
  if (missing(max) || !is.numeric(max) || length(max) != 1 || is.na(max)) {
    stop("`max` must be a single numeric value.", call. = FALSE)
  }
  if (min >= max) {
    stop("`min` must be strictly less than `max`.", call. = FALSE)
  }
  check_number(
    step, "step", positive = TRUE, null_ok = TRUE,
    msg = "`step` must be a single positive numeric value."
  )

  hidden_native <- hidden_native_input(
    input_id,
    type = "hidden",
    class = "sb-slider-native",
    value = paste(value, collapse = ","),
    style = NULL
  )

  wrapper_style <- if (orientation == "vertical") {
    "display:inline-flex;"
  } else if (!is.null(width)) {
    normalize_width_style(width)
  } else {
    NULL
  }

  runtime_component(
    component = "slider",
    props = list(
      min = min,
      max = max,
      step = step,
      ticks = isTRUE(ticks),
      orientation = orientation,
      showValue = isTRUE(show_value),
      minLabel = if (is.null(min_label)) NULL else as.character(min_label),
      maxLabel = if (is.null(max_label)) NULL else as.character(max_label),
      disabled = isTRUE(disabled),
      invalid = isTRUE(invalid),
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = as.numeric(value)),
    binding = list(input = TRUE, type = "shinyblocks.slider"),
    class = class,
    style = wrapper_style,
    root_class = "sb-slider-root",
    children = list(hidden_native)
  )
}

#' Update a runtime slider input
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_slider()`.
#' @param value Optional replacement value. One or two numeric values.
#' @param min Optional lower bound.
#' @param max Optional upper bound.
#' @param step Optional step size.
#' @param orientation Optional slider orientation. One of `"horizontal"` or
#'   `"vertical"`.
#' @param show_value Optional flag for rendering the current value label.
#' @param min_label Optional replacement minimum label. Use `NULL` to clear.
#' @param max_label Optional replacement maximum label. Use `NULL` to clear.
#' @param disabled Optional disabled state.
#' @param invalid Optional invalid flag.
#' @param style Optional replacement inline CSS styles for the slider.
#' @param class Optional replacement classes for the wrapper.
#' @param notify Whether Shiny should receive an input event when `value`
#'   changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_slider <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  value,
  min,
  max,
  step,
  orientation,
  show_value,
  min_label,
  max_label,
  disabled,
  invalid,
  style,
  class,
  notify = TRUE
) {
  payload <- list()

  if (!missing(value)) {
    if (is.null(value) || !is.numeric(value) || length(value) < 1 ||
          length(value) > 2 || any(is.na(value))) {
      stop("`value` must be one or two numeric values.", call. = FALSE)
    }
    payload <- payload_set_if_present(payload, "value", value, as.numeric)
  }
  if (!missing(min)) {
    check_number(min, "min", msg = "`min` must be a single numeric value.")
    payload <- payload_set_if_present(payload, "min", min, as.numeric)
  }
  if (!missing(max)) {
    check_number(max, "max", msg = "`max` must be a single numeric value.")
    payload <- payload_set_if_present(payload, "max", max, as.numeric)
  }
  if (!missing(min) && !missing(max) && min >= max) {
    stop("`min` must be strictly less than `max`.", call. = FALSE)
  }
  if (!missing(step)) {
    if (is.null(step)) {
      payload["step"] <- list(NULL)
    } else {
      check_number(
        step, "step", positive = TRUE,
        msg = "`step` must be a single positive numeric value."
      )
      payload$step <- as.numeric(step)
    }
  }
  if (!missing(orientation)) {
    payload$orientation <- match_arg(orientation, c("horizontal", "vertical"))
  }

  payload <- apply_update_fields(payload, list(
    field("showValue", "show_value", isTRUE),
    field_clearable("minLabel", "min_label", as.character),
    field_clearable("maxLabel", "max_label", as.character),
    field("disabled", transform = isTRUE),
    field("invalid", transform = isTRUE),
    field_style("style"),
    field_clearable("class")
  ))

  runtime_input_update(session, input_id, "slider", payload, notify = notify)
}
