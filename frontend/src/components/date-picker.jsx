import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot, labelIdForInput } from "../runtime/dom.js";
import { setNativeDatePickerValue } from "../runtime/native-inputs.js";
import {
  floatingTransform,
  useFloatingPosition
} from "../runtime/overlays.js";
import { classNames } from "./shared.jsx";

// --- Pure date helpers (ISO `yyyy-mm-dd` <-> calendar math) -----------------

const pad2 = (n) => String(n).padStart(2, "0");

// Parse an ISO `yyyy-mm-dd` string into a {y, m, d} record (m is 1-indexed).
// Returns null for empty/invalid input so callers can represent "no value".
function parseIso(value) {
  if (typeof value !== "string") return null;
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value.trim());
  if (!match) return null;
  const y = Number(match[1]);
  const m = Number(match[2]);
  const d = Number(match[3]);
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  return { y, m, d };
}

function toIso(y, m, d) {
  return `${String(y).padStart(4, "0")}-${pad2(m)}-${pad2(d)}`;
}

function daysInMonth(year, month0) {
  return new Date(year, month0 + 1, 0).getDate();
}

// Shift an ISO date by `delta` days using local Date arithmetic.
function addDays(iso, delta) {
  const parts = parseIso(iso);
  if (!parts) return iso;
  const date = new Date(parts.y, parts.m - 1, parts.d + delta);
  return toIso(date.getFullYear(), date.getMonth() + 1, date.getDate());
}

function todayIso() {
  const now = new Date();
  return toIso(now.getFullYear(), now.getMonth() + 1, now.getDate());
}

// Shiny `dateInput()` display tokens. Case-sensitive; the regex lists every
// token longest-first so multi-char tokens win over their single-char prefixes
// (`yyyy` over `yy`, `dd` over `d`, `mm` over `m`). `mm`/`MM` and `dd`/`DD`
// differ only by case. Single-char `d`/`m` are unpadded; `yy` is the 2-digit
// year.
function formatLabel(iso, format) {
  const parts = parseIso(iso);
  if (!parts) return "";
  const date = new Date(parts.y, parts.m - 1, parts.d);
  const intl = (opts) => new Intl.DateTimeFormat(undefined, opts).format(date);
  const yyyy = String(parts.y).padStart(4, "0");
  const tokens = {
    yyyy,
    yy: yyyy.slice(-2),
    MM: intl({ month: "long" }),
    mm: pad2(parts.m),
    m: String(parts.m),
    DD: intl({ weekday: "long" }),
    dd: pad2(parts.d),
    d: String(parts.d),
    M: intl({ month: "short" }),
    D: intl({ weekday: "short" })
  };
  return String(format || "yyyy-mm-dd").replace(
    /yyyy|yy|MM|mm|DD|dd|M|D|m|d/g,
    (token) => tokens[token]
  );
}

// Header labels (Su, Mo, …) rotated to the configured first day of week.
function weekdayLabels(weekstart) {
  const labels = [];
  // 2024-01-07 is a Sunday; walk forward from it for stable short names.
  for (let i = 0; i < 7; i += 1) {
    const date = new Date(2024, 0, 7 + ((weekstart + i) % 7));
    labels.push(new Intl.DateTimeFormat(undefined, { weekday: "short" }).format(date));
  }
  return labels;
}

export function DatePicker({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const spriteHref = props.spriteHref || "";

  const [value, setValueState] = useState(
    typeof state.value === "string" ? state.value : ""
  );
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [format, setFormat] = useState(props.format || "yyyy-mm-dd");
  const [min, setMin] = useState(props.min || null);
  const [max, setMax] = useState(props.max || null);
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const weekstart = Number.isFinite(Number(props.weekstart)) ? Number(props.weekstart) : 0;

  const [open, setOpenState] = useState(false);
  const initialView = parseIso(value) || parseIso(todayIso());
  const [view, setView] = useState({ y: initialView.y, m: initialView.m - 1 });
  const [focused, setFocused] = useState(value || todayIso());

  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const returnFocusRef = useRef(null);
  const dayRefs = useRef({});
  const contentId = `${inputId || "date-picker"}-content`;
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

  // Single writer: expando + dataset + hidden native input are written together
  // from the mount effect, the user-action setter, and the receive handler.
  function writeValue(next) {
    if (!root) return;
    root.__sbDatePickerValue = next;
    root.dataset.sbDatePickerValue = next;
    setNativeDatePickerValue(root, next, false);
  }

  function setValue(next, notify) {
    const iso = typeof next === "string" ? next : "";
    setValueState(iso);
    if (!root) return;
    root.__sbDatePickerValue = iso;
    root.dataset.sbDatePickerValue = iso;
    setNativeDatePickerValue(root, iso, notify);
    if (notify) root.dispatchEvent(new CustomEvent("sb:date-picker-change"));
  }

  function setOpen(next) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      returnFocusRef.current = document.activeElement;
      const anchor = parseIso(value) || parseIso(todayIso());
      setView({ y: anchor.y, m: anchor.m - 1 });
      setFocused(value || todayIso());
    }
    setOpenState(nextOpen);
  }

  function selectDay(iso) {
    if (disabled || isDisabledDay(iso)) return;
    setValue(iso, true);
    setOpen(false);
    requestAnimationFrame(() => triggerRef.current?.focus({ preventScroll: true }));
  }

  function moveFocus(nextIso) {
    if (!nextIso) return;
    const parts = parseIso(nextIso);
    if (!parts) return;
    setFocused(nextIso);
    setView({ y: parts.y, m: parts.m - 1 });
  }

  function onGridKeyDown(event) {
    let next = null;
    if (event.key === "ArrowLeft") next = addDays(focused, -1);
    else if (event.key === "ArrowRight") next = addDays(focused, 1);
    else if (event.key === "ArrowUp") next = addDays(focused, -7);
    else if (event.key === "ArrowDown") next = addDays(focused, 7);
    else if (event.key === "Home") next = addDays(focused, -(((parseIso(focused).d) % 7)));
    else if (event.key === "PageUp") {
      const d = parseIso(focused);
      const date = new Date(d.y, d.m - 2, d.d);
      next = toIso(date.getFullYear(), date.getMonth() + 1, date.getDate());
    } else if (event.key === "PageDown") {
      const d = parseIso(focused);
      const date = new Date(d.y, d.m, d.d);
      next = toIso(date.getFullYear(), date.getMonth() + 1, date.getDate());
    } else if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      selectDay(focused);
      return;
    } else if (event.key === "Escape") {
      event.stopPropagation();
      setOpen(false);
      requestAnimationFrame(() => triggerRef.current?.focus({ preventScroll: true }));
      return;
    } else {
      return;
    }
    event.preventDefault();
    moveFocus(next);
  }

  // Single-writer: install the expando synchronously on mount and whenever the
  // committed value changes, so `getValue` reads a fresh value pre-bind.
  useEffect(() => {
    writeValue(value);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [value, root]);

  useEffect(() => {
    if (!root) return undefined;
    root.toggleAttribute("data-disabled", disabled);
    const native = root.querySelector("input.sb-date-picker-native");
    if (native) native.disabled = disabled;
  }, [disabled, root]);

  useEffect(() => {
    if (!root) return undefined;

    root.__sbDatePickerReceive = (data) => {
      const nextData = data || {};
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
      if (Object.prototype.hasOwnProperty.call(nextData, "value")) {
        setValue(nextData.value == null ? "" : String(nextData.value), Boolean(nextData.notify));
      }
    };

    return () => {
      delete root.__sbDatePickerReceive;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [root]);

  useEffect(() => {
    if (!open) return undefined;

    const focusFrame = requestAnimationFrame(() => {
      const node = dayRefs.current[focused];
      if (node && typeof node.focus === "function") {
        node.focus({ preventScroll: true });
      } else if (contentRef.current) {
        contentRef.current.focus({ preventScroll: true });
      }
    });

    function onPointerDown(event) {
      const target = event.target;
      if (triggerRef.current?.contains(target)) return;
      if (contentRef.current?.contains(target)) return;
      setOpen(false);
    }

    document.addEventListener("pointerdown", onPointerDown);

    return () => {
      cancelAnimationFrame(focusFrame);
      document.removeEventListener("pointerdown", onPointerDown);
      const target = returnFocusRef.current;
      returnFocusRef.current = null;
      if (target && typeof target.focus === "function") {
        requestAnimationFrame(() => target.focus({ preventScroll: true }));
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, focused]);

  // Move keyboard focus to the active day as the user arrows around.
  useEffect(() => {
    if (!open) return;
    const node = dayRefs.current[focused];
    if (node && typeof node.focus === "function") {
      node.focus({ preventScroll: true });
    }
  }, [focused, open]);

  const headers = weekdayLabels(weekstart);
  const monthLabel = new Intl.DateTimeFormat(undefined, {
    month: "long",
    year: "numeric"
  }).format(new Date(view.y, view.m, 1));

  const firstWeekday = new Date(view.y, view.m, 1).getDay();
  const offset = (firstWeekday - weekstart + 7) % 7;
  const total = daysInMonth(view.y, view.m);
  const cells = [];
  for (let i = 0; i < offset; i += 1) cells.push(null);
  for (let day = 1; day <= total; day += 1) cells.push(day);

  const triggerLabel = value ? formatLabel(value, format) : (placeholder || "Pick a date");
  const portal = ensurePortalRoot();

  function shiftMonth(delta) {
    const date = new Date(view.y, view.m + delta, 1);
    setView({ y: date.getFullYear(), m: date.getMonth() });
  }

  return (
    <div
      className={classNames("sb-date-picker-shell", className)}
      data-slot="date-picker"
      data-disabled={disabled ? "true" : undefined}
      data-invalid={isInvalid ? "true" : undefined}
    >
      <button
        ref={triggerRef}
        type="button"
        className="sb-date-picker-trigger"
        data-slot="date-picker-trigger"
        data-state={open ? "open" : "closed"}
        data-placeholder={!value ? "true" : undefined}
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
        <svg className="sb-date-picker-icon" aria-hidden="true" focusable="false">
          <use href={`${spriteHref}#sb-icon-calendar`} />
        </svg>
        <span className="sb-date-picker-value">{triggerLabel}</span>
      </button>
      {open && position &&
        createPortal(
          <div
            id={contentId}
            ref={contentRef}
            className="sb-date-picker-content"
            data-slot="date-picker-content"
            role="dialog"
            aria-label="Choose date"
            tabIndex={-1}
            style={{
              position: "fixed",
              top: `${position.top}px`,
              left: `${position.left}px`,
              transform: floatingTransform("bottom", "start")
            }}
          >
            <div className="sb-date-picker-calendar" data-slot="date-picker-calendar">
              <div className="sb-date-picker-nav">
                <button
                  type="button"
                  className="sb-date-picker-nav-btn"
                  aria-label="Previous month"
                  onClick={() => shiftMonth(-1)}
                >
                  <svg aria-hidden="true" focusable="false">
                    <use href={`${spriteHref}#sb-icon-chevron-left`} />
                  </svg>
                </button>
                <span className="sb-date-picker-month" aria-live="polite">{monthLabel}</span>
                <button
                  type="button"
                  className="sb-date-picker-nav-btn"
                  aria-label="Next month"
                  onClick={() => shiftMonth(1)}
                >
                  <svg aria-hidden="true" focusable="false">
                    <use href={`${spriteHref}#sb-icon-chevron-right`} />
                  </svg>
                </button>
              </div>
              <div
                className="sb-date-picker-grid"
                role="grid"
                onKeyDown={onGridKeyDown}
              >
                <div className="sb-date-picker-weekdays" role="row">
                  {headers.map((label, index) => (
                    <span key={index} className="sb-date-picker-weekday" role="columnheader">
                      {label}
                    </span>
                  ))}
                </div>
                <div className="sb-date-picker-days">
                  {cells.map((day, index) => {
                    if (day == null) {
                      return <span key={`pad-${index}`} className="sb-date-picker-pad" />;
                    }
                    const iso = toIso(view.y, view.m + 1, day);
                    const selected = iso === value;
                    const isToday = iso === todayIso();
                    const dayDisabled = isDisabledDay(iso);
                    const isFocusable = iso === focused;
                    return (
                      <button
                        key={iso}
                        ref={(node) => {
                          if (node) dayRefs.current[iso] = node;
                          else delete dayRefs.current[iso];
                        }}
                        type="button"
                        className="sb-date-picker-day"
                        data-slot="date-picker-day"
                        data-selected={selected ? "true" : undefined}
                        data-today={isToday ? "true" : undefined}
                        role="gridcell"
                        aria-selected={selected ? "true" : "false"}
                        aria-current={isToday ? "date" : undefined}
                        tabIndex={isFocusable ? 0 : -1}
                        disabled={dayDisabled}
                        onClick={() => selectDay(iso)}
                        onFocus={() => setFocused(iso)}
                      >
                        {day}
                      </button>
                    );
                  })}
                </div>
              </div>
            </div>
          </div>,
          portal
        )}
    </div>
  );
}
