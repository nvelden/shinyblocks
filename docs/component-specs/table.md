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
- **row format** — `row_format(row, i)` returns per-row `{class, style}` carried
  in `props$rowMeta` and applied to each body `<tr>`.
- **loading** — `update_block_table(loading = TRUE)` renders token-based
  skeleton rows (header stays visible, footer hidden, `tbody aria-busy`).
- **selected hook** — `[data-state="selected"]` row styling is present
  for the future interactive slice; this phase does not set selection state.
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
  registers a **receive-only** Shiny `InputBinding` (`shinyblocks.table`): it owns
  the mount so `sendInputMessage` routes here, exposes no real value (`input$<id>`
  is `null`), and forwards the payload to React via `el.__sbTableReceive`, which
  merges it over current props and re-renders without remounting.
- `class` / `style` are mount-time-only and are not pushed by
  `update_block_table()`; change them by re-rendering the `block_table()`.

## R API

### `block_table(data, columns, caption, max_rows, na, digits, rownames, row_format, striped, hover, bordered, id, class, style)`

| Argument | Purpose |
| --- | --- |
| `data` | Data frame or tibble to render. Required. |
| `columns` | Optional named list of `table_column()` specs. Names must match `data` columns. |
| `caption` | Optional caption rendered below the table. |
| `max_rows` | Optional non-negative row limit; clipped tables render a footer note. |
| `na` | String for missing values. Defaults to `""`. Per-column overrides win. |
| `digits` | Decimal places for default numeric formatting. `NULL` keeps R's `format()`. |
| `rownames` | Render `row.names(data)` as a leading column. Default `FALSE`. |
| `row_format` | `function(row, i)` returning `list(class=, style=)` (or `NULL`) per row. |
| `striped` / `bordered` | Zebra body rows / cell borders. Both default `FALSE`. |
| `hover` | Highlight rows on hover (shadcn base). Default `TRUE`. |
| `id` | Optional input id. Required only to update the table from the server. |
| `class` / `style` | Extra classes / inline style on the runtime mount and table container. |

### `update_block_table(session, id, data, ..., loading)`

| Argument | Purpose |
| --- | --- |
| `session` / `id` | Shiny session and the `block_table(id = )` to refresh. |
| `data`, `columns`, `caption`, `max_rows`, `na`, `digits`, `rownames`, `row_format`, `striped`, `hover`, `bordered` | Formatting arguments matching `block_table()`; applied when `data` is supplied. |
| `loading` | `TRUE` shows skeleton rows; `FALSE` clears the loading state without changing data. |

### `table_column(label, align, format, width, digits, na)`

| Argument | Purpose |
| --- | --- |
| `label` | Optional header label. Defaults to the data column name. |
| `align` | One of `left`, `center`, or `right`. |
| `format` | Optional function applied to the full R column vector. Must return one value per row. When set, `digits` is ignored for this column. |
| `width` | Optional CSS width for the column. |
| `digits` | Per-column decimal places, overriding the table-level `digits`. |
| `na` | Per-column missing-value string, overriding the table-level `na`. |

Missing values render with the `na` string (empty by default) in the payload and
therefore matching cells in the browser.

## Runtime mapping

| R input | Runtime payload |
| --- | --- |
| `data` | `props$rows` as array-of-arrays, after R formatting. |
| `names(data)` + `columns` | `props$columns` array of `{ key, label, align, width }`. |
| `caption` | `props$caption` |
| `max_rows` | `props$truncated` and `props$totalRows` |
| `row_format` | `props$rowMeta` array of `{ class, style }` (or `null`) per row. |
| `striped` / `hover` / `bordered` | `props$striped` / `props$hover` / `props$bordered` → container variant classes. |
| `update_block_table(loading=)` | `props$loading` → skeleton rows. |
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
| Footer surface | `--muted` |
| Style-profile geometry | `--sb-*` table/control spacing tokens |

## Deliberate divergences from shadcn

- **Data-frame API** — shadcn exposes composable JSX table parts;
  shinyblocks v1 accepts a data frame and serializes strict table data
  because Shiny authors usually start from R data objects.
- **Reactive via message, not output binding** — the table refreshes through
  `update_block_table()` over the `runtime_input_update` message path and a
  receive-only input binding, giving `renderTable()`-equivalent reactive data
  refresh without an output-binding/render-function layer. Sorting, pagination,
  row selection, and row actions remain the later data-table/action phase.
- **`max_rows` footer note** — a shinyblocks guardrail for large
  static frames. It uses shadcn's `TableFooter` slot rather than adding
  a variant.

## Reference screenshot

![Table](_screenshots/table.png)

Pending capture from <https://ui.shadcn.com/docs/components/table>.
Refresh and update the date when shadcn updates the canonical look.
