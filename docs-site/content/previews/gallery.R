htmltools::div(
  class = "grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 items-start w-full",
  
  # ================= COLUMN 1 =================
  htmltools::div(
    class = "flex flex-col gap-6",
    
    # Payment Method Card
    htmltools::div(
      `data-component-preview` = "card",
      shinyblocks::block_card(
        title = "Payment Method",
        description = "All transactions are secure and encrypted",
        htmltools::div(
          class = "flex flex-col gap-4 mt-2",
        
        # Name input
        htmltools::div(
          class = "flex flex-col gap-1.5",
          htmltools::tags$label(class = "text-xs font-semibold text-foreground", "Name on Card"),
          shinyblocks::block_input(input_id = "card_name", placeholder = "John Doe")
        ),
        
        # Card Number and CVV
        htmltools::div(
          class = "grid grid-cols-3 gap-3",
          htmltools::div(
            class = "col-span-2 flex flex-col gap-1.5",
            htmltools::tags$label(class = "text-xs font-semibold text-foreground", "Card Number"),
            shinyblocks::block_input(input_id = "card_num", placeholder = "1234 5678 9012 3456")
          ),
          htmltools::div(
            class = "flex flex-col gap-1.5",
            htmltools::tags$label(class = "text-xs font-semibold text-foreground", "CVV"),
            shinyblocks::block_input(input_id = "card_cvv", placeholder = "123")
          )
        ),
        
        # Month and Year
        htmltools::div(
          class = "grid grid-cols-2 gap-3",
          htmltools::div(
            class = "flex flex-col gap-1.5",
            htmltools::tags$label(class = "text-xs font-semibold text-foreground", "Month"),
            shinyblocks::block_select(input_id = "card_month", choices = c("MM", "01", "02", "03", "04", "05"))
          ),
          htmltools::div(
            class = "flex flex-col gap-1.5",
            htmltools::tags$label(class = "text-xs font-semibold text-foreground", "Year"),
            shinyblocks::block_select(input_id = "card_year", choices = c("YYYY", "2026", "2027", "2028"))
          )
        ),
        
        # Billing Address Section
        htmltools::div(
          class = "border-t border-border pt-4 mt-2 flex flex-col gap-3",
          htmltools::div(
            htmltools::tags$h4(class = "text-xs font-semibold text-foreground", "Billing Address"),
            htmltools::tags$p(class = "text-[10px] text-muted-foreground mt-0.5", "The billing address associated with your payment method")
          ),
          shinyblocks::block_checkbox(input_id = "billing_same", label = "Same as shipping address", value = TRUE)
        ),
        
        # Comments Textarea
        htmltools::div(
          class = "flex flex-col gap-1.5",
          htmltools::tags$label(class = "text-xs font-semibold text-foreground", "Comments"),
          shinyblocks::block_textarea(input_id = "billing_comments", placeholder = "Add any additional comments", rows = 2)
        ),
        
        # Form buttons
        htmltools::div(
          class = "flex gap-2.5 pt-2",
          htmltools::div(
            class = "flex-1",
            `data-component-preview` = "button",
            shinyblocks::block_button("Submit", class = "w-full justify-center")
          ),
          shinyblocks::block_button("Cancel", variant = "outline", class = "flex-1 justify-center")
        )
      )
    )
  )
),
  
  # ================= COLUMN 2 =================
  htmltools::div(
    class = "flex flex-col gap-6",
    
    # Empty State card
    shinyblocks::block_empty(
      title = "No Team Members",
      description = "Invite your team to collaborate on this project.",
      icon = "users",
      action = shinyblocks::block_button("Invite Members", size = "sm")
    ),
    
    # Badges Row
    htmltools::div(
      class = "flex flex-wrap gap-2 items-center justify-center py-2 px-1 border border-border/80 bg-muted/30 rounded-lg",
      shinyblocks::block_badge("Syncing"),
      shinyblocks::block_badge("Updating", variant = "secondary"),
      shinyblocks::block_badge("Loading", variant = "outline")
    ),

    # File upload
    shinyblocks::block_file_input(
      input_id = "gallery_upload",
      button_label = "Upload",
      placeholder = "Attach CSV",
      accept = c(".csv", "text/csv")
    ),
    
    # Send message input
    shinyblocks::block_input(input_id = "msg_input", placeholder = "+ Send a message..."),
    
    # Price Range Slider
    shinyblocks::block_card(
      title = "Price Range",
      description = "Set your budget range ($200 - 800).",
      shinyblocks::block_slider(input_id = "budget_slider", min = 200, max = 800, value = 500)
    ),
    
    # Search Input with results count
    shinyblocks::block_input(input_id = "search_inp", placeholder = "Search..."),
    
    # Domain url
    shinyblocks::block_input(input_id = "domain_inp", value = "https://example.com"),
    
    # Chat Textarea
    shinyblocks::block_card(
      title = "Ask, Search or Chat...",
      shinyblocks::block_textarea(input_id = "chat_box", placeholder = "Ask, Search or Chat...", rows = 3),
      footer = htmltools::div(
        class = "flex items-center justify-between text-[10px] text-muted-foreground w-full",
        htmltools::span("+ Auto"),
        htmltools::span("52% used")
      )
    ),
    
    # shadcn verified pill
    htmltools::div(
      class = "flex items-center justify-between border border-border bg-card/85 px-4 py-2.5 rounded-lg shadow-sm",
      htmltools::span(class = "text-xs font-semibold font-mono text-foreground", "@shadcn"),
      shinyblocks::block_badge("Verified", variant = "secondary")
    )
  ),
  
  # ================= COLUMN 3 =================
  htmltools::div(
    class = "flex flex-col gap-6",
    
    # URL address bar
    shinyblocks::block_input(input_id = "url_inp", placeholder = "https://"),
    
    # 2FA Prompt Banner
    shinyblocks::block_card(
      title = "Two-factor authentication",
      description = "Verify via email or phone number.",
      footer = shinyblocks::block_button("Enable", size = "sm")
    ),
    
    # Verification Alert
    shinyblocks::block_alert("Your profile has been verified.", variant = "default"),
    
    # Appearance Settings Separator
    htmltools::div(
      class = "relative py-2 flex items-center justify-center",
      htmltools::div(class = "absolute inset-0 flex items-center", htmltools::div(class = "w-full border-t border-border")),
      htmltools::span(class = "relative bg-background px-3 text-[10px] font-semibold uppercase tracking-wider text-muted-foreground/80", "Appearance Settings")
    ),
    
    # Compute Environment option
    htmltools::div(
      class = "flex flex-col gap-1.5",
      htmltools::tags$label(class = "text-xs font-semibold text-foreground", "Compute Environment"),
      shinyblocks::block_radio_group(
        input_id = "compute_env",
        choices = c(
          "Kubernetes - Run GPU workloads on a K8s configured cluster. This is the default." = "k8s",
          "Virtual Machine - Access a VM configured cluster to run workloads. (Coming soon)" = "vm"
        )
      )
    ),
    
    # Number of GPUs Card
    shinyblocks::block_card(
      title = "Number of GPUs",
      description = "You can add more later.",
      value = "8"
    ),
    
    # Wallpaper Tinting switch
    shinyblocks::block_card(
      title = "Wallpaper Tinting",
      description = "Allow the wallpaper to be tinted.",
      footer = shinyblocks::block_switch(input_id = "tinting_switch", label = "", value = TRUE)
    )
  ),
  
  # ================= COLUMN 4 =================
  htmltools::div(
    class = "flex flex-col gap-6",
    
    # Context Pill Area
    shinyblocks::block_card(
      title = "Context",
      description = "Ask, search, or make anything...",
      action = shinyblocks::block_button("@ Add context", size = "sm")
    ),
    
    # Action buttons row
    shinyblocks::block_tabs(
      id = "action_tabs",
      selected = "Archive",
      shinyblocks::block_tab(title = "Archive", value = "Archive"),
      shinyblocks::block_tab(title = "Report", value = "Report"),
      shinyblocks::block_tab(title = "Snooze", value = "Snooze")
    ),
    
    # Terms Checkbox
    shinyblocks::block_checkbox(input_id = "agree_terms", label = "I agree to the terms and conditions", value = TRUE),
    
    # Pagination & Copilot
    htmltools::div(
      class = "flex items-center gap-3",
      shinyblocks::block_button("Copilot", variant = "outline", size = "sm")
    ),
    
    # How did you hear about us?
    shinyblocks::block_card(
      title = "How did you hear about us?",
      description = "Select the option that best describes how you...",
      htmltools::div(
        class = "flex flex-wrap gap-2 mt-2",
        shinyblocks::block_badge("Social Media"),
        shinyblocks::block_badge("Search Engine", variant = "outline"),
        shinyblocks::block_badge("Referral", variant = "outline")
      )
    ),
    
    # Processing request Spinner Card
    shinyblocks::block_card(
      title = "Processing your request",
      description = "Please wait while we process your request. Do not refresh the page.",
      value = shinyblocks::block_spinner(),
      footer = shinyblocks::block_button("Cancel", variant = "outline", size = "sm")
    )
  )
)
