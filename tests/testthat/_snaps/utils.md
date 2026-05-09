# match_arg reports allowed values

    Code
      ns$match_arg("auto", c("system", "light", "dark"), "theme_mode")
    Condition
      Error:
      ! `theme_mode` must be one of "system", "light", "dark".

# validate_children accepts only tagged child items

    Code
      ns$validate_children(list(invalid), "nav-item", "block_nav")
    Condition
      Error:
      ! All children of `block_nav()` must be `nav-item` items.

# validate_icon_name reports unknown icons

    Code
      ns$validate_icon_name("not-an-icon")
    Condition
      Error:
      ! Unknown icon `not-an-icon`. Add it to `inst/www/icons/MANIFEST.json` first.

# block_button validates variant and size

    Code
      block_button("Save", variant = "primary")
    Condition
      Error:
      ! `variant` must be one of "default", "secondary", "outline", "ghost", "destructive", "link".

---

    Code
      block_button("Save", size = "xl")
    Condition
      Error:
      ! `size` must be one of "default", "sm", "lg", "icon".

# block_badge validates variant

    Code
      block_badge("New", variant = "primary")
    Condition
      Error:
      ! `variant` must be one of "default", "secondary", "outline", "destructive".

# block_alert validates required title and variant

    Code
      block_alert(NULL)
    Condition
      Error:
      ! `title` is required.

---

    Code
      block_alert("Notice", variant = "warning")
    Condition
      Error:
      ! `variant` must be one of "default", "destructive".

