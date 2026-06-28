registry <- list(
  list(
    name = "Layout",
    slug = "layout",
    file = "layout.R",
    description = "Page, sidebar, header, and body primitives that form the application frame.",
    featured = TRUE
  ),
  list(
    name = "Layout Primitives",
    slug = "layout-primitives",
    file = "layout-primitives.R",
    description = "Stack, cluster, and responsive grid helpers for composing application content.",
    featured = TRUE
  ),
  list(
    name = "Nav Group",
    slug = "nav-group",
    file = "nav-group.R",
    description = "Collapsible sidebar groups, section labels, and nested leaf items for block_nav().",
    featured = FALSE
  ),
  list(
    name = "Card",
    slug = "card",
    file = "card.R",
    description = "Group related content in structured, elegant containers.",
    featured = TRUE
  ),
  list(
    name = "Value Box",
    slug = "value-box",
    file = "value_box.R",
    description = "High-signal key-value metric card displays with supporting icons.",
    featured = TRUE
  ),
  list(
    name = "Badge",
    slug = "badge",
    file = "badge.R",
    description = "Compact, premium labels for displaying status and categories.",
    featured = TRUE
  ),
  list(
    name = "Alert",
    slug = "alert",
    file = "alert.R",
    description = "Inline messaging blocks with semantic layouts and inline icons.",
    featured = TRUE
  ),
  list(
    name = "Code",
    slug = "code",
    file = "code.R",
    description = "A premium monospace pre-formatted code block with terminal-style controls and copy actions.",
    featured = TRUE
  ),
  list(
    name = "Table",
    slug = "table",
    file = "table.R",
    description = "Styled data-frame tables with captions, column formatting, alignment, and truncation notes.",
    featured = TRUE
  ),
  list(
    name = "Button",
    slug = "button",
    file = "button.R",
    description = "Interactive controls for triggers, forms, and custom actions.",
    featured = TRUE
  ),
  list(
    name = "Task Button",
    slug = "task-button",
    file = "task-button.R",
    description = "An action button that locks on click, shows a busy state, and auto-resets after the click flush.",
    featured = FALSE
  ),
  list(
    name = "Select",
    slug = "select",
    file = "select.R",
    description = "Interactive dropdown control for single-value choice selection.",
    featured = TRUE
  ),
  list(
    name = "Date Picker",
    slug = "date-picker",
    file = "date-picker.R",
    description = "Calendar popover for single-date selection with a shiny.date value binding.",
    featured = TRUE
  ),
  list(
    name = "Date Range Picker",
    slug = "date-range-picker",
    file = "date-range-picker.R",
    description = "Calendar popover for two-endpoint range selection with a length-2 shiny.date value binding.",
    featured = TRUE
  ),
  list(
    name = "Checkbox",
    slug = "checkbox",
    file = "checkbox.R",
    description = "Stateful toggle selector for standalone options or boolean flags.",
    featured = TRUE
  ),
  list(
    name = "Textarea",
    slug = "textarea",
    file = "textarea.R",
    description = "Multi-line text editor with native height adjustments and error states.",
    featured = TRUE
  ),
  list(
    name = "File Input",
    slug = "file-input",
    file = "file-input.R",
    description = "Styled file uploads backed by Shiny's native upload binding.",
    featured = TRUE
  ),
  list(
    name = "Input",
    slug = "input",
    file = "input.R",
    description = "Premium single-line text input fields supporting diverse types.",
    featured = TRUE
  ),
  list(
    name = "Radio Group",
    slug = "radio-group",
    file = "radio_group.R",
    description = "Set of mutually exclusive options with clean arrow keyboard support.",
    featured = TRUE
  ),
  list(
    name = "Switch",
    slug = "switch",
    file = "switch.R",
    description = "Highly interactive slider-toggle switch for toggle inputs.",
    featured = TRUE
  ),
  list(
    name = "Input Group",
    slug = "input-group",
    file = "input_group.R",
    description = "Unified input control wrapping leading/trailing addon elements.",
    featured = FALSE
  ),
  list(
    name = "Field",
    slug = "field",
    file = "field.R",
    description = "Form field layout: labels, descriptions, fieldsets, groups, and validation states.",
    featured = FALSE
  ),
  list(
    name = "Image Output",
    slug = "image-output",
    file = "image-output.R",
    description = "shadcn-styled frames around Shiny's reactive imageOutput/renderImage raster outputs.",
    featured = FALSE
  ),
  list(
    name = "Plot Output",
    slug = "plot-output",
    file = "plot-output.R",
    description = "shadcn-styled frames around Shiny's reactive plotOutput/renderPlot graphics outputs.",
    featured = FALSE
  ),
  list(
    name = "Slider",
    slug = "slider",
    file = "slider.R",
    description = "Interactive range controls for single values or interval bounds.",
    featured = TRUE
  ),
  list(
    name = "Tabs",
    slug = "tabs",
    file = "tabs.R",
    description = "Structured navigation tabs that organize views and options.",
    featured = TRUE
  ),
  list(
    name = "Theme",
    slug = "theme",
    file = "theme.R",
    description = "Application-wide style engine managing design tokens and dark mode.",
    featured = FALSE
  ),
  list(
    name = "Style",
    slug = "style",
    file = "style.R",
    description = "Visual style profiles controlling sizing, spacing, surfaces, elevation, and motion.",
    featured = FALSE
  ),
  list(
    name = "Icon",
    slug = "icon",
    file = "icon.R",
    description = "High-quality vector graphics backed by a curated Lucide set.",
    featured = FALSE
  ),
  list(
    name = "Separator",
    slug = "separator",
    file = "separator.R",
    description = "Clean visual divider lines with vertical or horizontal orientation.",
    featured = FALSE
  ),
  list(
    name = "Skeleton",
    slug = "skeleton",
    file = "skeleton.R",
    description = "Dynamic placeholder panels simulating asynchronous content loading.",
    featured = FALSE
  ),
  list(
    name = "Spinner",
    slug = "spinner",
    file = "spinner.R",
    description = "Elegant CSS-driven loading indicator animations.",
    featured = FALSE
  ),
  list(
    name = "Progress",
    slug = "progress",
    file = "progress.R",
    description = "Embedded, server-driven progress bar that renders inline instead of as a notification panel.",
    featured = FALSE
  ),
  list(
    name = "Empty",
    slug = "empty",
    file = "empty.R",
    description = "Premium messaging cards for zero-state scenarios.",
    featured = TRUE
  ),
  list(
    name = "Dialog",
    slug = "dialog",
    file = "dialog.R",
    description = "Portal-rendered modal views containing forms, alerts, or details.",
    featured = TRUE
  ),
  list(
    name = "Popover",
    slug = "popover",
    file = "popover.R",
    description = "Non-modal overlay boxes that host dynamic contextual controls.",
    featured = TRUE
  ),
  list(
    name = "Tooltip",
    slug = "tooltip",
    file = "tooltip.R",
    description = "Lightweight, hover-triggered informational hint overlays.",
    featured = TRUE
  ),
  list(
    name = "Toast",
    slug = "toast",
    file = "toast.R",
    description = "Server-fired, auto-dismissing notifications anchored to a screen corner.",
    featured = TRUE
  ),
  list(
    name = "Gallery",
    slug = "gallery",
    file = "gallery.R",
    description = "Interactive cohesive dashboard layout prerendered directly from R package components.",
    featured = FALSE
  )
)
