shinyblocks::block_accordion(
  shinyblocks::block_accordion_item(
    "faq-1", "Is it accessible?",
    "Yes. It follows the WAI-ARIA accordion design pattern."
  ),
  shinyblocks::block_accordion_item(
    "faq-2", "Is it styled?",
    "Yes. It ships with token-driven defaults you can override."
  ),
  shinyblocks::block_accordion_item(
    "faq-3", "Is it animated?",
    "Yes. The panel height animates open and closed."
  ),
  open = "faq-1"
)
