# Accordion

> Shinyblocks function: `block_accordion()` / `update_block_accordion()`
> Item constructor: `block_accordion_item()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/accordion>
> Status: R-side composition primitive with a local Shiny value bridge
> (issue #91). Collapse mechanics are shared with the nav-group primitive
> and delegated through `shinyblocks.js`.

## States

- **closed** — item body is collapsed (grid-rows `0fr`) and `inert`, so
  its content is out of the tab order and a11y tree.
- **open** — item body expands (grid-rows `1fr`) with an animated height
  transition; the trigger chevron rotates 180°.
- **hover** — the trigger label underlines.
- **focus-visible** — the trigger owns a 3px `--ring` shadow at 50%
  opacity.
- **disabled item** — `data-disabled` item with a `disabled` trigger
  button; cannot be toggled by pointer or keyboard.
- **single vs multiple** — `type = "single"` keeps at most one item open
  (optionally collapsible to none); `type = "multiple"` toggles items
  independently.
- **server-updated** — `update_block_accordion()` opens/closes items by
  value without remounting.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | `block_accordion_item()` sections. |
| `id` | Optional Shiny input id. When set, the open value(s) are reported to `input$<id>`. |
| `type` | `single` (one open at a time) or `multiple` (independent). Create-only. |
| `collapsible` | Single mode only: whether the open item can collapse to none. Ignored (always `TRUE`) for `multiple`. Create-only. |
| `open` | Item value(s) open initially. A single value/`NULL` for single mode, a character vector for multiple. Must match item values. |
| `style` | Inline styles on the `.sb-accordion` wrapper. |
| `class` | Extra classes merged onto the `.sb-accordion` wrapper. |
| `update_block_accordion()` | Server updater that opens/closes items by `open`; `notify = TRUE` also refreshes `input$<id>`. |

`block_accordion_item(value, title, ..., icon, disabled, class)` builds a
single section. `value` is unique per accordion and is the value reported
and targeted by updates. `title` is a string or tag; `...` is arbitrary
body content that stays live in the DOM.

## Rendered contract

`block_accordion()` emits a self-contained DOM tree (no Radix runtime):

- `.sb-accordion[data-sb-accordion="true"]` root carrying
  `data-sb-accordion-input-id` (when `id` is set), `data-type`, and
  `data-collapsible`.
- One `.sb-accordion-item[data-value][data-state]` per item, each with a
  `.sb-accordion-header` `<h3>` wrapping a `.sb-accordion-trigger`
  `<button>` (`aria-expanded`, `aria-controls`, `data-state`) and a
  `.sb-accordion-content` `<div role="region">` (`aria-labelledby`,
  `data-state`, `inert` when closed) wrapping a
  `.sb-accordion-content-inner`.

## Shiny state contract

- When `id` is supplied, the accordion registers as a Shiny InputBinding
  (`shinyblocks.accordion`) keyed by its DOM id. Single mode reports a
  string or `NULL`; multiple mode reports a character vector
  (`character(0)` when nothing is open, via a typed input handler).
- Toggling and keyboard behaviour (Arrow/Home/End moving focus between
  triggers; Enter/Space via the native button) are delegated at the
  document, so state updates for static and dynamically inserted
  accordions without per-element wiring.
- `update_block_accordion(session, input_id, open, notify = TRUE)` opens
  the given item value(s) from the server via `sendInputMessage()`
  (routed by the element's DOM id). Single mode keeps at most one item
  open even if the server oversupplies. `notify = FALSE` moves the state
  silently.

## Token contract

| Visual role | Token |
| --- | --- |
| Item divider | `--border` |
| Trigger text | `--foreground` |
| Chevron | `--muted-foreground` |
| Focus ring | `--ring` |

## Accessibility

- Each trigger is a real `<button>` carrying `aria-expanded` and
  `aria-controls` pointing at its panel; the panel is a
  `role="region"` labelled by its trigger id.
- Closed panels are `inert`, keeping their content out of the tab order
  and a11y tree while the grid-rows height animation still runs.
- The chevron rotation and height transition are suppressed under
  `prefers-reduced-motion: reduce`.

## Deliberate divergences from shadcn

- `block_accordion()` is an R-side helper, not a React/Radix runtime
  component. It emits package-owned markup and lets the local
  `shinyblocks.js` runtime handle toggling/keyboard/ARIA, so panel bodies
  can hold live Shiny outputs.
- `block_collapsible()` (a standalone single trigger + content) is
  deferred; a single-item accordion covers the same need for now.

## Reference screenshot

![Accordion](_screenshots/accordion.png)

Captured from <https://ui.shadcn.com/docs/components/accordion>.
Refresh and update the date whenever shadcn updates the canonical look.
