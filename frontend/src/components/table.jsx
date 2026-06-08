import { useEffect, useRef, useState } from "react";
import { classNames } from "./shared.jsx";

function alignment(value) {
  return ["left", "center", "right"].includes(value) ? value : "left";
}

// Normalize a server-supplied `selected` payload (array of 1-based row indices)
// into a Set of positive integers, dropping anything invalid.
function toSelectedSet(value) {
  const out = new Set();
  if (!Array.isArray(value)) return out;
  value.forEach((entry) => {
    const n = Number(entry);
    if (Number.isInteger(n) && n >= 1) out.add(n);
  });
  return out;
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
  // DT-style row selection. `selected` holds 1-based row indices; the binding
  // reads `root.__sbTableValue` and re-publishes the input on `sb:table-change`.
  const [selected, setSelected] = useState(() =>
    toSelectedSet((payload.props || {}).selected)
  );

  const selectionMode = props.selection || "none";
  const selectable =
    (selectionMode === "single" || selectionMode === "multiple") &&
    props.loading !== true;

  // Single-writer (ADR 0019): the expando + dispatch are written synchronously
  // from the mount effect, the click/keyboard setter, and the receive handler —
  // never via a mirror useEffect. `cell` carries the last DT-style cell click.
  function publish(nextSet, lastClicked, cell, notify) {
    if (!root) return;
    root.__sbTableValue = {
      selected: Array.from(nextSet).sort((a, b) => a - b),
      lastClicked: lastClicked == null ? null : lastClicked,
      cell: cell || null
    };
    if (notify) root.dispatchEvent(new CustomEvent("sb:table-change"));
  }

  // Mount: install the receive handler and seed the value expando so the binding
  // resolves an initial selection. Non-selectable tables set no expando, so the
  // binding keeps reporting null (byte-identical legacy behavior).
  useEffect(() => {
    if (!root) return undefined;
    if (
      props.selection === "single" ||
      props.selection === "multiple"
    ) {
      publish(toSelectedSet(props.selected), null, null, false);
    }
    root.__sbTableReceive = (data) => {
      const next = data || {};
      if (Object.prototype.hasOwnProperty.call(next, "selected")) {
        const set = toSelectedSet(next.selected);
        setSelected(set);
        publish(set, null, null, true);
      } else if (next.selection === "none") {
        root.__sbTableValue = { selected: [], lastClicked: null, cell: null };
        root.dispatchEvent(new CustomEvent("sb:table-change"));
      }
      setProps((prev) => ({ ...prev, ...next }));
    };
    return () => {
      delete root.__sbTableReceive;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [root]);

  function activate(rowIndex, columnIndex, value) {
    if (!selectable) return;
    const row1 = rowIndex + 1;
    const nextSet = new Set(selected);
    if (selectionMode === "single") {
      const had = nextSet.has(row1);
      nextSet.clear();
      if (!had) nextSet.add(row1);
    } else if (nextSet.has(row1)) {
      nextSet.delete(row1);
    } else {
      nextSet.add(row1);
    }
    setSelected(nextSet);
    const cell =
      columnIndex == null
        ? null
        : { row: row1, col: columnIndex + 1, value: value == null ? null : value };
    publish(nextSet, row1, cell, true);
  }

  function onRowKeyDown(event, rowIndex) {
    if (event.key === "Enter" || event.key === " " || event.key === "Spacebar") {
      event.preventDefault();
      activate(rowIndex, null, null);
    }
  }

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
                const isSelected = selectable && selected.has(rowIndex + 1);
                return (
                  <tr
                    key={rowIndex}
                    data-slot="table-row"
                    className={classNames(
                      "sb-table-row",
                      selectable && "sb-table-row--selectable",
                      isSelected && "sb-table-row--selected",
                      meta && meta.class
                    )}
                    style={meta && meta.style ? meta.style : undefined}
                    aria-selected={selectable ? isSelected : undefined}
                    tabIndex={selectable ? 0 : undefined}
                    onKeyDown={selectable ? (event) => onRowKeyDown(event, rowIndex) : undefined}
                    {...(meta ? styleAttrs(meta.intent, meta.emphasis) : {})}
                  >
                    {columns.map((column, columnIndex) => {
                      const cell = rowCells[columnIndex] || null;
                      // Cell-level intent/emphasis/class win over the column default.
                      const intent = (cell && cell.intent) || column.intent;
                      const emphasis = (cell && cell.emphasis) || column.emphasis;
                      const value = Array.isArray(row) ? row[columnIndex] || "" : "";
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
                          onClick={selectable ? () => activate(rowIndex, columnIndex, value) : undefined}
                          {...styleAttrs(intent, emphasis)}
                        >
                          {value}
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
