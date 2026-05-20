shinyblocks::block_tabs(
  id = "account_tabs",
  shinyblocks::block_tab("Account", "Make changes to your account details here.", value = "account"),
  shinyblocks::block_tab("Password", "Change your password here.", value = "password"),
  selected = "account"
)
