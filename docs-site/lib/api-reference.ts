export interface ApiArgument {
  argument: string;
  type: string;
  defaultVal: string;
  description: string;
}

export interface ApiFunction {
  name: string;
  description: string;
  arguments: ApiArgument[];
}

export const API_REFERENCE_DATABASE: Record<string, ApiFunction[]> = {
  layout: [
    {
      name: "block_page",
      description: "Creates the main high-level responsive page layout container framing the application.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "UI content elements placed inside the body." },
        { argument: "title", type: "character", defaultVal: "NULL", description: "Optional browser page window title." },
        { argument: "sidebar", type: "shiny.tag", defaultVal: "NULL", description: "Layout sidebar element created by block_sidebar()." },
        { argument: "header", type: "shiny.tag", defaultVal: "NULL", description: "Layout header element created by block_header()." },
        { argument: "theme", type: "shiny.tag", defaultVal: "NULL", description: "Optional theme tags created by block_theme()." }
      ]
    },
    {
      name: "block_sidebar",
      description: "Builds a sleek side navigation panel containing brand titles and interactive link hierarchies.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Navigation links or sidebar content elements." },
        { argument: "title", type: "character", defaultVal: "NULL", description: "Sidebar branding or header title text." },
        { argument: "id", type: "character", defaultVal: "NULL", description: "Optional unique ID for sidebar state." },
        { argument: "collapsible", type: "logical", defaultVal: "FALSE", description: "Whether the sidebar can be collapsed." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Additional custom styling classes." }
      ]
    },
    {
      name: "block_header",
      description: "Renders the standard horizontal top header hosting actions and titles.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Header elements (e.g. title, search bar, dark mode toggles)." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom wrapper stylesheet class." }
      ]
    },
    {
      name: "block_body",
      description: "Houses main dashboard contents inside a token-aligned wrapper.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Main dashboard grid/content components." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "CSS class applied to the body container." }
      ]
    }
  ],
  "nav-item": [
    {
      name: "block_nav_item",
      description: "A navigation link element featuring custom glyphs and reactive selection highlight styling.",
      arguments: [
        { argument: "label", type: "character", defaultVal: "required", description: "Label text shown for the item." },
        { argument: "href", type: "character", defaultVal: "NULL", description: "Anchor URL reference path when clicked." },
        { argument: "icon", type: "character", defaultVal: "NULL", description: "Lucide icon glyph name." },
        { argument: "selected", type: "logical", defaultVal: "FALSE", description: "Initial selected state class highlight." }
      ]
    },
    {
      name: "block_nav",
      description: "Wraps multiple navigation link items inside a unified structural list.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "List of block_nav_item() elements." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "CSS class applied to the navigation wrapper." }
      ]
    }
  ],
  card: [
    {
      name: "block_card",
      description: "Combines groupings of visual data together in sleek tokenised surfaces.",
      arguments: [
        { argument: "...", type: "shiny.tag | character", defaultVal: "required", description: "Card body content elements." },
        { argument: "title", type: "character", defaultVal: "NULL", description: "Bold title string in card header." },
        { argument: "description", type: "character", defaultVal: "NULL", description: "Support paragraph text in card header." },
        { argument: "value", type: "character", defaultVal: "NULL", description: "High-signal primary stat/numeric highlight." },
        { argument: "footer", type: "shiny.tag | tagList", defaultVal: "NULL", description: "Action row elements at card bottom." },
        { argument: "style", type: "character", defaultVal: "NULL", description: "Custom inline styling properties." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom stylesheet styling classes." }
      ]
    },
    {
      name: "block_card_header",
      description: "Standard layout header container for placing text headers and action buttons.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Header inner elements." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom stylesheet styling classes." }
      ]
    },
    {
      name: "block_card_title",
      description: "Bold cardinal heading labels embedded inside standard visual wrappers.",
      arguments: [
        { argument: "...", type: "character | shiny.tag", defaultVal: "required", description: "Title textual context." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom styling classes." }
      ]
    },
    {
      name: "block_card_description",
      description: "Paragraph captions styled with dimmed palette tokens to support title labels.",
      arguments: [
        { argument: "...", type: "character | shiny.tag", defaultVal: "required", description: "Supporting text blocks." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom style classes." }
      ]
    },
    {
      name: "block_card_content",
      description: "Inner padded wrapper framing cardinal details.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Primary contents." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Additional classes." }
      ]
    },
    {
      name: "block_card_footer",
      description: "Divider-aligned bottom action panel container inside cards.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Action row widgets." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom stylesheet classes." }
      ]
    }
  ],
  "value-box": [
    {
      name: "block_value_box",
      description: "Renders standard visual boxes showcasing high-level numeric metrics.",
      arguments: [
        { argument: "title", type: "character", defaultVal: "required", description: "Descriptive label for the metric." },
        { argument: "value", type: "character", defaultVal: "required", description: "Numeric or key value indicator string." },
        { argument: "description", type: "character", defaultVal: "NULL", description: "Subtext copy under the main value." },
        { argument: "icon", type: "character", defaultVal: "NULL", description: "Leading decorative Lucide icon glyph name." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Additional custom style classes." }
      ]
    }
  ],
  badge: [
    {
      name: "block_badge",
      description: "Sleek compact status indicators displaying metadata categories.",
      arguments: [
        { argument: "label", type: "character", defaultVal: "required", description: "Text description inside the badge." },
        { argument: "variant", type: "'default' | 'secondary' | 'outline' | 'destructive'", defaultVal: "'default'", description: "Visual variant preset theme styles." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom classes applied to the badge wrapper." }
      ]
    }
  ],
  alert: [
    {
      name: "block_alert",
      description: "Inline warning panels communicating status callouts to users.",
      arguments: [
        { argument: "title", type: "character", defaultVal: "required", description: "Alert title text." },
        { argument: "description", type: "character", defaultVal: "NULL", description: "Supporting description subtext inside the alert." },
        { argument: "icon", type: "character", defaultVal: "NULL", description: "Leading Lucide icon name." },
        { argument: "variant", type: "'default' | 'destructive' | 'success' | 'warning' | 'info'", defaultVal: "'default'", description: "Stylesheet visual color preset category." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom container class classes." }
      ]
    }
  ],
  code: [
    {
      name: "block_code",
      description: "A premium monospace pre-formatted code block with custom line numbers, copy-to-clipboard button, and optional terminal header.",
      arguments: [
        { argument: "code", type: "character", defaultVal: "required", description: "The raw code string to display inside the block." },
        { argument: "language", type: "character", defaultVal: "NULL", description: "Optional programming language name displayed in the header." },
        { argument: "copyable", type: "logical", defaultVal: "TRUE", description: "Display a copy-to-clipboard action button." },
        { argument: "line_numbers", type: "logical", defaultVal: "TRUE", description: "Display sequential line numbers in the left margin." },
        { argument: "header", type: "logical", defaultVal: "FALSE", description: "Display macOS window control dots and language header bar." },
        { argument: "variant", type: "'default' | 'outline'", defaultVal: "'default'", description: "Thematic background card styling variant." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Additional custom styling classes to apply." },
        { argument: "style", type: "character", defaultVal: "NULL", description: "Inline custom CSS styles." }
      ]
    }
  ],
  table: [
    {
      name: "block_table",
      description: "Renders a data frame or tibble as a shadcn-style table through the shinyblocks runtime, with R-side formatting and a reactive server-side update path.",
      arguments: [
        { argument: "data", type: "data.frame", defaultVal: "required", description: "Data frame or tibble to render." },
        { argument: "columns", type: "named list", defaultVal: "NULL", description: "Optional table_column() specs keyed by data column name." },
        { argument: "caption", type: "character", defaultVal: "NULL", description: "Caption rendered below the table." },
        { argument: "max_rows", type: "integer", defaultVal: "NULL", description: "Optional row limit. Truncated tables render a footer note." },
        { argument: "na", type: "character", defaultVal: "\"\"", description: "String used to render missing values. Per-column overrides win." },
        { argument: "digits", type: "integer", defaultVal: "NULL", description: "Decimal places for default numeric formatting. NULL keeps R's format()." },
        { argument: "rownames", type: "logical", defaultVal: "FALSE", description: "Render row.names(data) as a leading column." },
        { argument: "row_format", type: "function", defaultVal: "NULL", description: "function(row, i) returning list(intent=, emphasis=, class=, style=) applied to that row's <tr>." },
        { argument: "striped", type: "logical", defaultVal: "FALSE", description: "Zebra-stripe body rows." },
        { argument: "hover", type: "logical", defaultVal: "TRUE", description: "Highlight rows on hover (shadcn base behavior)." },
        { argument: "bordered", type: "logical", defaultVal: "FALSE", description: "Draw cell borders." },
        { argument: "selection", type: "character", defaultVal: "\"none\"", description: "DT-style row selection mode: none, single, or multiple. Enables clickable rows reporting input$id_rows_selected, _row_last_clicked, and _cell_clicked." },
        { argument: "selected", type: "integer", defaultVal: "NULL", description: "1-based row indices to select on load (requires selection != none)." },
        { argument: "id", type: "character", defaultVal: "NULL", description: "Input id. Required to update the table from the server or to use row selection." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Additional classes applied to the runtime table container." },
        { argument: "style", type: "character | named list", defaultVal: "NULL", description: "Inline styles applied to the runtime mount and table container." }
      ]
    },
    {
      name: "update_block_table",
      description: "Re-renders an id-bound block_table() from the server with a freshly formatted payload (the same pipeline as the initial render).",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "current domain", description: "Shiny session." },
        { argument: "id", type: "character", defaultVal: "required", description: "Input id passed to block_table(id = )." },
        { argument: "data", type: "data.frame", defaultVal: "NULL", description: "Replacement data frame. Re-renders with the formatting arguments below." },
        { argument: "columns, caption, max_rows, na, digits, rownames, row_format, striped, hover, bordered", type: "matching block_table()", defaultVal: "block_table() defaults", description: "Formatting arguments applied when data is supplied." },
        { argument: "loading", type: "logical", defaultVal: "NULL", description: "TRUE shows skeleton rows; FALSE clears the loading state without changing data." },
        { argument: "selection", type: "character", defaultVal: "NULL", description: "Optional new row-selection mode (none, single, multiple). NULL leaves it unchanged." },
        { argument: "selected", type: "integer", defaultVal: "NULL", description: "1-based row indices to select; integer(0) clears. NULL leaves it unchanged." }
      ]
    },
    {
      name: "table_column",
      description: "Defines per-column display options for block_table().",
      arguments: [
        { argument: "label", type: "character", defaultVal: "NULL", description: "Header label. Defaults to the column name." },
        { argument: "align", type: "'left' | 'center' | 'right'", defaultVal: "'left'", description: "Text alignment for header and cells." },
        { argument: "format", type: "function", defaultVal: "NULL", description: "Function applied to the full R column vector before rendering. When set, digits is ignored for this column." },
        { argument: "width", type: "character", defaultVal: "NULL", description: "Optional CSS width for the column." },
        { argument: "digits", type: "integer", defaultVal: "NULL", description: "Per-column decimal places, overriding the table-level digits." },
        { argument: "na", type: "character", defaultVal: "NULL", description: "Per-column missing-value string, overriding the table-level na." },
        { argument: "intent", type: "intent enum", defaultVal: "NULL", description: "Token-backed styling intent for every cell in the column: muted, primary, secondary, destructive, success, warning, or accent. Theme-safe." },
        { argument: "emphasis", type: "'text' | 'soft' | 'solid'", defaultVal: "'text'", description: "How an intent renders: colored text, tinted background, or filled chip." },
        { argument: "class, style", type: "character | named list", defaultVal: "NULL", description: "Escape hatch: class / inline style on each <td>. You own theme-correctness." },
        { argument: "header_intent, header_emphasis, header_class, header_style", type: "intent enum | character", defaultVal: "NULL / 'text'", description: "Same styling controls applied to the column's <th> header cell." },
        { argument: "cell_intent, cell_emphasis, cell_class, cell_style", type: "function", defaultVal: "NULL", description: "function(value) callbacks over the column vector returning one entry per row; per-cell results win over the column-level styling." }
      ]
    }
  ],
  button: [
    {
      name: "block_button",
      description: "High-fidelity interactive triggers supporting click events, loading indicators, and form submissions.",
      arguments: [
        { argument: "label", type: "character", defaultVal: "required", description: "Label string on the button face." },
        { argument: "input_id", type: "character", defaultVal: "NULL", description: "Optional Shiny input trigger name." },
        { argument: "variant", type: "'default' | 'secondary' | 'outline' | 'ghost' | 'destructive' | 'link'", defaultVal: "'default'", description: "Thematic button style type." },
        { argument: "size", type: "'default' | 'sm' | 'lg' | 'icon'", defaultVal: "'default'", description: "Dimension size variant presets." },
        { argument: "icon", type: "character | shiny.tag", defaultVal: "NULL", description: "Inner icon element or Lucide name." },
        { argument: "disabled", type: "logical", defaultVal: "FALSE", description: "Whether the button is disabled." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom styling classes to merge." }
      ]
    },
    {
      name: "update_block_button",
      description: "Dynamically refreshes buttons from R server logic, triggering loading spinners or locking user inputs.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Standard active R/Shiny session." },
        { argument: "input_id", type: "character", defaultVal: "required", description: "Input trigger identifier to update." },
        { argument: "label", type: "character", defaultVal: "NULL", description: "New label string values to apply." },
        { argument: "variant", type: "character", defaultVal: "NULL", description: "Update the button's visual preset." },
        { argument: "size", type: "character", defaultVal: "NULL", description: "Update button dimension sizing." },
        { argument: "icon", type: "character", defaultVal: "NULL", description: "New Lucide icon glyph name." },
        { argument: "disabled", type: "logical", defaultVal: "NULL", description: "Enable/Disable button state." },
        { argument: "loading", type: "logical", defaultVal: "NULL", description: "Show spinner icon next to button label." }
      ]
    }
  ],
  select: [
    {
      name: "block_select",
      description: "Combines interactive search inputs with selection lists under robust dropdown panels.",
      arguments: [
        { argument: "input_id", type: "character", defaultVal: "required", description: "Shiny input binding identifier." },
        { argument: "choices", type: "list | character", defaultVal: "required", description: "List of selectable values/keys." },
        { argument: "selected", type: "character", defaultVal: "NULL", description: "Initial default selected value." },
        { argument: "placeholder", type: "character", defaultVal: "NULL", description: "Prompt text displayed when selection is empty." },
        { argument: "disabled", type: "logical", defaultVal: "FALSE", description: "Disable user inputs." },
        { argument: "width", type: "character", defaultVal: "'100%'", description: "Dimensions layout width." },
        { argument: "style", type: "character", defaultVal: "NULL", description: "Inline styling string." },
        { argument: "size", type: "'default' | 'sm' | 'lg'", defaultVal: "'default'", description: "Sizing dimensions." },
        { argument: "invalid", type: "logical", defaultVal: "FALSE", description: "Apply invalid visual highlights." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Additional styling classes." }
      ]
    },
    {
      name: "update_block_select",
      description: "Overwrites values, choices, or input locks from R servers.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Active Shiny session object." },
        { argument: "input_id", type: "character", defaultVal: "required", description: "Target input ID." },
        { argument: "choices", type: "list | character", defaultVal: "NULL", description: "New selection choices list." },
        { argument: "selected", type: "character", defaultVal: "NULL", description: "Value selector key to choose." },
        { argument: "disabled", type: "logical", defaultVal: "NULL", description: "Toggle input disabled state." },
        { argument: "invalid", type: "logical", defaultVal: "NULL", description: "Update invalid border styling." }
      ]
    }
  ],
  checkbox: [
    {
      name: "block_checkbox",
      description: "A customized check selection button for boolean switches.",
      arguments: [
        { argument: "input_id", type: "character", defaultVal: "required", description: "Input identifier returned as input$<id>." },
        { argument: "label", type: "character", defaultVal: "required", description: "Supporting text placed next to check control." },
        { argument: "value", type: "logical", defaultVal: "FALSE", description: "Initial active checkbox state." },
        { argument: "disabled", type: "logical", defaultVal: "FALSE", description: "Lock control input." },
        { argument: "style", type: "character", defaultVal: "NULL", description: "Custom container styles." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom style stylesheet classes." }
      ]
    },
    {
      name: "update_block_checkbox",
      description: "Modifies checking state, labels, or interactiveness on the fly.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Shiny web session object context." },
        { argument: "input_id", type: "character", defaultVal: "required", description: "Checkbox input ID." },
        { argument: "label", type: "character", defaultVal: "NULL", description: "Update label copy text." },
        { argument: "checked", type: "logical", defaultVal: "NULL", description: "Set active checked state." },
        { argument: "disabled", type: "logical", defaultVal: "NULL", description: "Lock checkbox interaction." }
      ]
    }
  ],
  textarea: [
    {
      name: "block_textarea",
      description: "Renders multi-line text input fields styled with premium boundary tokens.",
      arguments: [
        { argument: "input_id", type: "character", defaultVal: "required", description: "Text area selector target." },
        { argument: "placeholder", type: "character", defaultVal: "NULL", description: "Hint inside input field." },
        { argument: "rows", type: "integer", defaultVal: "3", description: "Default vertical lines size." },
        { argument: "disabled", type: "logical", defaultVal: "FALSE", description: "Freeze interactive inputs." },
        { argument: "invalid", type: "logical", defaultVal: "FALSE", description: "Show validation highlights." },
        { argument: "style", type: "character", defaultVal: "NULL", description: "Custom inline style overrides." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Additional CSS styles." }
      ]
    },
    {
      name: "update_block_textarea",
      description: "Alters value contexts and placeholders from server handlers.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Active R/Shiny session." },
        { argument: "input_id", type: "character", defaultVal: "required", description: "Target textarea component ID." },
        { argument: "value", type: "character", defaultVal: "NULL", description: "Replace full inner text area content." },
        { argument: "placeholder", type: "character", defaultVal: "NULL", description: "New descriptive hint text." },
        { argument: "disabled", type: "logical", defaultVal: "NULL", description: "Set text inputs blocked." },
        { argument: "invalid", type: "logical", defaultVal: "NULL", description: "Update validation border color." }
      ]
    }
  ],
  "file-input": [
    {
      name: "block_file_input",
      description: "Renders a styled file picker while preserving Shiny's native file upload data frame.",
      arguments: [
        { argument: "input_id", type: "character", defaultVal: "required", description: "Input identifier returned as input$<id>." },
        { argument: "multiple", type: "logical", defaultVal: "FALSE", description: "Allow selecting multiple files." },
        { argument: "accept", type: "character", defaultVal: "NULL", description: "Accepted MIME types or file extensions." },
        { argument: "button_label", type: "character", defaultVal: "\"Browse\"", description: "Text shown inside the visible picker button." },
        { argument: "placeholder", type: "character", defaultVal: "\"No file selected\"", description: "Text shown before files are selected." },
        { argument: "width", type: "character", defaultVal: "NULL", description: "CSS width applied to the wrapper." },
        { argument: "disabled", type: "logical", defaultVal: "FALSE", description: "Disable the visible picker and native file input." },
        { argument: "invalid", type: "logical", defaultVal: "FALSE", description: "Apply invalid visual highlights." },
        { argument: "style", type: "character | object", defaultVal: "NULL", description: "Inline styles applied to the visible control." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Additional class applied to the visible control." }
      ]
    }
  ],
  input: [
    {
      name: "block_input",
      description: "Builds a standard single-line interactive form input element.",
      arguments: [
        { argument: "input_id", type: "character", defaultVal: "required", description: "Input identifier." },
        { argument: "type", type: "'text' | 'password' | 'email' | 'url' | 'tel' | 'search' | 'number'", defaultVal: "'text'", description: "HTML text field variant category type." },
        { argument: "placeholder", type: "character", defaultVal: "NULL", description: "Preview text before typing." },
        { argument: "disabled", type: "logical", defaultVal: "FALSE", description: "Disable user inputs." },
        { argument: "invalid", type: "logical", defaultVal: "FALSE", description: "Highlight validation error borders." },
        { argument: "style", type: "character", defaultVal: "NULL", description: "Custom layout wrapper styling." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Additional styles to merge." }
      ]
    },
    {
      name: "update_block_input",
      description: "Refreshes user text, hint messages, or active lock states dynamically.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Active Shiny session object." },
        { argument: "input_id", type: "character", defaultVal: "required", description: "Target input control ID." },
        { argument: "value", type: "character", defaultVal: "NULL", description: "Update text input value." },
        { argument: "placeholder", type: "character", defaultVal: "NULL", description: "Set new placeholder copy." },
        { argument: "disabled", type: "logical", defaultVal: "NULL", description: "Freeze/unfreeze input." },
        { argument: "invalid", type: "logical", defaultVal: "NULL", description: "Toggle validation visual highlights." }
      ]
    }
  ],
  "radio-group": [
    {
      name: "block_radio_group",
      description: "Groups mutually exclusive options together under arrow-navigable radio circles.",
      arguments: [
        { argument: "input_id", type: "character", defaultVal: "required", description: "Radio group selector key." },
        { argument: "choices", type: "list | character", defaultVal: "required", description: "Available selection dictionary choices." },
        { argument: "selected", type: "character", defaultVal: "NULL", description: "Default selected value selector." },
        { argument: "disabled", type: "logical", defaultVal: "FALSE", description: "Lock option selection buttons." },
        { argument: "invalid", type: "logical", defaultVal: "FALSE", description: "Validation highlight boundary." },
        { argument: "orientation", type: "'vertical' | 'horizontal'", defaultVal: "'vertical'", description: "Flex layout style directions." },
        { argument: "style", type: "character", defaultVal: "NULL", description: "Inline styling string." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Merge styling classes." }
      ]
    },
    {
      name: "update_block_radio_group",
      description: "Replaces option selections, validation outlines, or list choices from Shiny servers.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Shiny web session object context." },
        { argument: "input_id", type: "character", defaultVal: "required", description: "Radio group input ID." },
        { argument: "choices", type: "list | character", defaultVal: "NULL", description: "New options layout database choices." },
        { argument: "selected", type: "character", defaultVal: "NULL", description: "Value to programmatically select." },
        { argument: "disabled", type: "logical", defaultVal: "NULL", description: "Block/allow group item selection." },
        { argument: "invalid", type: "logical", defaultVal: "NULL", description: "Apply invalid highlight state borders." }
      ]
    }
  ],
  switch: [
    {
      name: "block_switch",
      description: "A toggle switch input styled with premium smooth slide animations.",
      arguments: [
        { argument: "input_id", type: "character", defaultVal: "required", description: "Input id reported back to Shiny as input$." },
        { argument: "label", type: "character", defaultVal: "required", description: "Visible label rendered next to the toggle." },
        { argument: "value", type: "logical", defaultVal: "FALSE", description: "Initial checked state (TRUE/FALSE)." },
        { argument: "disabled", type: "logical", defaultVal: "FALSE", description: "Disables the switch while preserving server updates." },
        { argument: "style", type: "character | list", defaultVal: "NULL", description: "Inline CSS styles applied to the switch wrapper." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Additional class merged onto the runtime switch wrapper." }
      ]
    },
    {
      name: "update_block_switch",
      description: "Modifies toggle positions and interactive lockouts instantly.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Standard active R/Shiny session." },
        { argument: "input_id", type: "character", defaultVal: "required", description: "Target switch input ID." },
        { argument: "checked", type: "logical", defaultVal: "NULL", description: "Set new active toggled checked state." },
        { argument: "disabled", type: "logical", defaultVal: "NULL", description: "Toggle lock input interface interactions." }
      ]
    }
  ],
  "input-group": [
    {
      name: "block_input_group",
      description: "Fuses single-line text inputs together with adjacent labels or icon boxes.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Children elements (addons and block input)." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom stylesheet class." }
      ]
    },
    {
      name: "block_input_group_addon",
      description: "Wraps text, badges, or svg glyphs to merge adjacent to text input elements.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "UI content text, icon or badge addon." },
        { argument: "position", type: "'leading' | 'trailing'", defaultVal: "required", description: "Addon slot placement alignment sides." }
      ]
    }
  ],
  field: [
    {
      name: "block_field",
      description: "Layout wrapper for a single form field (label, control, description/error).",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Field contents: label, control, and optional description." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom stylesheet class." }
      ]
    },
    {
      name: "block_field_label",
      description: "A text label with an optional for attribute linking to its control's input ID.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Label text or inline content." },
        { argument: "for", type: "character", defaultVal: "NULL", description: "ID of the control this label describes." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom stylesheet class." }
      ]
    },
    {
      name: "block_field_description",
      description: "Helper/description text placed below the control element.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Helper text content." },
        { argument: "id", type: "character", defaultVal: "NULL", description: "Optional id for aria-describedby wiring." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom stylesheet class." }
      ]
    },
    {
      name: "block_field_group",
      description: "Flex grid to position multiple fields side-by-side within a form.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Child block_field() elements." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom stylesheet class." }
      ]
    },
    {
      name: "block_field_set",
      description: "A fieldset surface grouping related controls under a single boundary.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Legend, field groups, and fields." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom stylesheet class." }
      ]
    },
    {
      name: "block_field_legend",
      description: "A legend caption detailing the purpose of the surrounding fieldset.",
      arguments: [
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Legend caption content." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom stylesheet class." }
      ]
    },
    {
      name: "block_field_invalid",
      description: "Server-reactive validator that injects data-invalid attributes, aria descriptors, and formatted red error text.",
      arguments: [
        { argument: "field", type: "shiny.tag", defaultVal: "required", description: "The block_field() to mark invalid." },
        { argument: "message", type: "character", defaultVal: "required", description: "Validation error message to display." }
      ]
    }
  ],
  slider: [
    {
      name: "block_slider",
      description: "High-fidelity interactive visual range input sliders, supporting both single indicators and dual boundary ranges.",
      arguments: [
        { argument: "input_id", type: "character", defaultVal: "required", description: "Shiny input binding ID." },
        { argument: "value", type: "numeric | list", defaultVal: "required", description: "Initial active slider single value or range bounds list." },
        { argument: "min", type: "numeric", defaultVal: "required", description: "Boundary minimum limit range." },
        { argument: "max", type: "numeric", defaultVal: "required", description: "Boundary maximum limit range." },
        { argument: "step", type: "numeric", defaultVal: "NULL", description: "Interval steps numeric intervals." },
        { argument: "ticks", type: "logical", defaultVal: "FALSE", description: "Render numeric label grid ticks." },
        { argument: "orientation", type: "'horizontal' | 'vertical'", defaultVal: "'horizontal'", description: "Slider rail orientation." },
        { argument: "show_value", type: "logical", defaultVal: "FALSE", description: "Show the current value or range next to the rail." },
        { argument: "min_label", type: "character", defaultVal: "NULL", description: "Optional label at the minimum end of the rail." },
        { argument: "max_label", type: "character", defaultVal: "NULL", description: "Optional label at the maximum end of the rail." },
        { argument: "width", type: "character", defaultVal: "NULL", description: "CSS width applied to horizontal slider wrappers." },
        { argument: "disabled", type: "logical", defaultVal: "FALSE", description: "Disable user drag interaction." },
        { argument: "invalid", type: "logical", defaultVal: "FALSE", description: "Show validation warning colors." },
        { argument: "style", type: "character", defaultVal: "NULL", description: "Custom inline stylesheet styling." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "CSS styles container classes." }
      ]
    },
    {
      name: "update_block_slider",
      description: "Updates selection value arrays, error borders, or click blocks on the fly.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Shiny web session context." },
        { argument: "input_id", type: "character", defaultVal: "required", description: "Slider component identifier." },
        { argument: "value", type: "numeric | list", defaultVal: "NULL", description: "Set new selection values." },
        { argument: "min", type: "numeric", defaultVal: "NULL", description: "Update the minimum bound." },
        { argument: "max", type: "numeric", defaultVal: "NULL", description: "Update the maximum bound." },
        { argument: "step", type: "numeric", defaultVal: "NULL", description: "Update pointer and keyboard step size." },
        { argument: "orientation", type: "'horizontal' | 'vertical'", defaultVal: "NULL", description: "Update slider rail orientation." },
        { argument: "show_value", type: "logical", defaultVal: "NULL", description: "Toggle the current-value label." },
        { argument: "min_label", type: "character", defaultVal: "NULL", description: "Update or clear the minimum label." },
        { argument: "max_label", type: "character", defaultVal: "NULL", description: "Update or clear the maximum label." },
        { argument: "disabled", type: "logical", defaultVal: "NULL", description: "Freeze/unfreeze slider controls." },
        { argument: "invalid", type: "logical", defaultVal: "NULL", description: "Update validation error border outlines." }
      ]
    }
  ],
  tabs: [
    {
      name: "block_tabs",
      description: "Sleek reactive card panels organizing dashboard tabs dynamically.",
      arguments: [
        { argument: "id", type: "character", defaultVal: "NULL", description: "Optional Shiny input ID for the active tab value." },
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Tab layout child views created via block_tab()." },
        { argument: "selected", type: "character", defaultVal: "NULL", description: "Name of initial selected active view." },
        { argument: "variant", type: "'default' | 'line'", defaultVal: "'default'", description: "Visual tab list style." },
        { argument: "orientation", type: "'horizontal' | 'vertical'", defaultVal: "'horizontal'", description: "Tab list layout direction." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Styling classes applied on layouts wrapper." }
      ]
    },
    {
      name: "update_block_tabs",
      description: "Selects an active tab from the Shiny server.",
      arguments: [
        { argument: "session", type: "Shiny session", defaultVal: "current domain", description: "Session used to send the update message." },
        { argument: "input_id", type: "character", defaultVal: "required", description: "Input ID passed to block_tabs()." },
        { argument: "selected", type: "character", defaultVal: "required", description: "Tab value to activate." },
        { argument: "notify", type: "logical", defaultVal: "TRUE", description: "Whether to notify Shiny after selecting the tab." }
      ]
    },
    {
      name: "block_tab",
      description: "Wraps content sections placed inside tabs.",
      arguments: [
        { argument: "title", type: "character", defaultVal: "required", description: "Label string shown in tabs select row." },
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "UI elements to display inside the tab's pane." },
        { argument: "value", type: "character", defaultVal: "NULL", description: "Unique value key representing tab." }
      ]
    }
  ],
  theme: [
    {
      name: "block_theme",
      description: "Application-wide style engine managing design tokens, boundary rounding, and accent oklch color palettes.",
      arguments: [
        { argument: "...", type: "character", defaultVal: "required", description: "Accent token styles matching oklch colors or custom CSS properties (e.g. accent = 'oklch(0.6 0.15 150)', radius = '1rem')." }
      ]
    },
    {
      name: "update_block_theme",
      description: "Dynamically refreshes CSS tokens, theme states, or colors at runtime.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Shiny active web app session." },
        { argument: "...", type: "character", defaultVal: "required", description: "Custom accent token properties to override at runtime." }
      ]
    }
  ],
  style: [
    {
      name: "block_style",
      description: "Selects a built-in visual style profile controlling control sizing, spacing, surfaces, elevation, focus treatment, and motion. Pass to block_page(style = ).",
      arguments: [
        { argument: "profile", type: "character", defaultVal: "'default'", description: "Built-in style profile name (see block_style_profiles())." },
        { argument: "...", type: "character", defaultVal: "NULL", description: "Curated snake-case token overrides, e.g. control_height, surface_gap, surface_padding." },
        { argument: "scope", type: "character", defaultVal: "NULL", description: "Optional CSS selector to scope the profile to a subtree instead of the whole page." }
      ]
    },
    {
      name: "block_style_profiles",
      description: "Returns the character vector of built-in style-profile names accepted by block_style().",
      arguments: []
    }
  ],
  icon: [
    {
      name: "block_icon",
      description: "Optimized SVG vectors referencing Lucide glyph elements.",
      arguments: [
        { argument: "name", type: "character", defaultVal: "required", description: "Lucide icon glyph preset name." },
        { argument: "size", type: "'default' | 'sm' | 'lg' | 'xl'", defaultVal: "'default'", description: "Icon dimensions mapped to package size classes." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Styling classes to apply." },
        { argument: "color", type: "'default' | 'muted' | 'primary' | 'destructive' | 'success' | 'warning' | 'info'", defaultVal: "'default'", description: "Semantic foreground color token." },
        { argument: "...", type: "character", defaultVal: "NULL", description: "Additional attribute parameters." }
      ]
    }
  ],
  separator: [
    {
      name: "block_separator",
      description: "Clean divider line boundaries styled for grid splits.",
      arguments: [
        { argument: "orientation", type: "'horizontal' | 'vertical'", defaultVal: "'horizontal'", description: "Divider line alignment orientation." },
        { argument: "decorative", type: "logical", defaultVal: "TRUE", description: "Whether the separator is decorative-only." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "CSS stylesheet styling custom classes." }
      ]
    }
  ],
  skeleton: [
    {
      name: "block_skeleton",
      description: "Shimmering loading indicators matching layout shapes.",
      arguments: [
        { argument: "class", type: "character", defaultVal: "NULL", description: "Skeletons container styles and size sizing." },
        { argument: "...", type: "character", defaultVal: "NULL", description: "Custom inline arguments." }
      ]
    }
  ],
  spinner: [
    {
      name: "block_spinner",
      description: "Rotating spinner icons indicating asynchronous progress.",
      arguments: [
        { argument: "label", type: "character", defaultVal: "'Loading'", description: "Screenreader loading announcement label." },
        { argument: "size", type: "'default' | 'sm' | 'lg'", defaultVal: "'default'", description: "Spinner dimensions mapped to package size classes." },
        { argument: "color", type: "'default' | 'muted' | 'primary' | 'destructive' | 'success' | 'warning' | 'info'", defaultVal: "'default'", description: "Semantic foreground color token." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Styling animation/color custom classes." },
        { argument: "style", type: "character | list", defaultVal: "NULL", description: "Optional inline styles." }
      ]
    }
  ],
  empty: [
    {
      name: "block_empty",
      description: "Sleek placeholders displaying zero-state details and call-to-action buttons.",
      arguments: [
        { argument: "title", type: "character", defaultVal: "required", description: "Primary headline text inside card." },
        { argument: "description", type: "character", defaultVal: "NULL", description: "Supporting narrative instructions." },
        { argument: "icon", type: "character", defaultVal: "NULL", description: "SVG Lucide graphic glyph name." },
        { argument: "action", type: "shiny.tag", defaultVal: "NULL", description: "Custom click call trigger button tags." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Style stylesheet override classes." }
      ]
    }
  ],
  dialog: [
    {
      name: "block_dialog",
      description: "Fully accessible portal-rendered modal dialog screens containing interactive elements, focus trapping, and backdrop overlay clicks.",
      arguments: [
        { argument: "input_id", type: "character", defaultVal: "required", description: "Unique ID for dialog open/close state." },
        { argument: "title", type: "character", defaultVal: "NULL", description: "Header title text." },
        { argument: "description", type: "character", defaultVal: "NULL", description: "Subheader description text." },
        { argument: "trigger", type: "character", defaultVal: "NULL", description: "Button label to open the dialog." },
        { argument: "footer", type: "shiny.tag", defaultVal: "NULL", description: "Action buttons at the bottom." },
        { argument: "size", type: "'default' | 'sm' | 'lg'", defaultVal: "'default'", description: "Width sizing preset." },
        { argument: "hide_title", type: "logical", defaultVal: "FALSE", description: "Visually hide header." },
        { argument: "class", type: "character", defaultVal: "NULL", description: "Custom wrapper styles." },
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Dialog body content." }
      ]
    },
    {
      name: "update_block_dialog",
      description: "Forces dialog window close or open from Shiny handlers.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Active Shiny session." },
        { argument: "input_id", type: "character", defaultVal: "required", description: "Dialog input identifier." },
        { argument: "open", type: "logical", defaultVal: "NULL", description: "Set open/close dialog state (TRUE/FALSE)." }
      ]
    }
  ],
  popover: [
    {
      name: "block_popover",
      description: "Contextual portal-rendered popover content popups anchored next to interactive click targets.",
      arguments: [
        { argument: "trigger", type: "character | shiny.tag", defaultVal: "required", description: "Label string for click popover trigger." },
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Popover popup content layout elements." },
        { argument: "id", type: "character", defaultVal: "NULL", description: "Optional Shiny input trigger name." },
        { argument: "side", type: "'bottom' | 'top' | 'left' | 'right'", defaultVal: "'bottom'", description: "Anchor alignment orientation sides." },
        { argument: "align", type: "'center' | 'start' | 'end'", defaultVal: "'center'", description: "Placement centering alignment." },
        { argument: "content_style", type: "character", defaultVal: "NULL", description: "Inline styles on popover bubble wrapper." },
        { argument: "content_class", type: "character", defaultVal: "NULL", description: "Additional custom classes style." }
      ]
    },
    {
      name: "update_block_popover",
      description: "Forces contextual popovers to hide or expand dynamically.",
      arguments: [
        { argument: "session", type: "ShinySession", defaultVal: "required", description: "Standard active R/Shiny session." },
        { argument: "id", type: "character", defaultVal: "required", description: "Popover identifier." },
        { argument: "open", type: "logical", defaultVal: "NULL", description: "Programmatically open/close popover popups." }
      ]
    }
  ],
  tooltip: [
    {
      name: "block_tooltip",
      description: "Lightweight hover informational hint boxes rendered cleanly in the body portal to avoid layout clipping.",
      arguments: [
        { argument: "trigger", type: "character | shiny.tag", defaultVal: "required", description: "Label or UI element that triggers tooltip on hover/focus." },
        { argument: "...", type: "shiny.tag | tagList", defaultVal: "required", description: "Tooltip inner text or tag elements." },
        { argument: "side", type: "'top' | 'bottom' | 'left' | 'right'", defaultVal: "'top'", description: "Tooltip placement side relative to trigger." },
        { argument: "align", type: "'center' | 'start' | 'end'", defaultVal: "'center'", description: "Placement alignment along the chosen side." },
        { argument: "delay_duration", type: "integer", defaultVal: "700", description: "Time in milliseconds to wait before showing tooltip on hover." },
        { argument: "content_style", type: "character", defaultVal: "NULL", description: "Inline CSS overrides on tooltip popover." },
        { argument: "content_class", type: "character", defaultVal: "NULL", description: "Additional custom styling classes." }
      ]
    }
  ]
};
