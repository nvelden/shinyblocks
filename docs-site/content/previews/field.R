shinyblocks::block_field_set(
  shinyblocks::block_field_legend("Account details"),
  shinyblocks::block_field(
    shinyblocks::block_field_label("Email address", `for` = "email"),
    shinyblocks::block_input("email", type = "email", value = "john.doe@example.com"),
    shinyblocks::block_field_description("We'll never share your email address.")
  ),
  shinyblocks::block_field(
    shinyblocks::block_field_label("Password", `for` = "password"),
    shinyblocks::block_input("password", type = "password", value = "supersecret")
  )
)
