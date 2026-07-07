#' Create a segmented toggle group input
#'
#' Renders a shadcn-style toggle group: a joined row of pressable
#' buttons for single or multiple choice (view switchers, formatting
#' toolbars). Reports the pressed value(s) through a package-local
#' Shiny input binding: a string (or `NULL` when nothing is pressed)
#' for `type = "single"`, a character vector for `type = "multiple"`.
#'
#' @param input_id Input id.
#' @param choices Choice labels and values. A named character vector
#'   (`c(Label = "value")`), a list, or a character vector.
#' @param selected Optional initial value(s). For `type = "single"` a
#'   single value or `NULL` (nothing pressed); for `type = "multiple"`
#'   a character vector. Must match `choices`.
#' @param type `"single"` (radio-like, pressing another item releases
#'   the current one, pressing the active item releases it) or
#'   `"multiple"` (independent pressed states). Create-only.
#' @param variant Visual variant: `"default"` (borderless) or
#'   `"outline"`.
#' @param size Item size. One of `"default"`, `"sm"`, or `"lg"`.
#' @param icons Optional named list mapping choice values to icons.
#'   Each element is a vendored icon name (see [block_icon()]) or a
#'   `shiny.tag`.
#' @param icon_only Whether to hide item labels visually. Labels remain
#'   as the accessible name (`aria-label`), so every choice still needs
#'   a label. Requires `icons` covering every choice.
#' @param disabled `TRUE`/`FALSE` to disable the whole group, or a
#'   character vector of choice values to disable individual items.
#' @param style Inline CSS styles applied to the toggle-group wrapper.
#' @param class Additional classes for the wrapper.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_toggle_group <- function(
  input_id,
  choices,
  selected = NULL,
  type = c("single", "multiple"),
  variant = c("default", "outline"),
  size = c("default", "sm", "lg"),
  icons = NULL,
  icon_only = FALSE,
  disabled = FALSE,
  style = NULL,
  class = NULL
) {
  validate_input_id(input_id)
  type <- match_arg(type, c("single", "multiple"))
  variant <- match_arg(variant, c("default", "outline"))
  size <- match_arg(size, c("default", "sm", "lg"))
  choices_df <- normalize_choices(choices)
  validate_select_choice_values(choices_df$value)
  choice_values <- choices_df$value

  selected_values <- normalize_toggle_group_selected(
    selected,
    choice_values,
    type
  )
  disabled_state <- normalize_toggle_group_disabled(disabled, choice_values)
  icon_records <- normalize_toggle_group_icons(icons, choice_values)
  if (isTRUE(icon_only) && length(icon_records) < length(choice_values)) {
    stop(
      "`icon_only = TRUE` requires `icons` to cover every choice.",
      call. = FALSE
    )
  }

  hidden_native <- hidden_native_input(
    input_id,
    type = "hidden",
    class = "sb-toggle-group-native",
    value = paste(selected_values, collapse = ","),
    style = NULL,
    tabindex = NULL,
    aria_hidden = FALSE
  )

  state_value <- if (identical(type, "multiple")) {
    I(selected_values)
  } else if (length(selected_values) == 0) {
    NULL
  } else {
    selected_values[[1]]
  }

  runtime_component(
    component = "toggle-group",
    props = list(
      choices = toggle_group_choice_records(choices_df, icon_records),
      type = type,
      variant = variant,
      size = size,
      iconOnly = isTRUE(icon_only),
      disabled = disabled_state$group,
      disabledValues = I(disabled_state$values),
      spriteHref = sprite_href(),
      style = normalize_runtime_style(style)
    ),
    input_id = input_id,
    state = list(value = state_value),
    binding = list(input = TRUE, type = "shinyblocks.toggle-group"),
    class = class,
    root_class = "sb-toggle-group",
    children = list(hidden_native)
  )
}

#' Update a runtime toggle group input
#'
#' `type` and `icon_only` are create-only. When `selected` is supplied
#' without `choices`, membership is resolved client-side. Replacing
#' `choices` resets item icons, so pass `icons` together with `choices`
#' to keep them.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_toggle_group()`.
#' @param selected Optional new pressed value(s). `NULL` (single) or
#'   `character(0)` (multiple) releases everything.
#' @param choices Optional replacement choices.
#' @param icons Optional icons for the replacement `choices` (same
#'   shape as in [block_toggle_group()]). Requires `choices`.
#' @param disabled Optional `TRUE`/`FALSE` for the whole group, or a
#'   character vector of choice values to disable individually (which
#'   also re-enables the group).
#' @param variant Optional new visual variant.
#' @param size Optional new size.
#' @param style Optional replacement inline CSS styles.
#' @param class Optional replacement classes.
#' @param notify Whether Shiny should receive an input event when
#'   `selected` changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family forms
#' @export
update_block_toggle_group <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  selected,
  choices,
  icons,
  disabled,
  variant,
  size,
  style,
  class,
  notify = TRUE
) {
  payload <- list()

  if (missing(choices) && !missing(icons)) {
    stop("`icons` requires `choices`.", call. = FALSE)
  }

  if (!missing(choices)) {
    choices_df <- normalize_choices(choices)
    validate_select_choice_values(choices_df$value)
    icon_records <- normalize_toggle_group_icons(
      if (missing(icons)) NULL else icons,
      choices_df$value
    )
    payload$choices <- toggle_group_choice_records(choices_df, icon_records)
    payload$spriteHref <- sprite_href()
  }

  if (!missing(selected)) {
    payload["selected"] <- list(
      if (is.null(selected)) NULL else I(as.character(selected))
    )
  }

  if (!missing(disabled)) {
    disabled_state <- normalize_toggle_group_disabled(
      disabled,
      choice_values = NULL
    )
    payload$disabled <- disabled_state$group
    payload$disabledValues <- I(disabled_state$values)
  }

  if (!missing(variant)) {
    payload$variant <- match_arg(variant, c("default", "outline"))
  }
  if (!missing(size)) {
    payload$size <- match_arg(size, c("default", "sm", "lg"))
  }

  payload <- apply_update_fields(payload, list(
    field_style("style"),
    field_clearable("class")
  ))

  runtime_input_update(
    session, input_id, "toggle-group", payload,
    notify_key = "selected", notify = notify
  )
}

normalize_toggle_group_selected <- function(selected, choice_values, type) {
  if (is.null(selected)) {
    return(character())
  }

  selected <- as.character(selected)
  if (identical(type, "single") && length(selected) > 1) {
    stop(
      "`selected` must be a single value when `type = \"single\"`.",
      call. = FALSE
    )
  }
  if (anyDuplicated(selected)) {
    stop("`selected` must not contain duplicate values.", call. = FALSE)
  }
  if (any(!selected %in% choice_values)) {
    stop("`selected` must match one of `choices`.", call. = FALSE)
  }

  selected
}

# `disabled` is TRUE/FALSE for the whole group or a character vector of
# per-item choice values. `choice_values = NULL` skips membership
# validation (server updaters cannot see the client's current choices).
normalize_toggle_group_disabled <- function(disabled, choice_values) {
  if (is.logical(disabled) && length(disabled) == 1 && !is.na(disabled)) {
    return(list(group = isTRUE(disabled), values = character()))
  }
  if (is.character(disabled)) {
    if (!is.null(choice_values) && any(!disabled %in% choice_values)) {
      stop("`disabled` values must match `choices`.", call. = FALSE)
    }
    return(list(group = FALSE, values = as.character(disabled)))
  }
  stop(
    "`disabled` must be TRUE, FALSE, or a character vector of choice values.",
    call. = FALSE
  )
}

# Returns a named list keyed by choice value; each element is
# list(icon = <name>) or list(iconHtml = <fragment>).
normalize_toggle_group_icons <- function(icons, choice_values) {
  if (is.null(icons)) {
    return(list())
  }
  if (is.character(icons)) {
    icons <- as.list(icons)
  }
  if (!is.list(icons) || is.null(names(icons)) || any(!nzchar(names(icons)))) {
    stop(
      "`icons` must be a fully named list keyed by choice value.",
      call. = FALSE
    )
  }
  if (any(!names(icons) %in% choice_values)) {
    stop("`icons` names must match choice values.", call. = FALSE)
  }

  records <- lapply(icons, function(icon) {
    if (inherits(icon, "shiny.tag")) {
      return(list(iconHtml = html_fragment(icon)))
    }
    if (is.character(icon) && length(icon) == 1) {
      validate_icon_name(icon)
      return(list(icon = icon))
    }
    stop(
      "Each `icons` element must be a vendored icon name or a `shiny.tag`.",
      call. = FALSE
    )
  })
  names(records) <- names(icons)
  records
}

toggle_group_choice_records <- function(choices_df, icon_records = list()) {
  unname(lapply(seq_len(nrow(choices_df)), function(i) {
    value <- choices_df$value[[i]]
    record <- list(
      value = value,
      label = choices_df$label[[i]]
    )
    icon <- icon_records[[value]]
    if (!is.null(icon)) {
      record$icon <- icon$icon
      record$iconHtml <- icon$iconHtml
    }
    record
  }))
}
