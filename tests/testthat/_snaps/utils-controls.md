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
