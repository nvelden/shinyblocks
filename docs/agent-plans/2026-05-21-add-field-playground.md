# Plan — Add `block_field` components playground

This plan details the addition of an interactive playground, API reference table, and parity fixtures for the `block_field` component suite in the showcase gallery.

## Goals
- Create a dedicated "Field" showcase page containing an **Interactive Playground**, **API Reference Table**, and **Parity Fixtures** for the seven field primitives: `block_field()`, `block_field_group()`, `block_field_label()`, `block_field_description()`, `block_field_set()`, `block_field_legend()`, and `block_field_invalid()`.
- Align the layout using the premium two-column docked sidebar layout.
- Ensure the API Reference table is positioned above the Parity Fixtures section.
- Register the section in `inst/showcase/app.R` and source its server-side reactive observers.

## Proposed API / Playground
We will implement an interactive form layout inside the playground:
- **Left-hand options panel** (under `background: var(--muted)`):
  - **Field Set Controls**: Fieldset Legend (text input).
  - **First Name Field**: Label and Description (text inputs).
  - **Email Field**: Label and Description (text inputs).
  - **Password Field**: Label and Error message (text inputs), and Invalid toggle (checkbox).
  - **Styling**: Option to use a custom dashed border class.
- **Right-hand live canvas**:
  - Live Preview container.
  - Form rendering standard inputs inside customized field constructs.
  - UI Definition copyable R code.

## Files to Edit / Create

### 1. [NEW] [field.R](file:///Users/nielsvandervelden/Documents/2026%20github/shinyblocks/inst/showcase/R/examples/field.R)
The layout file for the showcase section:
- A `block_field_set("Interactive Playground")` with the flex-wrap container structure matching standard premium playgrounds.
- Left-hand side control panel nested under standard categories: "Form Layout", "State", and "Styling".
- Right-hand side preview canvas with `shiny::uiOutput("showcase_field_preview_ui")` and code snippet block `shiny::uiOutput("showcase_field_preview_code")`.
- **API Reference** table container `shiny::tableOutput("showcase_field_api_table")`.
- **Parity Fixtures** section containing static examples of fields in different configurations.

### 2. [NEW] [server_field.R](file:///Users/nielsvandervelden/Documents/2026%20github/shinyblocks/inst/showcase/R/server_field.R)
The reactive logic file for the showcase section:
- `register_field_showcase(input, output, session)` registration function.
- Reactive preview generator `output$showcase_field_preview_ui` assembling the `block_field_set`, `block_field_group`, `block_field`, and invalid error logic based on user selections.
- Reactive code generator `output$showcase_field_preview_code` displaying clean, copy-pasteable R code.
- Detailed API Reference table describing all 7 field components and their arguments.

### 3. [MODIFY] [app.R](file:///Users/nielsvandervelden/Documents/2026%20github/shinyblocks/inst/showcase/app.R)
- Source `R/server_field.R` at the top.
- Register the "field" section in the `sections` list (e.g. directly before "button" or after "input-group" under the "Form Fields" category).
- Call `register_field_showcase(input, output, session)` inside the main server handler.

## Verification Plan
1. **Automated Tests**:
   - Run `Rscript -e "devtools::test()"` to ensure no regressions.
2. **Manual Verification**:
   - Launch showcase app `make showcase` and navigate to the new `#field` route.
   - Test changing the legend, label texts, description texts, toggling the invalid state, and applying the custom dashed-border class.
   - Verify that both light and dark mode render beautifully, and that the API Reference comes directly before the Parity Fixtures.
