# Select

> Shinyblocks function: `block_select()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/select>

## States

- **default** — runtime-rendered native select with bordered trigger
  surface and package-owned chevron.
- **changed** — user selection updates `input$<id>` through the
  runtime Shiny bridge.
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
| `choices` | Character vector or named vector of labels/values. |
| `selected` | Initial selected value. |
| `placeholder` | Empty-value prompt shown before selection. |
| `disabled` | Disables browser interaction while keeping server updates possible. |
| `width` | CSS width for the runtime select wrapper. |
| `class` | Additional class merged onto the runtime select wrapper. |
| `size` | One of `default`, `sm`, or `lg`. |
| `invalid` | Applies `aria-invalid` and destructive border/ring styling. |

## Deliberate divergences from shadcn

- The current runtime spike uses a package-owned native `<select>`
  rather than Radix Select content/portal primitives. This removes the
  Shiny/selectize wrapper while keeping a small first stateful runtime
  contract; Radix open/content behavior is deferred to the overlay phase.
- `selected = NULL` in `update_block_select()` clears to the empty
  placeholder value (`""`) because browser selects do not have a stable
  JavaScript `null` value.

## Reference screenshot

![Select](_screenshots/select.png)

Captured from <https://ui.shadcn.com/docs/components/select> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
