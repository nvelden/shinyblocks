# Dropdown Menu

> Shinyblocks function: `block_dropdown_menu()` /
> `update_block_dropdown_menu()`
> Item constructors: `dropdown_menu_item()`, `dropdown_menu_label()`,
> `dropdown_menu_separator()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/dropdown-menu>
> Status: Runtime overlay component (issue #86).

## States

- **closed** — only the trigger button is rendered.
- **open** — the menu renders into `[data-shinyblocks-portal-root]` and
  is positioned relative to the trigger.
- **item hover/focus** — the active row carries `data-highlighted` and
  receives DOM focus (roving `tabindex`).
- **disabled item** — `data-disabled` row; skipped by pointer, keyboard,
  and typeahead.
- **destructive item** — `data-variant="destructive"` row painted with
  the `--destructive` token.
- **dismissed by interaction** — outside pointer down, `Escape`, `Tab`,
  or choosing an item closes the menu.
- **server-updated** — `update_block_dropdown_menu()` can open/close,
  replace items, reposition, disable the trigger, and update
  style/class without remounting.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `id` | `input_id` / runtime mount id | Optional; enables Shiny reporting. |
| `trigger` | `props$triggerHtml` | String label or serialized tag. |
| `label` | `props$triggerLabel` | Accessible name for the trigger. |
| `...` | `props$items` | Serialized item/label/separator parts. |
| `side` | `props$side` | Fixed-position side. |
| `align` | `props$align` | Alignment along the side. |
| `trigger_variant` | `props$triggerVariant` | Button variant for a string trigger. |
| `disabled` | `props$disabled` | Disables the trigger. |
| `style` | `props$contentStyle` | Inline content style object. |
| `class` | `props$contentClass` | Extra class on content. |

Each `props$items` entry is `{ type: "item" | "label" | "separator", ... }`.
Items carry `value`, `labelHtml`, `iconName`/`iconHtml`, `shortcut`,
`disabled`, and `variant`.

## Shiny State And Update Contract

- Without `id`, the menu is client-only and registers no input binding.
- With `id`, choosing an item reports its `value` to `input$<id>` as an
  **event** (`priority: "event"`), so choosing the same item twice fires
  again — treat it like an action button that carries a value.
- The runtime routes `sendInputMessage()` payloads to
  `el.__sbDropdownMenuReceive`.
- `update_block_dropdown_menu()` accepts `items`, `open`, `side`,
  `align`, `disabled`, `style`, and `class`.
- Updates never notify an input event; the reported value is the chosen
  item, never the open state.
- Passing `class = NULL` or `style = NULL` clears that field.

## Accessibility

- Trigger is a real `<button>` with `aria-haspopup="menu"`,
  `aria-expanded`, and `aria-controls` when open.
- Open content carries `role="menu"`; rows carry `role="menuitem"` (or
  `role="separator"`); labels are presentational headings.
- Keyboard: `ArrowUp`/`ArrowDown` cycle enabled items, `Home`/`End` jump
  to first/last, `Enter`/`Space` activate, `Escape`/`Tab` close, and
  printable characters typeahead to the next matching label.
- Roving `tabindex` keeps DOM focus on the active row; disabled items are
  skipped.
- Closing returns focus to the element that opened the menu.

## Token Contract

| Visual role | Token |
| --- | --- |
| Surface | `--popover` |
| Foreground | `--popover-foreground` |
| Border | `--border` |
| Active row | `--accent` / `--accent-foreground` |
| Destructive row | `--destructive` |
| Label / shortcut | `--muted-foreground` |

## Deliberate Divergences From Shadcn

- React runtime is package-local (`component = "dropdown-menu"`);
  shinyblocks does not ship `@radix-ui/react-dropdown-menu`.
- Checkbox items, radio groups, and sub-menus are deferred to follow-up
  work (see issue #86 discussion). This slice ships action items,
  labels, and separators.
- Positioning uses `getBoundingClientRect()` and fixed coordinates;
  Floating UI flip/shift/collision handling and arrows are deferred.
- Item content is serialized HTML, not live Shiny-bound children.
- No animated open/close transition yet.

## Reference Screenshot

Pending — capture and add under `_screenshots/dropdown-menu.png`.
