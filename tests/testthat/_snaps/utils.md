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

# block_switch validates size

    Code
      block_switch("alerts", "Alerts", size = "xl")
    Condition
      Error:
      ! `size` must be one of "default", "sm", "lg".

# block_badge validates variant

    Code
      block_badge("New", variant = "primary")
    Condition
      Error:
      ! `variant` must be one of "default", "secondary", "outline", "destructive", "ghost", "link".

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

# block_separator validates orientation

    Code
      block_separator(orientation = "diagonal")
    Condition
      Error:
      ! `orientation` must be one of "horizontal", "vertical".

# block_nav validates child types

    Code
      block_nav(htmltools::tags$div("Bad child"))
    Condition
      Error:
      ! All children of `block_nav()` must be `nav-item` items.

# block_field_invalid validates field input

    Code
      block_field_invalid(htmltools::tags$div("Bad field"), "Nope")
    Condition
      Error:
      ! `field` must be created by `block_field()`.

# block_select validates choices and selected value

    Code
      block_select("plan", choices = character())
    Condition
      Error:
      ! `choices` must contain at least one option.

---

    Code
      block_select("plan", choices = c("Free", "Pro"), selected = "Team")
    Condition
      Error:
      ! `selected` must match one of `choices`.

---

    Code
      block_select("plan", choices = c("Free", "Pro"), size = "xl")
    Condition
      Error:
      ! `size` must be one of "default", "sm", "lg".

# update_block_select validates selected replacement choices

    Code
      update_block_select(session, "plan", selected = "team", choices = c(Free = "free",
        Pro = "pro"))
    Condition
      Error:
      ! `selected` must match one of `choices`.

# block_textarea validates rows

    Code
      block_textarea("notes", rows = 0)
    Condition
      Error:
      ! `rows` must be a positive number.

# block_theme validates named and known tokens

    Code
      block_theme("bad")
    Condition
      Error:
      ! `block_theme()` requires named token overrides.

---

    Code
      block_theme(not_a_token = "red")
    Condition
      Error:
      ! Unknown theme token(s): `not_a_token`.

# update_block_theme requires a session

    Code
      update_block_theme(NULL)
    Condition
      Error:
      ! `session` is required.

