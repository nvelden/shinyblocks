# Table

> Shinyblocks function: `block_table()` / `table_column()` / `update_block_table()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/table>
> Status: Runtime component; shadcn `table.tsx` port with R-side data-frame
> serialization and a reactive server-side update path (issue #51).

## States

- **default** — native `<table>` rendered inside an overflow-x container.
- **caption** — optional caption rendered below the table, matching
  shadcn's `caption-bottom` placement.
- **hover row** — rows use the shadcn muted hover treatment, gated behind the
  `sb-table--hover` container class (`hover = TRUE` by default).
- **striped / bordered** — optional zebra body rows (`sb-table--striped`) and
  cell borders (`sb-table--bordered`); both off by default.
- **row format** — `row_format(row, i)` returns per-row `{intent, emphasis,
  class, style}` carried in `props$rowMeta` and applied to each body `<tr>`.
- **styling intent** — header, column, row, and single cells can carry a
  theme-safe `intent` (`muted/primary/secondary/destructive/success/warning/
  accent`) with an `emphasis` (`text/soft/solid`), rendered as `data-intent` /
  `data-emphasis` attributes resolved entirely through theme tokens. See
  [Styling intents](#styling-intents-issue-53).
- **loading** — `update_block_table(loading = TRUE)` renders token-based
  skeleton rows (header stays visible, footer hidden, `tbody aria-busy`).
- **selectable / selected** — with `selection = "single"` / `"multiple"`, body
  rows become clickable (`sb-table-row--selectable`, `cursor: pointer`,
  `tabIndex=0`, Enter/Space activation, themed `--ring` focus ring) and selected
  rows get `sb-table-row--selected` (an `--accent` tint that wins over hover and
  striped backgrounds) plus `aria-selected`. See
  [Row selection](#row-selection).
- **truncated** — `max_rows` clips rendered rows and adds a `tfoot`
  note showing the displayed and total row counts.
- **empty data** — zero-row data frames still render header slots and
  an empty body without falling back to host table widgets.

## Reactive model (issue #51)

`block_table()` and `update_block_table()` share one internal serializer,
`table_build_payload()`, so the initial UI render and every server-side refresh
produce identical payloads — data loading, column formatting, and row formatting
can never drift between the two paths.

- Author renders `block_table(data, id = "tbl", ...)` once in the UI, then pushes
  refreshes from `observe()` / `observeEvent()` with
  `update_block_table(session, "tbl", data = ..., loading = ...)`.
- Delivery reuses the runtime `runtime_input_update` message path. The table
  registers a Shiny `InputBinding` (`shinyblocks.table`): it owns the mount so
  `sendInputMessage` routes here and forwards the payload to React via
  `el.__sbTableReceive`, which merges it over current props and re-renders
  without remounting. With `selection = "none"` (the default) it reports no
  value (`input$<id>` is `null`), preserving the original receive-only behavior;
  see [Row selection](#row-selection) for the selectable mode.
- `class` / `style` are mount-time-only and are not pushed by
  `update_block_table()`; change them by re-rendering the `block_table()`.

## Row selection

`block_table(selection = )` ports the DT row-selection idiom so DT code carries
over. With `"single"` (one row, click again to deselect) or `"multiple"` (toggle
any number) the runtime tracks the selection in React state, writes it to the
`el.__sbTableValue` expando, and dispatches `sb:table-change`. The binding then
publishes:

- `input$<id>` and `input$<id>_rows_selected` — integer vector of the selected
  1-based row indices (the bare id is a shinyblocks convenience; `_rows_selected`
  is the DT-compatible name).
- `input$<id>_row_last_clicked` — 1-based index of the most recent click
  (`priority: "event"`, so re-clicking the same row re-fires).
- `input$<id>_cell_clicked` — `list(row, col, value)` for the most recent click,
  where `col` is the 1-based rendered column index and `value` is the displayed
  cell text (`priority: "event"`).

Seed an initial selection at mount with `block_table(selected = c(1, 3))`, or
drive it from the server with `update_block_table(selected = )` (pass
`integer(0)` to clear) and `update_block_table(selection = )` to switch modes.
Indices are 1-based and refer to rendered rows; for `max_rows`-truncated tables
they match the original data rows (truncation keeps the leading rows).

## Styling intents (issue #53)

Authors style any scope — header, column, row, single cell, and the value inside
a cell — in pure R, without breaking the theme system.

- **Intent enum** is the headline API across every scope:
  `muted`, `primary`, `secondary`, `destructive`, `success`, `warning`, `accent`
  — exactly the existing token families. It renders as a `data-intent` attribute
  resolved by token-only CSS (never a literal color), so an intent tracks the
  active preset, light/dark, and style profile automatically.
- **Emphasis axis** `text` (default, colored text) / `soft` (tinted background) /
  `solid` (filled chip), rendered as `data-emphasis`.
- **Precedence** is **cell > column**: a `cellMeta[i][j]` intent/emphasis wins
  over the column-level `intent`/`emphasis`; `class`/`style` layer on top.
- **Vectorized cell styling** — `cell_intent` / `cell_emphasis` / `cell_class` /
  `cell_style` are `function(value)` callbacks evaluated once over the whole
  (unformatted) column vector and returning one entry per row (length-1 results
  recycle). This matches the column-at-a-time formatting pipeline and avoids
  per-cell closures.
- **`cellMeta` clear-on-merge** — `cellMeta` is **always emitted** on any
  data-bearing payload (empty `{}` objects where unstyled). Because the runtime
  merges partial `update_block_table()` payloads over current props, omitting it
  would leave stale per-cell styling — the same rule already applied to `rowMeta`.
- **Escape hatch** — `class` / `style` (and the `header_*` / `cell_*` variants)
  remain available. You own theme-correctness here; prefer `var(--token)` over
  literal colors. Values stay escaped text — no raw-HTML cell injection.

## R API

### `block_table(data, columns, caption, max_rows, na, digits, rownames, row_format, striped, hover, bordered, selection, selected, id, class, style)`

| Argument | Purpose |
| --- | --- |
| `data` | Data frame or tibble to render. Required. |
| `columns` | Optional named list of `table_column()` specs. Names must match `data` columns. |
| `caption` | Optional caption rendered below the table. |
| `max_rows` | Optional non-negative row limit; clipped tables render a footer note. |
| `na` | String for missing values. Defaults to `""`. Per-column overrides win. |
| `digits` | Decimal places for default numeric formatting. `NULL` keeps R's `format()`. |
| `rownames` | Render `row.names(data)` as a leading column. Default `FALSE`. |
| `row_format` | `function(row, i)` returning `list(intent=, emphasis=, class=, style=)` (any subset, or `NULL`) per row. |
| `striped` / `bordered` | Zebra body rows / cell borders. Both default `FALSE`. |
| `hover` | Highlight rows on hover (shadcn base). Default `TRUE`. |
| `selection` | Row-selection mode: `"none"` (default), `"single"`, or `"multiple"`. See [Row selection](#row-selection). |
| `selected` | Integer vector of 1-based row indices to select on load (requires `selection != "none"`). |
| `id` | Optional input id. Required to update the table from the server or to use row `selection`. |
| `class` / `style` | Extra classes / inline style on the runtime mount and table container. |

### `update_block_table(session, id, data, ..., loading, selection, selected)`

| Argument | Purpose |
| --- | --- |
| `session` / `id` | Shiny session and the `block_table(id = )` to refresh. |
| `data`, `columns`, `caption`, `max_rows`, `na`, `digits`, `rownames`, `row_format`, `striped`, `hover`, `bordered` | Formatting arguments matching `block_table()`; applied when `data` is supplied. |
| `loading` | `TRUE` shows skeleton rows; `FALSE` clears the loading state without changing data. |
| `selection` | Optional new selection mode. `NULL` leaves it unchanged. |
| `selected` | Optional 1-based row indices to select; `integer(0)` clears. `NULL` leaves it unchanged. |

### `table_column(label, align, format, width, digits, na, intent, emphasis, class, style, header_*, cell_*)`

| Argument | Purpose |
| --- | --- |
| `label` | Optional header label. Defaults to the data column name. |
| `align` | One of `left`, `center`, or `right`. |
| `format` | Optional function applied to the full R column vector. Must return one value per row. When set, `digits` is ignored for this column. |
| `width` | Optional CSS width for the column. |
| `digits` | Per-column decimal places, overriding the table-level `digits`. |
| `na` | Per-column missing-value string, overriding the table-level `na`. |
| `intent` | Token-backed styling intent applied to every `<td>` in the column. One of the intent enum. |
| `emphasis` | How `intent` renders: `text` (default), `soft`, or `solid`. |
| `class` / `style` | Escape-hatch class / inline style on each `<td>`. |
| `header_intent` / `header_emphasis` / `header_class` / `header_style` | Same controls applied to the column `<th>`. |
| `cell_intent` / `cell_emphasis` / `cell_class` / `cell_style` | `function(value)` callbacks over the column vector returning one entry per row; per-cell results win over the column-level styling. |

Missing values render with the `na` string (empty by default) in the payload and
therefore matching cells in the browser.

## Runtime mapping

| R input | Runtime payload |
| --- | --- |
| `data` | `props$rows` as array-of-arrays, after R formatting. |
| `names(data)` + `columns` | `props$columns` array of `{ key, label, align, width }`. |
| `caption` | `props$caption` |
| `max_rows` | `props$truncated` and `props$totalRows` |
| `row_format` | `props$rowMeta` array of `{ intent, emphasis, class, style }` (or `null`) per row. |
| `table_column(intent/emphasis/class/style)` | `props$columns[].intent / emphasis / class / style`. |
| `table_column(header_*)` | `props$columns[].headerIntent / headerEmphasis / headerClass / headerStyle`. |
| `table_column(cell_*)` | `props$cellMeta` matrix of `{ intent, emphasis, class, style }` (or `{}`) per cell; always emitted (clear-on-merge). |
| `striped` / `hover` / `bordered` | `props$striped` / `props$hover` / `props$bordered` → container variant classes. |
| `update_block_table(loading=)` | `props$loading` → skeleton rows. |
| `selection` / `selected` | `props$selection` (omitted when `"none"`) → selectable rows; `props$selected` → initial 1-based selection. Selection changes report `input$<id>` / `_rows_selected` / `_row_last_clicked` / `_cell_clicked`. |
| `class` / `style` | `className` / mount `style` (mount-time only). |

Runtime slots mirror shadcn: `table-container`, `table`,
`table-header`, `table-body`, `table-footer`, `table-row`,
`table-head`, `table-cell`, and `table-caption`.

## Token contract

| Visual role | Token |
| --- | --- |
| Table text | `--foreground` |
| Header and caption text | `--muted-foreground` |
| Row borders | `--border` |
| Row hover / selected surface | `--muted` |
| Striped (zebra) rows | `--muted` |
| Bordered cells | `--border` |
| Loading skeleton shimmer | `--muted` (shared `shinyblocks-pulse` keyframe) |
| Selected row | `--accent` (via `color-mix`, wins over hover/striped) |
| Selectable row focus ring | `--ring` |
| Footer surface | `--muted` |
| Intent text / soft / solid | `--<intent>` + `--<intent>-foreground` (normalized to a per-intent ink / surface / on-chip text; `soft` tints via `color-mix`) |
| Style-profile geometry | `--sb-*` table/control spacing tokens |

## Deliberate divergences from shadcn

- **Data-frame API** — shadcn exposes composable JSX table parts;
  shinyblocks v1 accepts a data frame and serializes strict table data
  because Shiny authors usually start from R data objects.
- **Reactive via message, not output binding** — the table refreshes through
  `update_block_table()` over the `runtime_input_update` message path and an
  input binding, giving `renderTable()`-equivalent reactive data refresh without
  an output-binding/render-function layer. Sorting, pagination, and row actions
  remain the later data-table/action phase.
- **DT-style selection inputs** — row selection follows the DT idiom
  (`_rows_selected` / `_row_last_clicked` / `_cell_clicked`) so DT code ports
  over, but indices are emitted from the rendered runtime rows rather than a
  DataTables instance. The bare `input$<id>` additionally mirrors
  `_rows_selected` as a shinyblocks convenience; `cell_clicked$col` is a 1-based
  rendered column index (including a leading `rownames` column when present).
- **`max_rows` footer note** — a shinyblocks guardrail for large
  static frames. It uses shadcn's `TableFooter` slot rather than adding
  a variant.

## Reference screenshot

![Table](_screenshots/table.png)

Pending capture from <https://ui.shadcn.com/docs/components/table>.
Refresh and update the date when shadcn updates the canonical look.
