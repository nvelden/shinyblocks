# block_select rejects malformed logical flags

    Code
      block_select("plan", c("Free", "Pro"), disabled = "yes")
    Condition
      Error:
      ! `disabled` must be a non-missing length-one logical.

---

    Code
      block_select("plan", c("Free", "Pro"), invalid = NA)
    Condition
      Error:
      ! `invalid` must be a non-missing length-one logical.

---

    Code
      block_select("plan", c("Free", "Pro"), multiple = 1)
    Condition
      Error:
      ! `multiple` must be a non-missing length-one logical.

