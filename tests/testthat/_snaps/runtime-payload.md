# runtime payload helpers validate inputs

    Code
      ns$runtime_payload(component = "")
    Condition
      Error:
      ! `component` must be a non-empty string.

---

    Code
      ns$runtime_payload(component = "fixture", props = list("unnamed"))
    Condition
      Error:
      ! `props` must be a fully named list.

