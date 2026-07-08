shinyblocks::block_combobox(
  "preview_combobox",
  choices = list(
    "Next.js" = "nextjs",
    "React" = "react",
    "Astro" = "astro",
    "SvelteKit" = "sveltekit"
  ),
  selected = "nextjs",
  placeholder = "Select framework",
  search_placeholder = "Search framework..."
)
