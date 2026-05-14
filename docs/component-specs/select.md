# Select

> Shinyblocks function: `block_select()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/select>

## States

- **default** — custom runtime trigger and portal popup backed by a
  hidden native `<select>` that carries the Shiny value.
- **changed** — user selection updates `input$<id>` through the
  component-specific Shiny input binding.
- **server-updated** — `update_block_select()` can update value,
  choices, placeholder, and disabled state.
- **focus-visible** — 3px `--ring` shadow on the visible trigger shell.
- **invalid** — destructive ring when the runtime select carries
  `aria-invalid="true"`.
- **disabled** — runtime disables the rendered control and preserves
  server updateability.
- **sizes** — `sm`, `default`, and `lg` adjust the trigger height and
  horizontal padding while keeping typography aligned with shadcn.

## Token contract

| Visual role | Token |
| --- | --- |
| Trigger surface | `--background` |
| Trigger border | `--input` |
| Trigger text | `--foreground` |
| Chevron | `--muted-foreground` |
| Focus ring | `--ring` |
| Invalid ring | `--destructive`, `--border` |

## Exposed shinyblocks options

| Argument | Purpose |
| --- | --- |
| `input_id` | Shiny input id used for `input$<id>` and update messages. |
| `choices` | Character vector or named vector of labels/values. Values must be unique and non-empty; `""` is reserved as the placeholder sentinel. |
| `selected` | Initial selected value. |
| `placeholder` | Empty-value prompt shown before selection. |
| `disabled` | Disables browser interaction while keeping server updates possible. |
| `width` | CSS width for the runtime select wrapper. |
| `class` | Additional class merged onto the runtime select wrapper. |
| `size` | One of `default`, `sm`, or `lg`. |
| `invalid` | Applies `aria-invalid` and destructive border/ring styling. |

## Runtime DOM Contract

- The visible UI is a package runtime overlay with shadcn-aligned
  trigger, content, viewport, item, and selected indicator parts.
- A hidden `<select id="{input_id}" class="sb-select-native">` remains
  in the runtime mount as the canonical Shiny value source.
- `ShinyblocksSelectBinding` is registered as `shinyblocks.select`.
  It reads and updates the hidden native control while routing server
  messages through `receiveMessage()`.
- `selected = NULL` in `update_block_select()` clears to the empty
  placeholder value (`""`) because browser selects do not have a stable
  JavaScript `null` value.

## Stable Styling Hooks

Use the `sb-*` hooks for package theming and downstream overrides:

- `.sb-select`
- `.sb-select-native`
- `.sb-select-trigger`
- `.sb-select-trigger-icon`
- `.sb-select-content`
- `.sb-select-viewport`
- `.sb-select-item`
- `.sb-select-item-indicator`

The runtime also mirrors shadcn `data-slot` attributes for parity
tooling, but those are not the primary public styling hooks.

## Reference screenshot

![Select](_screenshots/select.png)

Captured from <https://ui.shadcn.com/docs/components/select> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
