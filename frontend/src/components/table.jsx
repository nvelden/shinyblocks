import { classNames } from "./shared.jsx";

function alignment(value) {
  return ["left", "center", "right"].includes(value) ? value : "left";
}

function headStyle(column) {
  return {
    textAlign: alignment(column && column.align),
    ...(column && column.width ? { width: column.width } : {})
  };
}

function cellStyle(column) {
  return { textAlign: alignment(column && column.align) };
}

export function Table({ payload }) {
  const props = payload.props || {};
  const columns = Array.isArray(props.columns) ? props.columns : [];
  const rows = Array.isArray(props.rows) ? props.rows : [];
  const isTruncated = props.truncated === true;

  return (
    <div
      data-slot="table-container"
      className={classNames("sb-table-container", payload.className)}
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
                className="sb-table-head"
                scope="col"
                style={headStyle(column)}
              >
                {column.label || column.key || ""}
              </th>
            ))}
          </tr>
        </thead>
        <tbody data-slot="table-body" className="sb-table-body">
          {rows.map((row, rowIndex) => (
            <tr
              key={rowIndex}
              data-slot="table-row"
              className="sb-table-row"
            >
              {columns.map((column, columnIndex) => (
                <td
                  key={column.key || columnIndex}
                  data-slot="table-cell"
                  className="sb-table-cell"
                  style={cellStyle(column)}
                >
                  {Array.isArray(row) ? row[columnIndex] || "" : ""}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
        {isTruncated && (
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
