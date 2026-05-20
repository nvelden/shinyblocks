# Agent Plan: Showcase Playgrounds & API Tables

- **Goal**: Implement Interactive Playgrounds, API Reference Tables, and Parity Fixtures in the Showcase Shiny App for the remaining 13 components (`badge`, `alert`, `icon`, `separator`, `skeleton`, `spinner`, `empty`, `card`, `value-box`, `tabs`, `theme`, `layout`, `nav-item`).
- **Assumptions**: 
  - Standard showcase grid layout using `block_field_set()`, a left flex preview/code column, and a right background-styled control column.
  - Interactive server callbacks defined in separate scoped helper files under `inst/showcase/R/server_<name>.R`.
- **Proposed API**: 
  - Define custom `register_<name>_showcase()` functions returning table data and UI outputs, sourced in `inst/showcase/app.R`.
- **Files to Edit**:
  - `inst/showcase/app.R` (main registration)
  - `inst/showcase/R/server_*.R` (new server handlers)
  - `inst/showcase/R/examples/*.R` (example page markups)
- **Tests/Checks**:
  - `make check-fast` for lints, style compilations, and tests.
  - Run showcase server and interactively verify parameter variations.
- **Open Questions**: None.
