import { useEffect, useState } from "react";
import { classNames } from "./shared.jsx";

function alignment(value) {
  return ["left", "center", "right"].includes(value) ? value : "left";
}

function headStyle(column) {
  return {
    textAlign: alignment(column && column.align),
    ...(column && column.width ? { width: column.width } : {}),
    ...(column && column.headerStyle ? column.headerStyle : {})
  };
}

// Theme-safe styling resolves cell-level metadata over column-level defaults; the
// runtime only ever forwards the `data-intent`/`data-emphasis` attributes, never a
// literal color, so the token CSS in 09-table.css tracks the active theme.
function styleAttrs(intent, emphasis) {
  if (!intent) return {};
  return { "data-intent": intent, "data-emphasis": emphasis || "text" };
}

function bodyCellStyle(column, meta) {
  return {
    textAlign: alignment(column && column.align),
    ...(column && column.style ? column.style : {}),
    ...(meta && meta.style ? meta.style : {})
  };
}

export function Table({ payload, root }) {
  const [props, setProps] = useState(() => payload.props || {});

  // Receive-only update path. `update_block_table()` pushes a fresh (possibly
  // partial) props payload through the runtime `table` InputBinding, which
  // forwards it here. Merge it over the current props so a server-side refresh
  // re-renders without remounting.
  useEffect(() => {
    if (!root) return undefined;
    root.__sbTableReceive = (data) => {
      const next = data || {};
      setProps((prev) => ({ ...prev, ...next }));
    };
    return () => {
      delete root.__sbTableReceive;
    };
  }, [root]);

  const columns = Array.isArray(props.columns) ? props.columns : [];
  const rows = Array.isArray(props.rows) ? props.rows : [];
  const rowMeta = Array.isArray(props.rowMeta) ? props.rowMeta : [];
  const cellMeta = Array.isArray(props.cellMeta) ? props.cellMeta : [];
  const isTruncated = props.truncated === true;
  const isLoading = props.loading === true;
  // Keep the table footprint stable while loading: reuse the current row count,
  // or a small default before the first data render.
  const skeletonRows = rows.length > 0 ? rows.length : 5;

  return (
    <div
      data-slot="table-container"
      className={classNames(
        "sb-table-container",
        props.striped && "sb-table--striped",
        props.bordered && "sb-table--bordered",
        props.hover !== false && "sb-table--hover",
        isLoading && "sb-table--loading",
        payload.className
      )}
    >
      <table data-slot="table" className="sb-table-element">
        {props.caption && (
          <caption data-slot="table-caption" className="sb-table-caption">
            {props.caption}
          </caption>
        )}
        <thead data-slot="table-header" className="sb-table-header">
          <tr data-slot="table-row" className="sb-table-row">
            {columns.map((column, index) => (
              <th
                key={column.key || index}
                data-slot="table-head"
                className={classNames("sb-table-head", column.headerClass)}
                scope="col"
                style={headStyle(column)}
                {...styleAttrs(column.headerIntent, column.headerEmphasis)}
              >
                {column.label || column.key || ""}
              </th>
            ))}
          </tr>
        </thead>
        <tbody data-slot="table-body" className="sb-table-body" aria-busy={isLoading || undefined}>
          {isLoading
            ? Array.from({ length: skeletonRows }).map((_, rowIndex) => (
                <tr
                  key={`skeleton-${rowIndex}`}
                  data-slot="table-row"
                  className="sb-table-row"
                >
                  {columns.map((column, columnIndex) => (
                    <td
                      key={column.key || columnIndex}
                      data-slot="table-cell"
                      className="sb-table-cell"
                      style={bodyCellStyle(column, null)}
                    >
                      <span className="sb-skeleton sb-table-skeleton" aria-hidden="true" />
                    </td>
                  ))}
                </tr>
              ))
            : rows.map((row, rowIndex) => {
                const meta = rowMeta[rowIndex] || null;
                const rowCells = cellMeta[rowIndex] || [];
                return (
                  <tr
                    key={rowIndex}
                    data-slot="table-row"
                    className={classNames("sb-table-row", meta && meta.class)}
                    style={meta && meta.style ? meta.style : undefined}
                    {...(meta ? styleAttrs(meta.intent, meta.emphasis) : {})}
                  >
                    {columns.map((column, columnIndex) => {
                      const cell = rowCells[columnIndex] || null;
                      // Cell-level intent/emphasis/class win over the column default.
                      const intent = (cell && cell.intent) || column.intent;
                      const emphasis = (cell && cell.emphasis) || column.emphasis;
                      return (
                        <td
                          key={column.key || columnIndex}
                          data-slot="table-cell"
                          className={classNames(
                            "sb-table-cell",
                            column.class,
                            cell && cell.class
                          )}
                          style={bodyCellStyle(column, cell)}
                          {...styleAttrs(intent, emphasis)}
                        >
                          {Array.isArray(row) ? row[columnIndex] || "" : ""}
                        </td>
                      );
                    })}
                  </tr>
                );
              })}
        </tbody>
        {isTruncated && !isLoading && (
          <tfoot data-slot="table-footer" className="sb-table-footer">
            <tr data-slot="table-row" className="sb-table-row">
              <td
                data-slot="table-cell"
                className="sb-table-cell"
                colSpan={Math.max(columns.length, 1)}
              >
                Showing {rows.length} of {props.totalRows} rows
              </td>
            </tr>
          </tfoot>
        )}
      </table>
    </div>
  );
}
