import { useEffect, useState } from "react";
import { classNames } from "./shared.jsx";

const VARIANTS = new Set(["default", "success", "warning", "info", "destructive"]);

function num(value, fallback) {
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

function clamp(value, min, max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

// Compute the displayed/clamped percent for a determinate bar. The track is
// degenerate when `max === min`; treat that as empty (0%).
function percentOf(value, min, max) {
  if (max <= min) return 0;
  return clamp(((value - min) / (max - min)) * 100, 0, 100);
}

// The runtime owns merged-state validity: the server sends partial updates and
// cannot see current client `min`/`max`/`value`. After merging the supplied
// fields we (1) repair an inverted range by swapping endpoints so `min < max`
// holds, then (2) clamp `value` into the repaired `[min, max]`. A single-endpoint
// update that crosses the other bound therefore resolves to a valid state
// instead of a NaN/negative-width bar.
function reconcile(state) {
  let { min, max, value } = state;
  if (min > max) {
    const swapped = min;
    min = max;
    max = swapped;
  }
  value = clamp(value, min, max);
  return { ...state, min, max, value };
}

function initialState(payload) {
  const props = payload.props || {};
  const raw = payload.state || {};
  const min = num(raw.min, 0);
  const max = num(raw.max, 1);
  return reconcile({
    value: num(raw.value, min),
    min,
    max,
    indeterminate: Boolean(raw.indeterminate),
    message: props.message == null ? null : String(props.message),
    detail: props.detail == null ? null : String(props.detail),
    label: props.label == null ? null : String(props.label),
    showValue: Boolean(props.showValue),
    variant: VARIANTS.has(props.variant) ? props.variant : "default",
    className: payload.className || "",
    style: props.style || {}
  });
}

// Merge one `update_block_progress()` / `inc_block_progress()` payload into the
// current state. Presence (`key in data`) means "set"; absence means "preserve".
// Text fields sent as `null` clear to empty (rendered nodes collapse).
function applyUpdate(prev, data) {
  const next = { ...prev };

  if (data.action === "increment") {
    next.value = prev.value + num(data.amount, 0);
  } else if ("value" in data) {
    next.value = num(data.value, prev.value);
  }
  if ("min" in data) next.min = num(data.min, prev.min);
  if ("max" in data) next.max = num(data.max, prev.max);
  if ("indeterminate" in data) next.indeterminate = Boolean(data.indeterminate);
  if ("showValue" in data) next.showValue = Boolean(data.showValue);
  if ("variant" in data) {
    next.variant = VARIANTS.has(data.variant) ? data.variant : "default";
  }
  if ("message" in data) next.message = data.message == null ? null : String(data.message);
  if ("detail" in data) next.detail = data.detail == null ? null : String(data.detail);
  if ("label" in data) next.label = data.label == null ? null : String(data.label);
  if ("className" in data) next.className = data.className || "";
  if ("style" in data) next.style = data.style || {};

  return reconcile(next);
}

export function Progress({ payload, root }) {
  const [state, setState] = useState(() => initialState(payload));

  useEffect(() => {
    if (!root) return undefined;
    root.__sbProgressReceive = (data) => {
      setState((prev) => applyUpdate(prev, data || {}));
    };
    return () => {
      if (root.__sbProgressReceive) delete root.__sbProgressReceive;
    };
  }, [root]);

  const { value, min, max, indeterminate } = state;
  const percent = percentOf(value, min, max);
  const rounded = Math.round(percent);
  const valueText = state.showValue && !indeterminate ? `${rounded}%` : null;

  // D6 header model: `label` is the static header-left primary; `message` is the
  // dynamic status line. With both, label leads and message renders beneath it;
  // with only one, that text is the primary line. Header collapses when empty.
  const hasLabel = state.label != null && state.label !== "";
  const hasMessage = state.message != null && state.message !== "";
  const hasDetail = state.detail != null && state.detail !== "";
  const hasHeader = hasLabel || hasMessage || valueText != null;

  const ariaLabel = (hasLabel && state.label) || (hasMessage && state.message) || "Progress";

  const progressbarAria = indeterminate
    ? { "aria-busy": "true", "aria-label": ariaLabel }
    : {
        "aria-valuemin": min,
        "aria-valuemax": max,
        "aria-valuenow": value,
        "aria-valuetext": `${rounded}%`,
        "aria-label": ariaLabel
      };

  return (
    <div
      className={classNames("sb-progress-body", state.className)}
      data-slot="progress"
      data-variant={state.variant}
      style={state.style}
    >
      {hasHeader ? (
        <div className="sb-progress-header" data-slot="progress-header">
          <div className="sb-progress-header-text">
            {hasLabel ? (
              <span className="sb-progress-label" data-slot="progress-label">
                {state.label}
              </span>
            ) : null}
            {hasMessage ? (
              <span className="sb-progress-message" data-slot="progress-message">
                {state.message}
              </span>
            ) : null}
          </div>
          {valueText != null ? (
            <span className="sb-progress-value" data-slot="progress-value">
              {valueText}
            </span>
          ) : null}
        </div>
      ) : null}
      <div
        className="sb-progress-track"
        data-slot="progress-track"
        data-indeterminate={indeterminate ? "true" : undefined}
        role="progressbar"
        {...progressbarAria}
      >
        <div
          className="sb-progress-indicator"
          data-slot="progress-indicator"
          style={
            indeterminate
              ? undefined
              : { transform: `translateX(-${100 - percent}%)` }
          }
        />
      </div>
      {hasDetail ? (
        <div className="sb-progress-detail" data-slot="progress-detail">
          {state.detail}
        </div>
      ) : null}
    </div>
  );
}
