# Table

> Shinyblocks function: `block_table()` / `table_column()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/table>
> Status: Runtime presentational component; static v1 port of shadcn
> `table.tsx` with R-side data-frame serialization.

## States

- **default** — native `<table>` rendered inside an overflow-x container.
- **caption** — optional caption rendered below the table, matching
  shadcn's `caption-bottom` placement.
- **hover row** — rows use the shadcn muted hover treatment.
- **selected hook** — `[data-state="selected"]` row styling is present
  for the future interactive slice; v1 does not set selection state.
- **truncated** — `max_rows` clips rendered rows and adds a `tfoot`
  note showing the displayed and total row counts.
- **empty data** — zero-row data frames still render header slots and
  an empty body without falling back to host table widgets.

## R API

### `block_table(data, columns, caption, max_rows, class, style)`

| Argument | Purpose |
| --- | --- |
| `data` | Data frame or tibble to render. Required. |
| `columns` | Optional named list of `table_column()` specs. Names must match `data` columns. |
| `caption` | Optional caption rendered below the table. |
| `max_rows` | Optional non-negative row limit; clipped tables render a footer note. |
| `class` / `style` | Extra classes / inline style on the runtime mount and table container. |

### `table_column(label, align, format, width)`

| Argument | Purpose |
| --- | --- |
| `label` | Optional header label. Defaults to the data column name. |
| `align` | One of `left`, `center`, or `right`. |
| `format` | Optional function applied to the full R column vector. Must return one value per row. |
| `width` | Optional CSS width for the column. |

Missing values render as empty strings in the payload and therefore
empty cells in the browser.

## Runtime mapping

| R input | Runtime payload |
| --- | --- |
| `data` | `props$rows` as array-of-arrays, after R formatting. |
| `names(data)` + `columns` | `props$columns` array of `{ key, label, align, width }`. |
| `caption` | `props$caption` |
| `max_rows` | `props$truncated` and `props$totalRows` |
| `class` / `style` | `className` / mount `style` |

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
| Footer surface | `--muted` |
| Style-profile geometry | `--sb-*` table/control spacing tokens |

## Deliberate divergences from shadcn

- **Data-frame API** — shadcn exposes composable JSX table parts;
  shinyblocks v1 accepts a data frame and serializes strict table data
  because Shiny authors usually start from R data objects.
- **Static v1** — no Shiny input binding, no `update_block_table()`,
  no sorting, no pagination, and no row actions. Those belong to the
  later data-table/action phase.
- **`max_rows` footer note** — a shinyblocks guardrail for large
  static frames. It uses shadcn's `TableFooter` slot rather than adding
  a variant.

## Reference screenshot

![Table](_screenshots/table.png)

Pending capture from <https://ui.shadcn.com/docs/components/table>.
Refresh and update the date when shadcn updates the canonical look.
