# ADR 0014: Wrap by Default for Form Inputs

## Status

Superseded by [ADR 0017](0017-full-runtime-port.md) for future
component work (2026-05-12). Existing wrapped controls are migration
scaffolding until the runtime implementation replaces them.

## Context

`shinyblocks` ports the shadcn/ui design system into an R-first Shiny
package. That does **not** mean every form control should be rebuilt
from scratch in package-owned HTML and JavaScript.

Shiny already provides stable input bindings, updater functions, and a
well-understood reactive contract for controls like text inputs,
selects, checkboxes, radios, and textareas. Re-implementing those
controls one by one would create a parallel input runtime that the
package would need to maintain across browser changes, Shiny releases,
and CRAN constraints.

The short-lived first implementation of `block_select()` proved the
maintenance risk. A custom trigger/menu/listbox can be made to look
close to shadcn, but it duplicates selection state, keyboard behavior,
and focus management that Shiny + Selectize already handle. It also
creates drift risk with `updateSelectInput()` and related server-side
helpers.

At the same time, some shadcn interactions are not reachable through
thin wrappers alone. A command-palette combobox, chip-based multi-select,
or calendar-backed date picker have interaction models that exceed what
plain wrapper CSS can faithfully express.

## Decision

For form inputs, `shinyblocks` will **wrap by default** and
**re-implement by exception**.

### Default rule

When Shiny already provides a control with the right reactive contract,
the `shinyblocks` API should wrap that control and restyle it with:

- semantic token-based CSS;
- additive wrapper markup (`block_field()`, `block_input_group()`,
  etc.);
- ARIA/state attributes layered on top of the existing binding;
- small additive JavaScript only when needed for polish, not for
  replacing the core input model.

This is the default for:

- text inputs;
- textareas;
- native/selectize-backed selects;
- checkboxes;
- radio groups;
- simple boolean toggles when a wrapper can map onto an existing input.

### Exception rule

The package may re-implement a form control only when a thin wrapper
cannot faithfully reach the corresponding shadcn interaction model.

Examples that likely qualify:

- combobox with command-style filtering;
- multi-select with removable chips/tokens;
- calendar-backed date picker;
- OTP/segmented code entry;
- other controls whose keyboard and focus model materially differ from
  the underlying Shiny primitive.

Every exception requires a dedicated ADR that:

1. states why wrapping is insufficient;
2. names the Shiny contract being replaced or supplemented;
3. justifies the JavaScript and accessibility maintenance cost;
4. defines the updater/reactivity story.

## Consequences

**Positive:**

- Preserves Shiny updater compatibility (`updateSelectInput()` and
  similar helpers) wherever possible.
- Keeps most controls on a stable and familiar reactive substrate.
- Makes theming the primary job and input reimplementation the
  exception.
- Reduces long-term JavaScript maintenance pressure.

**Negative / accepted costs:**

- Some wrapped controls will only approximate shadcn visually rather
  than reproducing the exact DOM shape upstream uses.
- Styling must account for upstream widget HTML, especially Selectize.
- The package will need a clear per-control line between "good enough
  via wrapper" and "needs a dedicated implementation."

## Initial Application

- `block_field_*()` and `block_input_group_*()` remain wrapper
  primitives.
- `block_select()` is refactored from a custom headless select back to a
  thin wrapper around Shiny's select/selectize path.
- Future advanced controls must justify any custom runtime through new
  ADRs rather than following `block_select()` as precedent.
