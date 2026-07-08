# Combobox

> Shinyblocks function: `block_combobox()` / `update_block_combobox()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/combobox>
> Status: Runtime form control (Command + Popover composition) with a
> portal-rendered popup and a hidden native `<select>` value bridge.

A searchable [`block_select()`](select.md). It closes the biggest catalog
gap for `selectize` migration: type-to-filter over a long choice list.
It shares the select value bridge, binding contract, and updater shape;
the only additions are the popup's filter box and no-results empty state.

## States

- **default** — custom runtime trigger and portal popup backed by a
  hidden native `<select>` that carries the Shiny value.
- **open** — the popup renders a focused search box above the option
  list; opening focuses the filter input so typing filters immediately.
- **filtering** — a case-insensitive substring match over choice labels
  (falling back to values) narrows the list; the highlight resets to the
  first match on each keystroke.
- **empty** — when the filter matches nothing, the list is replaced by
  the `empty_message` text (default `"No results found."`).
- **multiple** — `multiple = TRUE` emits a hidden native
  `<select multiple>` mirror, renders selections as removable chips, and
  initializes to a character vector (default: no selection). `Backspace`
  in an empty filter box removes the last chip.
- **changed** — user selection updates `input$<id>` through the
  component-specific `shinyblocks.combobox` input binding.
- **server-updated** — `update_block_combobox()` can update value,
  choices, placeholder, search/empty text, disabled state, width, class,
  size, and invalid.
- **focus-visible** — 3px `--ring` shadow on the visible trigger shell.
- **invalid** — destructive ring when `invalid = TRUE`.
- **disabled** — runtime disables the rendered control and preserves
  server updateability.
- **sizes** — `sm`, `default`, and `lg` adjust trigger height/padding.

## R API

### `block_combobox(input_id, choices, selected, placeholder, search_placeholder, empty_message, disabled, width, class, size, style, invalid, multiple, max_items)`

| Argument | Purpose |
| --- | --- |
| `input_id` | Shiny input id used for `input$<id>` and update messages. |
| `choices` | Character vector or named vector of labels/values. Values must be unique and non-empty; `""` is reserved as the placeholder sentinel. |
| `selected` | Initial selected value. In multiple mode, a character vector. |
| `placeholder` | Empty-value prompt shown on the trigger before selection. |
| `search_placeholder` | Placeholder in the type-to-filter box. Defaults to `"Search..."`. |
| `empty_message` | Text shown when the filter matches no choices. Defaults to `"No results found."`. |
| `disabled` | Disables browser interaction while keeping server updates possible. |
| `width` | CSS width for the runtime combobox wrapper. |
| `style` | Inline style on the runtime wrapper (create-only). |
| `class` | Additional class merged onto the runtime wrapper. |
| `size` | One of `default`, `sm`, or `lg`. |
| `invalid` | Applies `aria-invalid` and destructive border/ring styling. |
| `multiple` | Enables multiple-selection value semantics (create-only). |
| `max_items` | Optional selected-item cap for multiple mode (create-only). |

### `update_block_combobox(session, input_id, ...)`

Accepts `selected`, `choices`, `placeholder`, `search_placeholder`,
`empty_message`, `disabled`, `width`, `class`, `size`, and `invalid`, with
optional `notify` semantics. `multiple`, `max_items`, and `style` are
create-only. `selected = NULL` clears single comboboxes to the empty
placeholder value (`""`); `selected = character(0)` clears multiple
comboboxes. A vector `selected` reaching a single combobox collapses to its
first element.

## Runtime mapping

| R input | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | mount id | Drives `input$<id>` and message routing. |
| `choices` | `props$choices` | Array of `{ value, label }`. |
| `search_placeholder` | `props$searchPlaceholder` | Filter-box placeholder. |
| `empty_message` | `props$emptyMessage` | No-results text. |
| `selected` | `state$value` | Scalar (single) or array (multiple). |
| binding | `binding.type` | `shinyblocks.combobox`. |

## Accessibility

- The filter box is `role="combobox"` with `aria-expanded`,
  `aria-controls` pointing at the listbox, `aria-activedescendant` on the
  highlighted option, and `aria-autocomplete="list"`.
- The option list is `role="listbox"` (`aria-multiselectable="true"` in
  multiple mode); options are `role="option"` with `aria-selected`.
- Keyboard: `ArrowDown`/`ArrowUp`/`Home`/`End` move the highlight,
  `Enter` commits (single) or toggles (multiple), `Escape` closes and
  returns focus to the trigger, `Backspace` on an empty filter removes the
  last chip in multiple mode.

## Divergence from shadcn

shadcn composes an unstyled `Command` inside a `Popover` with an app-owned
trigger `Button`. shinyblocks ships a single opinionated control: the
trigger, filter, list, chips, and hidden native value source are one
package-owned runtime component so app authors write only R.
