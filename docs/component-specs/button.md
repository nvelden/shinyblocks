# Button

> Shinyblocks function: `block_button()` / `update_block_button()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/button>
> Status: Runtime component; Phase 7 spec refreshed around shipped
> variant/size contract, Shiny receive-only binding, and updater.

## States

- **default** — solid `--primary` fill, `--primary-foreground` label,
  no border. Hover dims to ~90% opacity.
- **secondary** — `--secondary` fill, `--secondary-foreground` label.
- **outline** — transparent fill, 1px `--input` border, `--foreground`
  label. Hover swaps to `--accent` fill + `--accent-foreground`.
- **ghost** — transparent fill, no border, `--foreground` label. Same
  hover treatment as outline.
- **destructive** — `--destructive` fill, `--destructive-foreground`
  label, hover dim.
- **link** — no fill, no border, underline-offset 4 on hover.
- **focus-visible** — runtime-owned 3px ring using `--ring` at 50%
  opacity.
- **invalid** — destructive-tinted ring and border when
  `aria-invalid="true"` is present.
- **disabled** — `pointer-events: none`, opacity `0.5`. Applies across
  all variants.
- **with icon** — leading or trailing 1rem icon, `gap-2` between icon
  and label.
- **size = icon** — square 9-spacing-unit footprint, no horizontal
  padding, label slot typically empty.

## R API

### `block_button(label, variant, size, icon, icon_position, ..., class)`

| Argument | Purpose |
| --- | --- |
| `label` | Button label. Accepts a string, an `htmltools` tag, or a tag list. |
| `variant` | One of `default`, `secondary`, `outline`, `ghost`, `destructive`, `link`. |
| `size` | One of `default`, `sm`, `lg`, `icon`. |
| `icon` | Optional vendored icon name (validated against the icon manifest) or a custom `htmltools` tag. |
| `icon_position` | `inline-start` (default) or `inline-end`. |
| `...` | Additional HTML attributes. Recognized: `id` (enables the runtime binding), `disabled`, `style`, plus any extra HTML attrs passed through. |
| `class` | Extra classes merged onto the wrapper. |

### `update_block_button(session, id, ...)`

Accepts `label`, `variant`, `size`, `icon`, `icon_position`, `disabled`,
`style`, and `class`. Omitted arguments are preserved client-side.
Passing `icon = NULL` or `style = NULL` explicitly clears those props.

## Runtime mapping

| R input | Runtime payload | Notes |
| --- | --- | --- |
| `label` | `props$labelHtml` | Serialized as an HTML fragment. |
| `variant` | `props$variant` | One of the six variants above. |
| `size` | `props$size` | One of `default`/`sm`/`lg`/`icon`. |
| `icon` (name) | `props$icon` | Resolves to the vendored Lucide sprite. |
| `icon` (tag) | embedded via `props$labelHtml` | Custom icon tag gains `data-icon=<position>`. |
| `icon_position` | `props$iconPosition` | Applied to the runtime layout. |
| `disabled` | `props$disabled` | Disables runtime + sets `aria-disabled`. |
| `id` | mount id + receive-only binding | Required to receive `update_block_button()` messages. |
| `style` | mount `style` | Normalised before serialisation. |
| `class` | `className` | Extra wrapper class. |

## Shiny state and update contract

- Pass `id = "..."` (via `...`) to make the button addressable from the
  server. Without an id, the button is purely presentational.
- The runtime registers a `shinyblocks.button` input binding that is
  **receive-only** — it never reports a value to `input$<id>`. Use
  `shiny::actionButton()` if you need click counts; use `block_button()`
  when you want shadcn fidelity plus server-driven updates.
- `update_block_button()` routes through `sendInputMessage()` and only
  notifies on fields that change.

## Token contract

| Visual role | Token |
| --- | --- |
| Default fill | `--primary` |
| Default label | `--primary-foreground` |
| Secondary fill | `--secondary` |
| Secondary label | `--secondary-foreground` |
| Outline border | `--input` |
| Outline / ghost hover fill | `--accent` |
| Outline / ghost hover label | `--accent-foreground` |
| Destructive fill | `--destructive` |
| Destructive label | `--destructive-foreground` |
| Focus ring | `--ring` |
| Invalid ring | `--destructive`, `--border` |
| Radius | `--radius-md` |

## Deliberate divergences from shadcn

- Always emits `type="button"` so the control never accidentally
  submits a parent form. shadcn-react inherits React form semantics;
  htmltools does not, so the type is set explicitly.
- Hover on solid variants uses an opacity dim instead of shadcn's
  `bg-primary/90` colour-mix. Equivalent visual result, simpler CSS.
- The runtime binding is receive-only by design — click counts stay
  with `shiny::actionButton()`.

## Reference screenshot

![Button](_screenshots/button.png)

Captured from <https://ui.shadcn.com/docs/components/button> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
