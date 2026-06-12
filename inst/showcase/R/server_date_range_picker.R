register_date_range_picker_showcase <- function(input, output, session) {
  # Accept a user-typed `yyyy-mm-dd` string; return it only when it is a real
  # ISO date, otherwise NULL so the preview stays resilient to half-typed input.
  valid_iso <- function(x) {
    if (is.null(x)) {
      return(NULL)
    }
    x <- trimws(x)
    if (!nzchar(x)) {
      return(NULL)
    }
    parsed <- suppressWarnings(as.Date(x, format = "%Y-%m-%d"))
    if (is.na(parsed) || !identical(format(parsed, "%Y-%m-%d"), x)) {
      return(NULL)
    }
    x
  }

  output$showcase_date_range_picker_preview_value <- showcase_render_code({
    value <- input$showcase_date_range_picker_preview
    val_str <- if (is.null(value) || length(value) == 0) {
      "<NULL>"
    } else {
      paste0(
        "c(",
        paste(sprintf('as.Date("%s")', format(value, "%Y-%m-%d")), collapse = ", "),
        ")"
      )
    }
    paste0("input$showcase_date_range_picker_preview = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_date_range_picker_preview_value",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_date_range_picker_doc_class, {
    update_block_date_range_picker(
      session,
      "showcase_date_range_picker_preview",
      class = if (isTRUE(input$showcase_date_range_picker_doc_class)) {
        "showcase-date-range-picker-preview-custom"
      } else {
        NULL
      }
    )
  }, ignoreInit = TRUE)

  output$showcase_date_range_picker_preview_ui <- shiny::renderUI({
    start <- valid_iso(input$showcase_date_range_picker_doc_start)
    end <- valid_iso(input$showcase_date_range_picker_doc_end)
    min <- valid_iso(input$showcase_date_range_picker_doc_min)
    max <- valid_iso(input$showcase_date_range_picker_doc_max)

    # The constructor errors on a half-open range; only pass a pair or neither.
    if (is.null(start) != is.null(end)) {
      start <- NULL
      end <- NULL
    }

    # Keep bounds internally consistent so the constructor never errors.
    if (!is.null(min) && !is.null(max) && min > max) {
      max <- NULL
    }
    if (!is.null(start) && !is.null(min) && start < min) {
      start <- NULL
      end <- NULL
    }
    if (!is.null(end) && !is.null(max) && end > max) {
      start <- NULL
      end <- NULL
    }

    placeholder <- input$showcase_date_range_picker_doc_placeholder %||% "Pick a date range"
    if (!nzchar(placeholder)) {
      placeholder <- "Pick a date range"
    }

    separator <- input$showcase_date_range_picker_doc_separator %||% " – "
    if (!nzchar(separator)) {
      separator <- " – "
    }

    format <- input$showcase_date_range_picker_doc_format %||% "yyyy-mm-dd"
    weekstart <- as.integer(input$showcase_date_range_picker_doc_weekstart %||% "0")

    width <- input$showcase_date_range_picker_doc_width %||% "300px"
    if (!nzchar(width)) {
      width <- NULL
    }

    style <- input$showcase_date_range_picker_doc_style %||% ""
    if (!nzchar(style)) {
      style <- NULL
    }

    block_date_range_picker(
      input_id = "showcase_date_range_picker_preview",
      start = start,
      end = end,
      min = min,
      max = max,
      separator = separator,
      placeholder = placeholder,
      format = format,
      weekstart = weekstart,
      disabled = isTRUE(input$showcase_date_range_picker_doc_disabled),
      invalid = isTRUE(input$showcase_date_range_picker_doc_invalid),
      width = width,
      style = style,
      class = if (isTRUE(input$showcase_date_range_picker_doc_class)) {
        "showcase-date-range-picker-preview-custom"
      } else {
        NULL
      }
    )
  })
  shiny::outputOptions(
    output,
    "showcase_date_range_picker_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_date_range_picker_preview_code <- showcase_render_code({
    start <- valid_iso(input$showcase_date_range_picker_doc_start)
    end <- valid_iso(input$showcase_date_range_picker_doc_end)
    min <- valid_iso(input$showcase_date_range_picker_doc_min)
    max <- valid_iso(input$showcase_date_range_picker_doc_max)
    if (is.null(start) != is.null(end)) {
      start <- NULL
      end <- NULL
    }
    placeholder_val <- input$showcase_date_range_picker_doc_placeholder
    separator_val <- input$showcase_date_range_picker_doc_separator
    format_val <- input$showcase_date_range_picker_doc_format
    weekstart_val <- input$showcase_date_range_picker_doc_weekstart
    width_val <- input$showcase_date_range_picker_doc_width
    style_val <- input$showcase_date_range_picker_doc_style
    class_val <- input$showcase_date_range_picker_doc_class
    disabled_val <- input$showcase_date_range_picker_doc_disabled
    invalid_val <- input$showcase_date_range_picker_doc_invalid

    args <- c('input_id = "showcase_date_range_picker_preview"')

    if (!is.null(start)) {
      args <- c(args, paste0('start = "', start, '"'))
    }
    if (!is.null(end)) {
      args <- c(args, paste0('end = "', end, '"'))
    }
    if (!is.null(min)) {
      args <- c(args, paste0('min = "', min, '"'))
    }
    if (!is.null(max)) {
      args <- c(args, paste0('max = "', max, '"'))
    }
    if (!is.null(placeholder_val) && nzchar(placeholder_val) && placeholder_val != "Pick a date range") {
      args <- c(args, paste0('placeholder = "', placeholder_val, '"'))
    }
    if (!is.null(separator_val) && nzchar(separator_val) && separator_val != " – ") {
      args <- c(args, paste0('separator = "', separator_val, '"'))
    }
    if (!is.null(format_val) && format_val != "yyyy-mm-dd") {
      args <- c(args, paste0('format = "', format_val, '"'))
    }
    if (!is.null(weekstart_val) && weekstart_val != "0") {
      args <- c(args, paste0("weekstart = ", weekstart_val))
    }
    if (isTRUE(disabled_val)) {
      args <- c(args, "disabled = TRUE")
    }
    if (isTRUE(invalid_val)) {
      args <- c(args, "invalid = TRUE")
    }
    if (!is.null(width_val) && nzchar(width_val) && width_val != "300px") {
      args <- c(args, paste0('width = "', width_val, '"'))
    }
    if (!is.null(style_val) && nzchar(style_val)) {
      args <- c(args, paste0('style = "', style_val, '"'))
    }
    if (isTRUE(class_val)) {
      args <- c(args, 'class = "showcase-date-range-picker-preview-custom"')
    }

    paste0("block_date_range_picker(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_date_range_picker_preview_code",
    suspendWhenHidden = FALSE
  )

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_date_range_picker() code here."
  ))

  output$showcase_date_range_picker_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_date_range_picker_reactive_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_date_range_picker_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("start", "end", "min", "max", "separator", "placeholder", "format", "weekstart", "disabled", "invalid", "width", "class", "style"),
      Type = c("Date | character", "Date | character", "Date | character", "Date | character", "character", "character", "character", "integer", "logical", "logical", "character", "character", "character"),
      Default = c("NULL", "NULL", "NULL", "NULL", "\" – \"", "\"Pick a date range\"", "\"yyyy-mm-dd\"", "0", "FALSE", "FALSE", "NULL", "NULL", "NULL"),
      Description = c(
        "Range start. Accepts a Date, POSIX time, or yyyy-mm-dd string. Provide both start and end, or neither (NULL starts empty).",
        "Range end. A reversed start/end pair is silently ordered, matching dateRangeInput().",
        "Earliest selectable date. NULL for no lower bound.",
        "Latest selectable date. NULL for no upper bound.",
        "Text placed between the two endpoints on the trigger label.",
        "Text shown on the trigger before a range is selected.",
        "Display format for each endpoint on the trigger label (yyyy/yy, mm/m, MM/M, dd/d, DD/D tokens). The value is always transported as ISO.",
        "First day of the week (Shiny convention: 0 = Sunday, 6 = Saturday).",
        "Disables browser interaction while server updates remain possible.",
        "Applies aria-invalid and destructive border/ring styling.",
        "CSS width applied to the runtime date-range-picker wrapper.",
        "Additional class merged onto the runtime date-range-picker wrapper.",
        "Inline CSS styles applied to the trigger."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_date_range_picker_api_table",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_date_range_picker_set_week, {
    monday <- Sys.Date() - (as.integer(format(Sys.Date(), "%u")) - 1)
    sunday <- monday + 6
    update_block_date_range_picker(
      session,
      "showcase_date_range_picker_preview",
      start = monday,
      end = sunday
    )
    reactive_code(paste0(
      "update_block_date_range_picker(\n",
      "  session = session,\n",
      "  input_id = \"showcase_date_range_picker_preview\",\n",
      "  start = monday,\n",
      "  end = sunday\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_date_range_picker_set_q4, {
    update_block_date_range_picker(
      session,
      "showcase_date_range_picker_preview",
      start = "2025-10-01",
      end = "2025-12-31"
    )
    reactive_code(paste0(
      "update_block_date_range_picker(\n",
      "  session = session,\n",
      "  input_id = \"showcase_date_range_picker_preview\",\n",
      "  start = \"2025-10-01\",\n",
      "  end = \"2025-12-31\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_date_range_picker_clear, {
    update_block_date_range_picker(
      session,
      "showcase_date_range_picker_preview",
      clear = TRUE
    )
    reactive_code(paste0(
      "update_block_date_range_picker(\n",
      "  session = session,\n",
      "  input_id = \"showcase_date_range_picker_preview\",\n",
      "  clear = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_date_range_picker_disable, {
    update_block_date_range_picker(session, "showcase_date_range_picker_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_date_range_picker(\n",
      "  session = session,\n",
      "  input_id = \"showcase_date_range_picker_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_date_range_picker_enable, {
    update_block_date_range_picker(session, "showcase_date_range_picker_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_date_range_picker(\n",
      "  session = session,\n",
      "  input_id = \"showcase_date_range_picker_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_date_range_picker_set_bounds, {
    update_block_date_range_picker(
      session,
      "showcase_date_range_picker_preview",
      min = "2025-01-01",
      max = "2025-12-31",
      start = "2025-06-01",
      end = "2025-06-30"
    )
    reactive_code(paste0(
      "update_block_date_range_picker(\n",
      "  session = session,\n",
      "  input_id = \"showcase_date_range_picker_preview\",\n",
      "  min = \"2025-01-01\",\n",
      "  max = \"2025-12-31\",\n",
      "  start = \"2025-06-01\",\n",
      "  end = \"2025-06-30\"\n",
      ")"
    ))
  })
}
