# Plan — Add All Shipped R Components to the Custom Docs Site

This plan details the addition of all 23 remaining `shinyblocks` R package components to the custom documentation site's dynamic preview gallery, index listing, and details sections.

## Goals
- Formulate static R-preview files under `docs-site/content/previews/*.R` for all shipped components.
- Register all 25 components in the previews compiler `docs-site/content/previews/_registry.R`.
- Regenerate the static previews, assets, and JSON payload manifest by running the build pipeline.
- Verify that every component is fully listed, rendered, and navigable with high-fidelity client hydration on the index and detail pages.

## Proposed Components List
We will add 23 new preview blocks to the website:
1. **Layout Shell** (`layout` / `block_page`, `block_sidebar`, `block_header`, `block_body`)
2. **Nav Item** (`nav-item` / `block_nav_item`)
3. **Value Box** (`value-box` / `block_value_box`)
4. **Badge** (`badge` / `block_badge`)
5. **Alert** (`alert` / `block_alert`)
6. **Select** (`select` / `block_select`)
7. **Checkbox** (`checkbox` / `block_checkbox`)
8. **Textarea** (`textarea` / `block_textarea`)
9. **Input** (`input` / `block_input`)
10. **Radio Group** (`radio-group` / `block_radio_group`)
11. **Switch** (`switch` / `block_switch`)
12. **Input Group** (`input-group` / `block_input_group`, `block_input_group_addon`)
13. **Slider** (`slider` / `block_slider`)
14. **Tabs** (`tabs` / `block_tabs`, `block_tab`)
15. **Theme** (`theme` / `block_theme`)
16. **Icon** (`icon` / `block_icon`)
17. **Separator** (`separator` / `block_separator`)
18. **Skeleton** (`skeleton` / `block_skeleton`)
19. **Spinner** (`spinner` / `block_spinner`)
20. **Empty** (`empty` / `block_empty`)
21. **Dialog** (`dialog` / `block_dialog`)
22. **Popover** (`popover` / `block_popover`)
23. **Tooltip** (`tooltip` / `block_tooltip`)

## Proposed Changes

### Previews
- badge.R
- alert.R
- checkbox.R
- textarea.R
- input.R
- radio_group.R
- switch.R
- input_group.R
- slider.R
- tabs.R
- separator.R
- skeleton.R
- spinner.R
- empty.R
- dialog.R
- popover.R
- tooltip.R
- value_box.R
- select.R
- layout.R
- nav_item.R
- theme.R
- icon.R

### Previews Registry
- `_registry.R` (Add metadata for all 25 components)

## Verification Plan
1. **Pipeline Execution**: Execute `cd docs-site && Rscript scripts/generate-previews.R` to compile all 25 preview pages.
2. **Next.js Production Build**: Run `cd docs-site && npm run build` to compile the entire site.
3. **Playwright E2E Tests**: Run `cd docs-site && npm run test:e2e` to verify route navigation, layout cards, and correct metadata resolution.
