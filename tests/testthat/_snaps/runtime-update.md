# runtime_update() rejects non-clearable NULL fields

    Code
      ns$runtime_update(session = fixture$session, input_id = "choice", component = "select",
      value = NULL)
    Condition
      Error:
      ! Cannot clear non-clearable update field(s): `value`.

# runtime_update_message() validates sessions and ids

    Code
      ns$runtime_update_message(session = NULL, input_id = "choice", component = "select")
    Condition
      Error:
      ! `session` is required.

---

    Code
      ns$runtime_update_message(session = test_session()$session, input_id = "",
      component = "select")
    Condition
      Error:
      ! `input_id` must be a non-empty string.

