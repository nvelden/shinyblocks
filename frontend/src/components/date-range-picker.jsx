import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot, labelIdForInput } from "../runtime/dom.js";
import { setNativeDateRangePickerValue } from "../runtime/native-inputs.js";
import {
  floatingTransform,
  useFloatingPosition
} from "../runtime/overlays.js";
import { Calendar, formatLabel, parseIso, todayIso } from "./calendar.jsx";
import { useDatePickerPopover } from "./date-picker-popover.js";
import { classNames } from "./shared.jsx";

// Range date picker. Reports `[startIso, endIso]` typed `shiny.date`, so the
// server deserializes `input$<id>` to a length-2 `Date` `c(start, end)`
// (matching `dateRangeInput()`). An empty or incomplete range reports `null`.
// Committed `start`/`end` are the reported value and only change on commit /
// server update / clear; the in-progress two-click selection lives in
// `draftAnchor` + `hover` so a half-open selection never leaks to the server.
export function DateRangePicker({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const spriteHref = props.spriteHref || "";

  const [start, setStart] = useState(
    typeof state.start === "string" ? state.start : ""
  );
  const [end, setEnd] = useState(
    typeof state.end === "string" ? state.end : ""
  );
  const [separator, setSeparator] = useState(
    typeof props.separator === "string" ? props.separator : " – "
  );
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const format = props.format || "yyyy-mm-dd";
  const [min, setMin] = useState(props.min || null);
  const [max, setMax] = useState(props.max || null);
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const weekstart = Number.isFinite(Number(props.weekstart)) ? Number(props.weekstart) : 0;

  // In-progress selection: `draftAnchor` is the first click, `hover` previews
  // the second endpoint (mouse hover or keyboard focus). Null when not selecting.
  const [draftAnchor, setDraftAnchor] = useState(null);
  const [hover, setHover] = useState(null);
  const selecting = draftAnchor != null;

  const initialView = parseIso(start) || parseIso(todayIso());
  const [view, setView] = useState({ y: initialView.y, m: initialView.m - 1 });
  const [focused, setFocused] = useState(start || todayIso());

  const { open, setOpen, setOpenState, triggerRef, contentRef, dayRefs } =
    useDatePickerPopover({
      root,
      disabled,
      nativeSelector: "input.sb-date-range-picker-native",
      focused,
      onOpen: () => {
        const anchor = parseIso(start) || parseIso(todayIso());
        setView({ y: anchor.y, m: anchor.m - 1 });
        setFocused(start || todayIso());
        setDraftAnchor(null);
        setHover(null);
      }
    });
  // Latest committed range, readable from the once-installed receive handler
  // without a stale closure (server updates may change one endpoint at a time).
  const committedRef = useRef({ start, end });
  const contentId = `${inputId || "date-range-picker"}-content`;
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;
  const position = useFloatingPosition({ open, triggerRef, side: "bottom", align: "start" });

  function isDisabledDay(iso) {
    if (min && iso < min) return true;
    if (max && iso > max) return true;
    return false;
  }

  // Single writer for the reported value: committed start/end + expando +
  // dataset + hidden native input. Only a committed (or cleared) range reaches
  // here, so the binding's `getValue` never sees a half-open selection.
  function commitRange(nextStart, nextEnd, notify) {
    setStart(nextStart);
    setEnd(nextEnd);
    if (!root) return;
    root.__sbDateRangePickerValue = { start: nextStart, end: nextEnd };
    root.dataset.sbDateRangePickerStart = nextStart;
    root.dataset.sbDateRangePickerEnd = nextEnd;
    setNativeDateRangePickerValue(root, nextStart, nextEnd, notify);
    if (notify) root.dispatchEvent(new CustomEvent("sb:date-range-picker-change"));
  }

  // Two-click range state machine. First click anchors the range (committed
  // value unchanged); second click commits the ordered pair and closes.
  function selectDay(iso) {
    if (disabled || isDisabledDay(iso)) return;
    if (!selecting) {
      setDraftAnchor(iso);
      setHover(iso);
      return;
    }
    let lo = draftAnchor;
    let hi = iso;
    if (hi < lo) {
      const swap = lo;
      lo = hi;
      hi = swap;
    }
    setDraftAnchor(null);
    setHover(null);
    commitRange(lo, hi, true);
    setOpen(false);
    requestAnimationFrame(() => triggerRef.current?.focus({ preventScroll: true }));
  }

  // Escape while the grid is focused: drop any in-progress selection (the
  // committed range is untouched) and close.
  function cancelFromGrid(event) {
    event.stopPropagation();
    setDraftAnchor(null);
    setHover(null);
    setOpen(false);
    requestAnimationFrame(() => triggerRef.current?.focus({ preventScroll: true }));
  }

  // Keyboard navigation moves focus; mirror it into the hover preview so the
  // in-range band tracks arrow keys, not just the mouse.
  useEffect(() => {
    if (selecting) setHover(focused);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [focused, selecting]);

  // Single-writer: keep the expando/dataset/native fresh for pre-bind reads and
  // whenever the committed range changes.
  useEffect(() => {
    committedRef.current = { start, end };
    if (!root) return;
    root.__sbDateRangePickerValue = { start, end };
    root.dataset.sbDateRangePickerStart = start;
    root.dataset.sbDateRangePickerEnd = end;
    setNativeDateRangePickerValue(root, start, end, false);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [start, end, root]);

  useEffect(() => {
    if (!root) return undefined;

    root.__sbDateRangePickerReceive = (data) => {
      const nextData = data || {};
      if (Object.prototype.hasOwnProperty.call(nextData, "separator")) {
        setSeparator(nextData.separator == null ? "" : String(nextData.separator));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        setPlaceholder(nextData.placeholder || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "min")) {
        setMin(nextData.min || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "max")) {
        setMax(nextData.max || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        if (nextDisabled) setOpenState(false);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "invalid")) {
        setInvalid(Boolean(nextData.invalid));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
      // Server updates are trusted as-is: a range pushed from R is committed
      // without re-checking the runtime's own min/max (R already validates
      // bounds for the fields present in the call). This intentionally matches
      // `updateDateRangeInput()` laxity — the server is the source of truth.
      const hasStart = Object.prototype.hasOwnProperty.call(nextData, "start");
      const hasEnd = Object.prototype.hasOwnProperty.call(nextData, "end");
      if (hasStart || hasEnd) {
        const committed = committedRef.current;
        let lo = hasStart ? (nextData.start == null ? "" : String(nextData.start)) : committed.start;
        let hi = hasEnd ? (nextData.end == null ? "" : String(nextData.end)) : committed.end;
        if (lo && hi && hi < lo) {
          const swap = lo;
          lo = hi;
          hi = swap;
        }
        setDraftAnchor(null);
        setHover(null);
        commitRange(lo, hi, Boolean(nextData.notify));
      }
    };

    return () => {
      delete root.__sbDateRangePickerReceive;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [root]);

  // The visible range band: the in-progress draft while selecting, else the
  // committed range. `lo`/`hi` are the ordered endpoints.
  let lo = null;
  let hi = null;
  if (selecting && draftAnchor) {
    const other = hover || draftAnchor;
    lo = draftAnchor <= other ? draftAnchor : other;
    hi = draftAnchor <= other ? other : draftAnchor;
  } else if (start && end) {
    lo = start;
    hi = end;
  }

  function dayProps(iso) {
    const isStart = lo != null && iso === lo;
    const isEnd = hi != null && iso === hi;
    const inRange = lo != null && hi != null && iso > lo && iso < hi;
    const selected = isStart || isEnd;
    const isToday = iso === todayIso();
    // While selecting the second endpoint the band is a hover *preview*; mark
    // it so the styling can render it at reduced emphasis vs a committed range.
    const isPreview = selecting && (inRange || (selected && iso !== draftAnchor));
    return {
      "data-range-start": isStart ? "true" : undefined,
      "data-range-end": isEnd ? "true" : undefined,
      "data-in-range": inRange ? "true" : undefined,
      "data-preview": isPreview ? "true" : undefined,
      "data-selected": selected ? "true" : undefined,
      "data-today": isToday ? "true" : undefined,
      "aria-selected": selected ? "true" : "false",
      "aria-current": isToday ? "date" : undefined,
      onMouseEnter: selecting ? () => setHover(iso) : undefined
    };
  }

  const hasRange = Boolean(start && end);
  const triggerLabel = hasRange
    ? `${formatLabel(start, format)}${separator}${formatLabel(end, format)}`
    : (placeholder || "Pick a date range");
  const portal = ensurePortalRoot(root);

  return (
    <div
      className={classNames("sb-date-range-picker-shell", className)}
      data-slot="date-range-picker"
      data-disabled={disabled ? "true" : undefined}
      data-invalid={isInvalid ? "true" : undefined}
    >
      <button
        ref={triggerRef}
        type="button"
        className="sb-date-range-picker-trigger"
        data-slot="date-range-picker-trigger"
        data-state={open ? "open" : "closed"}
        data-placeholder={!hasRange ? "true" : undefined}
        data-invalid={isInvalid ? "true" : undefined}
        aria-haspopup="dialog"
        aria-expanded={open ? "true" : "false"}
        aria-controls={open ? contentId : undefined}
        aria-invalid={isInvalid || undefined}
        aria-labelledby={labelledBy || undefined}
        aria-describedby={describedBy}
        disabled={disabled}
        style={style}
        onClick={() => setOpen(!open)}
      >
        <svg className="sb-date-range-picker-icon" aria-hidden="true" focusable="false">
          <use href={`${spriteHref}#sb-icon-calendar`} />
        </svg>
        <span className="sb-date-range-picker-value">{triggerLabel}</span>
      </button>
      {open && position &&
        createPortal(
          <div
            id={contentId}
            ref={contentRef}
            className="sb-date-range-picker-content"
            data-slot="date-range-picker-content"
            role="dialog"
            aria-label="Choose date range"
            tabIndex={-1}
            style={{
              position: "fixed",
              top: `${position.top}px`,
              left: `${position.left}px`,
              transform: floatingTransform("bottom", "start")
            }}
          >
            <Calendar
              classPrefix="sb-date-range-picker"
              slotPrefix="date-range-picker"
              view={view}
              setView={setView}
              weekstart={weekstart}
              spriteHref={spriteHref}
              focused={focused}
              setFocused={setFocused}
              dayRefs={dayRefs}
              isDisabledDay={isDisabledDay}
              onSelect={selectDay}
              onCancel={cancelFromGrid}
              getDayProps={dayProps}
            />
          </div>,
          portal
        )}
    </div>
  );
}
