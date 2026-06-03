# block_theme validates named and known tokens

    Code
      block_theme("bad")
    Condition
      Error:
      ! `block_theme()` overrides must be named.

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
